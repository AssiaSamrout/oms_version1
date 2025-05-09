@isTest
public with sharing class OrderItemCreationTest {
    @TestSetup
    static void makeData(){
        order__c order = new order__c();
        order.AccountId__c = '001XXXXXXXXXXXXXXX';  
        order.status__c = 'Draft';
        order.billing_street__c = '123 Main St';
        order.billing_city__c = 'San Francisco';
        order.billing_country__c = 'USA';
        order.billing_email__c = 'dkdcmkdkd@gmail.com';
        order.order_amount__c = 1000.00;
        order.PO_number__c = 'PO123456';
        order.PO_date__c = Date.today();
        order.order_start_date__c = Date.today();
        insert order;

        Product2 product = new Product2();
        product.Name = 'Test Product';  
        product.StockKeepingUnit = 'SKU123';
        product.IsActive = true;
        insert product;

    }

    @isTest
    static void testInsertOrderItemsNormalFlow(){
        List<OrderResponseWrapper.Item> items = new List<OrderResponseWrapper.Item>();
        for(Integer i = 0; i < 5; i++){
            OrderResponseWrapper.Item item = new OrderResponseWrapper.Item();
            item.sku = 'SKU'+(i+1);
            item.productName = 'Test Product'+(i+1);
            item.quantity = 1;
            item.unitPrice = 100.00;
            item.totalPrice = 100.00;
            item.description = 'Test Description';
            items.add(item);
        }

        Id orderId = [Select Id from order__c limit 1].Id;
        Test.startTest();
        OrderItemService.insertOrderItems(items, orderId);
        Test.stopTest();
        List<order_item__c> orderItems = [SELECT Id, Product2Id__c, Name, quantity__c, unit_price__c, total_price__c, description__c FROM order_item__c WHERE orderId__c = :orderId];
        System.assertEquals(5, orderItems.size(), 'Order items count should be 5');
        for(order_item__c orderItem : orderItems){
            System.assertNotEquals(null, orderItem.Product2Id__c, 'Product2Id should not be null');
            System.assertNotEquals(null, orderItem.Name, 'Name should not be null');
            System.assertNotEquals(null, orderItem.quantity__c, 'Quantity should not be null');
            System.assertNotEquals(null, orderItem.unit_price__c, 'Unit Price should not be null');
            System.assertNotEquals(null, orderItem.total_price__c, 'Total Price should not be null');
            System.assertNotEquals(null, orderItem.description__c, 'Description should not be null');
        }
    }

    @isTest
    static void testInsertOrderItemsInvalidSKU(){
        OrderResponseWrapper.Item item = new OrderResponseWrapper.Item();
        item.sku = '';
        item.productName = 'Test Product';
        item.quantity = 1;
        item.unitPrice = 100.00;
        item.totalPrice = 100.00;
        item.description = 'Test Description';

        Id orderId = [Select Id from order__c limit 1].Id;

        Test.startTest();
        try {
            OrderItemService.insertOrderItems(new List<OrderResponseWrapper.Item>{item}, orderId);
            System.assert(false, 'Expected IllegalArgumentException for blank SKU');
        } catch (IllegalArgumentException e) {
            System.assertEquals('SKU cannot be blank', e.getMessage());
        }
        Test.stopTest();
    
    }

}