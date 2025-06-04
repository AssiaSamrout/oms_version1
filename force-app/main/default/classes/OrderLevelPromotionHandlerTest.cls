@isTest
public with sharing class OrderLevelPromotionHandlerTest {

    static AdjustmentDTO prepareDTO(Boolean eligiblePromo, Boolean withCoupon) {
        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = TestsSetUp.createOrder();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);

        List<Promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        Promotion__c promoToUse = promotions[0];

        Coupon__c coupon;
        if (withCoupon) {
         coupon = TestsSetUp.createValidCoupon(promoToUse);
        }else{
            coupon = null;
        }

        AdjustmentDTO dto = new AdjustmentDTO();
        dto.order = order;
        dto.orderItems = orderItems;
        dto.promotion = promoToUse;
        dto.coupon = withCoupon ? coupon : null;

        return dto;
    }

    
    @isTest
    static void testEligibilityAndDiscount(){

        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();

        Test.startTest();
         PromotionEligibilityResult promoEligibility = handler.evaluateEligibility(adjustmentDTO);
        Test.stopTest();

        System.assertEquals(true, promoEligibility.isEligible, 'Promotion should be eligible');
        System.assertEquals(0, promoEligibility.failureReasons.size(), 'No failure reasons should be present');

    }

    @isTest
    static void testIneligibleDiscount() {

        AdjustmentDTO adjustmentDTO = prepareDTO(false, true);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'order_level' LIMIT 1];
        Promotion__c promotion = new Promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 200.0,
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
        insert promotion;
        List<Promotion__c> queriedPromotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, isAutomatic__c,Percentage__c, Type__c,usageLimit__c, usageCount__c,DiscountValue__c
        FROM Promotion__c
        WHERE Id = :promotion.Id
    ];
        adjustmentDTO.promotion = queriedPromotions[0];
        
        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();

        Test.startTest();
        PromotionEligibilityResult promoEligibility = handler.evaluateEligibility(adjustmentDTO);
        Test.stopTest();

        System.assertEquals(false, promoEligibility.isEligible, 'Promotion should not be eligible');
        System.assertEquals(1, promoEligibility.failureReasons.size(), 'There should be one failure reason');
        System.assert(
    promoEligibility.failureReasons[0].contains('is not applicable on this order'),
    'Failure reason should contain the required message'
);
    }


    @isTest
    static void testCalculateDiscount() {

        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        
        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();

        Test.startTest();
        Decimal discount = handler.calculateDiscount(adjustmentDTO);
        Test.stopTest();

        System.assertEquals(10.0, discount, 'The discount should be 10.0 based on the promotion rule');
    }

    @isTest
    static void testGetAdjustments() {

        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        
        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();

        Test.startTest();
        List<Order_adjustment__c> adjustments = handler.getAdjustments(adjustmentDTO);
        Test.stopTest();

        System.assertEquals(1, adjustments.size(), 'There should be one adjustment created');
        System.assertEquals(adjustmentDTO.order.Id, adjustments[0].orderName__c, 'Adjustment should be linked to the correct order');
        System.assertEquals(adjustmentDTO.promotion.Id, adjustments[0].promotionName__c, 'Adjustment should be linked to the correct promotion');
    }

    @isTest
    static void testApplySideEffects(){
        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);

        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();
        Test.startTest();
        handler.applySideEffects(adjustmentDTO);
        Test.stopTest();
        System.assertNotEquals(null, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should not be null');
        System.assertEquals(10.0, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should equal the discount amount');
    }
    @isTest
    static void testApplySideEffectWithExistingAdjustments() {
        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        adjustmentDTO.order.Total_order_adjustments__c = 5.0; // Simulate existing adjustments

        OrderLevelPromotionHandler handler = new OrderLevelPromotionHandler();
        Test.startTest();
        handler.applySideEffects(adjustmentDTO);
        Test.stopTest();

        System.assertNotEquals(null, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should not be null');
        System.assertEquals(15.0, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should equal the existing amount plus the discount');
    }

}