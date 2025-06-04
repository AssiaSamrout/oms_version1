public with sharing class PercentageDiscountStrategy implements IDiscountStrategy {

    /*
        * This method calculates the discount amount based on a the percentage of the promotion.
        * It is used for promotions that apply a percentage discount to either the order total or specific items.
        * It checks if the promotion has a valid percentage or discount value set, and calculates the discount accordingly.
        *
        * @param order The order for which the discount is being calculated.
        * @param orderItemsByProduct A map of product Ids to their corresponding order items.
        * @param promotion The promotion object containing the percentage or discount value.
        * @return The calculated discount amount as a Decimal.
        * @throws IllegalArgumentException if both Percentage and DiscountValue are null or if both are set.
    */
    public Decimal calculateDiscount(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion){

        System.debug('inside percentage discount strategy');
        if(promotion.Percentage__c == null && promotion.DiscountValue__c == null) {
            throw new IllegalArgumentException('Percentage and Discount value cannot be null');
        }
        if(promotion.Percentage__c != null && promotion.DiscountValue__c != null) {
            throw new IllegalArgumentException('Both Percentage and Discount value cannot be set');
        }

        Decimal total = (promotion.RecordType.Name == 'order_level') ? order.SubTotal__c : getTotalitems(orderItemsByProduct, promotion.productId__c);
        if(total == null) {
            throw new IllegalArgumentException('Total cannot be null');
        }
        System.debug('Total amount for discount calculation in percentage strategy: ' + total);
        Decimal discountAmount = (total * promotion.Percentage__c) / 100;
        System.debug('Calculated discount amount in percentage strategy: ' + discountAmount);
        return discountAmount;

    }

    private Decimal getTotalitems(Map<Id, List<Order_item__c>> orderItemsByProduct, Id productId) {
        Decimal total = 0;

        List<Order_item__c> items = orderItemsByProduct.get(productId);

        if (items != null) {
            for (Order_item__c item : items) {
                total += (item.unit_price__c * item.quantity__c);
            }
        }

        return total;
    }

}