public with sharing class AdjustmentDTO {
    public Order__c order {get;set;}
    public List<Order_item__c> orderItems {get;set;}
    public Promotion__c promotion {get;set;}
    public Coupon__c coupon {get;set;}
    public Map<Id,List<Order_item__c>> orderItemsByProductId {get;set;} 

    public AdjustmentDTO(){
        this.order = null;
        this.orderItems = new List<Order_item__c>();
        this.promotion = null;
        this.coupon = null;
        this.orderItemsByProductId = new Map<Id,List<Order_item__c>>();
    }

    public AdjustmentDTO(Order__c order, List<Order_item__c> orderItems, Promotion__c promotion, Coupon__c coupon) {
        this.order = order;
        this.orderItems = orderItems;
        this.promotion = promotion;
        this.coupon = coupon;
        this.orderItemsByProductId = getOrderItemsByProductId(orderItems);
    }

    public Map<Id,List<Order_item__c>> getOrderItemsByProductId(List<Order_item__c> items){
        Map<Id,List<Order_item__c>> itemsByProductId = new Map<Id,List<Order_item__c>>();
        for(Order_item__c item : items){
            if(!itemsByProductId.containsKey(item.Product2Id__c)){
                itemsByProductId.put(item.Product2Id__c, new List<Order_item__c>());
            }
            itemsByProductId.get(item.Product2Id__c).add(item);
        }
        return itemsByProductId;
    }

}