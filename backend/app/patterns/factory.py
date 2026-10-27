from abc import ABC, abstractmethod

class INotifier(ABC):
    @abstractmethod
    def send(self, recipient: str, message: str) -> bool:
        pass

class EmailNotifier(INotifier):
    def send(self, recipient: str, message: str) -> bool:
        print(f"[Email Notification] Відправлено на {recipient}: {message}")
        return True

class SmsNotifier(INotifier):
    def send(self, recipient: str, message: str) -> bool:
        print(f"[SMS Gateway] Надіслано на номер {recipient}: {message}")
        return True

class NotificationFactory(ABC):
    @abstractmethod
    def create_notifier(self) -> INotifier:
        pass

    def dispatch(self, recipient: str, msg: str) -> bool:
        notifier = self.create_notifier()
        return notifier.send(recipient, msg)

class EmailNotificationFactory(NotificationFactory):
    def create_notifier(self) -> INotifier:
        return EmailNotifier()

class SmsNotificationFactory(NotificationFactory):
    def create_notifier(self) -> INotifier:
        return SmsNotifier()