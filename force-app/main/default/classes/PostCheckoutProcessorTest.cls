@isTest
public with sharing class PostCheckoutProcessorTest {
    @isTest
    public static void testprocessPostCheckout(){
        List<Product2> products = TestsSetUp.createProducts();
        order__c order = TestsSetUp.createOrder();
        List<order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
         coupon__c coupon = TestsSetUp.createValidCoupon(promotions[1]);
        //list of coupon codes
        List<String> couponCodes = new List<String>();
            couponCodes.add(coupon.Code__c);
        

        Test.startTest();
        PostCheckoutProcessor.processPostCheckout(order, orderItems, couponCodes);
        System.debug('Order after processing: ' + order);
        Test.stopTest();
        // Verify order updates
        order__c updatedOrder = [SELECT Id, NetTotal__c, Total_order_adjustments__c FROM order__c WHERE Id = :order.Id];
        List<order_adjustment__c> adjustments = [SELECT Id, Amount__c,Description__c FROM order_adjustment__c WHERE orderName__c = :order.Id];
        System.debug('Adjustments: ' + adjustments);

        System.debug('Updated Order: ' + updatedOrder);
        System.assertNotEquals(null, updatedOrder.NetTotal__c, 'NetTotal should be updated');
    }
}