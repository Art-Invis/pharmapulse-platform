from abc import ABC, abstractmethod

class ILoyaltyStrategy(ABC):
    @abstractmethod
    def calculate_discount(self, base_price: float, is_prescription: bool) -> float:
        """Повертає суму знижки для конкретного товару"""
        pass

    @abstractmethod
    def is_delivery_free(self) -> bool:
        """Визначає, чи є доставка кур'єром безкоштовною"""
        pass

class StandardLoyalty(ILoyaltyStrategy):
    def calculate_discount(self, base_price: float, is_prescription: bool) -> float:
        return 0.0

    def is_delivery_free(self) -> bool:
        return False

class SocialLoyalty(ILoyaltyStrategy):
    def __init__(self, social_discount_rate: float = 0.15):
        self.social_discount_rate = social_discount_rate

    def calculate_discount(self, base_price: float, is_prescription: bool) -> float:
        # Соціальна знижка 15% нараховується лише на рецептурні засоби
        if is_prescription:
            return round(base_price * self.social_discount_rate, 2)
        return 0.0

    def is_delivery_free(self) -> bool:
        return False

class PremiumLoyalty(ILoyaltyStrategy):
    def __init__(self, premium_discount_rate: float = 0.10):
        self.premium_discount_rate = premium_discount_rate

    def calculate_discount(self, base_price: float, is_prescription: bool) -> float:
        # Преміум отримує 10% на будь-яку продукцію
        return round(base_price * self.premium_discount_rate, 2)

    def is_delivery_free(self) -> bool:
        # Безкоштовна доставка для клієнтів із карткою Premium
        return True

def get_loyalty_strategy(tier: str) -> ILoyaltyStrategy:
    tier_map = {
        "Social": SocialLoyalty(),
        "Premium": PremiumLoyalty(),
        "Standard": StandardLoyalty()
    }
    return tier_map.get(tier, StandardLoyalty())