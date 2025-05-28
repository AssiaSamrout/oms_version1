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
                                                        unit_price__c=20.0,
                                                        total_price__c=20.0);
            orderItems.add(orderItem);
        }
        insert orderItems;
        return orderItems;
    }

    public static List<Product2> createProducts(){
         // Create a test product
        List<Product2> products = new List<Product2>();
        for(Integer i=0;i<5;i++){
            Product2 prod = new Product2(Name='Test Product '+ i,
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
            MinAmount__c = null,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = true,
            usageLimit__c = 10,
            usageCount__c = 0,
            Type__c= 'Percentage',
            Percentage__c = 10.0,
            DiscountValue__c = null,
            Description__c = 'description of promotion 1'
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
            DiscountValue__c = null,
            Description__c = 'description of promotion 2'
        );
        promotions.add(promotion2);
        
        insert promotions;
        List<promotion__c> queriedPromotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, isAutomatic__c,Percentage__c, Type__c,usageLimit__c, usageCount__c,DiscountValue__c,productId__c, Description__c
        FROM promotion__c
        WHERE Id IN :promotions
    ];
        return queriedPromotions;
    }

    public static List<promotion__c> makeItemLevelPromotion() {
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Test Product 0' LIMIT 1];
        
        // Create a test promotion for item level
        List<promotion__c> promotions = new List<promotion__c>();

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='promotion__c' AND Name = 'item_level' LIMIT 1];
        promotion__c promotion1 = new promotion__c (
            Name='Item level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 50.0,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = true,
            usageLimit__c = 5,
            usageCount__c = 0,
            Type__c= 'Percentage',
            Percentage__c = 15.0,
            DiscountValue__c = null,
            Description__c = 'description of item level promotion 1',
            productId__c = product.Id
        );
        
        promotions.add(promotion1);
        
        insert promotions;

        List<promotion__c> queriedPromotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, isAutomatic__c,Percentage__c, Type__c,usageLimit__c, usageCount__c,DiscountValue__c,
        productId__c, Description__c
        FROM promotion__c
        WHERE Id IN :promotions];

        return queriedPromotions;
    }

    public static coupon__c createValidCoupon(promotion__c promotion){
        coupon__c coupon = new coupon__c(
            PromotionId__c = promotion.Id,
            Name = 'Test Coupon',
            Code__c = 'TESTCOUPON',
            IsActive__c = true,
            UsageLimit__c = 100,
            UsageCount__c = 0,
            Expiration_date__c = Date.today().addDays(30)
        );

        insert coupon;
        return coupon;
    }
}