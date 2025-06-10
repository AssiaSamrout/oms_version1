public with sharing class PromotionService {

    // Get a single promotion by Id, safely returning null if not found order__c
    public static Promotion__c getPromotionById(Id promotionId) {
        if (!Promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }

        List<Promotion__c> promotions = [
            SELECT Id, Name, Percentage__c, RecordTypeId, RecordType.Name, DiscountValue__c, 
                   IsAutomatic__c, Type__c, ActiveFrom__c, ActiveTo__c,Description__c,MinAmount__c
            FROM Promotion__c
            WHERE Id = :promotionId
            LIMIT 1
        ];

        return promotions.isEmpty() ? null : promotions[0];
    }

    // Get a list of promotions by their Ids
    public static List<Promotion__c> getPromotionsByIds(List<Id> promotionIds) {
        if (!Promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        
         if (promotionIds == null || promotionIds.isEmpty()) {
        return new List<Promotion__c>(); 
    }

        return [
            SELECT Id, Name, Percentage__c, RecordTypeId, RecordType.Name, DiscountValue__c, 
                   IsAutomatic__c, Type__c, ActiveFrom__c, ActiveTo__c,Description__c,MinAmount__c
            FROM Promotion__c
            WHERE Id IN :promotionIds
        ];
    }

    public static List<Promotion__c> getAutoApplicablePromotions(){
        if(!Promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        return [SELECT Id, Name, Percentage__c, RecordType.Name,MinAmount__c,DiscountValue__c, IsAutomatic__c, Type__c, ActiveFrom__c, activeTo__C,Description__c
                FROM Promotion__c
                WHERE IsAutomatic__c = true
                AND ActiveFrom__c <= :Date.today()
                AND (ActiveTo__c >= :Date.today() OR ActiveTo__c = null)
        ];
    }

    public static List<Promotion__c> getPromotionsByIdWithAutoPromo(List<Id> promotionIds){
        if(!Promotion__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        
        if (promotionIds == null || promotionIds.isEmpty()) {
            return new List<Promotion__c>(); 
        }

        return [
            SELECT Id, Name, Percentage__c, RecordTypeId, RecordType.Name, DiscountValue__c, 
                   IsAutomatic__c, Type__c, ActiveFrom__c, ActiveTo__c,Description__c,MinAmount__c
            FROM Promotion__c
            WHERE (
                   Id IN :promotionIds
                   AND ActiveFrom__c <= :Date.today()
                   AND (ActiveTo__c >= :Date.today() OR ActiveTo__c = null)
                   )
                 OR 
                  (
                   IsAutomatic__c = true
                   AND ActiveFrom__c <= :Date.today()
                   AND (ActiveTo__c >= :Date.today() OR ActiveTo__c = null)
                  )
        ];
    }

    /*
        * Check if the order is eligible for the promotion based on the rules defined in the PromotionRulesEngine.
        * 
        * @param order The order to check for eligibility.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items.
        * @param promotion The promotion to check against the order.
        * @return A PromotionEligibilityResult indicating whether the order is eligible and any failure reasons.
    */
    public static PromotionEligibilityResult isEligible(CartDTO cartDTO, Map<String,List<ItemDTO>> itemsByProductId,Promotion__c promotion){
        //check the rule of the promotion if it is applicable on this order using rule 
            // Promotion__c promotion = [
            // SELECT Id, Name, Percentage__c,RecordTypeId, RecordType.Name,DiscountValue__c, IsAutomatic__c, Type__c, ActiveFrom__c, activeTo__C
            // FROM Promotion__c
            // WHERE Id = :promo.Id 
            // ];

            //we should make sure that promotion has recordType.name field value(this field does not get retrieved when the promotion is inserted)
        System.debug('inside is promotion applicable');
        if(cartDTO == null || promotion ==null){
            throw new IllegalArgumentException('Order, OrderItems and Promotion cannot be null');
        }

        return PromotionRulesEngine.isEligible(cartDTO,itemsByProductId, promotion);
    }

    /*
        * Calculate the discount amount for the order based on the promotion type.
        * This method uses the DiscountTypeFactory to get the appropriate discount strategy.
        * 
        * @param order The order for which the discount is to be calculated.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items.
        * @param promotion The promotion containing the discount rules.
        * @return The calculated discount amount as a Decimal.
    */

    public static Decimal calculateDiscount(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion){
        //calculate the discount amount based on the promotion type 
        //calling promotion type factory to get the discount strategy
        System.debug('inside calculate discount');
        IDiscountStrategy discountCalculation = DiscountTypeFactory.getDiscountStrategy(promotion);
        if(discountCalculation == null) {
            throw new IllegalArgumentException('Discount calculation strategy not found');
        }
        return discountCalculation.calculateDiscount(order, orderItemsByProduct, promotion);
    }

}

