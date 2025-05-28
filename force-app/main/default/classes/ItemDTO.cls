public with sharing class ItemDTO {
    public String sku {get; set;}
    public String productName {get; set;}
    public Integer quantity {get; set;}
    public String description {get; set;}
    public Decimal unitPrice {get; set;}
    public Decimal totalPrice {get; set;}
}