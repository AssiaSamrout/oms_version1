public Interface IDiscountStrategy {
    Decimal calculateDiscount(order__c order, List<order_item__c> orderItems, promotion__c promotion);
}