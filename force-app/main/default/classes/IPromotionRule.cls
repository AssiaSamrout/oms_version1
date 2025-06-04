public Interface IPromotionRule {
    /*     * This method checks if the order is eligible for a promotion based on the defined rules.
           * It verifies if the order meets the criteria specified in the promotion.
           * 
           * @return true if the order is eligible for the promotion, false otherwise.
           * @param order The order to check for eligibility.
           * @param orderItemsByProduct A map of product Ids to their corresponding order items.
           * @param promotion The promotion to check against the order.
     */
   // Boolean isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion);
    Boolean isEligible(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion);
}