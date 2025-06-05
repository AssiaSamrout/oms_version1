@isTest
public with sharing class PostCheckoutProcessorTest {
    //create normal flow test
    @isTest
    public static void testPostCheckout(){
        Account account = new Account(Name='Test Account');
        insert account;
        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = new Order__c(AccountId__c=account.Id, Status__c='Draft',SubTotal__c=200.0);
        insert order;
        List<Order_item__c> orderItems = new List<Order_item__c>();
        for(Product2 prod : products){
            Order_item__c orderItem = new Order_item__c(OrderId__c=order.Id, 
                                                        Product2Id__c=prod.Id, 
                                                        Quantity__c=2, 
                                                        Unit_price__c=20.0,
                                                        Total_price__c=20.0);
            orderItems.add(orderItem);
        }
        insert orderItems;
        List<Promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        Coupon__c coupon = TestsSetUp.createValidCoupon(promotions[1]);
        //list of coupon codes
        List<String> couponCodes = new List<String>();
        couponCodes.add(coupon.Code__c);
        Test.startTest();
        PromotionsCheckoutResult result = PostCheckoutProcessor.processPostCheckout(order, orderItems, couponCodes);
        System.debug('Order after processing: ' + order);
        Test.stopTest();
        // Verify order updates
        Order__c updatedOrder = [SELECT Id, NetTotal__c, Total_order_adjustments__c FROM Order__c WHERE Id = :order.Id];
        List<Order_adjustment__c> adjustments = [SELECT Id, Amount__c, Description__c FROM Order_adjustment__c WHERE orderName__c = :order.Id];
        System.debug('Adjustments: ' + adjustments);
        System.debug('result of promotion checkout inside the test:'+result);
        System.debug('faliure reasons of the result: ' + result.failureReasons);
        System.debug('Updated Order: ' + updatedOrder);
        System.assertEquals(true, result.isValid, 'The checkout result should be valid');
        System.assertEquals(140.0, updatedOrder.NetTotal__c, 'NetTotal should be updated to 140.0 since 20% and 10% discount applied');
    }

    //test with item level promotions
    @isTest
    public static void testPostCheckoutWithItemLevelPromotion(){
        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = TestsSetUp.createOrder();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        List<Promotion__c> promotions = TestsSetUp.makeItemLevelPromotion();
        Coupon__c coupon = TestsSetUp.createValidCoupon(promotions[0]);
        //list of coupon codes
        List<String> couponCodes = new List<String>();
            couponCodes.add(coupon.Code__c);
       
    }


    @isTest
    public static void testprocessPostCheckoutfailure(){
        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = TestsSetUp.createOrder();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        List<Promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
         Coupon__c coupon = TestsSetUp.createValidCoupon(promotions[1]);
        //list of coupon codes
        List<String> couponCodes = new List<String>();
            couponCodes.add(coupon.Code__c);
        

        Test.startTest();
       PromotionsCheckoutResult result = PostCheckoutProcessor.processPostCheckout(order, orderItems, couponCodes);
        System.debug('Order after processing: ' + order);
        Test.stopTest();
        // Verify order updates
        Order__c updatedOrder = [SELECT Id, NetTotal__c, Total_order_adjustments__c FROM Order__c WHERE Id = :order.Id];
        List<Order_adjustment__c> adjustments = [SELECT Id, Amount__c,Description__c FROM Order_adjustment__c WHERE orderName__c = :order.Id];
        System.debug('Adjustments: ' + adjustments);
        System.debug('result of promotion checkout inside the failure test:'+result);
        System.debug('faliure reasons of the result: ' + result.failureReasons);
        System.debug('Updated Order: ' + updatedOrder);

        System.assertEquals(false, result.isValid, 'The checkout result should be valid');
        System.assertEquals(null, updatedOrder.NetTotal__c, 'NetTotal should be updated');
    }

    

}