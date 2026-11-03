from pydantic import BaseModel

class PharmacyBranchResponse(BaseModel):
    id: int
    address: str
    phone: str

    class Config:
        from_attributes = True