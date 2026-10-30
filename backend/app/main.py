from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import DatabaseConnection, Base
from app.api import orders, catalog
from app.patterns.observer import CustomerNotificationDispatcher, PharmacyStockSynchronizer
from app.api import orders, catalog, users
app = FastAPI(title="PharmaPulse API")

# Налаштування CORS для локальної розробки (щоб Flutter Web міг робити запити)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # У продакшені тут має бути URL фронтенду
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    db_conn = DatabaseConnection.get_instance()
    Base.metadata.create_all(bind=db_conn.engine)

    orders.event_manager.subscribe(CustomerNotificationDispatcher(prefer_sms=True))
    orders.event_manager.subscribe(PharmacyStockSynchronizer())

# Реєстрація роутерів
app.include_router(orders.router)
app.include_router(catalog.router)
app.include_router(orders.router)
app.include_router(catalog.router)
app.include_router(users.router)

@app.get("/")
def health_check():
    return {"status": "ok", "system": "PharmaPulse API is running"}