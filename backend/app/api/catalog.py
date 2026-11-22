from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.entities import Medicine, PharmacyBranch
from app.schemas.medicine import MedicineResponse, MedicineCreate
from app.schemas.pharmacy import PharmacyBranchResponse
from app.models.entities import Medicine, PharmacyBranch, Promotion
from app.schemas.promotion import PromotionCreate, PromotionResponse

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

@router.get("/promotions", response_model=List[PromotionResponse])
def get_promotions(db: Session = Depends(get_db)):
    """Повертає список актуальних акцій та сезонних знижок (нові зверху)."""
    return db.query(Promotion).order_by(Promotion.created_at.desc()).all()

@router.post("/promotions", response_model=PromotionResponse, status_code=status.HTTP_201_CREATED)
def create_promotion(promo: PromotionCreate, db: Session = Depends(get_db)):
    """Створює нову акцію (для панелі адміністратора/фармацевта)."""
    new_promo = Promotion(
        title=promo.title,
        description=promo.description,
        discount_percent=promo.discount_percent,
        medicine_id=promo.medicine_id,
    )
    db.add(new_promo)
    db.commit()
    db.refresh(new_promo)
    return new_promo