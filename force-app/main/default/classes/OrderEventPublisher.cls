public with sharing class OrderEventPublisher {
    
    public static void publishOrderCreatedEvent(Order__c order){
        OrderCreated__e event = new OrderCreated__e(
            orderId__c = order.Id
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