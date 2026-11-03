from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "PharmaPulse API"
    DATABASE_URL: str = "sqlite:///./pharmapulse.db"

    class Config:
        case_sensitive = True

settings = Settings()