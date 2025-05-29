public with sharing class MinOrderAmountRule implements IPromotionRule{
    public Boolean isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion){
        if(order.SubTotal__c == null) {
            throw new IllegalArgumentException('Order amount cannot be null');
        }
        return promotion.MinAmount__c == null || order.SubTotal__c >= promotion.MinAmount__c;
    }
    // public Boolean isEligible(PromotionEvaluationContext context) {
    //     if (context.order.SubTotal__c == null) {
    //         throw new IllegalArgumentException('Order amount cannot be null');
    //     }
    //     return context.promotion.MinAmount__c == null || context.order.SubTotal__c >= context.promotion.MinAmount__c;
    // }
}