from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String)
    email = Column(String, unique=True, index=True)
    phone = Column(String)
    role = Column(String, default="Client")
    loyalty_tier = Column(String, default="Standard")

    # Зв'язки
    prescriptions = relationship("Prescription", back_populates="user")
    orders = relationship("Order", back_populates="user")

class Prescription(Base):
    __tablename__ = "prescriptions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    code = Column(String, unique=True, index=True)
    patient_full_name = Column(String)
    doctor_full_name = Column(String)
    expiry_date = Column(DateTime)
    is_verified = Column(Boolean, default=False)

    # Зв'язок
    user = relationship("User", back_populates="prescriptions")

class Medicine(Base):
    __tablename__ = "medicines"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    active_substance = Column(String)
    price = Column(Float)
    is_prescription_required = Column(Boolean, default=False)
    manufacturer = Column(String)
    stock = Column(Integer, default=15)

class PharmacyBranch(Base):
    __tablename__ = "pharmacy_branches"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    address = Column(String)
    city = Column(String)
    phone = Column(String, default="+380800505050") # ДОДАЙ ЦЕЙ РЯДОК

class OrderItem(Base):
    __tablename__ = "order_items"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    medicine_id = Column(Integer, ForeignKey("medicines.id"))
    quantity = Column(Integer)
    price_per_unit = Column(Float)
    
    # Зв'язки
    order = relationship("Order", back_populates="items")
    medicine = relationship("Medicine")

class Order(Base):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    branch_id = Column(Integer, ForeignKey("pharmacy_branches.id"), nullable=True)
    delivery_type = Column(String)
    status = Column(String, default="Pending")
    raw_total = Column(Float)
    final_price = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Зв'язки
    user = relationship("User", back_populates="orders")
    branch = relationship("PharmacyBranch")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")