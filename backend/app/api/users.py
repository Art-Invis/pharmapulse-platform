from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from app.core.database import get_db
from app.models.entities import User
from app.schemas.user import UserProfileResponse

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserProfileResponse)
def get_my_profile(db: Session = Depends(get_db)):
    """Повертає профіль поточного користувача з його рецептами та історією замовлень."""
    current_user_id = 2 
    
    user = db.query(User)\
        .options(
            joinedload(User.prescriptions), 
            joinedload(User.orders)
        )\
        .filter(User.id == current_user_id)\
        .first()
        
    if not user:
        raise HTTPException(status_code=404, detail="Користувача не знайдено")
        
    user.orders.sort(key=lambda x: x.created_at, reverse=True)
        
    return user