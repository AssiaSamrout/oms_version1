public with sharing class OrderService {

    public OrderProcessingResult createOrder(OrderResponseWrapper orderResponse) {
        OrderProcessingResult result = new OrderProcessingResult();
        Savepoint sp = Database.setSavepoint();

        try {
            order__c newOrder = createOrderRecord(orderResponse);

            OrderItemService.InsertResult insertResult = OrderItemService.insertOrderItems(orderResponse.items, newOrder.Id);

            if (!insertResult.errors.isEmpty()) {
                Database.rollback(sp);
                result.success = false;
                result.message = 'Some order items failed to insert: ' + String.join(insertResult.errors, '; ');
                return result;
            }

            result.success = true;
            result.message = 'Order created successfully. You will receive a confirmation email shortly.';
            result.orderId = newOrder.Id;

        } catch (Exception e) {
            Database.rollback(sp);
            result.success = false;
            result.message = 'Error during order processing: ' + e.getMessage();
        }

        return result;
    }

    private order__c createOrderRecord(OrderResponseWrapper orderResponse) {
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

        insert newOrder;
        return newOrder;
    }
}
