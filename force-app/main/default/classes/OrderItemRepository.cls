public with sharing class OrderItemRepository {
    
    public static Database.SaveResult[] insertItems(List<order_item__c> items, Boolean allOrNone) {
        return Database.insert(items, allOrNone);
    }

    public static List<order_item__c> getOrderItemsByOrderId(Id orderId) {

        if(!order_item__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Order Item object not accessible');
        }
        if (orderId == null) {
            throw new IllegalArgumentException('Order ID cannot be null');
        }
        
        List<order_item__c> orderItems = [SELECT Id, Name, quantity__c, total_price__c, unit_price__c, Product2Id__c
                                           FROM order_item__c 
                                           WHERE orderId__c = :orderId];
        return orderItems;
    }

}