public with sharing class Product2service {

    public static void insertproduct2() {
        if (!Schema.sObjectType.Product2.isCreateable()) {
            System.debug('Product2 object is not creatable');
            return;
        }

        List<Product2> productlist = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            Product2 p = new Product2();
            p.Name = 'Test Product' + i;
            p.ProductCode = 'TestCode' + i;
            p.Description = 'Test Description' + i;
            p.Family = 'Test Family' + i;
            productlist.add(p);
        }

        try {
            insert productlist;
        } catch (DMLException e) {
            System.debug('Error inserting products: ' + e.getMessage());
        }

        System.debug('Products inserted successfully');
        List<Product2> insertedProducts = [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Name LIKE 'Test Product%'];
        System.debug('Inserted Products: ' + insertedProducts);
    }
}
