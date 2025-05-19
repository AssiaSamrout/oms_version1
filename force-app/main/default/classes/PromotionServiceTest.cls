@isTest
public with sharing class PromotionServiceTest {
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

    @isTest
    public static void testIseligible(){
        
        List<Product2> products = TestsSetUp.createProducts();
        order__c order = TestsSetUp.createOrder();
        List<order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();

       
        Test.startTest();
        PromotionEligibilityResult result1 = PromotionService.isEligible(order, orderItems, promotions[0]);
        PromotionEligibilityResult result2 = PromotionService.isEligible(order, orderItems, promotions[1]);
        Test.stopTest();

     
        System.assertEquals(true, result1.isEligible, 'Order should be eligible for the promotion');
        System.assertEquals(0, result1.failureReasons.size(), 'There should be no failure reasons');
        System.assertEquals(false, result2.isEligible, 'Order should not be eligible for the promotion');
        System.assertEquals(1, result2.failureReasons.size(), 'There should be one failure reason');

    }

    @isTest
    public static void testCalculateDiscount(){
       
        List<Product2> products = TestsSetUp.createProducts();
        order__c order = TestsSetUp.createOrder();
        List<order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();

        Test.startTest();
        Decimal discount1 = PromotionService.calculateDiscount(order, orderItems, promotions[0]);
        Test.stopTest();

        System.debug('Discount calculated: ' + discount1);
              System.assertNotEquals(null, discount1, 'Discount should not be null');
    }
    
    @isTest
    public static void testgetPromotionById(){
        List<promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
        Test.startTest();
        	promotion__c promotion=PromotionService.getPromotionById(promotions[0].Id);
        Test.stopTest();
        
        System.debug('gotten promotion in test get promotion by id: '+promotion);
        System.assertNotEquals(null, promotion, 'it should contains promotion information');
   
    }

    
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
    
    @isTest
    static void testGetPromotionById_invalidId() {
        
        Id fakeId = 'a1A000000000XYZAAA'; 

        Test.startTest();
            promotion__c result = PromotionService.getPromotionById(fakeId);
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null for non-existing promotion Id');
    }

    @isTest
    static void testGetPromotionsByIds_validAndInvalidIds() {
 
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

    @isTest
    static void testGetPromotionsByIds_emptyList() {
        Test.startTest();
            List<promotion__c> results = PromotionService.getPromotionsByIds(new List<Id>());
        Test.stopTest();

  
        System.assertEquals(0, results.size(), 'Expected empty list for empty input');
    }

    @isTest
    static void testGetPromotionsByIds_nullList() {
    List<Id> nullList = null;

    Test.startTest();
        List<promotion__c> results = PromotionService.getPromotionsByIds(nullList);
    Test.stopTest();

    System.assertEquals(0, results.size(), 'Expected empty list for null input');
}

    

}