@isTest
public with sharing class PromotionServiceTest {
    /*
        * Test method to verify that the getAutoApplicablePromotions method
        * returns the correct promotions that are automatically applicable.
        */
    @isTest
    public static void testGetAutoApplicablePromotions(){
       
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();

       
        Test.startTest();
        
        List<promotion__c> results = PromotionService.getAutoApplicablePromotions();
        Test.stopTest();
        System.debug('Results from getAutoApplicablePromotions: ' + results);
       
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'There should be one applicable promotion');
    }

    /*
        * Test method to verify the eligibility of an order for a promotion.
        * This test checks if the order meets the minimum amount requirement for the promotion.
        * It prepares necessary data, inserts a promotion, and asserts that the order is eligible.
    */
    @isTest
    public static void testIseligible(){
        
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
       
        Test.startTest();
        PromotionEligibilityResult result1 = PromotionService.isEligible(order, orderItemsByProductId, promotions[0]);
        PromotionEligibilityResult result2 = PromotionService.isEligible(order, orderItemsByProductId, promotions[1]);
        Test.stopTest();

     
        System.assertEquals(true, result1.isEligible, 'Order should be eligible for the promotion');
        System.assertEquals(0, result1.failureReasons.size(), 'There should be no failure reasons');
        System.assertEquals(false, result2.isEligible, 'Order should not be eligible for the promotion');
        System.assertEquals(1, result2.failureReasons.size(), 'There should be one failure reason');

    }
    /*
        * Test method to verify that an order is not eligible for a promotion
        * when the minimum amount requirement is not met.
        * This test prepares necessary data, inserts a promotion, and asserts that the order is not eligible.
    */
    @isTest
    public static void testCalculateDiscount(){
       
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

        Test.startTest();
        Decimal discount1 = PromotionService.calculateDiscount(order,orderItemsByProductId, promotions[0]);
        Test.stopTest();

        System.debug('Discount calculated: ' + discount1);
              System.assertNotEquals(null, discount1, 'Discount should not be null');
    }

    /*
        *Test method to verify that the getPromotionById method
        * retrieves the correct promotion by its Id.
    */
    
    @isTest
    public static void testgetPromotionById(){
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        Test.startTest();
        	promotion__c promotion=PromotionService.getPromotionById(promotions[0].Id);
        Test.stopTest();
        
        System.debug('gotten promotion in test get promotion by id: '+promotion);
        System.assertNotEquals(null, promotion, 'it should contains promotion information');
   
    }

    /*
        * Test method to verify that the getPromotionsByIds method
        * retrieves the correct promotions by their Ids.
    */
    
    @isTest
    public static void testgetpromotionsById(){
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        List<Id> proIDs = new List<Id>();
        for(promotion__c pro :promotions){
            proIDs.add(pro.Id);
        }
	    Test.startTest();
        	List<promotion__c> promotionsres=PromotionService.getPromotionsByIds(proIDs);
        Test.stopTest();      
        System.assertNotEquals(null, promotionsres, 'it should contains promotion information');
    }

    /*
        * Test method to verify that the getPromotionById method
        * returns null for a non-existing promotion Id.
    */
    
    @isTest
    static void testGetPromotionByIdinvalidId() {
        
        Id fakeId = 'a1A000000000XYZAAA'; 

        Test.startTest();
            promotion__c result = PromotionService.getPromotionById(fakeId);
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null for non-existing promotion Id');
    }
    /*
        * Test the result of entering invalid Ids in the getPromotionsByIds method.
    */
    @isTest
    static void testGetPromotionsByIdsvalidAndInvalidIds() {
 
        List<promotion__c> testPromotions = TestsSetUp.makeDataForPromotionRule();
        List<Id> promoIds = new List<Id>();

        for (promotion__c promo : testPromotions) {
            promoIds.add(promo.Id);
        }

        Id fakeId = 'a1A000000000XYZAAA'; 
        promoIds.add(fakeId);

        Test.startTest();
            List<promotion__c> results = PromotionService.getPromotionsByIds(promoIds);
        Test.stopTest();

 
        System.assertEquals(testPromotions.size(), results.size(), 'Only real promotions should be returned');
        for (promotion__c p : results) {
            System.assertNotEquals(fakeId, p.Id, 'Fake ID should not be included');
        }
    }

    /*
        * Test method to verify that the getPromotionsByIds method
        * returns an empty list when no Ids are provided.
    */
    @isTest
    static void testGetPromotionsByIdsemptyList() {
        Test.startTest();
            List<promotion__c> results = PromotionService.getPromotionsByIds(new List<Id>());
        Test.stopTest();

  
        System.assertEquals(0, results.size(), 'Expected empty list for empty input');
    }


    /*
        * Test method to verify that the getPromotionsByIds method
        * returns an empty list when a null list is provided.
    */
    @isTest
    static void testGetPromotionsByIds_nullList() {
    List<Id> nullList = null;

    Test.startTest();
        List<promotion__c> results = PromotionService.getPromotionsByIds(nullList);
    Test.stopTest();

    System.assertEquals(0, results.size(), 'Expected empty list for null input');
}

    

}