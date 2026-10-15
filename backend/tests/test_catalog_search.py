from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.db import Base
from app.models import RawListing
from app.schemas import AnalyzeRequest
from app.services.analysis import analyze, search_comparisons


def test_pc_analysis_includes_retail_catalog_without_marketplace_data():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    request = AnalyzeRequest(
        mode="pc",
        query="RTX 4060",
        component_type="gpu",
        price=5_000_000,
        condition="any",
    )

    try:
        with Session(engine) as session:
            _, comparisons, _, _ = analyze(session, request)
    finally:
        engine.dispose()

    retail = [item for item in comparisons if item.source == "komponen_retail"]
    assert retail
    assert all(item.condition == "new" for item in retail)
    assert all(item.listing_url is None for item in retail)
    assert all("4060 ti" not in item.title.lower() for item in retail)


def test_pc_analysis_keeps_marketplace_results_with_retail_catalog():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    request = AnalyzeRequest(
        mode="pc",
        query="RTX 4060",
        component_type="gpu",
        price=5_000_000,
        condition="any",
    )

    try:
        with Session(engine) as session:
            session.add(
                RawListing(
                    source="tokopedia",
                    category="pc",
                    raw_title="MSI GeForce RTX 4060 Ventus 2X 8GB",
                    raw_price=4_900_000,
                    listing_hash="catalog-search-marketplace",
                    condition="new",
                )
            )
            session.commit()
            _, comparisons, _, _ = analyze(session, request)
    finally:
        engine.dispose()

    sources = {item.source for item in comparisons}
    assert "tokopedia" in sources
    assert "komponen_retail" in sources


def test_search_comparisons_returns_catalog_results_without_price_analysis():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    request = AnalyzeRequest(
        mode="pc",
        query="RTX 4060",
        component_type="gpu",
        condition="any",
    )

    try:
        with Session(engine) as session:
            results = search_comparisons(session, request)
    finally:
        engine.dispose()

    assert results
    assert all(item.source == "komponen_retail" for item in results)
