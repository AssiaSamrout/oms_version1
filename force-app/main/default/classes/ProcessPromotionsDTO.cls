public with sharing class ProcessPromotionsDTO {
    public Order__c order {get;set;}
    public List<Order_item__c> orderItems {get;set;}
    public List<Promotion__c> promotions {get;set;}
    public Map<Id,Coupon__c> promoToCoupon {get;set;}
    public String promotionType {get;set;}

    
    
}