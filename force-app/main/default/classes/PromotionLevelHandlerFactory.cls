public with sharing class PromotionLevelHandlerFactory {
    public static IPromotionLevelHandler getPromotionLevelHandler(String promotionType) {
        if(String.isBlank(promotionType)) {
            throw new IllegalArgumentException('Promotion type cannot be null or empty');
        }
        if(promotionType == 'item_level'){
            System.debug('inside item level promotion handler factory');
            return new ItemLevelPromotionHandler();
        }
        if(promotionType == 'order_level'){
            System.debug('inside order level promotion handler factory');
            return new OrderLevelPromotionHandler();
        }
        throw new PromoException('Invalid promotion type: ' + promotion.RecordType.Name);
    }
}