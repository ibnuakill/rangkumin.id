import whisper
import torch
import json
from pathlib import Path
from app.core.config import settings, BASE_DIR

class WhisperService:
    def __init__(self):
        self.model = None
        self.custom_dict = self._load_custom_dict()

    def _load_model(self):
        if self.model is None:
            print(f"Loading Whisper model: {settings.WHISPER_MODEL}")
            self.model = whisper.load_model(settings.WHISPER_MODEL)
            print("Whisper model loaded!")
        return self.model

    def _load_custom_dict(self):
        dict_path = BASE_DIR / settings.CUSTOM_DICT_PATH
        if dict_path.exists():
            with open(dict_path, "r", encoding="utf-8") as f:
                return json.load(f)
        return {}

    def _apply_custom_dict(self, text: str) -> str:
        for wrong, correct in self.custom_dict.items():
            text = text.replace(wrong, correct)
        return text

    async def transcribe(self, audio_path: str) -> dict:
        model = self._load_model()
        result = model.transcribe(
            audio_path,
            language="id",
            task="transcribe"
        )
        transcript = self._apply_custom_dict(result["text"])
        return {
            "transcript": transcript.strip(),
            "duration": result.get("duration"),
            "language": result.get("language")
        }

whisper_service = WhisperService()