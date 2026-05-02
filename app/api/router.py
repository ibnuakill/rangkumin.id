from fastapi import APIRouter
from app.api.endpoints import transcribe, summarize, notes

router = APIRouter()

router.include_router(transcribe.router, prefix="/api/v1", tags=["Transcribe"])
router.include_router(summarize.router, prefix="/api/v1", tags=["Summarize"])
router.include_router(notes.router, prefix="/api/v1", tags=["Notes"])