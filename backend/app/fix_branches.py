import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'pharmapulse.db')

conn = None
try:
    conn = sqlite3.connect(DB_PATH)
    
    conn.execute("ALTER TABLE pharmacy_branches ADD COLUMN name VARCHAR DEFAULT 'Аптека PharmaPulse'")
    
    conn.commit()
    print("✅ Колонку 'name' успішно додано до таблиці pharmacy_branches!")
except Exception as e:
    print(f"❌ Помилка (можливо колонка вже існує): {e}")
finally:
    if conn:
        conn.close()
