public with sharing class CouponValidationService {
    /*
     * This class provides methods to validate coupon codes.
     * It checks if the coupon exists, if it is valid, and retrieves the associated promotion.
     */
    public static CouponValidationResult validateCouponCode(CartWrapper cart){
        try{
        CouponValidationResult result = new CouponValidationResult();

        Coupon__c coupon = CouponService.getCouponByCouponCode(cart.couponCode[0]);
            System.debug(coupon);
            if(coupon == null){
     
            result.isValid = false;
                result.errorMessages = new List<String>();
            result.errorMessages.add('Coupon not found');
            result.coupon = null;
            result.promotion = null;
            return result;
        }

        Boolean isValid = CouponService.validateCoupon(coupon);
        if(!isValid) {
            result.isValid = false;
            result.errorMessages.add('Coupon is not valid');
            result.coupon = coupon;
            result.promotion = null;
            return result;
        }

        Promotion__c promotion = PromotionService.getPromotionById(coupon.PromotionId__c);

        if(promotion == null) {
            result.isValid = false;
            result.errorMessages = new List<String>();
            result.errorMessages.add('Promotion not found');
            result.coupon = coupon;
            result.promotion = null;
            return result;
        } 
   

        CartDTO cartDTO = new CartDTO(cart);

        PromotionEligibilityResult eligiblityResult = PromotionService.isEligible(cartDTO, cartDTO.itemsByProductId, promotion);
      
        result.isValid = eligiblityResult.isEligible;
        result.errorMessages=eligiblityResult.failureReasons;
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
            result.errorMessages = new List<String>();
            result.errorMessages.add('Query error while validating coupon: ' + e.getMessage());
            return result;
        }
        catch(IllegalArgumentException e) {
            System.debug('Validation error: ' + e.getMessage());
            CouponValidationResult result = new CouponValidationResult();
            result.coupon = null;
            result.promotion = null;
            result.isValid = false;
            result.errorMessages = new List<String>();
            result.errorMessages.add('Validation error while validating coupon: ' + e.getMessage());
            return result;
        } catch(Exception e) { 
            System.debug('Unexpected error: ' + e.getMessage());
            CouponValidationResult result = new CouponValidationResult();
            result.coupon = null;
            result.promotion = null;
            result.isValid = false;
            result.errorMessages = new List<String>();
            result.errorMessages.add('Unexpected error while validating coupon: ' + e.getMessage());
            return result;
        }

    }


    

}