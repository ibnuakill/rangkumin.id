from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NoteBase(BaseModel):
    title: str
    transcript: Optional[str] = None
    summary: Optional[str] = None
    audio_filename: Optional[str] = None
    duration: Optional[int] = None

class NoteCreate(NoteBase):
    pass

class NoteUpdate(BaseModel):
    title: Optional[str] = None
    transcript: Optional[str] = None
    summary: Optional[str] = None

class NoteResponse(NoteBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class TranscribeResponse(BaseModel):
    transcript: str
    duration: Optional[float] = None
    language: Optional[str] = None

class SummarizeRequest(BaseModel):
    transcript: str

class SummarizeResponse(BaseModel):
    summary: str