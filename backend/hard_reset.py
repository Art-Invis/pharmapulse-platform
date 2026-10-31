import os
import random
from datetime import datetime, timedelta

# Динамічно визначаємо абсолютний шлях до файлу pharmapulse.db
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'pharmapulse.db')

print("Очищення старої БД...")
if os.path.exists(DB_PATH):
    try:
        os.remove(DB_PATH)
        print(f"🗑️ Стару базу {DB_PATH} успішно видалено!")
    except PermissionError:
        print(f"❌ ПОМИЛКА: Файл {DB_PATH} заблоковано.")
        print("⚠️ НАТИСНИ Ctrl+C у терміналі uvicorn (зупини сервер) і запусти скрипт знову!")
        exit()
else:
    print("Файлу бази даних не знайдено, переходимо до створення...")

# Підключаємо залежності без префікса backend.
from app.core.database import Base, DatabaseConnection
from app.models.entities import User, Medicine, PharmacyBranch, Prescription, Order, OrderItem

print("Ініціалізація нової бази даних...")
db_conn = DatabaseConnection.get_instance()
engine = db_conn.engine

# Створюємо чисті таблиці з нуля
Base.metadata.create_all(bind=engine)
db = db_conn.get_session()

print("Заповнення розширеними тестовими даними...")

# 1. Додаємо аптечні філії (Lviv & Kyiv)
print("-> Створення мережі аптек...")
branches = [
    PharmacyBranch(name="Аптека «Центральна»", address="вул. Шевченка, 10", city="Львів"),
    PharmacyBranch(name="Аптека «На спальному»", address="вул. Сихівська, 25", city="Львів"),
    PharmacyBranch(name="Аптека «Цілодобова»", address="просп. Чорновола, 45", city="Львів"),
    PharmacyBranch(name="Аптека «Подорожник-Експрес»", address="вул. Городоцька, 112", city="Львів"),
    PharmacyBranch(name="Аптека «Привокзальна»", address="площа Двірцева, 1", city="Львів"),
]
db.add_all(branches)
db.commit()

# 2. Додаємо Користувачів (Клієнти та Фармацевти)
print("-> Створення облікових записів...")
users = [
    User(full_name="Іван Коваль", email="ivan@test.com", phone="+380991112233", role="Client", loyalty_tier="Standard"),
    User(full_name="Олена Петрівна", email="olena@test.com", phone="+380991112244", role="Client", loyalty_tier="Premium"),
    User(full_name="Петро Соціальний", email="petro@test.com", phone="+380991112255", role="Client", loyalty_tier="Social"),
    User(full_name="Мар'яна Кравчук", email="mariana@test.com", phone="+380673334455", role="Client", loyalty_tier="Premium"),
    User(full_name="Андрій Токар", email="andriy@test.com", phone="+380637778899", role="Client", loyalty_tier="Standard"),
    User(full_name="Олександр Мороз", email="moroz@test.com", phone="+380505556677", role="Client", loyalty_tier="Social"),
    User(full_name="Дмитро Фармацевт", email="pharmacist@test.com", phone="+380509990011", role="Pharmacist", loyalty_tier="Standard"),
]
db.add_all(users)
db.commit()

# 3. Додаємо розширений перелік медикаментів
print("-> Створення каталогу медикаментів...")
medicines = [
    # Звичайні (Без рецепта)
    Medicine(name="Аспірин-С", active_substance="Ацетилсаліцилова кислота", price=55.50, is_prescription_required=False, manufacturer="Bayer", stock=150),
    Medicine(name="Вітамін D3", active_substance="Холекальциферол", price=185.00, is_prescription_required=False, manufacturer="Дарниця", stock=30),
    Medicine(name="Корвалмент", active_substance="Розчин ментолу", price=45.00, is_prescription_required=False, manufacturer="Фармак", stock=100),
    Medicine(name="Парацетамол", active_substance="Парацетамол", price=32.10, is_prescription_required=False, manufacturer="Дарниця", stock=250),
    Medicine(name="Ібупрофен-Д", active_substance="Ібупрофен", price=68.40, is_prescription_required=False, manufacturer="Фармак", stock=85),
    Medicine(name="Но-Шпа", active_substance="Дротаверин", price=145.00, is_prescription_required=False, manufacturer="Sanofi", stock=40),
    Medicine(name="Анальгін", active_substance="Метамізол натрію", price=25.00, is_prescription_required=False, manufacturer="Здоров'я", stock=300),
    Medicine(name="Мезим Форте", active_substance="Панкреатин", price=115.20, is_prescription_required=False, manufacturer="Berlin-Chemie", stock=60),
    Medicine(name="АЦЦ 200", active_substance="Ацетилцистеїн", price=160.00, is_prescription_required=False, manufacturer="Sandoz", stock=45),
    Medicine(name="Активоване вугілля", active_substance="Вугілля активоване", price=12.50, is_prescription_required=False, manufacturer="Борщагівський ХФЗ", stock=500),
    
    # Рецептурні (is_prescription_required=True)
    Medicine(name="Амоксицилін", active_substance="Амоксицилін", price=120.00, is_prescription_required=True, manufacturer="Київмедпрепарат", stock=0), 
    Medicine(name="Німесил", active_substance="Німесулід", price=280.00, is_prescription_required=True, manufacturer="Berlin-Chemie", stock=15),
    Medicine(name="Сумамед", active_substance="Азитроміцин", price=320.00, is_prescription_required=True, manufacturer="Pliva", stock=12),
    Medicine(name="Дексаметазон", active_substance="Дексаметазон", price=95.00, is_prescription_required=True, manufacturer="Фармак", stock=25),
    Medicine(name="Каптопрес", active_substance="Каптоприл / Гідрохлортіазид", price=82.00, is_prescription_required=True, manufacturer="Дарниця", stock=110),
]
db.add_all(medicines)
db.commit()

