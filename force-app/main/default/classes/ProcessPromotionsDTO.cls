public with sharing class ProcessPromotionsDTO {
    public order__c order {get;set;}
    public List<order_item__c> orderItems {get;set;}
    public List<promotion__c> promotions {get;set;}
    public Map<Id,coupon__c> promoToCoupon {get;set;}
    public String promotionType {get;set;}
    
}