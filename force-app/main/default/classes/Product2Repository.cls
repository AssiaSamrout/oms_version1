public with sharing class Product2Repository {
    /*
        * This method retrieves Product2 records based on a set of SKUs.
        * It checks for accessibility of the Product2 object and the StockKeepingUnit field.
        * It returns a map where the key is the SKU and the value is the corresponding Product2 record.
        *
        * @param skuSet A set of SKUs to search for in Product2 records.
        * @return A map of SKU to Product2 records.
        * @throws SecurityException if the Product2 object or StockKeepingUnit field is not accessible.
        
    */
    public static Map<String, Product2> findProductBySKU(Set<String> skuSet) {

        if (!Product2.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Product2 object not accessible');
        }
        if (!Schema.Product2.StockKeepingUnit.getDescribe().isAccessible()) {
            throw new SecurityException('Product2 SKU field not accessible');
        }
        System.debug('SKUs requested: ' + skuSet);

        List<Product2> products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :skuSet];
        
        System.debug('Products found: ' + products);

        Map<String, Product2> skuToProductMap = new Map<String, Product2>();
        for (Product2 product : products) {
            skuToProductMap.put(product.StockKeepingUnit, product);
        }
        return skuToProductMap;
    }

}