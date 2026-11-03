from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.entities import Medicine, PharmacyBranch
from app.schemas.medicine import MedicineResponse
from app.schemas.pharmacy import PharmacyBranchResponse

router = APIRouter(prefix="/catalog", tags=["Catalog"])

@router.get("/medicines", response_model=List[MedicineResponse])
def get_all_medicines(db: Session = Depends(get_db)):
    """Повертає список усіх доступних медикаментів для вітрини."""
    medicines = db.query(Medicine).all()
    return medicines

@router.get("/branches", response_model=List[PharmacyBranchResponse])
def get_all_branches(db: Session = Depends(get_db)):
    """Повертає список аптечних точок для вибору самовивозу."""
    branches = db.query(PharmacyBranch).all()
    return branches