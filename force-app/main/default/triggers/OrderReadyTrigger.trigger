trigger OrderReadyTrigger on OrderCreated__e (after insert){
    for(OrderCreated__e event: Trigger.new){
       System.debug('the pint where async process is called');
       // to avoid logic in trigger, we call a class method to handle the logic 
    }
}