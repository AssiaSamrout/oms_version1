public with sharing class OrderRepository {
    public static order__c createOrderRecord(OrderResponseWrapper orderResponse) {
        order__c newOrder = new order__c();
        newOrder.AccountId__c = orderResponse.accountId;
        newOrder.status__c = 'Draft';
        newOrder.billing_street__c = orderResponse.billingInfo.street;
        newOrder.billing_city__c = orderResponse.billingInfo.city;
        newOrder.billing_country__c = orderResponse.billingInfo.country;
        newOrder.billing_email__c = orderResponse.billingInfo.email;
        newOrder.order_amount__c = orderResponse.orderAmount;
        newOrder.PO_number__c = orderResponse.poNumber;

        if (!String.isBlank(orderResponse.poDate)) {
            newOrder.PO_date__c = Date.valueOf(orderResponse.poDate);
        }

        if (!String.isBlank(orderResponse.orderStartDate)) {
            newOrder.order_start_date__c = Date.valueOf(orderResponse.orderStartDate);
        }

        try {
            insert newOrder;
        } catch (DmlException e) {
            throw new DmlException('Failed to insert order: ' + e.getMessage());
        }
        return newOrder;
    }
}