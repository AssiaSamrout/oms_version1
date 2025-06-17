public Interface IPromotionApplicationStrategy {
   
    void applyDiscount(AdjustmentDTO adjustmentDTO,OrderSummaryDTO orderData);

    void applySideEffects(AdjustmentDTO adjustmentDTO,OrderSummaryDTO orderData,Decimal discountAmount);
}