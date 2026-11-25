from abc import ABC, abstractmethod
from typing import List, Optional
from app.models.entities import Order, OrderItem, Medicine, Prescription, PharmacyBranch, User
from app.patterns.strategy import ILoyaltyStrategy

class IOrderBuilder(ABC):
    @abstractmethod
    def reset(self) -> None:
        pass

    @abstractmethod
    def set_customer(self, user: User) -> "IOrderBuilder":
        pass

    @abstractmethod
    def add_item(self, medicine: Medicine, qty: int) -> "IOrderBuilder":
        pass

    @abstractmethod
    def set_delivery(self, delivery_type: str, address: Optional[str] = None, branch: Optional[PharmacyBranch] = None) -> "IOrderBuilder":
        pass

    @abstractmethod
    def attach_prescription(self, p: Prescription) -> "IOrderBuilder":
        pass

    @abstractmethod
    def apply_pricing(self, strategy: ILoyaltyStrategy) -> "IOrderBuilder":
        pass

    @abstractmethod
    def get_result(self) -> Order:
        pass

class OrderBuilder(IOrderBuilder):
    def __init__(self):
        self.reset()

    def reset(self) -> None:
        self._order = Order()
        self._items: List[OrderItem] = []
        self._medicines_cache: List[Medicine] = []

    def set_customer(self, user: User) -> "IOrderBuilder":
        self._order.user_id = user.id
        self._order.user = user
        return self

    def add_item(self, medicine: Medicine, qty: int) -> "IOrderBuilder":
        item = OrderItem(
            medicine_id=medicine.id,
            quantity=qty,
            unit_price=medicine.price
        )
        self._items.append(item)
        self._medicines_cache.append(medicine)
        return self

    def set_delivery(self, delivery_type: str, address: Optional[str] = None, branch: Optional[PharmacyBranch] = None) -> "IOrderBuilder":
        self._order.delivery_type = delivery_type
        self._order.delivery_address = address
        if branch:
            self._order.branch_id = branch.id
            self._order.branch = branch
        return self

    def attach_prescription(self, p: Prescription) -> "IOrderBuilder":
        if p.validate():
            self._order.prescription_id = p.id
            self._order.prescription = p
        return self

    def apply_pricing(self, strategy: ILoyaltyStrategy) -> "IOrderBuilder":
        raw_total = 0.0
        total_discount = 0.0

        for item, med in zip(self._items, self._medicines_cache):
            item_raw = item.unit_price * item.quantity
            raw_total += item_raw
            total_discount += strategy.calculate_discount(item_raw, med.is_prescription_required)

        # Вартість доставки
        delivery_cost = 0.0 if (self._order.delivery_type == "Pickup" or strategy.is_delivery_free()) else 50.0

        self._order.raw_total = round(raw_total, 2)
        self._order.final_price = round(max(0.0, raw_total - total_discount + delivery_cost), 2)
        return self

    def get_result(self) -> Order:
        # Перевірка наявності рецепта, якщо є хоча б один рецептурний препарат
        has_prescription_items = any(m.is_prescription_required for m in self._medicines_cache)
        if has_prescription_items and not self._order.prescription_id:
            raise ValueError("Для замовлення рецептурних медикаментів обов'язково потрібен рецепт!")

        self._order.items = self._items
        self._order.status = "Pending"
        result = self._order
        self.reset()
        return result