public with sharing class BasePromotionDiscountStrategy implements IPromotionDiscountStrategy {
    
    /*
     * This method evaluates the eligibility of a cart for a given promotion.
     * It returns a PromotionEligibilityResult object that contains the result of the evaluation.
     * @param cartDTO The cart data transfer object containing details about the cart.
     * @param promotion The promotion object to evaluate against the cart.
     * @return A PromotionEligibilityResult object indicating whether the cart is eligible for the promotion.
     */
    public PromotionEligibilityResult evaluateEligibility(CartDTO cartDTO, Promotion__c promotion) {
        return PromotionService.isEligible(cartDTO, promotion);
    }

    /*
     * This method calculates the discount for a given cart and promotion.
     * It returns a Decimal value representing the discount amount.
     * @param cartDTO The cart data transfer object containing details about the cart.
     * @param promotion The promotion object to calculate the discount for.
     * @return A Decimal value representing the discount amount for the cart under the specified promotion.
     */
    public abstract void applyDiscount(CartDTO cartDTO, Promotion__c promotion) {
        // This method is intended to be overridden by concrete promotion strategies.
        // No default implementation is provided in the base class.
    }
    
}