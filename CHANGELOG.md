# Changelog — WorthBang Android

Semua perubahan penting pada proyek ini dicatat di file ini.

## 2026-09-29 — Backend tickets B1–B10 selesai

Endpoint `/api/v1/*` dibangun di repo `WorthGaBang` (folder `backend/app/routers/mobile.py`);
spesifikasi lengkap ada di `API_CONTRACT.md`. App ticket T0 & T1 juga mulai dikerjakan.

| Ticket | Judul | Status |
|--------|-------|--------|
| T0 | Flutter scaffold: project, flavors, theme light/dark, l10n id, icon, go_router + bottom nav 4 tab | ✅ Selesai |
| T1 | Core infra: Dio auth interceptor, secure storage, Drift schema, WorkManager init | ✅ Selesai |
| B1 | Auth: register/login/refresh/logout (bcrypt + JWT 15 mnt / 7 hari) | ✅ Selesai |
| B2 | History & wishlist: GET/POST/DELETE `/api/v1/history`, `/api/v1/wishlist` | ✅ Selesai |
| B3 | Alerts: POST/GET/DELETE `/api/v1/alerts` | ✅ Selesai |
| B4 | Stores LBS: GET `/api/v1/stores/nearby` + seed CSV toko kota demo | ✅ Selesai |
| B5 | Tren harga: GET `/api/v1/trend?query=&days=30` (deskriptif, tanpa prediksi) | ✅ Selesai |
| B6 | Random builder: POST `/api/v1/builder/random {budget, use_case}` | ✅ Selesai |
| B7 | Chatbot: POST `/api/v1/chat/ask` (Gemini server-side, grounding DB harga) | ✅ Selesai |
| B8 | Mini-game Tebak Harga: GET `/api/v1/game/question` + POST `/api/v1/game/submit` | ✅ Selesai |
| B9 | Currency rates (cache 1 jam), feedback, PUT `/api/v1/users/me` (multipart) | ✅ Selesai |
| B10 | History push: POST `/api/v1/history` — backup/sync entri hash-chain dari app | ✅ Selesai |
