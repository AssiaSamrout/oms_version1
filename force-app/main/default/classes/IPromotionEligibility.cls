public interface IPromotionEligibility {
    PromotionEligibilityResult evaluateEligibility(CartDTO cartDTO, Promotion__c promotion);
}