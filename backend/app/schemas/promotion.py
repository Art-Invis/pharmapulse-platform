from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class PromotionCreate(BaseModel):
    title: str = Field(..., min_length=2)
    description: str = Field(..., min_length=5)
    discount_percent: float = Field(default=0.0, ge=0, le=90)
    medicine_id: Optional[int] = None

class PromotionResponse(BaseModel):
    id: int
    title: str
    description: str
    discount_percent: float
    medicine_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True