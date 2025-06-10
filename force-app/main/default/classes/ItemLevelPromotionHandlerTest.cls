@isTest
public with sharing class ItemLevelPromotionHandlerTest {
    static AdjustmentDTO prepareDTO(Boolean eligiblePromo, Boolean withCoupon) {
        List<Product2> products = TestsSetUp.createProducts();
        Order__c order = TestsSetUp.createOrder();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);

        List<Promotion__c> promotions = TestsSetUp.makeItemLevelPromotion();
        Promotion__c promoToUse = promotions[0];

        coupon__c coupon;
        if (withCoupon) {
            coupon = TestsSetUp.createValidCoupon(promoToUse);
        } else {
            coupon = null;
        }

        AdjustmentDTO dto = new AdjustmentDTO(order, orderItems,promoToUse,withCoupon ? coupon : null);
       /* dto.order = order;
        dto.orderItems = orderItems;
        dto.promotion = promoToUse;
        dto.coupon = withCoupon ? coupon : null;*/

        return dto;
    }

    @isTest
    static void testEligibilityAndDiscount(){
        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        ItemLevelPromotionHandler handler = new ItemLevelPromotionHandler();

        Test.startTest();
        PromotionEligibilityResult promoEligibility = handler.evaluateEligibility(adjustmentDTO);
        Test.stopTest();
		System.debug('INSIDE TEST ELIGIBLITY AND DISCOUNT TEST:'+promoEligibility);
        System.assertEquals(true, promoEligibility.isEligible, 'Promotion should be eligible');
        System.assertEquals(0, promoEligibility.failureReasons.size(), 'No failure reasons should be present');
    }

    @isTest
    static void testIneligibleDiscount() {
        AdjustmentDTO adjustmentDTO = prepareDTO(false, true);
        Product2 prod = new Product2(Name='Test Product '+ 6,
                                        StockKeepingUnit='SKU'+ 6,
                                        IsActive=true);
        insert prod;
        System.debug('INSIDE TEST INELIHIBLE DISCOUNT PRODUCT ID: ' + prod.Id);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'item_level' LIMIT 1];
        Promotion__c promotion = new Promotion__c (
            Name='Item level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = null,
            ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),
            IsAutomatic__c = true,
            UsageLimit__c = 10,
            UsageCount__c = 0,
            Type__c= 'Percentage',
            Percentage__c = 10.0,
            DiscountValue__c = null,
            productId__c = prod.Id,
            Description__c = 'description of item level promotion 2'
        );
        insert promotion;
        List<Promotion__c> queriedPromotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, IsAutomatic__c,Percentage__c, Type__c,UsageLimit__c, UsageCount__c,DiscountValue__c,
               productId__c, Description__c
        FROM Promotion__c
        WHERE Id = :promotion.Id
    ];
        adjustmentDTO.promotion = queriedPromotions[0];

        ItemLevelPromotionHandler handler = new ItemLevelPromotionHandler();

        Test.startTest();
        PromotionEligibilityResult promoEligibility = handler.evaluateEligibility(adjustmentDTO);
        Test.stopTest();

        System.assertEquals(false, promoEligibility.isEligible, 'Promotion should not be eligible');
        System.assertEquals(1, promoEligibility.failureReasons.size(), 'One failure reason should be present');
    }

    @isTest
    static void testCalculateDiscount() {

        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        
        ItemLevelPromotionHandler handler = new ItemLevelPromotionHandler();

        Test.startTest();
        Decimal discount = handler.calculateDiscount(adjustmentDTO);
        Test.stopTest();
        System.debug('INSIDE CALCULATE DISCOUNT: ' + discount);
        System.assertEquals(3.0, discount, 'Discount should be 10.0');

    }

    @isTest
    static void testGetAdjustments() {
        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        
        ItemLevelPromotionHandler handler = new ItemLevelPromotionHandler();

        Test.startTest();
        List<Order_adjustment__c> adjustments = handler.getAdjustments(adjustmentDTO);
        Test.stopTest();
        System.debug('INSIDE GET ADJUSTMENTS: ' + adjustments.size());
        System.debug('ADJUSTMENTS: ' + adjustments);
        System.assertNotEquals(1, adjustments.size(), 'Adjustments should not be empty');
    }

    @isTest
    static void testApplySideEffects() {
        AdjustmentDTO adjustmentDTO = prepareDTO(true, true);
        
        ItemLevelPromotionHandler handler = new ItemLevelPromotionHandler();

        Test.startTest();
        handler.applySideEffects(adjustmentDTO);
        Test.stopTest();

        System.assertNotEquals(null, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should not be null');
        System.assertEquals(3.0, adjustmentDTO.order.Total_order_adjustments__c, 'Total order adjustments should equal the discount applied');
    }

}