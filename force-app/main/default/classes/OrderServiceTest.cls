@isTest
private class OrderServiceTest {

    private static OrderResponseWrapper buildValidOrderResponse() {
        String sku = 'SKU123';
        Product2 product = new Product2(Name='Test Product', StockKeepingUnit=sku, IsActive=true);
        insert product;

        OrderResponseWrapper.Item item = new OrderResponseWrapper.Item();
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
        wrapper.accountId = UserInfo.getUserId(); 
        wrapper.orderStartDate = String.valueOf(Date.today());
        wrapper.poNumber = 'PO12345';
        wrapper.poDate = String.valueOf(Date.today());
        wrapper.orderAmount = 100.0;
        wrapper.status = 'Draft';
        wrapper.shippingMethod = 'Standard';
        wrapper.items = new List<OrderResponseWrapper.Item>{ item };
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
    static void testCreateOrder_success() {
        OrderResponseWrapper wrapper = buildValidOrderResponse();

        Test.startTest();
        OrderService service = new OrderService();
        OrderProcessingResult result = service.createOrder(wrapper);
        Test.stopTest();

        System.assertEquals(true, result.success,'result should be true');
        System.assertNotEquals(null, result.orderId,'orderId should not be null');
        System.assert(result.message.contains('Order created successfully'),'message should contain success message');  
    }

    @isTest
    static void testCreateOrder_itemInsertFailure() {
        createProduct('SKU123');

        OrderResponseWrapper.Item badItem = new OrderResponseWrapper.Item();
        badItem.sku = 'INVALID_SKU';
        badItem.productName = 'Invalid Product';
        badItem.quantity = 1;
        badItem.unitPrice = 10;
        badItem.totalPrice = 10;
        badItem.description = 'Bad SKU';

        OrderResponseWrapper wrapper = new OrderResponseWrapper();
        wrapper.items = new List<OrderResponseWrapper.Item>{ badItem };

        Test.startTest();
        OrderService service = new OrderService();
        OrderProcessingResult result = service.createOrder(wrapper);
        Test.stopTest();

        System.assertEquals(false, result.success,'result should be false');
        System.assert(result.message.contains('Some order items failed to insert'),'message should contain error message');
        System.assertEquals(null, result.orderId,'orderId should be null');
    }

    @isTest
    static void testCreateOrder_exceptionThrown() {
        Test.startTest();
        OrderService service = new OrderService();
        OrderProcessingResult result = service.createOrder(null);
        Test.stopTest();

        System.assertEquals(false, result.success,'result should be false');
        System.assert(result.message.startsWith('Error during order processing'),'message should start with error message');
        System.assertEquals(null, result.orderId,'errors should be empty');
    }
}
