public Interface IPromotionRule {
    
    Boolean isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion);
   // Boolean isEligible(PromotionEvaluationContext context);
}