public with sharing class PromotionProcessor {
    /*
    * Processes a single promotion and applies its effects to the order.
    * helper method for processPromotions.

    * @param promo The promotion to process.
    * @param handler The handler for the promotion level.
    * @param dto The DTO containing order and items.
    * @param allAdjustments List to collect all adjustments made by promotions.
    * @param couponsToUpdate List to collect coupons that need to be updated.
    * @param checkoutResult The result object to update with success or failure.
    * @return Boolean indicating whether the promotion was processed successfully.
*/
    public static Boolean processSinglePromotion(
    IPromotionLevelHandler handler, 
    AdjustmentDTO adjustmentDTO,
    PromotionsCheckoutResult checkoutResult
) {
    
    try {
        PromotionEligibilityResult result = handler.evaluateEligibility(adjustmentDTO);
        if (!result.isEligible) {
            checkoutResult.isValid = false;
            checkoutResult.failureReasons = result.failureReasons;
            checkoutResult.successMessage = null;
            checkoutResult.statusCode = 422;
            return false;
        }

    } catch(PromoException e){
            System.debug('Promotion processing failed for ' + adjustmentDTO.promotion.Name + ': ' + e.getMessage()+ 'Trace: ' + e.getStackTraceString());
            checkoutResult.isValid = false;
            checkoutResult.failureReasons.add('Unexpected error during promotion');
            checkoutResult.failureReasons.add('Promotion processing failed for ' + adjustmentDTO.promotion.Name + ': ' + e.getMessage());
            checkoutResult.successMessage = null;
            return false;
        } catch (Exception e) {
            System.debug('Unexpected error during promotion processing: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString());
            checkoutResult.isValid = false;
            checkoutResult.failureReasons.add('Unexpected error during promotion processing: ' + e.getMessage());
            checkoutResult.successMessage = null;
            return false;
        }
    return true;
}

/*
    * Creates adjustments based on the promotion and order items.
    * This method retrieves adjustments from the handler and adds them to the list.
    *
    * @param adjustmentDTO The DTO containing order, items, and promotion.
    * @param checkoutResult The result object to update with success or failure.
    * @param handler The handler for the promotion level.
    * @return List of Order_adjustment__c created by the promotion.
*/

public static List<Order_adjustment__c> createAdjustments(
        AdjustmentDTO adjustmentDTO,
        PromotionsCheckoutResult checkoutResult,
        IPromotionLevelHandler handler
        ){
            List<Order_adjustment__c> allAdjustments = new List<Order_adjustment__c>();
            try{
            List<Order_adjustment__c> adjustments = handler.getAdjustments(adjustmentDTO);
            if (!adjustments.isEmpty()) {
                allAdjustments.addAll(adjustments);
            }
            }catch (Exception e) {
                System.debug('Unexpected error inside PostCheckoutProcessor.createAdjustments: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString());
                checkoutResult.isValid = false;
                checkoutResult.failureReasons.add('Unexpected error during promotion processing: ' + e.getMessage());
                checkoutResult.successMessage = null;
                return new List<Order_adjustment__c>();
            }
            return allAdjustments;
    }

    /*
    * Applies side effects of the promotion, such as updating coupon usage count.
    * This method updates the coupon usage count and returns a list of coupons to update.
    *
    * @param adjustmentDTO The DTO containing order, items, and promotion.
    * @param checkoutResult The result object to update with success or failure.
    * @param handler The handler for the promotion level.
    * @return List of Coupon__c that need to be updated.
    */

    public static List<Coupon__c> applySideEffects(
        AdjustmentDTO adjustmentDTO,
        PromotionsCheckoutResult checkoutResult,
        IPromotionLevelHandler handler
    ){
        List<Coupon__c> couponsToUpdate = new List<Coupon__c>();
        try{
        handler.applySideEffects(adjustmentDTO);

        if (adjustmentDTO.coupon != null) {
            adjustmentDTO.coupon.UsageCount__c = (adjustmentDTO.coupon.UsageCount__c ?? 0) + 1;
            couponsToUpdate.add(adjustmentDTO.coupon);
        }
    }catch(Exception e){
        System.debug('Unexpected error inside PostCheckoutProcessor.applySideEffects: ' + e.getMessage() + ' Trace: ' + e.getStackTraceString());
                checkoutResult.isValid = false;
                checkoutResult.failureReasons.add('Unexpected error during promotion processing: ' + e.getMessage());
                checkoutResult.successMessage = null;
                return new List<Coupon__c>();
    }
        return couponsToUpdate;
    }

    /*
    * Updates the coupons and adjustments in the database.
    * This method updates the coupons and inserts the adjustments into the database.
    *
    * @param couponsToUpdate List of Coupon__c to update.
    * @param allAdjustments List of Order_adjustment__c to insert.
    */

    public static void updateCouponsAndAdjustments(List<Coupon__c> couponsToUpdate, List<Order_adjustment__c> allAdjustments) {
        if (!couponsToUpdate.isEmpty()) {
            try {
                System.debug('Updating coupons: ' + couponsToUpdate);
                update couponsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating coupons: ' + e.getMessage());
                throw new DmlException('Error updating coupons: ' + e.getMessage());
            }
        }

        if (!allAdjustments.isEmpty()) {
            try {
                System.debug('Inserting adjustments: ' + allAdjustments);
                insert allAdjustments;
            } catch (DmlException e) {
                System.debug('Error inserting adjustments: ' + e.getMessage());
                throw new DmlException('Error inserting adjustments: ' + e.getMessage());
            }
        }
    }
}