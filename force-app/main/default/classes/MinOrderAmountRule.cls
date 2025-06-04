public with sharing class MinOrderAmountRule implements IPromotionRule{
    /*
        * This method checks if the order is eligible for a promotion based on the minimum order amount rule.
        * It verifies if the order's SubTotal__c meets the minimum amount specified in the promotion.
        * It is used for order level promotions where a minimum order amount is required.
        *
        * @param order The order to check for eligibility.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items (not used in this rule).
        * @param promotion The promotion to check against the order.
        * @return true if the order is eligible for the promotion, false otherwise.
    */
    public Boolean isEligible(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion) {
        if (order.SubTotal__c == null) {
            throw new IllegalArgumentException('Order amount cannot be null');
        }
        return promotion.MinAmount__c == null || order.SubTotal__c >= promotion.MinAmount__c;
    }
}