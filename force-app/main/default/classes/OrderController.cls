@RestResource(urlMapping='/order/*')
global with sharing class OrderController {
    @HttpPost
    global static void createOrder() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String requestBody = req.requestBody.toString();
            if (String.isBlank(requestBody)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('Request body is empty.');
                return;
            }

            OrderResponseWrapper orderResponse = (OrderResponseWrapper) JSON.deserialize(requestBody, OrderResponseWrapper.class);
            OrderService orderService = new OrderService();
            Id createdOrderId = orderService.createOrder(orderResponse);

            res.statusCode = 201;
            res.responseBody = Blob.valueOf('Order created successfully. ID: ' + createdOrderId);

        } catch (DmlException dmle) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('DML Error: ' + dmle.getMessage());
        } catch (IllegalArgumentException iae) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Invalid input: ' + iae.getMessage());
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Unexpected error: ' + ex.getMessage());
        }
    }
}
