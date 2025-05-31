/*
    * OrderResponseWrapper.cls
    * 
    * This class is used to encapsulate the response structure for order details.
    * It includes information about the order, customer, billing info, items, adjustments, and payment.
    *
*/

public with sharing class OrderResponseWrapper {
    
    public String orderName;
    public String orderDate;
    public String accountId;
    public BillingInfo billingInfo;
    public Customer customer;
    public String orderStartDate;
    public String poNumber;
    public String poDate;
    public Decimal orderAmount;
    public String status;
    public List<ItemDTO> items;
    public List<Adjustment> adjustments;
    public Payment payment;
    public String shippingMethod;

    public class BillingInfo {
        public String street;
        public String city;
        public String country;
        public String email;
    }

    public class Customer {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public ShippingAddress shippingAddress;
    }

    public class ShippingAddress {
        public String street;
        public String city;
        public String postalCode;
        public String country;
        public String email;
        public String phone;
    }

    public class Adjustment {
        public String type;
        public String code;
        public Decimal amount;
        public String description;
    }

    public class Payment {
        public String method;
        public Decimal amount;
        public String transactionId;
    }

}