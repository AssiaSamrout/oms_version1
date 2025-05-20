public with sharing class PromotionService {

    // Get a single promotion by Id, safely returning null if not found
    public static promotion__c getPromotionById(Id promotionId) {
        if (!promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }

        List<promotion__c> promotions = [
            SELECT Id, Name, Percentage__c, RecordTypeId, RecordType.Name, DiscountValue__c, 
                   isAutomatic__c, Type__c, activeFrom__c, activeTo__c,	productId__c
            FROM promotion__c
            WHERE Id = :promotionId
            LIMIT 1
        ];

        return promotions.isEmpty() ? null : promotions[0];
    }

    // Get a list of promotions by their Ids
    public static List<promotion__c> getPromotionsByIds(List<Id> promotionIds) {
        if (!promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        
         if (promotionIds == null || promotionIds.isEmpty()) {
        return new List<promotion__c>(); 
    }

        return [
            SELECT Id, Name, Percentage__c, RecordTypeId, RecordType.Name, DiscountValue__c, 
                   isAutomatic__c, Type__c, activeFrom__c, activeTo__c
            FROM promotion__c
            WHERE Id IN :promotionIds
        ];
    }

    public static List<promotion__c> getAutoApplicablePromotions(){
        if(!promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        return [SELECT Id, Name, Percentage__c, RecordType.Name,DiscountValue__c, isAutomatic__c, Type__c, activeFrom__c, activeTo__C
                FROM promotion__c
                WHERE isAutomatic__c = true
                AND activeFrom__c <= :Date.today()
                AND (activeTo__c >= :Date.today() OR activeTo__c = null)

        ];
    }

    public static PromotionEligibilityResult isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion){
        //check the rule of the promotion if it is applicable on this order using rule 
            // promotion__c promotion = [
            // SELECT Id, Name, Percentage__c,RecordTypeId, RecordType.Name,DiscountValue__c, isAutomatic__c, Type__c, activeFrom__c, activeTo__C
            // FROM promotion__c
            // WHERE Id = :promo.Id 
            // ];

            //we should make sure that promotion has recordType.name field value(this field does not get retrieved when the promotion is inserted)
        System.debug('inside is promotion applicable');
        if(order == null || orderItems == null || promotion ==null){
            throw new IllegalArgumentException('Order, OrderItems and Promotion cannot be null');
        }

        return PromotionRulesEngine.isEligible(order, orderItems, promotion);
    }



    public static Decimal calculateDiscount(order__c order, List<order_item__c> orderItems, promotion__c promotion){
        //calculate the discount amount based on the promotion type 
        //calling promotion type factory to get the discount strategy
        System.debug('inside calculate discount');
        IDiscountStrategy discountCalculation = DiscountTypeFactory.getDiscountStrategy(promotion);
        if(discountCalculation == null) {
            throw new IllegalArgumentException('Discount calculation strategy not found');
        }
        return discountCalculation.calculateDiscount(order, orderItems, promotion);
    }

}