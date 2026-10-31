from pydantic import BaseModel

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
        from_attributes = True  # Дозволяє автоматичний парсинг з об'єктів SQLAlchemy