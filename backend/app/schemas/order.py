from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# --- ВХІДНІ ДАНІ (Що приходить з Flutter) ---
class OrderItemCreate(BaseModel):
    medicine_id: int
    quantity: int

class OrderCreate(BaseModel):
    user_id: int
    delivery_type: str
    branch_id: Optional[int] = None
    items: List[OrderItemCreate] # Тепер бекенд приймає список товарів!

# --- ВИХІДНІ ДАНІ (Що відправляється у Flutter) ---
class OrderItemResponse(BaseModel):
    medicine_id: int
    quantity: int
    price_per_unit: float

    class Config:
        from_attributes = True

class OrderResponse(BaseModel):
    id: int
    user_id: int
    delivery_type: str
    branch_id: Optional[int] = None
    status: str
    raw_total: float
    final_price: float
    created_at: datetime
    items: List[OrderItemResponse] = [] 

    class Config:
        from_attributes = True