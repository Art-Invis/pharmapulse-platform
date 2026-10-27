from fastapi import FastAPI
from app.core.database import DatabaseConnection, Base
from app.api import orders
from app.patterns.observer import CustomerNotificationDispatcher, PharmacyStockSynchronizer

app = FastAPI(title="PharmaPulse API")

@app.on_event("startup")
def on_startup():
    # 1. Ініціалізація БД через Singleton
    db_conn = DatabaseConnection.get_instance()
    Base.metadata.create_all(bind=db_conn.engine)

    # 2. Реєстрація підписників Observer
    # Додаємо сповіщення (Factory Method викличе SMS) та синхронізатор залишків
    orders.event_manager.subscribe(CustomerNotificationDispatcher(prefer_sms=True))
    orders.event_manager.subscribe(PharmacyStockSynchronizer())

app.include_router(orders.router)

@app.get("/")
def health_check():
    return {"status": "ok", "system": "PharmaPulse API is running"}