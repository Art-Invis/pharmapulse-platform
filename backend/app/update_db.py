from app.core.database import DatabaseConnection
from app.models.entities import Base

db_conn = DatabaseConnection.get_instance()
engine = db_conn.engine

Base.metadata.create_all(bind=engine)
print("База даних успішно оновлена! Таблиця order_items створена.")
