public with sharing class AdjustmentDTO {
    public order__c order {get;set;}
    public List<order_item__c> orderItems {get;set;}
    public promotion__c promotion {get;set;}
    public coupon__c coupon {get;set;}
    public Map<Id,List<order_item__c>> orderItemsByProductId {get;set;} 

    public AdjustmentDTO(){
        this.order = null;
        this.orderItems = new List<order_item__c>();
        this.promotion = null;
        this.coupon = null;
        this.orderItemsByProductId = new Map<Id,List<order_item__c>>();
    }

    public AdjustmentDTO(order__c order, List<order_item__c> orderItems, promotion__c promotion, coupon__c coupon) {
        this.order = order;
        this.orderItems = orderItems;
        this.promotion = promotion;
        this.coupon = coupon;
        this.orderItemsByProductId = getOrderItemsByProductId(orderItems);
    }

    public Map<Id,List<order_item__c>> getOrderItemsByProductId(List<order_item__c> items){
        Map<Id,List<order_item__c>> itemsByProductId = new Map<Id,List<order_item__c>>();
        for(order_item__c item : items){
            if(!itemsByProductId.containsKey(item.Product2Id__c)){
                itemsByProductId.put(item.Product2Id__c, new List<order_item__c>());
            }
            itemsByProductId.get(item.Product2Id__c).add(item);
        }
        return itemsByProductId;
    }

}