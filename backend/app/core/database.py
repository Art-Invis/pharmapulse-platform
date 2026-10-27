import threading
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

Base = declarative_base()

class DatabaseConnection:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(DatabaseConnection, cls).__new__(cls)
                cls._instance._init_connection()
            return cls._instance

    def _init_connection(self):
        # connect_args потрібні виключно для SQLite
        connect_args = {"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {}
        self.engine = create_engine(settings.DATABASE_URL, connect_args=connect_args)
        self.session_factory = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)
        self.is_connected = True

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls()
        return cls._instance

    def get_session(self):
        return self.session_factory()

# Dependency для контролерів FastAPI
def get_db():
    db = DatabaseConnection.get_instance().get_session()
    try:
        yield db
    finally:
        db.close()