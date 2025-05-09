public with sharing class OrderEventPublisher {
    
    public static void publishOrderCreatedEvent(order__c order){
        Order_Ready_For_Payment__e event = new Order_Ready_For_Payment__e(
            orderId__c = order.Id,
            orderTotalAmount__c = order.order_amount__c
        );

        Database.SaveResult result = EventBus.publish(event);

        if(!result.isSuccess()){
            for(Database.Error error : result.getErrors()){
                System.debug('Error publshing auth payment event:'+ error.getMessage());
            }
        }else{
            System.debug('Event published successfully');
        }

    }

}