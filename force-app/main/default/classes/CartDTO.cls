public with sharing class CartDTO {
    public Decimal subtotal{get;set;}
    public Id accountId {get;set;}
    public String shippingMethod {get;set;}
    public Date cartDate {get;set;}
    public String couponCode {get;set;}
    public List<ItemDTO> items {get;set;}
}