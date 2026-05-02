import os
import uuid
from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.whisper_service import whisper_service
from app.models.schemas import TranscribeResponse
from app.core.config import UPLOAD_PATH

router = APIRouter()

ALLOWED_EXTENSIONS = {".mp3", ".wav", ".m4a", ".ogg", ".flac"}

@router.post("/transcribe", response_model=TranscribeResponse)
async def transcribe_audio(file: UploadFile = File(...)):
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Format file tidak didukung. Gunakan: {ALLOWED_EXTENSIONS}"
        )

    filename = f"{uuid.uuid4()}{ext}"
    file_path = UPLOAD_PATH / filename

    try:
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)

        result = await whisper_service.transcribe(str(file_path))
        return TranscribeResponse(**result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        if file_path.exists():
            os.remove(file_path)