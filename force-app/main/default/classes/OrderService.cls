public with sharing class OrderService {
    /*
        * This class handles order processing, including creating orders and calculating total amounts.
        * It interacts with OrderRepository and OrderItemService to manage order records and items.
        *
        *@param orderResponse The response wrapper containing order details.
        * @return An OrderProcessingResult indicating success or failure of the order creation.
        * @throws IllegalArgumentException if the orderResponse is null or invalid.
        * @throws DmlException if there is an error during the order creation process.
        * @throws Exception for any unexpected errors during order processing.\
      
    */
    public OrderProcessingResult createOrder(OrderResponseWrapper orderResponse) {
        OrderProcessingResult result = new OrderProcessingResult();
        Savepoint sp = Database.setSavepoint();

        try {
            Order__c newOrder = OrderRepository.createOrderRecord(orderResponse);

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

    public static Order__c getOrderById(Id orderId){
        if (orderId == null) {
            System.debug('inside OrderService: Order ID cannot be null');
            throw new IllegalArgumentException('Order ID cannot be null');
        }

        Order__c order = OrderRepository.getOrderById(orderId);
        if (order == null) {
            System.debug('inside OrderService: Order not found with ID: ' + orderId);
            throw new IllegalArgumentException('Order not found with ID: ' + orderId);
        }

        return order;
    }

    public static Decimal calculateTotalAmount(List<Order_item__c> orderItems) {
        Decimal totalAmount = 0;
        for (Order_item__c item : orderItems) {
            totalAmount += item.unit_price__c * item.quantity__c;
        }
        return totalAmount;
    }

    public static Decimal adjustTotalAmount(Decimal totalAmount, Decimal adjustment) {
        if (adjustment == null) {
            throw new IllegalArgumentException('Adjustment cannot be null');
        }
        return totalAmount - adjustment;
    }
    
}
