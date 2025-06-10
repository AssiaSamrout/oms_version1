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
    Order__c order = TestsSetUp.createOrder();
    List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
    List<Promotion__c> promotions = TestsSetUp.makeDataForPromotionRule();
    CartDTO cartDTO = new CartDTO();
    cartDTO.totalAmount = order.SubTotal__c;
    cartDTO.couponCode = new List<String>();
    cartDTO.items = OrderItemService.convertOrderItemsToDTO(orderItems);
    Map<String,List<ItemDTO>> itemsByProductId = new Map<String,List<ItemDTO>>();
    for(Order_item__c item : orderItems){
        if(!itemsByProductId.containsKey(item.Product2Id__c)){
            itemsByProductId.put(item.Product2Id__c, new List<ItemDTO>());
        }
        ItemDTO itemDTO = new ItemDTO();
        itemDTO.productId = item.Product2Id__c;
        itemDTO.quantity = item.Quantity__c;
        itemDTO.unitPrice = item.Unit_price__c;
        itemDTO.totalPrice = item.Total_price__c;
        itemDTO.description = item.Description__c;
        itemDTO.size = item.Size__c;
        itemDTO.color = item.Color__c;
        itemDTO.productName = item.Name; 

        itemsByProductId.get(item.Product2Id__c).add(itemDTO);
    }

        //insert promotion
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='promotion__c' AND Name = 'order_level' LIMIT 1];
        Promotion__c promotion = new Promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 100.0,
            ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),
            IsAutomatic__c = true,
            UsageLimit__c = 10,
            UsageCount__c = 0,
            Description__c = 'Test promotion for order level eligibility'
        );
        insert promotion;
    Test.startTest();
        PromotionEligibilityResult result = PromotionRulesEngine.isEligible(cartDTO,itemsByProductId , promotions[0]);
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
    Order__c order = TestsSetUp.createOrder();
    List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);

     CartDTO cartDTO = new CartDTO();
        cartDTO.totalAmount = order.SubTotal__c;
        cartDTO.couponCode = new List<String>();
        cartDTO.items = OrderItemService.convertOrderItemsToDTO(orderItems);

        Map<String,List<ItemDTO>> itemsByProductId = new Map<String,List<ItemDTO>>();
        for(Order_item__c item : orderItems){
            if(!itemsByProductId.containsKey(item.Product2Id__c)){
                itemsByProductId.put(item.Product2Id__c, new List<ItemDTO>());
            }
            ItemDTO itemDTO = new ItemDTO();
            itemDTO.productId = item.Product2Id__c;
            itemDTO.quantity = item.Quantity__c;
            itemDTO.unitPrice = item.Unit_price__c;
            itemDTO.totalPrice = item.Total_price__c;
            itemDTO.description = item.Description__c;
            itemDTO.size = item.Size__c;
            itemDTO.color = item.Color__c;
            itemDTO.productName = item.Name;
            itemsByProductId.get(item.Product2Id__c).add(itemDTO);
        }

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'order_level' LIMIT 1];
        Promotion__c promotion1 = new Promotion__c (
            Name='Order level promo with min amount',
            RecordTypeId = rt.Id,
            MinAmount__c = 500.0,
            ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),
            IsAutomatic__c = true,
            UsageLimit__c = 10,
            UsageCount__c = 0,
            Description__c = 'Test promotion for order level eligibility'
        );
        insert promotion1;
        Promotion__c promotion = [SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c, IsAutomatic__c
        FROM Promotion__c
        WHERE Id = :promotion1.Id];
        Test.startTest();
        PromotionEligibilityResult result = PromotionRulesEngine.isEligible(cartDTO,itemsByProductId, promotion);
        Test.stopTest();
        System.debug('from testing engine:'+result.isEligible);
        System.debug('from testing engine:'+result.failureReasons);
        System.assertEquals(false,result.isEligible,'order should not be eligible for this order');
        System.assertEquals(1,result.failureReasons.size(),'we should have one failure reaon here');
    }

}