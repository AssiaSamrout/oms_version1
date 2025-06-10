public with sharing class CartWrapper {
   public Decimal totalAmount{get;set;}
    public Id accountId {get;set;}
    public String shippingMethod {get;set;}
    public Date cartDate {get;set;}
    public List<String> couponCode {get;set;}
    public List<ItemDTO> items {get;set;}
}