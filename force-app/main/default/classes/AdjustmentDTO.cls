public with sharing class AdjustmentDTO {
    public Order__c order {get;set;}
    public List<Order_item__c> orderItems {get;set;}
    public Promotion__c promotion {get;set;}
    public Coupon__c coupon {get;set;}
    public Map<Id,List<Order_item__c>> orderItemsByProductId {get;set;} 
    public Map<String,List<ItemDTO>> itemsByProductId {get;set;}

    public AdjustmentDTO(){
        this.order = null;
        this.orderItems = new List<Order_item__c>();
        this.promotion = null;
        this.coupon = null;
        this.orderItemsByProductId = new Map<Id,List<Order_item__c>>();
        this.itemsByProductId = new Map<String,List<ItemDTO>>();
    }

    public AdjustmentDTO(Order__c order, List<Order_item__c> orderItems, Promotion__c promotion, Coupon__c coupon) {
        this.order = order;
        this.orderItems = orderItems;
        this.promotion = promotion;
        this.coupon = coupon;
        this.orderItemsByProductId = getOrderItemsByProductId(orderItems);
        this.itemsByProductId = getItemsByProductId(orderItems);
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

    public Map<String,List<ItemDTO>> getItemsByProductId(List<Order_item__c> items){
        Map<String,List<ItemDTO>> itemsByProductId = new Map<String,List<ItemDTO>>();
        
        for(Order_item__c item : items){
            if(!itemsByProductId.containsKey(item.Product2Id__c)){
                itemsByProductId.put(item.Product2Id__c, new List<ItemDTO>());
            }
            //working on default constructor for ItemDTO
            ItemDTO itemDTO = new ItemDTO(); // Assuming ItemDTO has a default constructor
            itemDTO.productId = item.Product2Id__c;
            itemDTO.quantity = item.Quantity__c;
            itemDTO.unitPrice = item.Unit_price__c;
            itemDTO.totalPrice = item.Total_price__c;
            itemDTO.description = item.Description__c;
            itemDTO.size = item.Size__c;
            itemDTO.color = item.Color__c;

            itemsByProductId.get(item.Product2Id__c).add(itemDTO);
            //itemsByProductId.get(item.Product2Id__c).add(new ItemDTO(item));
        }
        return itemsByProductId;
    }

}