public with sharing class PercentageDiscountStrategy implements IDiscountStrategy {
    public Decimal calculateDiscount(order__c order, List<order_item__c> orderItems, promotion__c promotion){

        System.debug('inside percentage discount strategy');
        if(promotion.Percentage__c == null && promotion.DiscountValue__c == null) {
            throw new IllegalArgumentException('Percentage and Discount value cannot be null');
        }
        if(promotion.Percentage__c != null && promotion.DiscountValue__c != null) {
            throw new IllegalArgumentException('Both Percentage and Discount value cannot be set');
        }

        Decimal total = (promotion.RecordType.Name == 'order_level') ? order.SubTotal__c : getTotalitems(orderItems, promotion.productId__c);
        if(total == null) {
            throw new IllegalArgumentException('Total cannot be null');
        }

        return (total * promotion.Percentage__c) / 100;

    }

    private Decimal getTotalitems(List<order_item__c> orderItems, Id productId){
        Decimal total = 0;
        for(order_item__c item : orderItems){
            total+= (item.unit_price__c * item.quantity__c);
        }
        return total;
    }

}