@isTest
public with sharing class CouponControllerTest {

    public static Map<String,Object> mockCartPayload() {
        Map<String,Object> payload = new Map<String,Object>();

        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = TestsSetUp.createOrder();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);

        List<Promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        Promotion__c promoToUse = promotions[0];

        Coupon__c coupon = TestsSetUp.createValidCoupon(promoToUse);
        Account account = [SELECT Id FROM Account WHERE Name= 'Test Account' LIMIT 1][0];
        payload.put('subtotal', order.SubTotal__c);
        payload.put('accountId', account.Id); 
        payload.put('shippingMethod', 'Standard');
        payload.put('cartDate', Date.today());
        payload.put('couponCode', coupon.Code__c);
        payload.put('items', orderItems);
        return payload; 
    }

    public static RestRequest buildrestReq(String body) {
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestURI = '/coupons';
        req.requestBody = Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json');
        return req;
    }

    @isTest
    static void testCouponControllerEmptyPayload() {
        RestContext.request = buildrestReq('');
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        CouponController.validateCoupon();
        Test.stopTest();
        System.assertEquals(400, res.statusCode, 'Response should be 400 for empty payload');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Request body is empty'), 'Response should contain error message for empty request body');
    }

    @isTest
    public static void testCouponControllerValidPayload() {
        Map<String,Object> payload = mockCartPayload();
        RestContext.request = buildrestReq(JSON.serialize(payload));
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        CouponController.validateCoupon();
        Test.stopTest();
        System.assertEquals(200, res.statusCode, 'Response should be 200 for valid payload');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('isValid'), 'Response should contain isValid field');
        System.assert(responseBody.contains('Coupon is eligible'), 'Response should contain success message');
    }

    @isTest
    public static void testCouponControllerInvalidPayload() {
        Map<String,Object> payload = mockCartPayload();
        payload.put('couponCode', 'INVALID_CODE');
        RestContext.request = buildrestReq(JSON.serialize(payload));
        
        RestResponse res = new RestResponse(); 
        RestContext.response = res;

        Test.startTest();
        CouponController.validateCoupon(); 
        Test.stopTest();
        
        String responseBody = res.responseBody.toString();
        System.debug('INSIDE TEST COUPON CONTROLLER, INVALID PAYLOAD:' + responseBody);
        System.assert(responseBody.contains('isValid'), 'Response should contain isValid field');
        System.assertEquals(400, res.statusCode, 'Response should be 400 for invalid coupon code');
    }

    @isTest
    public static void testCouponControllerBadJson() {
        String badJson = '{invalidJson: }'; 
        RestContext.request = buildrestReq(badJson);
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        CouponController.validateCoupon();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Should return 400 for bad JSON');
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('Invalid or malformed JSON.'), 'Should return error message for bad JSON');
    }
}
