@isTest
public with sharing class PostCheckoutProcessorTest {
    @isTest
    public static void testprocessPostCheckout(){
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
        System.debug('result:'+result);
        System.debug('Updated Order: ' + updatedOrder);
        System.assertEquals(true, result.isValid, 'The checkout result should be valid');
        System.assertNotEquals(null, updatedOrder.NetTotal__c, 'NetTotal should be updated');
    }
}