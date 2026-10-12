"""Tests for the WorthBang mobile API (B1..B9) — additive, existing endpoints untouched."""
import io
import os
import tempfile
from datetime import datetime, timedelta, timezone

os.environ["DATABASE_URL"] = f"sqlite:///{tempfile.mkdtemp()}/test_mobile.db"
os.environ["JWT_SECRET_KEY"] = "test-secret-key-that-is-long-enough-for-hs256"

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select

from app.db import SessionLocal
from app.main import app
from app.models import AnalysisLog, PCComponent, RawListing, Store, utcnow

@pytest.fixture(scope="module")
def client():
    with TestClient(app) as c:
        yield c

def _register(client, email="dan@x.com", password="min8karakter", name="Dan"):
    return client.post(
        "/api/v1/auth/register",
        json={"name": name, "email": email, "password": password},
    )

def _auth_headers(client, email="dan@x.com", password="min8karakter"):
    r = client.post("/api/v1/auth/login", json={"email": email, "password": password})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}, r.json()["refresh_token"]

# ---------------- B1: auth ----------------

def test_register_login_flow(client):
    r = _register(client)
    assert r.status_code == 201, r.text
    body = r.json()
    assert body["token_type"] == "bearer"
    assert body["user"]["email"] == "dan@x.com"
    assert "password" not in body["user"]

    r = client.post("/api/v1/auth/login", json={"email": "dan@x.com", "password": "min8karakter"})
    assert r.status_code == 200
    assert r.json()["user"]["name"] == "Dan"

def test_register_duplicate_409(client):
    _register(client, email="dup@x.com")
    r = _register(client, email="dup@x.com")
    assert r.status_code == 409
    assert r.json()["detail"] == "Email already registered"

def test_register_short_password_422(client):
    r = _register(client, email="short@x.com", password="123")
    assert r.status_code == 422

def test_login_wrong_password_generic_401(client):
    _register(client, email="wrongpw@x.com")
    r = client.post("/api/v1/auth/login", json={"email": "wrongpw@x.com", "password": "salahpass"})
    assert r.status_code == 401
    assert r.json()["detail"] == "Invalid email or password"
    # unknown email -> same generic message (no user enumeration)
    r = client.post("/api/v1/auth/login", json={"email": "nope@x.com", "password": "salahpass"})
    assert r.status_code == 401
    assert r.json()["detail"] == "Invalid email or password"

def test_refresh_rotation(client):
    _register(client, email="rot@x.com")
    r = client.post("/api/v1/auth/login", json={"email": "rot@x.com", "password": "min8karakter"})
    refresh1 = r.json()["refresh_token"]
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh1})
    assert r.status_code == 200
    refresh2 = r.json()["refresh_token"]
    assert refresh2 != refresh1
    # old refresh token is revoked after rotation
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh1})
    assert r.status_code == 401

def test_refresh_invalid_401(client):
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": "bogus.token.here"})
    assert r.status_code == 401

def test_logout_revokes(client):
    _register(client, email="logout@x.com")
    headers, refresh = _auth_headers(client, email="logout@x.com")
    r = client.post("/api/v1/auth/logout", headers=headers)
    assert r.status_code == 204
    r = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert r.status_code == 401

def test_protected_requires_auth(client):
    assert client.get("/api/v1/history").status_code == 401
    assert client.post("/api/v1/history", json={}).status_code == 401
    # /api/v1/chat/ask sengaja terbuka (tanpa auth) — sesuai desain awal;
    # temuan audit "spend Gemini tanpa auth" masih berlaku, belum diperbaiki.
    r = client.get("/api/v1/history", headers={"Authorization": "Bearer invalid"})
    assert r.status_code == 401

# ---------------- B2: history & wishlist ----------------

