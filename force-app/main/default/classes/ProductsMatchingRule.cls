public with sharing class ProductsMatchingRule implements IPromotionRule {

    /*
        * This method checks if the order is eligible for a promotion based on the product matching rule.
        * It verifies if the promotion's productId__c matches any of the order items' Product2Id__c.
        * It is for item level promotions where the promotion is applicable to specific products.
        *
        * @param order The order to check for eligibility.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items.
        * @param promotion The promotion to check against the order.
        * @return true if the order is eligible for the promotion, false otherwise.
    */
    public Boolean isEligible(order__c order, Map<Id,List<order_item__c>> orderItemsByProduct, promotion__c promotion) {
        if (promotion.productId__c == null) {
            return false;
        }

        List<order_item__c> items = orderItemsByProduct.get(promotion.productId__c);
        if (items != null && !items.isEmpty()) {
            return true; 
        }

        return false;
    }



    // public Boolean isEligible(order__c order, Map<Id,List<order_item__c>> orderItemsByProduct, promotion__c promotion) {
    //     if (promotion.productId__c == null) {
    //         return false;
    //     }

    //     for (order_item__c item : orderItems) {
    //         if (item.Product2Id__c == promotion.productId__c) {
    //             return true; 
    //         }
    //     }

    //     return false; // No match found
    // }
    
}