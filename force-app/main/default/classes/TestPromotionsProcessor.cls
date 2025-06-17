@isTest
public with sharing class TestPromotionsProcessor {
	@isTest
    public static void testprocesspromotionsEligibility(){
        
        RecordType orderLevelRT =  [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'order_level' LIMIT 1];

        // Create mock promotions
        Promotion__c promo1 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Fixed amount',DiscountValue__c = 10.0, ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 1');
        Promotion__c promo2 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Percentage',Percentage__c = 10.0,ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 2');
        
        List<Promotion__c> unorderedpromotions = new List<Promotion__c>{promo2, promo1 };
		insert unorderedpromotions;
        List<Promotion__c> promotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c,
            IsAutomatic__c,Percentage__c, Type__c,UsageLimit__c, UsageCount__c,
            DiscountValue__c,productId__c, Description__c,PriorityNumber__c
        FROM Promotion__c
        WHERE Id IN :unorderedpromotions
    ];
        PromotionRule__c rule1 = new PromotionRule__c(
        	Promotion__c = promotions[0].Id,
			RuleCondition__c = 'MinAmountRule',
			Name = 'MinAmountRule',
			ParameterValue__c = '100.0'
        );
        
        PromotionRule__c rule2 = new PromotionRule__c(
        	Promotion__c = promotions[1].Id,
			RuleCondition__c = 'MinAmountRule',
			Name = 'MinAmountRule',
			ParameterValue__c = '100.0'
        );
        
        insert new List<PromotionRule__c>{rule1,rule2};
        
        CartDTO cart= new CartDTO();
        cart.totalAmount = 170.0;
        cart.items = null;
        
        Test.startTest();
        promotionsCheckoutResult result = promotionsProcessor.processpromotionsEligibility(cart,promotions);
        Test.stopTest();
        System.debug(result);
        System.assertEquals(True,result.isValid,'should be true');
        
    }
    
    @isTest
    public static void testprocesspromotionsEligibilitynotEligible(){
        
        
        RecordType orderLevelRT =  [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'order_level' LIMIT 1];

        // Create mock promotions
        Promotion__c promo1 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Fixed amount',DiscountValue__c = 10.0, ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 1');
        Promotion__c promo2 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Percentage',Percentage__c = 10.0,ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 2');
        
        List<Promotion__c> unorderedpromotions = new List<Promotion__c>{promo2, promo1 };
		insert unorderedpromotions;
        List<Promotion__c> promotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name, MinAmount__c,
            IsAutomatic__c,Percentage__c, Type__c,UsageLimit__c, UsageCount__c,
            DiscountValue__c,productId__c, Description__c,PriorityNumber__c
        FROM Promotion__c
        WHERE Id IN :unorderedpromotions
    ];
        PromotionRule__c rule1 = new PromotionRule__c(
        	Promotion__c = promotions[0].Id,
			RuleCondition__c = 'MinAmountRule',
			Name = 'MinAmountRule',
			ParameterValue__c = '50.0'
        );
        
        PromotionRule__c rule2 = new PromotionRule__c(
        	Promotion__c = promotions[1].Id,
			RuleCondition__c = 'MinAmountRule',
			Name = 'MinAmountRule',
			ParameterValue__c = '100.0'
        );
        
        insert new List<PromotionRule__c>{rule1,rule2};
        
        CartDTO cart= new CartDTO();
        cart.totalAmount = 70.0;
        cart.items = null;
        
        Test.startTest();
        promotionsCheckoutResult result = promotionsProcessor.processpromotionsEligibility(cart,promotions);
        Test.stopTest();
        System.debug(result);
        System.assertEquals(false,result.isValid,'should be true');
        
    }
    
    @isTest
    public static void testapplypromotions(){
        Order__c order = TestsSetUp.createOrder();
        List<Product2> products = TestsSetUp.createProducts();
        List<Order_item__c> orderItems = TestsSetUp.createOrderItems(order, products);
        
        RecordType orderLevelRT =  [SELECT Id FROM RecordType WHERE SObjectType='Promotion__c' AND Name = 'order_level' LIMIT 1];
        Promotion__c promo1 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Fixed amount',DiscountValue__c = 10.0, ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 1');
        Promotion__c promo2 = new Promotion__c( RecordType = orderLevelRT, PriorityNumber__c = 1, Type__c = 'Percentage',Percentage__c = 10.0,ActiveFrom__c = Date.Today(),
            ActiveTo__c = Date.Today().addDays(30),Description__c = 'description of promotion 2');
        
        List<Promotion__c> unorderedpromotions = new List<Promotion__c>{promo2, promo1 };
		insert unorderedpromotions;
        List<Promotion__c> promotions = [
        SELECT Id, Name, RecordTypeId, RecordType.Name,RecordType.DeveloperName, MinAmount__c,
            IsAutomatic__c,Percentage__c, Type__c,UsageLimit__c, UsageCount__c,
            DiscountValue__c,productId__c, Description__c,PriorityNumber__c
        FROM Promotion__c
        WHERE Id IN :unorderedpromotions
    ];
        
        ProcesspromotionsDTO dto = new ProcesspromotionsDTO();
        dto.order = order;
		dto.orderItems = orderItems;
		dto.promotions = promotions;
        dto.promoToCoupon = new Map<Id,Coupon__c>();
        dto.promotionType = null;
        
        Test.startTest();
        	OrderSummaryDTO summary= promotionsProcessor.applypromotions(dto); 
        Test.stopTest();
        System.debug('dto inside test apply promotions:'+summary);
        System.debug('aaaaaaaaaaaaa totalAdjustments :'+summary.totalAdjustments);
        System.assertEquals(20.0,summary.totalAdjustments,'this is the correct value that shuld occur');
        
    }

}