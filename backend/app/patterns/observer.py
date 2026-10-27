from abc import ABC, abstractmethod
from typing import List
from app.models.entities import Order, PharmacyBranch, pharmacy_stocks
from app.patterns.factory import EmailNotificationFactory, SmsNotificationFactory
from app.core.database import DatabaseConnection

class IOrderObserver(ABC):
    @abstractmethod
    def update(self, order: Order, event_type: str) -> None:
        pass

class OrderEventManager:
    def __init__(self):
        self._observers: List[IOrderObserver] = []

    def subscribe(self, observer: IOrderObserver) -> None:
        if observer not in self._observers:
            self._observers.append(observer)

    def unsubscribe(self, observer: IOrderObserver) -> None:
        if observer in self._observers:
            self._observers.remove(observer)

    def notify_observers(self, order: Order, event_type: str) -> None:
        for observer in self._observers:
            observer.update(order, event_type)

class CustomerNotificationDispatcher(IOrderObserver):
    def __init__(self, prefer_sms: bool = False):
        self.factory = SmsNotificationFactory() if prefer_sms else EmailNotificationFactory()

    def update(self, order: Order, event_type: str) -> None:
        recipient = order.user.phone if isinstance(self.factory, SmsNotificationFactory) else order.user.email
        message = f"Замовлення #{order.id}: статус змінено на '{order.status}' (Подія: {event_type})."
        self.factory.dispatch(recipient, message)

class PharmacyStockSynchronizer(IOrderObserver):
    def update(self, order: Order, event_type: str) -> None:
        # Списання виконується, коли статус переходить у комплектацію/виконання
        if event_type in ["order_completed", "order_processing"] and order.branch_id:
            db = DatabaseConnection.get_instance().get_session()
            try:
                for item in order.items:
                    # Оновлюємо кількість залишку в таблиці pharmacy_stocks
                    stmt = (
                        pharmacy_stocks.update()
                        .where(
                            pharmacy_stocks.c.pharmacy_id == order.branch_id,
                            pharmacy_stocks.c.medicine_id == item.medicine_id
                        )
                        .values(quantity=pharmacy_stocks.c.quantity - item.quantity)
                    )
                    db.execute(stmt)
                db.commit()
                print(f"[Stock Sync] Списано залишки для замовлення #{order.id} на філії #{order.branch_id}")
            except Exception as e:
                db.rollback()
                print(f"[Stock Sync Error] Помилка коригування залишків: {e}")
            finally:
                db.close()