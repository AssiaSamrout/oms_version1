public with sharing class OrderItemService {

    public class InsertResult {
        public List<order_item__c> successfulItems = new List<order_item__c>();
        public List<String> errors = new List<String>();
    }

    public static InsertResult insertOrderItems(List<OrderResponseWrapper.Item> items, Id orderId) {
        if (!order_item__c.SObjectType.getDescribe().isCreateable()) {
            throw new SecurityException('OrderItem object not creatable');
        }

        validateInput(items);

        Set<String> skus = new Set<String>();
        for (OrderResponseWrapper.Item item : items) {
            skus.add(item.sku);
        }

        Map<String, Product2> skuToProductMap = Product2Repository.findProductBySKU(skus);
        validateSkus(skus, skuToProductMap.keySet());

        List<order_item__c> orderItems = buildOrderItems(items, skuToProductMap, orderId);

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

    private static void validateInput(List<OrderResponseWrapper.Item> items) {
        for (OrderResponseWrapper.Item item : items) {
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

    private static List<order_item__c> buildOrderItems(List<OrderResponseWrapper.Item> items, Map<String, Product2> skuMap, Id orderId) {
        List<order_item__c> orderItems = new List<order_item__c>();
        for (OrderResponseWrapper.Item item : items) {
            Product2 product = skuMap.get(item.sku);
            if (product == null){ 
            continue;
            }

            order_item__c oi = new order_item__c(
                orderId__c = orderId,
                Product2Id__c = product.Id,
                Name = item.productName,
                quantity__c = item.quantity,
                unit_price__c = item.unitPrice,
                total_price__c = item.totalPrice,
                description__c = item.description
            );
            orderItems.add(oi);
        }
        return orderItems;
    }
}
