from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload 
from typing import List

from app.core.database import get_db
from app.models.entities import Order, User, Medicine, PharmacyBranch, OrderItem, Prescription 
from app.schemas.order import OrderCreate, OrderResponse
from app.patterns.builder import OrderBuilder
from app.patterns.strategy import get_loyalty_strategy
from app.patterns.observer import OrderEventManager

router = APIRouter(prefix="/orders", tags=["Orders"])

# Глобальний менеджер подій для патерна Observer
event_manager = OrderEventManager()

@router.post("/", response_model=OrderResponse)
def create_order(order_in: OrderCreate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == order_in.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Користувача не знайдено")

    builder = OrderBuilder()
    builder.set_customer(user)

    # Налаштування доставки
    delivery_address = getattr(order_in, 'delivery_address', None)
    if order_in.branch_id:
        branch = db.query(PharmacyBranch).filter(PharmacyBranch.id == order_in.branch_id).first()
        builder.set_delivery(order_in.delivery_type, delivery_address, branch)
    else:
        builder.set_delivery(order_in.delivery_type, delivery_address)

    for item_in in order_in.items:
        med = db.query(Medicine).filter(Medicine.id == item_in.medicine_id).first()
        if not med:
            raise HTTPException(status_code=404, detail=f"Препарат #{item_in.medicine_id} не знайдено")
        
        if med.stock < item_in.quantity:
            raise HTTPException(status_code=400, detail=f"Недостатньо на складі: {med.name} (Залишок: {med.stock})")
            
        builder.add_item(med, item_in.quantity)

    valid_prescription = db.query(Prescription).filter(
        Prescription.user_id == user.id,
        Prescription.is_verified == True
    ).first()
    
    if valid_prescription:
        builder.attach_prescription(valid_prescription)
    # ------------------------------------------------------------------

    # Застосування патерну Strategy для знижок
    strategy = get_loyalty_strategy(user.loyalty_tier)
    builder.apply_pricing(strategy)
    
    try:
        order = builder.get_result() 
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    db.add(order)

    for item_in in order_in.items:
        med = db.query(Medicine).filter(Medicine.id == item_in.medicine_id).first()
        med.stock -= item_in.quantity
    # ---------------------------------------------------------------------------

    db.commit()
    db.refresh(order)
    return order

@router.patch("/{order_id}/status", response_model=OrderResponse)
def update_order_status(order_id: int, new_status: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Замовлення не знайдено")

    order.status = new_status
    db.commit()
    db.refresh(order)

    event_manager.notify_observers(order, event_type=f"order_{new_status.lower()}")
    
    return order

@router.get("/", response_model=List[OrderResponse])
def get_all_orders(db: Session = Depends(get_db)):
    """Повертає список усіх замовлень для панелі адміністратора."""
    orders = db.query(Order).options(joinedload(Order.items)).order_by(Order.created_at.desc()).all()
    return orders