public with sharing class FixedDiscountStrategy implements IDiscountStrategy {
    public Decimal calculateDiscount(order__c order, List<order_item__c> orderItems, promotion__c promotion) {
        if (promotion.DiscountValue__c == null) {
            throw new IllegalArgumentException('Discount value cannot be null');
        }
        if (promotion.Percentage__c != null) {
            throw new IllegalArgumentException('Percentage cannot be set for fixed discount strategy');
        }
        if (promotion.DiscountValue__c < 0) {
            throw new IllegalArgumentException('Discount value cannot be negative');
        }
        return promotion.DiscountValue__c;
    }
    
}