def test_history_attributed_from_analyze(client):
    _register(client, email="hist@x.com")
    headers, _ = _auth_headers(client, email="hist@x.com")
    r = client.post(
        "/api/v1/analyze",
        json={"mode": "pc", "query": "RTX 4060", "price": 4500000, "condition": "any"},
        headers=headers,
    )
    assert r.status_code == 200, r.text
    r = client.get("/api/v1/history", headers=headers)
    assert r.status_code == 200
    items = r.json()["items"]
    assert len(items) >= 1
    assert items[0]["query"] == "RTX 4060"
    assert items[0]["input_price"] == 4500000
    # other user's history is isolated
    _register(client, email="hist2@x.com")
    headers2, _ = _auth_headers(client, email="hist2@x.com")
    assert client.get("/api/v1/history", headers=headers2).json()["items"] == []

# ---------------- B10: push history (hash-chain backup / offline sync) ----------------

def test_history_push_and_list(client):
    _register(client, email="hpush@x.com")
    headers, _ = _auth_headers(client, email="hpush@x.com")
    r = client.post(
        "/api/v1/history",
        json={"mode": "laptop", "query": "MacBook Air M1", "input_price": 11500000,
              "score": 88.5, "verdict": "worth it"},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    item = r.json()
    assert item["query"] == "MacBook Air M1"
    assert item["input_price"] == 11500000
    assert item["score"] == 88.5
    assert item["verdict"] == "worth it"
    # appears in GET /history, newest first
    items = client.get("/api/v1/history", headers=headers).json()["items"]
    assert any(i["id"] == item["id"] for i in items)

def test_history_push_isolated_per_user(client):
    _register(client, email="hpush2@x.com")
    headers, _ = _auth_headers(client, email="hpush2@x.com")
    r = client.post(
        "/api/v1/history",
        json={"mode": "pc", "query": "RTX 4060", "input_price": 4500000,
              "score": 82.0, "verdict": "wajar"},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    _register(client, email="hpush3@x.com")
    headers3, _ = _auth_headers(client, email="hpush3@x.com")
    assert client.get("/api/v1/history", headers=headers3).json()["items"] == []

def test_history_push_requires_auth(client):
    r = client.post(
        "/api/v1/history",
        json={"mode": "pc", "query": "RTX 4060", "input_price": 4500000,
              "score": 82.0, "verdict": "wajar"},
    )
    assert r.status_code == 401

def test_history_push_validation(client):
    _register(client, email="hpush4@x.com")
    headers, _ = _auth_headers(client, email="hpush4@x.com")
    # bad mode
    r = client.post("/api/v1/history",
                    json={"mode": "tablet", "query": "iPad", "input_price": 5000000,
                          "score": 80.0, "verdict": "wajar"}, headers=headers)
    assert r.status_code == 422
    # score out of range
    r = client.post("/api/v1/history",
                    json={"mode": "pc", "query": "RTX 4060", "input_price": 4500000,
                          "score": 150.0, "verdict": "wajar"}, headers=headers)
    assert r.status_code == 422

def test_history_push_created_at_naive_assumed_utc(client):
    """Regression: naive created_at (no offset) must not 500 — assumed UTC."""
    _register(client, email="hpush5@x.com")
    headers, _ = _auth_headers(client, email="hpush5@x.com")
    r = client.post(
        "/api/v1/history",
        json={"mode": "pc", "query": "RTX 4060", "input_price": 4500000,
              "score": 82.0, "verdict": "wajar",
              "created_at": "2026-09-29T10:00:00"},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    item = r.json()
    # stored as UTC instant: naive 10:00 -> 10:00 UTC (SQLite returns naive on read)
    stored = datetime.fromisoformat(item["created_at"])
    if stored.tzinfo is None:
        stored = stored.replace(tzinfo=timezone.utc)
    assert stored == datetime(2026, 9, 29, 10, 0, tzinfo=timezone.utc), item["created_at"]

def test_history_push_created_at_with_offset(client):
    """Aware created_at with +07:00 offset is preserved as-is."""
    _register(client, email="hpush6@x.com")
    headers, _ = _auth_headers(client, email="hpush6@x.com")
    r = client.post(
        "/api/v1/history",
        json={"mode": "laptop", "query": "ThinkPad", "input_price": 9000000,
              "score": 75.0, "verdict": "wajar",
              "created_at": "2026-09-29T17:00:00+07:00"},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    item = r.json()
    # 17:00+07:00 == 10:00 UTC instant (SQLite returns naive on read)
    stored = datetime.fromisoformat(item["created_at"])
    if stored.tzinfo is None:
        stored = stored.replace(tzinfo=timezone.utc)
    assert stored == datetime(2026, 9, 29, 10, 0, tzinfo=timezone.utc), item["created_at"]

def test_history_push_created_at_future_clamped(client):
    """Future client clock is clamped to server now."""
    _register(client, email="hpush7@x.com")
    headers, _ = _auth_headers(client, email="hpush7@x.com")
    before = utcnow()
    r = client.post(
        "/api/v1/history",
        json={"mode": "pc", "query": "RTX 4060", "input_price": 4500000,
              "score": 82.0, "verdict": "wajar",
              "created_at": "2999-01-01T00:00:00"},
        headers=headers,
    )
    assert r.status_code == 201, r.text
    after = utcnow()
    stored = r.json()["created_at"]
    assert stored is not None
    # clamped into [before, after] — never the year 2999
    assert "2999" not in stored, stored
    assert before.isoformat() <= stored <= after.isoformat(), stored

def _seed_store():
    with SessionLocal() as db:
        if db.scalar(select(Store).where(Store.name == "Toko Test")):
            return
        db.add(Store(
            name="Toko Test", address="Jl. Test 1", city="Jakarta",
            lat=-6.2000, lng=106.8000,
            prices_json='{"RTX 4060": 4700000}',
        ))
        db.commit()

def _seed_listings():
    with SessionLocal() as db:
        exists = db.scalar(select(RawListing).where(RawListing.raw_title.like("%TRENDTEST%")))
        if exists:
            return
        now = utcnow()
        for day in range(10):
            for i in range(3):
                db.add(RawListing(
                    source="tokopedia", category="pc",
                    raw_title=f"TRENDTEST GPU Card Batch {day}",
                    raw_price=4_000_000 + day * 50_000,
                    listing_hash=f"trendtest-{day}-{i}",
                    scraped_at=now - timedelta(days=9 - day),
                ))
        db.commit()

def test_chat_no_key_503(client):
    r = client.post("/api/v1/chat/ask", json={"message": "rakit PC 8 juta"})
    assert r.status_code == 503

# ---------------- B7: chat scope guard ----------------

def test_chat_offtopic_refused_without_gemini_call(client):
    # Pre-filter jalan sebelum cek API key: off-topic selalu 200 + penolakan.
    r = client.post("/api/v1/chat/ask", json={"message": "bagi resep rendang dong"})
    assert r.status_code == 200
    body = r.json()
    assert body["build"] is None
    assert "di luar keahlianku" in body["reply"]

@pytest.mark.parametrize("msg,expected", [
    ("rakit PC 8 juta", True),
    ("rtx 4060 harganya berapa?", True),
    ("halo bang", True),
    ("5 juta cukup untuk laptop kuliah?", True),
    ("p", True),
    ("bagi resep rendang", False),
    ("siapa presiden indonesia?", False),
    ("cara memprogram robot", False),  # jebakan: mengandung "ram"/"pro"
    ("tolong kerjakan PR matematikaku", False),
])
def test_is_in_scope(msg, expected):
    from app.routers.mobile import _is_in_scope
    assert _is_in_scope(msg) is expected

def test_existing_endpoints_still_work(client):
    assert client.get("/health").status_code == 200
    r = client.get("/api/v1/suggest/pc", params={"q": "RTX"})
    assert r.status_code == 200
    assert r.json()["section"] == "pc"
