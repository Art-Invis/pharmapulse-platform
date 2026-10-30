from pydantic import BaseModel, EmailStr
from typing import List
from datetime import datetime
from .order import OrderResponse

class UserBase(BaseModel):
    full_name: str
    email: EmailStr
    phone: str

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int
    role: str
    loyalty_tier: str

    class Config:
        from_attributes = True

class PrescriptionResponse(BaseModel):
    id: int
    code: str
    doctor_full_name: str
    expiry_date: datetime
    is_verified: bool

    class Config:
        from_attributes = True

class UserProfileResponse(UserResponse):
    prescriptions: List[PrescriptionResponse] = []
    orders: List[OrderResponse] = []

    class Config:
        from_attributes = True