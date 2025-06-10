public with sharing class CartDTO {
    public Decimal totalAmount{get;set;}
    public Id accountId {get;set;}
    public String shippingMethod {get;set;}
    public Date cartDate {get;set;}
    public List<String> couponCode {get;set;}
    public List<ItemDTO> items {get;set;}

    public Map<String,List<ItemDTO>> itemsByProductId {get;set;}

    public CartDTO() {
        this.totalAmount = 0;
        this.accountId = null;
        this.shippingMethod = null;
        this.cartDate = null;
        this.couponCode = new List<String>();
        this.items = new List<ItemDTO>();
        this.itemsByProductId = new Map<String,List<ItemDTO>>();
    }

    public CartDTO(CartWrapper cartWrapper) {
        this.totalAmount = cartWrapper.totalAmount;
        this.accountId = cartWrapper.accountId;
        this.shippingMethod = cartWrapper.shippingMethod;
        this.cartDate = cartWrapper.cartDate;
        this.couponCode = cartWrapper.couponCode;
        this.items = cartWrapper.items;
        this.itemsByProductId = getItemsByProductId(cartWrapper.items);
    }

    public Map<String,List<ItemDTO>> getItemsByProductId(List<ItemDTO> items) {
        Map<String,List<ItemDTO>> itemsByProductId = new Map<String,List<ItemDTO>>();
        
        for(ItemDTO item : items) {
            if(!itemsByProductId.containsKey(item.productId)) {
                itemsByProductId.put(item.productId, new List<ItemDTO>());
            }
            itemsByProductId.get(item.productId).add(item);
        }
        return itemsByProductId;
    }

}