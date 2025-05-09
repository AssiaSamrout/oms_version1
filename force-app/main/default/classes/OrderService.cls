public with sharing class OrderService {

    public OrderProcessingResult createOrder(OrderResponseWrapper orderResponse) {
        OrderProcessingResult result = new OrderProcessingResult();
        Savepoint sp = Database.setSavepoint();

        try {
            order__c newOrder = OrderRepository.createOrderRecord(orderResponse);

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

    
}
