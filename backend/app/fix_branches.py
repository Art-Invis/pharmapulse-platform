import os
import sqlite3

# Автоматично знаходимо абсолютний шлях до файлу бази даних pharmapulse.db
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'pharmapulse.db')

conn = None
try:
    # Підключаємось до нашої бази за правильним шляхом
    conn = sqlite3.connect(DB_PATH)
    
    # Додаємо відсутню колонку name із дефолтним значенням
    conn.execute("ALTER TABLE pharmacy_branches ADD COLUMN name VARCHAR DEFAULT 'Аптека PharmaPulse'")
    
    conn.commit()
    print("✅ Колонку 'name' успішно додано до таблиці pharmacy_branches!")
except Exception as e:
    print(f"❌ Помилка (можливо колонка вже існує): {e}")
finally:
    if conn:
        conn.close()
