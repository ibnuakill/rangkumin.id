from fastapi import APIRouter
from app.api.endpoints import transcribe, summarize

router = APIRouter()

router.include_router(
    transcribe.router,
    prefix="/api/v1",
    tags=["Transcribe"]
)

router.include_router(
    summarize.router,
    prefix="/api/v1",
    tags=["Summarize"]
)