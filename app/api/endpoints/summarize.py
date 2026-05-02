from fastapi import APIRouter, HTTPException
from app.services.summarizer_service import summarizer_service
from app.models.schemas import SummarizeRequest, SummarizeResponse

router = APIRouter()

@router.post("/summarize", response_model=SummarizeResponse)
async def summarize_text(request: SummarizeRequest):
    if not request.transcript.strip():
        raise HTTPException(status_code=400, detail="Teks tidak boleh kosong")

    try:
        result = await summarizer_service.summarize(request.transcript)
        return SummarizeResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))