from abc import ABC, abstractmethod
from typing import List
from app.models.entities import Order


class IOrderState(ABC):
    """Абстрактний інтерфейс стану замовлення (GoF State Pattern)."""

    @property
    @abstractmethod
    def name(self) -> str:
        pass

    @property
    @abstractmethod
    def allowed_transitions(self) -> List[str]:
        pass

    def transition_to(self, order: Order, new_status: str) -> None:
        if new_status == self.name:
            return
        if new_status not in self.allowed_transitions:
            if not self.allowed_transitions:
                raise ValueError(
                    f"Замовлення у фінальному статусі '{self.name}' не можна змінювати."
                )
            allowed = ", ".join(self.allowed_transitions)
            raise ValueError(
                f"Недопустимий перехід зі статусу '{self.name}' у '{new_status}'. "
                f"Дозволені переходи: {allowed}."
            )
        order.status = new_status


class PendingState(IOrderState):
    @property
    def name(self) -> str:
        return "Pending"

    @property
    def allowed_transitions(self) -> List[str]:
        return ["Processing", "Cancelled"]


class ProcessingState(IOrderState):
    @property
    def name(self) -> str:
        return "Processing"

    @property
    def allowed_transitions(self) -> List[str]:
        return ["Ready", "Cancelled"]


class ReadyState(IOrderState):
    @property
    def name(self) -> str:
        return "Ready"

    @property
    def allowed_transitions(self) -> List[str]:
        return ["Completed", "Cancelled"]


class CompletedState(IOrderState):
    @property
    def name(self) -> str:
        return "Completed"

    @property
    def allowed_transitions(self) -> List[str]:
        return []


class CancelledState(IOrderState):
    @property
    def name(self) -> str:
        return "Cancelled"

    @property
    def allowed_transitions(self) -> List[str]:
        return []


class OrderStateContext:
    """Контекст для керування життєвим циклом замовлення."""

    _STATE_MAP = {
        "Pending": PendingState,
        "Processing": ProcessingState,
        "Ready": ReadyState,
        "Completed": CompletedState,
        "Cancelled": CancelledState,
    }

    def __init__(self, order: Order):
        self.order = order
        state_cls = self._STATE_MAP.get(order.status)
        if not state_cls:
            raise ValueError(f"Невідомий поточний статус замовлення: '{order.status}'")
        self._state: IOrderState = state_cls()

    def change_status(self, new_status: str) -> None:
        if new_status not in self._STATE_MAP:
            raise ValueError(f"Невідомий цільовий статус: '{new_status}'")
        self._state.transition_to(self.order, new_status)
        self._state = self._STATE_MAP[new_status]()