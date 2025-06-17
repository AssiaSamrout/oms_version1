public with sharing class PromotionsCheckoutResult {
   public  Boolean isValid { get; set; }
   public String successMessage { get; set; }
   public List<String> failureReasons { get; set; }
   public Integer statusCode { get; set; }
 
   public PromotionsCheckoutResult() {
       this.isValid = true;
       this.successMessage = '';
       this.failureReasons = new List<String>();
       this.statusCode = 200; // Default to HTTP 200 OK
   }
    public PromotionsCheckoutResult(String successMessage) {
        this.isValid = true;
        this.successMessage = successMessage;
        this.failureReasons = new List<String>();
        this.statusCode = 200; // HTTP OK
    }

}