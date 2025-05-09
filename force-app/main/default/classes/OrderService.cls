public with sharing class OrderService{
    public Id createOrder(OrderResponseWrapper orderResponse) {
        try {
            order__c newOrder = new order__c();
          //  newOrder.OrderDate = Date.valueOf(orderResponse.orderDate);
            newOrder.AccountId__c = orderResponse.accountId;
            newOrder.status__c = 'Draft';
            newOrder.billing_street__c = orderResponse.billingInfo.street;
            newOrder.billing_city__c = orderResponse.billingInfo.city;
            newOrder.billing_country__c = orderResponse.billingInfo.country;
            newOrder.billing_email__c = orderResponse.billingInfo.email;
            newOrder.order_amount__c = orderResponse.orderAmount;
            newOrder.PO_number__c = orderResponse.poNumber;
            newOrder.PO_date__c = Date.valueOf(orderResponse.poDate);
            newOrder.order_start_date__c = Date.valueOf(orderResponse.orderStartDate);

            Database.SaveResult sr = Database.insert(newOrder, false);

            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    throw new DmlException('Error creating Order: ' + err.getMessage());
                }
            }

            OrderItemService.insertOrderItems(orderResponse.items, newOrder.Id);

            return newOrder.Id;

        } catch (Exception e) {
            System.debug('Exception in createOrder: ' + e.getMessage());
            throw e;
        }
    }
}
