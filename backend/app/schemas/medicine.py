from pydantic import BaseModel, Field

class MedicineBase(BaseModel):
    name: str
    active_substance: str
    price: float
    is_prescription_required: bool
    manufacturer: str
    stock: int 

class MedicineResponse(MedicineBase):
    id: int

    class Config:
        from_attributes = True  

class MedicineCreate(BaseModel):
    name: str = Field(..., min_length=2)
    active_substance: str = Field(..., min_length=2)
    price: float = Field(..., gt=0)
    is_prescription_required: bool = False
    manufacturer: str = Field(..., min_length=2)
    stock: int = Field(default=10, ge=0)