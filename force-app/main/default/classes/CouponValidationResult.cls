public with sharing class CouponValidationResult {
    public Boolean isValid { get; set; }
    public List<String> errorMessages { get; set; }
    public Coupon__c coupon { get; set; }
    public Promotion__c promotion { get; set; }

}