@isTest
public with sharing class OrderControllerTest {

    private static RestRequest createRequest(String body){
        RestRequest req = new RestRequest();
        req.requestURI = '/OrderController';
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(body);
        req.addHeader('Content-Type', 'application/json');
        return req;
    }
    


}