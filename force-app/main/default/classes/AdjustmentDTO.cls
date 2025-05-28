public with sharing class AdjustmentDTO {
    public order__c order {get;set;}
    public List<order_item__c> orderItems {get;set;}
    public promotion__c promotion {get;set;}
    public coupon__c coupon {get;set;}

    public AdjustmentDTO(){
        this.order = null;
        this.orderItems = new List<order_item__c>();
        this.promotion = null;
        this.coupon = null;
    }

    public AdjustmentDTO(order__c order, List<order_item__c> orderItems, promotion__c promotion, coupon__c coupon) {
        this.order = order;
        this.orderItems = orderItems;
        this.promotion = promotion;
        this.coupon = coupon;
    }

}