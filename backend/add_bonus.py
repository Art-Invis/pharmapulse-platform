import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'pharmapulse.db')

conn = None
try:
    conn = sqlite3.connect(DB_PATH)
    
    conn.execute("ALTER TABLE users ADD COLUMN bonus_balance FLOAT DEFAULT 0.0")
    
    conn.commit()
    print("✅ Колонку bonus_balance успішно додано!")
except Exception as e:
    print(f"❌ Помилка (можливо колонка вже існує): {e}")
finally:
    if conn:
        conn.close()
