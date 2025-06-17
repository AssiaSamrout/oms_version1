public with sharing class BasePromotionEligibility implements IPromotionEligibility {
    /*
     * This method evaluates the eligibility of a cart for a given promotion.
     * It returns a PromotionEligibilityResult object that contains the result of the evaluation.
     * @param cartDTO The cart data transfer object containing details about the cart.
     * @param promotion The promotion object to evaluate against the cart.
     * @return A PromotionEligibilityResult object indicating whether the cart is eligible for the promotion.
     */
    public PromotionEligibilityResult evaluateEligibility(CartDTO cartDTO, Promotion__c promotion) {
        return PromotionService.isEligible(cartDTO,cartDTO.itemsByProductId, promotion);
    }
}