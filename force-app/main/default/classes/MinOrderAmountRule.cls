public with sharing class MinOrderAmountRule implements IPromotionRule{
    public Boolean isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion){
        if(order.SubTotal__c == null) {
            throw new IllegalArgumentException('Order amount cannot be null');
        }
        return promotion.MinAmount__c == null || order.SubTotal__c >= promotion.MinAmount__c;
    }
}