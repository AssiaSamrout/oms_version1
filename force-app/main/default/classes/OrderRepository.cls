public with sharing class OrderRepository {
    /*
     * This class is responsible for handling order-related operations such as creating and retrieving orders.
     * It interacts with the custom order__c object in Salesforce.
     */
    public static Order__c createOrderRecord(OrderResponseWrapper orderResponse) {
        Order__c newOrder = new Order__c();
        newOrder.AccountId__c = orderResponse.accountId;
        newOrder.Status__c = 'Draft';
        newOrder.Billing_street__c = orderResponse.billingInfo.street;
        newOrder.Billing_city__c = orderResponse.billingInfo.city;
        newOrder.Billing_country__c = orderResponse.billingInfo.country;
        newOrder.Billing_email__c = orderResponse.billingInfo.email;
        newOrder.SubTotal__c = orderResponse.orderAmount;
        newOrder.PO_number__c = orderResponse.poNumber;

        if (!String.isBlank(orderResponse.poDate)) {
            newOrder.PO_date__c = Date.valueOf(orderResponse.poDate);
        }

        if (!String.isBlank(orderResponse.orderStartDate)) {
            newOrder.Order_start_date__c = Date.valueOf(orderResponse.orderStartDate);
        }

        try {
            insert newOrder;
        } catch (DmlException e) {
            throw new DmlException('Failed to insert order: ' + e.getMessage());
        }
        return newOrder;
    }

    public static Order__c getOrderById(Id orderId) {
        if (orderId == null) {
            throw new IllegalArgumentException('Order ID cannot be null');
        }

        if(!Order__c.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Order object not accessible');
        }
        List<Order__c> orders = [SELECT Id, Name,SubTotal__c, AccountId__c, Status__c, Billing_street__c, Billing_city__c, Billing_country__c, Billing_email__c, Order_amount__c, PO_number__c, PO_date__c, Order_start_date__c
                                 FROM Order__c
                                 WHERE Id = :orderId];

        return orders[0];
    }

}