public with sharing class FixedDiscountStrategy implements IDiscountStrategy {
    /*
        * This method calculates the discount for a fixed amount promotion.
        * It checks if the promotion's DiscountValue__c is set and valid.
        * It is used for promotions that provide a fixed discount amount.
        *
        * @param order The order to calculate the discount for.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items (not used in this strategy).
        * @param promotion The promotion to calculate the discount from.
        * @return The fixed discount value as specified in the promotion.
        * @throws IllegalArgumentException if the DiscountValue__c is null or negative, or if Percentage__c is set.
    */
    public Decimal calculateDiscount(order__c order, Map<Id,List<order_item__c>> orderItemsByProduct, promotion__c promotion) {
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