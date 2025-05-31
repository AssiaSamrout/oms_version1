public Interface IDiscountStrategy {
    Decimal calculateDiscount(order__c order, Map<Id,List<order_item__c>> orderItemsByProduct, promotion__c promotion);
}