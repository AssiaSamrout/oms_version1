public with sharing class Product2Repository {

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