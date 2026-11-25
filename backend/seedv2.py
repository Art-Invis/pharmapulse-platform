import os
import random
from datetime import datetime, timedelta

# Виправлено імпорти: прибрано префікс backend і додано DatabaseConnection замість engine
from app.core.database import Base, DatabaseConnection
from app.models.entities import User, Medicine, PharmacyBranch, Prescription, Order, OrderItem

print("Ініціалізація нової бази даних...")

# Отримуємо engine та session через ваш синглтон підключення
db_conn = DatabaseConnection.get_instance()
engine = db_conn.engine

# 1. Створюємо всі таблиці з нуля на основі наших оновлених моделей
Base.metadata.create_all(bind=engine)

# Виправлено: прибрано функцію next(), оскільки get_session() повертає готовий об'єкт Session
db = db_conn.get_session()

# 2. Додаємо Аптеки (PharmacyBranch)
print("Додавання аптек...")
branches = [
    PharmacyBranch(name="Аптека «Центральна»", address="вул. Шевченка, 10", city="Львів"),
    PharmacyBranch(name="Аптека «На спальному»", address="вул. Сихівська, 25", city="Львів"),
    PharmacyBranch(name="Аптека «Цілодобова»", address="просп. Чорновола, 45", city="Львів"),
    PharmacyBranch(name="Аптека «Подорожник-Експрес»", address="вул. Городоцька, 112", city="Львів"),
    PharmacyBranch(name="Аптека «Здоров'я»", address="вул. Личаківська, 33", city="Львів"),
]
db.add_all(branches)
db.commit()

# 3. Додаємо Користувачів (User)
print("Додавання користувачів...")
users = [
    User(full_name="Іван Коваль", email="ivan@test.com", phone="+380991112233", role="Client", loyalty_tier="Standard"),
    User(full_name="Олена Петрівна", email="olena@test.com", phone="+380991112244", role="Client", loyalty_tier="Premium"),
    User(full_name="Петро Соціальний", email="petro@test.com", phone="+380991112255", role="Client", loyalty_tier="Social"),
    User(full_name="Мар'яна Кравчук", email="mariana@test.com", phone="+380673334455", role="Client", loyalty_tier="Premium"),
    User(full_name="Андрій Токар", email="andriy@test.com", phone="+380637778899", role="Client", loyalty_tier="Standard"),
    User(full_name="Дмитро Фармацевт", email="pharmacist@test.com", phone="+380509990011", role="Pharmacist", loyalty_tier="Standard"),
]
db.add_all(users)
db.commit()  # Зберігаємо, щоб згенерувалися автоінкрементні ID

# 4. Додаємо Ліки (Medicine) з різними залишками, цінами та рецептурністю
print("Додавання медикаментів...")
medicines = [
    Medicine(name="Аспірин-С", active_substance="Ацетилсаліцилова кислота", price=55.50, is_prescription_required=False, manufacturer="Bayer", stock=150),
    Medicine(name="Амоксицилін", active_substance="Амоксицилін", price=120.00, is_prescription_required=True, manufacturer="Київмедпрепарат", stock=0),  # Спеціально 0 для перевірки UI
    Medicine(name="Вітамін D3", active_substance="Холекальциферол", price=185.00, is_prescription_required=False, manufacturer="Дарниця", stock=30),
    Medicine(name="Німесил", active_substance="Німесулід", price=280.00, is_prescription_required=True, manufacturer="Berlin-Chemie", stock=15),
    Medicine(name="Корвалмент", active_substance="Розчин ментолу", price=45.00, is_prescription_required=False, manufacturer="Фармак", stock=100),
    Medicine(name="Парацетамол", active_substance="Парацетамол", price=32.10, is_prescription_required=False, manufacturer="Дарниця", stock=250),
    Medicine(name="Ібупрофен", active_substance="Ібупрофен", price=68.40, is_prescription_required=False, manufacturer="Фармак", stock=85),
    Medicine(name="Но-Шпа", active_substance="Дротаверин", price=145.00, is_prescription_required=False, manufacturer="Sanofi", stock=40),
    Medicine(name="Сумамед", active_substance="Азитроміцин", price=320.00, is_prescription_required=True, manufacturer="Pliva", stock=12),
    Medicine(name="Анальгін", active_substance="Метамізол натрію", price=25.00, is_prescription_required=False, manufacturer="Здоров'я", stock=300),
]
db.add_all(medicines)
db.commit()

# 5. Додаємо Рецепти (Prescription)
print("Додавання рецептів...")
prescriptions = [
    Prescription(user_id=users[0].id, code="RX-777-111", patient_full_name=users[0].full_name, doctor_full_name="Д-р Хаус", expiry_date=datetime.now() + timedelta(days=30), is_verified=True),
    Prescription(user_id=users[1].id, code="RX-888-222", patient_full_name=users[1].full_name, doctor_full_name="Д-р Комаровський", expiry_date=datetime.now() + timedelta(days=15), is_verified=False),
    Prescription(user_id=users[3].id, code="RX-999-333", patient_full_name=users[3].full_name, doctor_full_name="Д-р Пирогов", expiry_date=datetime.now() + timedelta(days=45), is_verified=True),
]
db.add_all(prescriptions)
db.commit()

# 6. Додаємо Замовлення (Order) та Позиції замовлень (OrderItem) для адмінки/кошика
print("Додавання тестових замовлень та позицій...")

# Замовлення 1 (Іван Коваль)
o1 = Order(
    user_id=users[0].id, 
    status="Pending", 
    delivery_type="Pickup", 
    final_price=156.00, 
    created_at=datetime.now() - timedelta(hours=2)
)
db.add(o1)
db.commit()

# ЗМІНЕНО: price -> price_per_unit
oi1 = OrderItem(order_id=o1.id, medicine_id=medicines[0].id, quantity=2, price_per_unit=medicines[0].price)  # 2x Аспірин
oi2 = OrderItem(order_id=o1.id, medicine_id=medicines[4].id, quantity=1, price_per_unit=medicines[4].price)  # 1x Корвалмент
db.add_all([oi1, oi2])

# Замовлення 2 (Олена Петрівна)
o2 = Order(
    user_id=users[1].id, 
    status="Processing", 
    delivery_type="Courier", 
    final_price=465.00, 
    created_at=datetime.now() - timedelta(days=1)
)
db.add(o2)
db.commit()

# ЗМІНЕНО: price -> price_per_unit
oi3 = OrderItem(order_id=o2.id, medicine_id=medicines[3].id, quantity=1, price_per_unit=medicines[3].price)  # 1x Німесил
oi4 = OrderItem(order_id=o2.id, medicine_id=medicines[2].id, quantity=1, price_per_unit=medicines[2].price)  # 1x Вітамін D3
db.add_all([oi3, oi4])

# Замовлення 3 (Петро Соціальний)
o3 = Order(
    user_id=users[2].id, 
    status="Ready", 
    delivery_type="Pickup", 
    final_price=64.20, 
    created_at=datetime.now() - timedelta(hours=5)
)
db.add(o3)
db.commit()

# ЗМІНЕНО: price -> price_per_unit
oi5 = OrderItem(order_id=o3.id, medicine_id=medicines[5].id, quantity=2, price_per_unit=medicines[5].price)  # 2x Парацетамол
db.add_all([oi5])

db.commit()
print("✅ Успіх! Нова, розширена та чиста база даних створена та заповнена даними.")
