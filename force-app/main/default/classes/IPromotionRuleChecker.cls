public Interface IPromotionRuleChecker {
    Boolean isEligible(CartDTO cartDTO, PromotionRule__c assignment);
}