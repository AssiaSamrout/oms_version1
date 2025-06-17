
    /**
 * A Data Transfer Object (DTO) to encapsulate a summary of order-related data,
 * including adjustments, items, couponUsage count, and total adjustment amount.
 * This class is designed to be a lightweight container for passing data between
 * different layers or methods without exposing full SObjects unnecessarily to
 * reduce coupling and have one source of truth for adding and adjusting order data.
 */
public with sharing class OrderSummaryDTO {


    /**
     * A list of order adjustment records associated with the order.
     * Replace 'Order_adjustment__c' with your actual Order Adjustment SObject or a more generic DTO if needed.
     */
    public List<Order_adjustment__c> orderAdjustments { get; set; }

    /**
     * A list of order item records.
     * Replace 'Order_item__c' with your actual Order Item SObject (e.g., standard OrderItem or a custom one
     */
    public List<Order_item__c> orderItems { get; set; }

    /**
     * An integer field to track couponUsage,
     * which could represent anything from a count of operations to a specific threshold.
     */
    public Integer couponUsage { get; set; }

    /**
     * A decimal field representing the total monetary amount of all adjustments.
     */
    public Decimal totalAdjustments { get; set; }

    /**
     * Constructor for OrderSummaryDTO.
     * Initializes the lists to prevent NullPointerExceptions when adding elements.
     */
    public OrderSummaryDTO() {
        this.orderAdjustments = new List<Order_adjustment__c>();
        this.orderItems = new List<Order_item__c>();
        this.couponUsage = 0; // Initialize couponUsage to 0
        this.totalAdjustments = 0; // Initialize totalAdjustments to 0
        // couponUsage and totalAdjustments will be initialized to their default values (0 for Integer, null for Decimal)
        // or can be explicitly set if a default non-zero value is desired.
    }

    /**
     * Overloaded constructor to allow for initial population of fields.
     * @param initialOrderAdjustments A list of order adjustment records.
     * @param initialOrderItems A list of order item records.
     * @param initialcouponUsage The initial value for the couponUsage count.
     * @param initialTotalAdjustments The initial total amount for adjustments.
     */
    public OrderSummaryDTO(
        List<Order_adjustment__c> initialOrderAdjustments,
        List<Order_item__c> initialOrderItems,
        Integer initialcouponUsage,
        Decimal initialTotalAdjustments
    ) {
        this.orderAdjustments = (initialOrderAdjustments != null) ? initialOrderAdjustments : new List<Order_adjustment__c>();
        this.orderItems = (initialOrderItems != null) ? initialOrderItems : new List<Order_item__c>();
        this.couponUsage = initialcouponUsage;
        this.totalAdjustments = initialTotalAdjustments;
    }

    public void addOrderAdjustment(Order_adjustment__c adjustment) {
        if (adjustment != null) {
            this.orderAdjustments.add(adjustment);
        }
    }
   
}

