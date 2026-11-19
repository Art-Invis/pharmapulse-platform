from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.entities import Medicine, PharmacyBranch
from app.schemas.medicine import MedicineResponse, MedicineCreate
from app.schemas.pharmacy import PharmacyBranchResponse

router = APIRouter(prefix="/catalog", tags=["Catalog"])

@router.get("/medicines", response_model=List[MedicineResponse])
def get_all_medicines(db: Session = Depends(get_db)):
    """Повертає список усіх доступних медикаментів для вітрини."""
    return db.query(Medicine).all()

@router.post("/medicines", response_model=MedicineResponse, status_code=status.HTTP_201_CREATED)
def create_medicine(medicine: MedicineCreate, db: Session = Depends(get_db)):
    """Додає новий медикамент до каталогу (для панелі адміністратора/фармацевта)."""
    new_med = Medicine(
        name=medicine.name,
        active_substance=medicine.active_substance,
        price=medicine.price,
        is_prescription_required=medicine.is_prescription_required,
        manufacturer=medicine.manufacturer,
        stock=medicine.stock,
    )
    db.add(new_med)
    db.commit()
    db.refresh(new_med)
    return new_med

@router.get("/branches", response_model=List[PharmacyBranchResponse])
def get_all_branches(db: Session = Depends(get_db)):
    """Повертає список аптечних точок для вибору самовивозу."""
    return db.query(PharmacyBranch).all()