public with sharing class OrderItemService {

    public static void insertOrderItems(List<OrderResponseWrapper.Item> items, Id orderId) {
        if (!OrderItem.SObjectType.getDescribe().isCreateable()) {
            throw new SecurityException('OrderItem object not creatable');
        }
        if (!Product2.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Product2 object not accessible');
        }

        Set<String> skuSet = new Set<String>();
        for (OrderResponseWrapper.Item item : items) {
            if (String.isBlank(item.sku)) {
                throw new IllegalArgumentException('SKU cannot be blank');
            }
            skuSet.add(item.sku);
        }

        List<Product2> products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :skuSet];

        if (products.size() != skuSet.size()) {
            throw new IllegalArgumentException('One or more SKUs are invalid');
        }

        Map<String, Id> skuToIdMap = new Map<String, Id>();
        for (Product2 product : products) {
            skuToIdMap.put(product.StockKeepingUnit, product.Id);
        }

        List<order_item__c> orderItems = new List<order_item__c>();

        for (OrderResponseWrapper.Item item : items) {
            order_item__c orderItem = new order_item__c();
            orderItem.orderId__c = orderId;
            orderItem.Product2Id__c = skuToIdMap.get(item.sku);
            orderItem.Name = item.productName;
            orderItem.quantity__c = item.quantity;
            orderItem.unit_price__c = item.unitPrice;
            orderItem.total_price__c = item.totalPrice;
            orderItem.description__c = item.description;
            orderItems.add(orderItem);
        }

        Database.SaveResult[] saveResults = Database.insert(orderItems, false);

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error creating OrderItem: ' + err.getMessage());
                    throw new DmlException('Error creating OrderItem: ' + err.getMessage());
                }
            }
        }
    }
}
