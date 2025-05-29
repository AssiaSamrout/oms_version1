public with sharing class ProductsMatchingRule implements IPromotionRule {

    public Boolean isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion) {
        if (promotion.productId__c == null) {
            return false;
        }

        for (order_item__c item : orderItems) {
            if (item.Product2Id__c == promotion.productId__c) {
                return true; 
            }
        }

        return false; // No match found
    }

    // public Boolean isEligible(PromotionEvaluationContext context) {
    //     if (context.promotion.productId__c == null) {
    //         return false;
    //     }

    //     List<order_item__c> items = context.orderItemsByPromotionId.get(context.promotion.productId__c);
    //     if (items != null && !items.isEmpty()) {
    //         return true; 
    //     }

    //     return false;
    // }
    
}