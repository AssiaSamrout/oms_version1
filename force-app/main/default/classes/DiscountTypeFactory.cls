public with sharing class DiscountTypeFactory {
    /*
        * Factory method to get the appropriate discount strategy based on the promotion type.
        * 
        * @param promotion The promotion object containing the type of discount.
        * @return An instance of IDiscountStrategy corresponding to the promotion type.
        * @throws PromoException if the promotion type is invalid.
    */ 
    public static IDiscountStrategy getDiscountStrategy(promotion__c promotion){
        if(promotion.Type__c == 'Percentage'){
            System.debug('inside percentage discount strategy factory');
            return new PercentageDiscountStrategy();
        }
        if(promotion.Type__c == 'Fixed amount'){
            System.debug('inside Fixed discount strategy factory');
            return new FixedDiscountStrategy();
        }
        throw new PromoException('Invalid promotion type: ' + promotion.Type__c);
    }
}