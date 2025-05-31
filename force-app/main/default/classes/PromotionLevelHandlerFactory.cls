public with sharing class PromotionLevelHandlerFactory {
    /*
        * Factory method to get the appropriate promotion level handler based on the promotion type.
        * 
        * @param promotionType The type of promotion (e.g., 'item_level', 'order_level').
        * @return An instance of IPromotionLevelHandler corresponding to the promotion type.
        * @throws IllegalArgumentException if the promotion type is null or empty.
        * @throws PromoException if the promotion type is invalid.
    */
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