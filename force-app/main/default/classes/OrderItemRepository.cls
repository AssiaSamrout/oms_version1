public with sharing class OrderItemRepository {
    
    public static Database.SaveResult[] insertItems(List<order_item__c> items, Boolean allOrNone) {
        return Database.insert(items, allOrNone);
    }

}