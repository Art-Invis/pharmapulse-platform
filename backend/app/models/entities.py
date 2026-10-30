from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship
from app.core.database import Base

# Many-to-Many: Наявність медикаментів у аптечних точках
pharmacy_stocks = Table(
    "pharmacy_stocks",
    Base.metadata,
    Column("pharmacy_id", Integer, ForeignKey("pharmacy_branches.id"), primary_key=True),
    Column("medicine_id", Integer, ForeignKey("medicines.id"), primary_key=True),
    Column("quantity", Integer, default=0)
)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String, nullable=False)
    role = Column(String, default="Customer")  # Customer, Pharmacist, Admin
    loyalty_tier = Column(String, default="Standard")  # Standard, Social, Premium

    prescriptions = relationship("Prescription", back_populates="user")
    orders = relationship("Order", back_populates="user")

class Medicine(Base):
    __tablename__ = "medicines"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    active_substance = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    is_prescription_required = Column(Boolean, default=False)
    manufacturer = Column(String, nullable=False)

    branches = relationship("PharmacyBranch", secondary=pharmacy_stocks, back_populates="medicines")

class PharmacyBranch(Base):
    __tablename__ = "pharmacy_branches"

    id = Column(Integer, primary_key=True, index=True)
    address = Column(String, nullable=False)
    phone = Column(String, nullable=False)

    medicines = relationship("Medicine", secondary=pharmacy_stocks, back_populates="branches")
    orders = relationship("Order", back_populates="branch")

class Prescription(Base):
    __tablename__ = "prescriptions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    code = Column(String, unique=True, index=True, nullable=False)
    patient_full_name = Column(String, nullable=False)
    doctor_full_name = Column(String, nullable=False)
    expiry_date = Column(DateTime, nullable=False)
    is_verified = Column(Boolean, default=False)

    user = relationship("User", back_populates="prescriptions")
    orders = relationship("Order", back_populates="prescription")

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    branch_id = Column(Integer, ForeignKey("pharmacy_branches.id"), nullable=True)
    prescription_id = Column(Integer, ForeignKey("prescriptions.id"), nullable=True)
    
    delivery_type = Column(String, nullable=False)  # "Delivery" або "Pickup"
    delivery_address = Column(String, nullable=True)
    raw_total = Column(Float, default=0.0)
    final_price = Column(Float, default=0.0)
    status = Column(String, default="Pending")  # Pending, Processing, Ready, Completed, Cancelled
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="orders")
    branch = relationship("PharmacyBranch", back_populates="orders")
    prescription = relationship("Prescription", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=False)
    medicine_id = Column(Integer, ForeignKey("medicines.id"), nullable=False)
    quantity = Column(Integer, default=1)
    unit_price = Column(Float, nullable=False)

    order = relationship("Order", back_populates="items")
    medicine = relationship("Medicine")

class Medicine(Base):
    __tablename__ = "medicines"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    active_substance = Column(String)
    price = Column(Float)
    is_prescription_required = Column(Boolean, default=False)
    manufacturer = Column(String)
    stock = Column(Integer, default=15) # НОВЕ ПОЛЕ: Залишок на складі