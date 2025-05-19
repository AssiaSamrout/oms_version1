public with sharing class DiscountTypeFactory {
    public static IDiscountStrategy getDiscountStrategy(promotion__c promotion){
        if(promotion.Type__c == 'Percentage'){
            System.debug('inside percentage discount strategy factory');
            return new PercentageDiscountStrategy();
        }
        if(promotion.Type__c == 'Fixed'){
            System.debug('inside Fixed discount strategy factory');
            return new FixedDiscountStrategy();
        }
        throw new PromoException('Invalid promotion type: ' + promotion.Type__c);
    }
}