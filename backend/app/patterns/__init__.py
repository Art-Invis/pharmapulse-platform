from app.patterns.strategy import (
    ILoyaltyStrategy,
    StandardLoyalty,
    SocialLoyalty,
    PremiumLoyalty,
    get_loyalty_strategy,
)
from app.patterns.factory import (
    INotifier,
    EmailNotifier,
    SmsNotifier,
    NotificationFactory,
    EmailNotificationFactory,
    SmsNotificationFactory,
)
from app.patterns.observer import (
    IOrderObserver,
    OrderEventManager,
    CustomerNotificationDispatcher,
    PharmacyStockSynchronizer,
)
from app.patterns.builder import IOrderBuilder, OrderBuilder