public with sharing class OrderItemRepository {
    /*     * This class provides methods to interact with the Order_item__c object.
           * It includes methods for inserting order items and retrieving order items by order ID.
     */
    public static Database.SaveResult[] insertItems(List<Order_item__c> items, Boolean allOrNone) {
        return Database.insert(items, allOrNone);
    }

    public static List<Order_item__c> getOrderItemsByOrderId(Id orderId) {

        if(!Order_item__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Order Item object not accessible');
        }
        if (orderId == null) {
            throw new IllegalArgumentException('Order ID cannot be null');
        }
        
        List<Order_item__c> orderItems = [SELECT Id, Name, quantity__c, total_price__c, unit_price__c, Product2Id__c
                                           FROM Order_item__c 
                                           WHERE orderId__c = :orderId];
        return orderItems;
    }

}