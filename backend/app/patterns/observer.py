from abc import ABC, abstractmethod
from typing import List

from app.models.entities import Order, PharmacyBranch, Medicine 
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
        # Патерн Observer: Відслідковуємо скасування замовлення і повертаємо товар на склад
        if event_type == "order_cancelled":
            
            # БЕЗПЕЧНЕ ОТРИМАННЯ СЕСІЇ (працює і з yield, і з return)
            session_obj = DatabaseConnection.get_instance().get_session()
            db = next(session_obj) if hasattr(session_obj, '__next__') else session_obj
            
            try:
                for item in order.items:
                    # Шукаємо препарат у базі та повертаємо йому кількість
                    med = db.query(Medicine).filter(Medicine.id == item.medicine_id).first()
                    if med:
                        med.stock += item.quantity
                db.commit()
                print(f"[Stock Sync] Замовлення #{order.id} скасовано. Залишки повернуто на склад.")
            except Exception as e:
                db.rollback()
                print(f"[Stock Sync Error] Помилка повернення залишків: {e}")
            finally:
                db.close()