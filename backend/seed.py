# backend/seed.py
from app.core.database import DatabaseConnection, Base
from app.models.entities import User, Medicine, PharmacyBranch, pharmacy_stocks
from sqlalchemy import insert
import datetime

def run_seed():
    db_conn = DatabaseConnection.get_instance()
    engine = db_conn.engine
    Session = db_conn.session_factory

    # Перестворюємо всі таблиці для чистого старту
    print("Очищення та створення таблиць...")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = Session()

    try:
        print("Додавання користувачів...")
        u1 = User(full_name="Олексій Мартинюк", email="oleksiy@example.com", phone="+380991112233", role="Customer", loyalty_tier="Standard")
        u2 = User(full_name="Олена Коваль", email="olena@example.com", phone="+380994445566", role="Customer", loyalty_tier="Premium")
        u3 = User(full_name="Василь Петрович", email="vasyl@example.com", phone="+380997778899", role="Customer", loyalty_tier="Social")
        db.add_all([u1, u2, u3])
        db.flush() # щоб отримати ID

        print("Додавання аптечних філій...")
        b1 = PharmacyBranch(address="м. Львів, вул. Наукова 35А", phone="+380322223344")
        b2 = PharmacyBranch(address="м. Львів, вул. Стрийська 200", phone="+380322225566")
        db.add_all([b1, b2])
        db.flush()

        print("Додавання медикаментів...")
        m1 = Medicine(name="Ібупрофен 400мг", active_substance="Ibuprofen", price=120.50, is_prescription_required=False, manufacturer="Дарниця")
        m2 = Medicine(name="Амоксицилін", active_substance="Amoxicillin", price=215.00, is_prescription_required=True, manufacturer="Київмедпрепарат")
        m3 = Medicine(name="Вітамін C", active_substance="Ascorbic acid", price=85.00, is_prescription_required=False, manufacturer="Стирол")
        db.add_all([m1, m2, m3])
        db.flush()

        print("Додавання залишків на склади аптек...")
        # У першій філії є ібупрофен і антибіотик
        db.execute(insert(pharmacy_stocks).values(pharmacy_id=b1.id, medicine_id=m1.id, quantity=50))
        db.execute(insert(pharmacy_stocks).values(pharmacy_id=b1.id, medicine_id=m2.id, quantity=15))
        
        # У другій філії є лише вітаміни та ібупрофен
        db.execute(insert(pharmacy_stocks).values(pharmacy_id=b2.id, medicine_id=m1.id, quantity=100))
        db.execute(insert(pharmacy_stocks).values(pharmacy_id=b2.id, medicine_id=m3.id, quantity=200))

        db.commit()
        print("✅ Базу даних успішно наповнено тестовими даними!")

    except Exception as e:
        db.rollback()
        print(f"❌ Помилка під час наповнення бази: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    run_seed()