# 4. Додаємо цифрові медичні рецепти
print("-> Генерація електронних рецептів...")
prescriptions = [
    Prescription(user_id=users[0].id, code="RX-777-111", patient_full_name=users[0].full_name, doctor_full_name="Д-р Хаус", expiry_date=datetime.now() + timedelta(days=30), is_verified=True),
    Prescription(user_id=users[1].id, code="RX-888-222", patient_full_name=users[1].full_name, doctor_full_name="Д-р Комаровський", expiry_date=datetime.now() + timedelta(days=15), is_verified=False),
    Prescription(user_id=users[2].id, code="RX-999-333", patient_full_name=users[2].full_name, doctor_full_name="Д-р Пирогов", expiry_date=datetime.now() + timedelta(days=45), is_verified=True),
    Prescription(user_id=users[3].id, code="RX-555-444", patient_full_name=users[3].full_name, doctor_full_name="Д-р Супрун", expiry_date=datetime.now() - timedelta(days=2), is_verified=True),
]
db.add_all(prescriptions)
db.commit()

# 5. Додаємо Замовлення (Orders) — ТЕПЕР З ОБОВ'ЯЗКОВИМ raw_total
print("-> Створення історії замовлень для адмінки...")
orders = [
    Order(user_id=users[0].id, branch_id=branches[0].id, status="Pending", delivery_type="Pickup", raw_total=156.00, final_price=156.00, created_at=datetime.now() - timedelta(hours=2)),
    Order(user_id=users[1].id, branch_id=branches[1].id, status="Processing", delivery_type="Courier", raw_total=465.00, final_price=465.00, created_at=datetime.now() - timedelta(days=1)),
    Order(user_id=users[2].id, branch_id=branches[0].id, status="Ready", delivery_type="Pickup", raw_total=64.20, final_price=64.20, created_at=datetime.now() - timedelta(hours=5)),
    Order(user_id=users[3].id, branch_id=branches[2].id, status="Completed", delivery_type="Pickup", raw_total=320.00, final_price=320.00, created_at=datetime.now() - timedelta(days=3)),
    Order(user_id=users[4].id, branch_id=branches[1].id, status="Cancelled", delivery_type="Courier", raw_total=145.00, final_price=145.00, created_at=datetime.now() - timedelta(days=2)),
]
db.add_all(orders)
db.commit()

# 6. Наповнюємо замовлення конкретними товарами (OrderItem) — ТЕПЕР З ОБОВ'ЯЗКОВИМ price_per_unit
print("-> Прив'язка товарів до замовлень...")
order_items = [
    # Позиції для замовлення 1 (2x Аспірин, 1x Корвалмент)
    OrderItem(order_id=orders[0].id, medicine_id=medicines[0].id, quantity=2, price_per_unit=55.50),
    OrderItem(order_id=orders[0].id, medicine_id=medicines[2].id, quantity=1, price_per_unit=45.00),
    
    # Позиції для замовлення 2 (1x Німесил, 1x Вітамін D3)
    OrderItem(order_id=orders[1].id, medicine_id=medicines[11].id, quantity=1, price_per_unit=280.00),
    OrderItem(order_id=orders[1].id, medicine_id=medicines[1].id, quantity=1, price_per_unit=185.00),
    
    # Позиції для замовлення 3 (2x Парацетамол)
    OrderItem(order_id=orders[2].id, medicine_id=medicines[3].id, quantity=2, price_per_unit=32.10),
    
    # Позиції для замовлення 4 (1x Сумамед)
    OrderItem(order_id=orders[3].id, medicine_id=medicines[12].id, quantity=1, price_per_unit=320.00),
    
    # Позиції для замовлення 5 (1x Но-Шпа)
    OrderItem(order_id=orders[4].id, medicine_id=medicines[5].id, quantity=1, price_per_unit=145.00),
]
db.add_all(order_items)
db.commit()

print("✅ Успіх! Ідеально чиста база перестворена та заповнена великою кількістю правильних даних!")
