@isTest
public with sharing class TestsSetUp {

     public static order__c createOrder() {
        // Create a test account
        Account account = new Account(Name='Test Account');
        insert account;

        // Create a test order
        order__c order = new order__c(AccountId__c=account.Id, status__c='Draft',SubTotal__c=100.0);
        insert order;
        return order;
    }

    public static List<order_item__c> createOrderItems(order__c order, List<Product2> products) {
        // Create test order items
        List<order_item__c> orderItems = new List<order_item__c>();
        for(Product2 prod : products){
            order_item__c orderItem = new order_item__c(orderId__c=order.Id, 
                                                        Product2Id__c=prod.Id, 
                                                        quantity__c=1, 
                                                        unit_price__c=20.0);
            orderItems.add(orderItem);
        }
        insert orderItems;
        return orderItems;
    }

    public static List<Product2> createProducts(){
         // Create a test product
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<5;i++){
            Product2 prod = new Product2(Name='Test Product '+1 ,
                                        StockKeepingUnit='SKU'+ i,
                                        IsActive=true);
            products.add(prod);
        }
        insert products;

        return products;
        
    }

    public static List<promotion__c> makeDataForPromotionRule() {
        
        // Create a test promotion

        List<promotion__c> promotions = new List<promotion__c>();

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='promotion__c' AND Name = 'order_level' LIMIT 1];
        promotion__c promotion1 = new promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 100.0,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = true,
            usageLimit__c = 10,
            usageCount__c = 0,
            Type__c= 'Percentage',
            Percentage__c = 10.0,
            DiscountValue__c = null
        );
        
        promotions.add(promotion1);
        promotion__c promotion2 = new promotion__c(
            Name = 'order level promot without min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 200.0,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = false,
            usageLimit__c = 10,
            usageCount__c = 0,
            Type__c= 'Percentage',
            Percentage__c = 20.0,
            DiscountValue__c = null
        );
        promotions.add(promotion2);
        
        insert promotions;
        List<promotion__c> queriedPromotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, isAutomatic__c,Percentage__c, Type__c,usageLimit__c, usageCount__c,DiscountValue__c
        FROM promotion__c
        WHERE Id IN :promotions
    ];
        return queriedPromotions;
    }
}