public with sharing class OrderProcessingResult {
    public Boolean success { get; set; }
    public String message { get; set; }
    public Id orderId { get; set; }

    public OrderProcessingResult() {
        this.success = false;
        this.message = '';
    }

    public OrderProcessingResult(Boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public OrderProcessingResult(Boolean success, String message, Id orderId) {
        this.success = success;
        this.message = message;
        this.orderId = orderId;
    }
}
