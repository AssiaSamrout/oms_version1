public with sharing class CouponService {
    /*
     * This class provides methods to manage and validate coupons.
     * It includes methods to retrieve coupons by code, validate them, increment usage count, and change their active status.
     */
    public static Coupon__c getCouponByCouponCode(String code) {
        if(String.isBlank(code)) {
            throw new IllegalArgumentException('Coupon code cannot be null or empty');
        }

        if(!Coupon__c.SObjectType.getDescribe().isAccessible()){
            throw new SecurityException('Coupon object not accessible');
        }
        List<Coupon__c> results = [
            SELECT Id, Name, Code__c,UsageLimit__c, UsageCount__c,IsActive__c,
                   Expiration_Date__c, PromotionId__r.Id, PromotionId__r.Name,
                   PromotionId__r.DiscountValue__c, PromotionId__r.Type__c
            FROM Coupon__c
            WHERE Code__c = :code
           //   AND (UsageLimit__c = null OR UsageCount__c < UsageLimit__c)
            LIMIT 1
        ];
        return results.isEmpty() ? null : results[0];
    }

    public static List<Coupon__c> getCouponsByCouponCodes(List<String> codes) {
        if(codes == null || codes.isEmpty()) {
            throw new IllegalArgumentException('Coupon codes cannot be null or empty');
        }

        if(!Coupon__c.SObjectType.getDescribe().isAccessible()){
            throw new SecurityException('Coupon object not accessible');
        }
        List<Coupon__c> results = [
            SELECT Id, Name, Code__c,UsageLimit__c, UsageCount__c,IsActive__c,
                   Expiration_Date__c, PromotionId__r.Id, PromotionId__r.Name,
                   PromotionId__r.DiscountValue__c, PromotionId__r.Type__c
            FROM Coupon__c
            WHERE Code__c IN :codes
        ];
        return results;
    }


    public static Boolean validateCoupon(Coupon__c coupon){
        if(coupon == null) {
            throw new IllegalArgumentException('Coupon cannot be null');
        }
        if(coupon.IsActive__c == false){
            return false;
        }

        if(coupon.Expiration_Date__c != null && coupon.Expiration_Date__c < System.now()) {
            return false;
        }

        if(coupon.UsageLimit__c != null && coupon.UsageCount__c >= coupon.UsageLimit__c) {
            changeIsActive(coupon, false);
            return false;
        }
        if(coupon.PromotionId__r == null) {
            return false;
        }

        return true;

    }

    public static void incrementUsageCount(Coupon__c coupon){
        if(!Coupon__c.SObjectType.getDescribe().isUpdateable()){
            throw new SecurityException('Coupon object not updatable');
        }
        if(coupon == null){
            throw new IllegalArgumentException('Coupon cannot be null');
        }
        if(coupon.UsageCount__c == null && coupon.UsageLimit__c == null){
            throw new IllegalArgumentException('usage limit and usage count are unavailable');
        }
        coupon.UsageCount__c = (coupon.UsageCount__c == null ? 0 : coupon.UsageCount__c+1);

        update coupon;
    }

    public static void changeIsActive(Coupon__c coupon, Boolean isActive){
        if(!Coupon__c.SObjectType.getDescribe().isUpdateable()){
            throw new SecurityException('Coupon object not updatable');
        }
        if(coupon == null){
            throw new IllegalArgumentException('Coupon cannot be null');
        }
        coupon.IsActive__c = isActive;
        update coupon;
    }


}
