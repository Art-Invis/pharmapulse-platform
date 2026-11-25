from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class OrderItemCreate(BaseModel):
    medicine_id: int
    quantity: int = Field(gt=0, description="Кількість має бути більшою за нуль")

class OrderCreate(BaseModel):
    user_id: int
    delivery_type: str = Field(pattern="^(Delivery|Pickup)$")
    delivery_address: Optional[str] = None
    branch_id: Optional[int] = None
    prescription_id: Optional[int] = None
    items: List[OrderItemCreate]

class OrderResponse(BaseModel):
    id: int
    user_id: int
    delivery_type: str
    status: str
    raw_total: float
    final_price: float
    created_at: datetime

    class Config:
        from_attributes = True