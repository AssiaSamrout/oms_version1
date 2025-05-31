public Interface IPromotionLevelHandler {
    /*
     * This interface defines the methods for handling promotions at different levels (item-level or order-level).
     * It includes methods to evaluate eligibility, calculate discounts, retrieve adjustments, and apply side effects.
     */
    PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO);
    Decimal calculateDiscount(AdjustmentDTO adjustmentDTO);
    List<order_adjustment__C> getAdjustments(AdjustmentDTO adjustmentDTO);
    void applySideEffects(AdjustmentDTO adjustmentDTO);
}