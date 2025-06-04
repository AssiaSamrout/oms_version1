public with sharing class CouponValidationResult {
    public Boolean isValid { get; set; }
    public String errorMessage { get; set; }
    public Coupon__c coupon { get; set; }
    public Promotion__c promotion { get; set; }

}