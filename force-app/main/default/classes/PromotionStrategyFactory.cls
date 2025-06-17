public with sharing class PromotionStrategyFactory {
    public static IPromotionApplicationStrategy getStrategy(Promotion__c promo) {
        String scope = promo.RecordType.DeveloperName;
        String type = promo.Type__c;

        if (scope == 'Order_Level') {
            if (type == 'Fixed amount'){ return new OrderLFixedAmountPromotionStrategy();}
            if (type == 'Percentage') { return new OrderLPercentageOffPromotionStrategy(); }
        } else if (scope == 'Item_Level') {
           //same logic as Order_Level
           System.debug('create concrete classes for item level that implements IPromotionApplicationStrategy');
        }

        throw new IllegalArgumentException('Unsupported Promotion Type: ' + scope + ' + ' + type);
    }
}