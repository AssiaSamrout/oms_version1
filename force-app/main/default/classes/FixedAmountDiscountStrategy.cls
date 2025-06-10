public with sharing class FixedAmountDiscountStrategy extends BasePromotionDiscountStrategy {
    /*
     * This method applies a fixed amount discount to the cart based on the promotion.
     * It updates the cart's total amount by subtracting the fixed discount amount.
     * @param cartDTO The cart data transfer object containing details about the cart.
     * @param promotion The promotion object containing the fixed discount amount.
     */
    public override void applyDiscount(CartDTO cartDTO, Promotion__c promotion) {
        if (promotion.DiscountValue__c == null) {
            throw new IllegalArgumentException('Discount value cannot be null');
        }
        if (promotion.Percentage__c != null) {
            throw new IllegalArgumentException('Percentage cannot be set for fixed discount strategy');
        }
        if (promotion.DiscountValue__c < 0) {
            throw new IllegalArgumentException('Discount value cannot be negative');
        }

        cartDTO.totalAmount -= promotion.DiscountValue__c;
    }
}
