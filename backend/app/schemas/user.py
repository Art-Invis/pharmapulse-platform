from pydantic import BaseModel, EmailStr

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