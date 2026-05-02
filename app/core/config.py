from pydantic_settings import BaseSettings
from pathlib import Path

class Settings(BaseSettings):
    APP_NAME: str = "VoiceToNotes"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    DATABASE_URL: str = "sqlite:///./voice_to_notes.db"

    UPLOAD_DIR: str = "uploads"
    MAX_AUDIO_DURATION: int = 3600

    WHISPER_MODEL: str = "small"
    CUSTOM_DICT_PATH: str = "custom_dict/rpl_term.json"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_PATH = BASE_DIR / settings.UPLOAD_DIR
UPLOAD_PATH.mkdir(exist_ok=True)