public Interface IDiscountStrategy {
    Decimal calculateDiscount(Order__c order, Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion);
}