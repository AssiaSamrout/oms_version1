public with sharing class CouponValidationResult {
    public Boolean isValid { get; set; }
    public String errorMessage { get; set; }
    public coupon__c coupon { get; set; }
    public promotion__c promotion { get; set; }

}