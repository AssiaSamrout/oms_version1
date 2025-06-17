@RestResource(urlMapping='/order/create')
global with sharing class OrderController {
    /*
     * This class handles the creation of orders via a REST API endpoint.
     * It processes incoming JSON requests, validates the data, and interacts with the OrderService
     * to create orders in Salesforce.
     * It returns appropriate HTTP responses based on the success or failure of the order creation.
     */
    @HttpPost
    global static void createOrder() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
 
        try {
            String requestBody = req.requestBody.toString();
            if (String.isBlank(requestBody)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => 'Request body is empty.'
                }));
                return;
            }

            OrderResponseWrapper orderResponse = (OrderResponseWrapper) JSON.deserialize(requestBody, OrderResponseWrapper.class);
            if (orderResponse == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => 'Invalid or malformed JSON.'
                }));
                return;
            }

            OrderService orderService = new OrderService();
            
            OrderProcessingResult result = orderService.createOrder(orderResponse);
            if (!result.success) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                    'error' => result.message
                }));
                return;
            }

            Id createdOrderId = result.orderId;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'message' => 'Order created successfully.',
                'orderId' => createdOrderId
            }));

        } catch (IllegalArgumentException iae) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'error' => iae.getMessage()
            }));
        } catch (DmlException dmle) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'error' => 'DML Error: ' + dmle.getMessage()
            }));
        } catch (Exception ex) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
                'error' => 'Unexpected error: ' + ex.getMessage()
            }));
        }
    }
}
