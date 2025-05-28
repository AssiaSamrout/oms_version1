public Interface IPromotionLevelHandler {
    PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO);
    Decimal calculateDiscount(AdjustmentDTO adjustmentDTO);
    List<order_adjustment__C> getAdjustments(AdjustmentDTO adjustmentDTO);
    void applySideEffects(AdjustmentDTO adjustmentDTO);
}