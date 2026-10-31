import os
import sqlite3

# Автоматично знаходимо абсолютний шлях до бази даних pharmapulse.db
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'pharmapulse.db')

conn = None
try:
    conn = sqlite3.connect(DB_PATH)
    
    # Додаємо колонку
    conn.execute("ALTER TABLE medicines ADD COLUMN stock INTEGER DEFAULT 15")
    
    # Зробимо один препарат "Немає в наявності" для перевірки UI
    conn.execute("UPDATE medicines SET stock = 0 WHERE name LIKE '%Амоксицилін%'")
    
    conn.commit()
    print("Поле stock успішно додано! Амоксицилін тепер відсутній на складі.")
except Exception as e:
    print(f"Помилка (можливо колонка вже існує): {e}")
finally:
    if conn:
        conn.close()
