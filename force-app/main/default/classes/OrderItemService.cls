/*
    * OrderResponseWrapper.cls
    * 
    * This class is used to encapsulate the response structure for order details.
    * It includes information about the order, customer, billing info, items, adjustments, and payment.
    * It is designed to be used in conjunction with the OrderService and OrderRepository classes
*/
public with sharing class OrderItemService {

    public class InsertResult {
        public List<Order_item__c> successfulItems = new List<Order_item__c>();
        public List<String> errors = new List<String>();
    }

    public static InsertResult insertOrderItems(List<ItemDTO> items, Id orderId) {
        if (!Order_item__c.SObjectType.getDescribe().isCreateable()) {
            throw new SecurityException('OrderItem object not creatable');
        }

        validateInput(items);

        Set<String> skus = new Set<String>();
        for (ItemDTO item : items) {
            skus.add(item.sku);
        }

        Map<String, Product2> skuToProductMap = Product2Repository.findProductBySKU(skus);
        validateSkus(skus, skuToProductMap.keySet());

        List<Order_item__c> orderItems = buildOrderItems(items, skuToProductMap, orderId);

        InsertResult result = new InsertResult();
        Database.SaveResult[] saveResults = OrderItemRepository.insertItems(orderItems, false);

        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                result.successfulItems.add(orderItems[i]);
            } else {
                String sku = items[i].sku;
                for (Database.Error err : saveResults[i].getErrors()) {
                    result.errors.add('Error for SKU ' + sku + ': ' + err.getMessage());
                }
            }
        }

        return result;
    }

    private static void validateInput(List<ItemDTO> items) {
        for (ItemDTO item : items) {
            if (String.isBlank(item.sku)) {
                throw new IllegalArgumentException('SKU cannot be blank');
            }
        }
    }

    public static void validateSkus(Set<String> givenSKU, Set<String> foundSKU) {
        Set<String> missingSkus = new Set<String>(givenSKU);
        missingSkus.removeAll(foundSKU);
        if (!missingSkus.isEmpty()) {
            throw new IllegalArgumentException('Invalid SKUs: ' + String.join(new List<String>(missingSkus), ', '));
        }
    }

    private static List<Order_item__c> buildOrderItems(List<ItemDTO> items, Map<String, Product2> skuMap, Id orderId) {
        List<Order_item__c> orderItems = new List<Order_item__c>();
        for (ItemDTO item : items) {
            Product2 product = skuMap.get(item.sku);
            if (product == null){ 
            continue;
            }

            Order_item__c oi = new Order_item__c(
                OrderId__c = orderId,
                Product2Id__c = product.Id,
                Name = item.productName,
                Quantity__c = item.quantity,
                Unit_price__c = item.unitPrice,
                Total_price__c = item.totalPrice,
                Description__c = item.description,
                Size__c = item.size,
                Color__c = item.color
            );
            orderItems.add(oi);
        }
        return orderItems;
    }

    public static List<Order_item__c> getOrderItemsByOrderId(Id orderId) {
        if (orderId == null) {
            System.debug('inside OrderItemService: Order ID cannot be null');
            throw new IllegalArgumentException('Order ID cannot be null');
        }

        List<Order_item__c> orderItems = OrderItemRepository.getOrderItemsByOrderId(orderId);
        if (orderItems == null || orderItems.isEmpty()) {
            System.debug('inside OrderItemService: Order items not found for Order ID: ' + orderId);
            throw new IllegalArgumentException('Order items not found for Order ID: ' + orderId);
        }

        return orderItems;
    }

    public static Decimal adjustTotalAmount(Decimal totalItemAmount, Decimal adjustment) {
        if (adjustment == null) {
            throw new IllegalArgumentException('Adjustment cannot be null');
        }
        return totalItemAmount - adjustment;
    }

    public static Decimal calculateTotalItemAmount(Integer quantity, Decimal unitPrice) {
        if (quantity == null || unitPrice == null) {
            throw new IllegalArgumentException('Quantity and Unit Price cannot be null');
        }
        return quantity * unitPrice;
    }

    public static List<ItemDTO> convertOrderItemsToDTO(List<Order_item__c> orderitems){
        List<ItemDTO> itemDTOs = new List<ItemDTO>();
        for (Order_item__c orderItem : orderitems) {
            ItemDTO itemDTO = new ItemDTO();
            itemDTO.productId = orderItem.Product2Id__c;
            itemDTO.productName = orderItem.Name;
            itemDTO.quantity = orderItem.Quantity__c;
            itemDTO.unitPrice = orderItem.Unit_price__c;
            itemDTO.totalPrice = orderItem.Total_price__c;
            itemDTO.description = orderItem.Description__c;
            itemDTO.size = orderItem.Size__c;
            itemDTO.color = orderItem.Color__c;
            itemDTOs.add(itemDTO);
        }
        return itemDTOs;
    }

}
