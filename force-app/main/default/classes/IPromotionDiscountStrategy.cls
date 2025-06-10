/*
    This interface defines the methods required for evaluating promotion eligibility and calculating discounts.
*/
public interface IPromotionDiscountStrategy {
    /* 
    This method evaluates the eligibility of a cart for a given promotion.
    It returns a PromotionEligibilityResult object that contains the result of the evaluation.
    @param cartDTO The cart data transfer object containing details about the cart.
    @param promotion The promotion object to evaluate against the cart.
    @return A PromotionEligibilityResult object indicating whether the cart is eligible for the promotion.
     */
    PromotionEligibilityResult evaluateEligibility(CartDTO cartDTO, Promotion__c promotion);

    /*
        * This method calculates the discount for a given cart and promotion.
        * It returns a Decimal value representing the discount amount.
        * @param cartDTO The cart data transfer object containing details about the cart.
        * @param promotion The promotion object to calculate the discount for.
        * @return A Decimal value representing the discount amount for the cart under the specified promotion.
    */
    void applyDiscount(CartDTO cartDTO,Promotion__c promotion);

}