public with sharing class CouponValidationService {
    /*
     * This class provides methods to validate coupon codes.
     * It checks if the coupon exists, if it is valid, and retrieves the associated promotion.
     */
    public static CouponValidationResult validateCouponCode(String couponCode){
        try{
        CouponValidationResult result = new CouponValidationResult();
        coupon__c coupon = CouponService.getCouponByCouponCode(couponCode);
        if(coupon == null) {
            result.isValid = false;
            result.errorMessage = 'Coupon not found';
            result.coupon = null;
            result.promotion = null;
            return result;
        }

        Boolean isValid = CouponService.validateCoupon(coupon);
        if(!isValid) {
            result.isValid = false;
            result.errorMessage = 'Coupon is not valid';
            result.coupon = coupon;
            result.promotion = null;
            return result;
        }

        promotion__c promotion = PromotionService.getPromotionById(coupon.PromotionId__c);
        if(promotion == null) {
            result.isValid = false;
            result.errorMessage = 'Promotion not found';
            result.coupon = coupon;
            result.promotion = null;
            return result;
        } 
        
        result.isValid = true;
        result.errorMessage = null;
        result.coupon = coupon;
        result.promotion = promotion;
        return result;
        }
        catch(QueryException e) {
            System.debug('Query error: ' + e.getMessage());
            CouponValidationResult result = new CouponValidationResult();
            result.coupon = null;
            result.promotion = null;
            result.isValid = false;
            result.errorMessage = 'Database query error while validating coupon '+ e.getMessage();
            return result;
        }
        catch(IllegalArgumentException e) {
            System.debug('Validation error: ' + e.getMessage());
            CouponValidationResult result = new CouponValidationResult();
            result.coupon = null;
            result.promotion = null;
            result.isValid = false;
            result.errorMessage = 'Invalid argument inside validatingCoupon: ' + e.getMessage();
            return result;
        } catch(Exception e) { 
            System.debug('Unexpected error: ' + e.getMessage());
            CouponValidationResult result = new CouponValidationResult();
            result.coupon = null;
            result.promotion = null;
            result.isValid = false;
            result.errorMessage = 'Unexpected error while validating coupon: ' + e.getMessage();
            return result;
        }

    }


    

}