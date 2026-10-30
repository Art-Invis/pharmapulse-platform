from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from typing import List
from pydantic import BaseModel

from app.core.database import get_db
from app.models.entities import User
from app.schemas.user import UserResponse, UserProfileResponse

router = APIRouter(prefix="/users", tags=["Users"])

# Схема для оновлення рівня лояльності
class LoyaltyUpdate(BaseModel):
    loyalty_tier: str

@router.get("/", response_model=List[UserResponse])
def get_all_users(db: Session = Depends(get_db)):
    """Повертає список усіх користувачів (для екрану входу та адмінки)."""
    return db.query(User).all()

@router.get("/profile", response_model=UserProfileResponse)
def get_user_profile(user_id: int = Query(..., description="ID поточного користувача"), db: Session = Depends(get_db)):
    """Повертає профіль вибраного користувача з його рецептами та історією замовлень."""
    user = db.query(User)\
        .options(
            joinedload(User.prescriptions), 
            joinedload(User.orders)
        )\
        .filter(User.id == user_id)\
        .first()
        
    if not user:
        raise HTTPException(status_code=404, detail="Користувача не знайдено")
        
    # Сортуємо замовлення від найновіших до найстаріших
    user.orders.sort(key=lambda x: x.created_at, reverse=True)
    return user

@router.patch("/{user_id}/loyalty", response_model=UserResponse)
def update_user_loyalty(user_id: int, payload: LoyaltyUpdate, db: Session = Depends(get_db)):
    """Дозволяє фармацевту змінити рівень лояльності клієнта."""
    valid_tiers = ["Standard", "Social", "Premium"]
    if payload.loyalty_tier not in valid_tiers:
        raise HTTPException(status_code=400, detail="Недійсний рівень лояльності")
        
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Користувача не знайдено")
        
    user.loyalty_tier = payload.loyalty_tier
    db.commit()
    db.refresh(user)
    return user