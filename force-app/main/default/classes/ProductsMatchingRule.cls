public with sharing class ProductsMatchingRule implements IPromotionRule {

    /*
        * This method checks if the order is eligible for a promotion based on the product matching rule.
        * It verifies if the promotion's productId__c matches any of the order items' Product2Id__c.
        * It is for item level promotions where the promotion is applicable to specific products.
        *
        * @param order The order to check for eligibility.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items.
        * @param promotion The promotion to check against the order.
        * @return true if the order is eligible for the promotion, false otherwise.
    */
    public Boolean isEligible(CartDTO cartDTO,Map<String,List<ItemDTO>> itemsByProductId, Promotion__c promotion) {
        if (promotion.productId__c == null) {
            return false;
        }

        List<ItemDTO> items = itemsByProductId.get(promotion.productId__c);
        if (items != null && !items.isEmpty()) {
            return true; 
        }

        return false;
    }
    // public Boolean isEligible(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion) {
    //     if (promotion.productId__c == null) {
    //         return false;
    //     }

    //     List<Order_item__c> items = orderItemsByProduct.get(promotion.productId__c);
    //     if (items != null && !items.isEmpty()) {
    //         return true; 
    //     }

    //     return false;
    // }


    
}