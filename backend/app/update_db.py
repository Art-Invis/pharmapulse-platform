from app.core.database import DatabaseConnection
from app.models.entities import Base

# Отримуємо екземпляр підключення та його внутрішній engine
db_conn = DatabaseConnection.get_instance()
engine = db_conn.engine

# Створюємо всі нові таблиці (зокрема order_items)
Base.metadata.create_all(bind=engine)
print("База даних успішно оновлена! Таблиця order_items створена.")
