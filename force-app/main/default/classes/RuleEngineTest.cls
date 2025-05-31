@isTest
public with sharing class RuleEngineTest {
   /*
    * Test method to verify the eligibility of an order for a promotion.
    * This test checks if the order meets the minimum amount requirement for the promotion.
    * It prepares necessary data, inserts a promotion, and asserts that the order is eligible.
   */
   @isTest
   public static void testIsEligible(){

    //prepare data
    List<Product2> products = TestsSetUp.createProducts();
    order__c order = TestsSetUp.createOrder();
    List<order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
    List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
    Map<Id,List<order_item__c>> orderItemsByProductId = new Map<Id,List<order_item__c>>();
    for(order_item__c item : orderItems){
        if(!orderItemsByProductId.containsKey(item.Product2Id__c)){
            orderItemsByProductId.put(item.Product2Id__c, new List<order_item__c>());
        }
        orderItemsByProductId.get(item.Product2Id__c).add(item);
    }

        //insert promotion
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='promotion__c' AND Name = 'order_level' LIMIT 1];
        promotion__c promotion = new promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 100.0,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = true,
            usageLimit__c = 10,
            usageCount__c = 0,
            Description__c = 'Test promotion for order level eligibility'
        );
        insert promotion;
    Test.startTest();
        PromotionEligibilityResult result = PromotionRulesEngine.isEligible(order, orderItemsByProductId, promotions[0]);
        System.assertEquals(true, result.isEligible, 'Order should be eligible for the promotion');
        System.assertEquals(0, result.failureReasons.size(), 'There should be no failure reasons');
    Test.stopTest();

   }
    
   /*
    * Test method to verify that an order is not eligible for a promotion
    * when the minimum amount requirement is not met.
    * This test prepares necessary data, inserts a promotion, and asserts that the order is not eligible.
   */
    @isTest
    public static void testIsEligibleNotApplicable(){
        //prepare data
    List<Product2> products = TestsSetUp.createProducts();
    order__c order = TestsSetUp.createOrder();
    List<order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
     Map<Id,List<order_item__c>> orderItemsByProductId = new Map<Id,List<order_item__c>>();
    for(order_item__c item : orderItems){
        if(!orderItemsByProductId.containsKey(item.Product2Id__c)){
            orderItemsByProductId.put(item.Product2Id__c, new List<order_item__c>());
        }
        orderItemsByProductId.get(item.Product2Id__c).add(item);
    }
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='promotion__c' AND Name = 'order_level' LIMIT 1];
        promotion__c promotion1 = new promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 500.0,
            activeFrom__c = Date.Today(),
            activeTo__c = Date.Today().addDays(30),
            isAutomatic__c = true,
            usageLimit__c = 10,
            usageCount__c = 0,
            Description__c = 'Test promotion for order level eligibility'
        );
        insert promotion1;
        promotion__c promotion = [SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, isAutomatic__c
        FROM promotion__c
        WHERE Id = :promotion1.Id];
        Test.startTest();
        PromotionEligibilityResult result = PromotionRulesEngine.isEligible(order, orderItemsByProductId, promotion);
        Test.stopTest();
        System.debug('from testing engine:'+result.isEligible);
        System.debug('from testing engine:'+result.failureReasons);
        System.assertEquals(false,result.isEligible,'order should not be eligible for this order');
        System.assertEquals(1,result.failureReasons.size(),'we should have one failure reaon here');
    }

}