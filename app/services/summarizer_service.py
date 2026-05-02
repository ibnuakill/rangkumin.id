from transformers import pipeline
from app.core.config import settings

class SummarizerService:
    def __init__(self):
        self.summarizer = None

    def _load_model(self):
        if self.summarizer is None:
            print("Loading summarizer model...")
            self.summarizer = pipeline(
                "summarization",
                model="facebook/bart-large-cnn",
                device=-1
            )
            print("Summarizer model loaded!")
        return self.summarizer

    def _chunk_text(self, text: str, max_chunk: int = 1000) -> list:
        words = text.split()
        chunks = []
        current = []
        count = 0
        for word in words:
            current.append(word)
            count += 1
            if count >= max_chunk:
                chunks.append(" ".join(current))
                current = []
                count = 0
        if current:
            chunks.append(" ".join(current))
        return chunks

    async def summarize(self, text: str) -> dict:
        if len(text.split()) < 30:
            return {"summary": text}

        model = self._load_model()
        chunks = self._chunk_text(text)
        summaries = []

        for chunk in chunks:
            result = model(
                chunk,
                max_length=150,
                min_length=40,
                do_sample=False
            )
            summaries.append(result[0]["summary_text"])

        final_summary = " ".join(summaries)
        return {"summary": final_summary}

summarizer_service = SummarizerService()