public with sharing class PostCheckoutProcessor {
    /*
     * This class processes post-checkout operations for an order, applying promotions and updating the order.
     * It validates coupons, retrieves applicable promotions, and applies them to the order and its items.
     * The results of the processing are returned in a PromotionsCheckoutResult object.
     * 
     * @param order The order to process.
     * @param orderItems The list of order items associated with the order.
     * @param couponCodes The list of coupon codes to apply.
     */
    public static PromotionsCheckoutResult processPostCheckout(Order__c order, List<Order_item__c> orderItems, List<String> couponCodes) {
        System.debug('Processing post checkout for order: ' + order.Id);
        if (!Order__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Order object is not updateable');
        }

        List<Coupon__c> coupons = CouponService.getCouponsByCouponCodes(couponCodes);
        if (coupons.isEmpty()) {
            throw new IllegalArgumentException('No valid coupons found');
        }
        validateCoupons(coupons);
        // Get promotion IDs from coupons
        List<Id> promotionIds = new List<Id>();
        for (Coupon__c coupon : coupons) {
            if (coupon.PromotionId__c != null) {
                promotionIds.add(coupon.PromotionId__c);
            }
        }
        System.debug('Promotion IDs from coupons: ' + promotionIds);

        // Get applicable and auto promotions together
        List<Promotion__c> promotions = PromotionService.getPromotionsByIdWithAutoPromo(promotionIds);
        if (promotions.isEmpty()) {
            throw new IllegalArgumentException('No applicable promotions found');
        }

        System.debug('Found promotions: ' + promotions);

        Map<Id, Coupon__c> promoToCoupon = buildPromoToCouponMap(coupons);

        // Split promotions by level
        Map<String, List<Promotion__c>> promoMap = splitPromotionsByLevel(promotions);
        PromotionsCheckoutResult checkoutResult;

        if(!promoMap.get('order_level').isEmpty()){
        // Process each type of promotion
        ProcessPromotionsDTO processDTO = new ProcessPromotionsDTO();
        processDTO.order = order;
        processDTO.orderItems = orderItems;
        processDTO.promoToCoupon = promoToCoupon;
        processDTO.promotions = promoMap.get('order_level');
        processDTO.promotionType = 'order_level';
        
        checkoutResult = processPromotions(processDTO);
        
        if (!checkoutResult.isValid) {
            return checkoutResult;
        }
    }

        if(!promoMap.get('item_level').isEmpty()){
        ProcessPromotionsDTO itemLevelDTO = new ProcessPromotionsDTO();
        itemLevelDTO.order = order;
        itemLevelDTO.orderItems = orderItems;
        itemLevelDTO.promoToCoupon = promoToCoupon;
        itemLevelDTO.promotions = promoMap.get('item_level');
        itemLevelDTO.promotionType = 'item_level';

        checkoutResult= processPromotions(itemLevelDTO);
       
        if (!checkoutResult.isValid) {
            return checkoutResult;
        } 
    }

        // Recalculate and update order
        order.NetTotal__c = OrderService.adjustTotalAmount(
            order.SubTotal__c,
            (order.Total_order_adjustments__c != null ? order.Total_order_adjustments__c : 0)
        );

        try {
            update order;
        } catch (DmlException e) {
            throw new DmlException('Error updating order: ' + e.getMessage());
        }

        
        return checkoutResult;
    }

    /*
    * Processes promotions for the given order and order items.
    * This method applies all applicable promotions to the order and its items,
    * updating the order adjustments and coupons as necessary using the needed classes.
    *
    * @param dto The DTO containing order, order items, promotions, and coupon mappings.
    */

    public static PromotionsCheckoutResult processPromotions(ProcessPromotionsDTO dto) {
        PromotionsCheckoutResult checkoutResult = new PromotionsCheckoutResult();
        System.debug('Processing promotions for type: ' + dto.promotionType);
        if (!Coupon__c.SObjectType.getDescribe().isUpdateable() || !Order_adjustment__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Coupon or Order Adjustment objects are not accessible or updatable');
        }

        if (dto.promotions.isEmpty()) {
            System.debug('No promotions found for type: ' + dto.promotionType);
            throw new IllegalArgumentException('No promotions found for type: ' + dto.promotionType);
        }

        System.debug('Processing promotions inside PostCheckoutProcessor.processPromotions method: ' + dto.promotionType);
    
        IPromotionLevelHandler handler = PromotionLevelHandlerFactory.getPromotionLevelHandler(dto.promotionType);
        List<Order_adjustment__c> allAdjustments = new List<Order_adjustment__c>();
        List<Coupon__c> couponsToUpdate = new List<Coupon__c>();
        System.debug('inside processPromotions before the loop');
        AdjustmentDTO adjustmentDTO = new AdjustmentDTO();
        Integer counter = 0;
        for (Promotion__c promo : dto.promotions) {
            counter++;
            adjustmentDTO.order = dto.order;
            adjustmentDTO.orderItems = dto.orderItems;
            adjustmentDTO.promotion = promo;
            adjustmentDTO.coupon = dto.promoToCoupon.get(promo.Id);
        if (!processSinglePromotion(handler, adjustmentDTO, checkoutResult)) {
            if(promo.IsAutomatic__c) {
                System.debug('Skipping automatic promotion: ' + promo.Name);
                continue; // Skip automatic promotions if not eligible
            }
            return checkoutResult; 
        }
        System.debug('PROCESSING PROMOTION: ' + promo.Name + ', COUNTER: ' + counter);

        allAdjustments.addAll(createAdjustments(adjustmentDTO, checkoutResult, handler));
        System.debug('Adjustments created for promotion: ' + promo.Name + ', Adjustments: ' + allAdjustments);
        couponsToUpdate.addAll(applySideEffects(adjustmentDTO, checkoutResult, handler));
    }
        System.debug('inisde processPromotions after the loop, before DML operations'+ ' couponsToUpdate: ' + couponsToUpdate + ', allAdjustments: ' + allAdjustments);
        // Update coupons and adjustments
        if (!couponsToUpdate.isEmpty() || !allAdjustments.isEmpty()) {
            updateCouponsAndAdjustments(couponsToUpdate, allAdjustments);
        }
        System.debug('Promotions processed successfully for type: ' + dto.promotionType);
        checkoutResult.isValid = true;
        checkoutResult.failureReasons = new List<String>();
        checkoutResult.statusCode = 200;
        checkoutResult.successMessage = 'Promotions processed successfully for type: ' + dto.promotionType;
        return checkoutResult;
        
    }

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
    private static Boolean processSinglePromotion(
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

    private static List<Order_adjustment__c> createAdjustments(
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

    private static List<Coupon__c> applySideEffects(
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

    private static void updateCouponsAndAdjustments(List<Coupon__c> couponsToUpdate, List<Order_adjustment__c> allAdjustments) {
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

    


   /*
        * Validates the coupons to ensure they are valid and applicable.
        * Throws an exception if any coupon is invalid.
        * helper method
        *
        * @param coupons The list of coupons to validate.
    */
    
    private static void validateCoupons(List<Coupon__c> coupons) {
        for (Coupon__c coupon : coupons) {
            if (!CouponService.validateCoupon(coupon)) {
                throw new IllegalArgumentException('Invalid coupon: ' + coupon.Code__c);
            }
        }
    }

    /*
        * Builds a map of Promotion Ids to Coupon objects for quick lookup.
        * helper method
        * 
        * @param coupons The list of coupons to build the map from.
        * @return A map where the key is the Promotion Id and the value is the corresponding Coupon object.
    */

    private static Map<Id, Coupon__c> buildPromoToCouponMap(List<Coupon__c> coupons) {
        System.debug('Building promo to coupon map');
        Map<Id, Coupon__c> ptcmap = new Map<Id, Coupon__c>();
        for (Coupon__c c : coupons) {
            if (c.PromotionId__c != null) {
                ptcmap.put(c.PromotionId__c, c);
            }
        }
        return ptcmap;
    }

    /*
        * Splits the list of promotions into two categories: order-level and item-level.
        * helper method
        *
        * @param promotions The list of promotions to split.
        * @return A map where the key is the promotion level ('order_level' or 'item_level') and the value is a list of promotions for that level.
    */

    private static Map<String, List<Promotion__c>> splitPromotionsByLevel(List<Promotion__c> promotions) {
        Map<String, List<Promotion__c>> result = new Map<String, List<Promotion__c>>{
            'order_level' => new List<Promotion__c>(),
            'item_level' => new List<Promotion__c>()
        };

        for (Promotion__c promo : promotions) {
            if (promo.RecordType.Name == 'order_level') {
                result.get('order_level').add(promo);
            } else if (promo.RecordType.Name == 'item_level') {
                result.get('item_level').add(promo);
            }
        }

        return result;
    }

}
