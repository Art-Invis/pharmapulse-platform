import time
from datetime import datetime, timedelta
from app.core.database import DatabaseConnection
from app.models.entities import Prescription, User

db_conn = DatabaseConnection.get_instance()
db = db_conn.get_session()

# Знаходимо наших тестових юзерів
user1 = db.query(User).filter(User.id == 1).first()
user2 = db.query(User).filter(User.id == 2).first()

# Створюємо унікальні коди на основі мітки часу (наприклад, RX-17302830)
timestamp = int(time.time())
code1 = f"RX-{timestamp}"
code2 = f"RX-{timestamp + 1}"

if user1:
    db.add(Prescription(
        user_id=user1.id, 
        code=code1, 
        patient_full_name=user1.full_name,  # Динамічно береться ім'я з бази
        doctor_full_name="Д-р Хаус", 
        expiry_date=datetime.now() + timedelta(days=30), 
        is_verified=True
    ))
if user2:
    db.add(Prescription(
        user_id=user2.id, 
        code=code2, 
        patient_full_name=user2.full_name,  # Динамічно береться ім'я з бази
        doctor_full_name="Д-р Комаровський", 
        expiry_date=datetime.now() + timedelta(days=15), 
        is_verified=False
    ))

db.commit()
print(f"Тестові рецепти ({code1}, {code2}) успішно додано в БД для реальних користувачів!")
