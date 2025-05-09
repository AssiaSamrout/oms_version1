trigger orderReadyForPaymentTrigger on Order_Ready_For_Payment__e (after insert) {
    for(Order_Ready_For_Payment__e event: Trigger.new){
        PaymentService.AuthorizePayment(event.orderId__c);
    }
}