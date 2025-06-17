@isTest
private class OrderServiceTest {

    private static OrderResponseWrapper buildValidOrderResponse() {
        String sku = 'SKU123';
        Product2 product = new Product2(Name='Test Product', StockKeepingUnit=sku, IsActive=true);
        insert product;

        Account account = new Account(Name='Test Account');
        insert account;

        ProductDTO item = new ProductDTO();
        item.sku = sku;
        item.productName = 'Test Product';
        item.quantity = 2;
        item.unitPrice = 50.0;
        item.totalPrice = 100.0;
        item.description = 'Item description';

        OrderResponseWrapper.BillingInfo billingInfo = new OrderResponseWrapper.BillingInfo();
        billingInfo.street = '123 Main St';
        billingInfo.city = 'New York';
        billingInfo.country = 'USA';
        billingInfo.email = 'billing@example.com';

        OrderResponseWrapper.ShippingAddress shippingAddress = new OrderResponseWrapper.ShippingAddress();
        shippingAddress.street = '456 Elm St';
        shippingAddress.city = 'Los Angeles';
        shippingAddress.postalCode = '90001';
        shippingAddress.country = 'USA';
        shippingAddress.email = 'customer@example.com';
        shippingAddress.phone = '1234567890';

        OrderResponseWrapper.Customer customer = new OrderResponseWrapper.Customer();
        customer.firstName = 'John';
        customer.lastName = 'Doe';
        customer.email = 'john.doe@example.com';
        customer.phone = '1234567890';
        customer.shippingAddress = shippingAddress;

        OrderResponseWrapper.Payment payment = new OrderResponseWrapper.Payment();
        payment.method = 'Credit Card';
        payment.amount = 100.0;
        payment.transactionId = 'TX123456';

        OrderResponseWrapper wrapper = new OrderResponseWrapper();
        wrapper.orderName = 'Test Order';
        wrapper.orderDate = String.valueOf(Date.today());
        wrapper.accountId = account.Id; 
        wrapper.orderStartDate = String.valueOf(Date.today());
        wrapper.poNumber = 'PO12345';
        wrapper.poDate = String.valueOf(Date.today());
        wrapper.orderAmount = 100.0;
        wrapper.status = 'Draft';
        wrapper.shippingMethod = 'Standard';
        wrapper.items = new List<ProductDTO>{ item };
        wrapper.billingInfo = billingInfo;
        wrapper.customer = customer;
        wrapper.payment = payment;
        wrapper.adjustments = new List<OrderResponseWrapper.Adjustment>();

        return wrapper;
    }

    private static void createProduct(String sku) {
        Product2 product = new Product2(Name='Product ' + sku, StockKeepingUnit=sku, IsActive=true);
        insert product;
    }
 
    @isTest
    static void testCreateOrdersuccess() {
        OrderResponseWrapper wrapper = buildValidOrderResponse();

        Test.startTest();
        OrderService service = new OrderService();
        System.debug('Wrapper item SKU: ' + wrapper.items[0].sku);

        OrderProcessingResult result = service.createOrder(wrapper);
        Test.stopTest();
        System.debug('inside success test:'+result.message);
        System.debug('Order ID: ' + result.orderId);
        System.assertEquals(true, result.success,'result should be true');
        System.assertNotEquals(null, result.orderId,'orderId should not be null');
        System.assert(result.message.contains('Order created successfully'),'message should contain success message');  
        

    }

    @isTest
    static void testCreateOrderitemInsertFailure() {
         OrderResponseWrapper wrapper = buildValidOrderResponse();

        ProductDTO badItem = new ProductDTO();
        badItem.sku = 'SKU123';
        badItem.productName = 'Invalid Product';
        badItem.quantity = 1;
        badItem.unitPrice = null;
        badItem.totalPrice = 10;
        badItem.description = 'dddddd  ggrgrtbb';

        wrapper.items = new List<ProductDTO>{ badItem };

        Test.startTest();
        OrderService service = new OrderService();
        OrderProcessingResult result = service.createOrder(wrapper);
        Test.stopTest();

        System.debug('inside failure test:'+result.success);
        System.debug('inside failure test:'+result.message);
        System.debug('Order ID: ' + result.orderId);
        System.assertEquals(false, result.success,'result should be false');
        System.assert(result.message.contains('Some order items failed to insert'),'message should contain error message');
        System.assertEquals(null, result.orderId,'orderId should be null');
    }

    @isTest
    static void testCreateOrderexceptionThrown() {

        //this works also if the sku is not present in the database
        Test.startTest();
        OrderService service = new OrderService();
        OrderProcessingResult result = service.createOrder(null);
        Test.stopTest();

        System.assertEquals(false, result.success,'result should be false');
        System.assert(result.message.startsWith('Error during order processing'),'message should start with error message');
        System.assertEquals(null, result.orderId,'errors should be empty');
    }
}
