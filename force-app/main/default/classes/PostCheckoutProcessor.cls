public with sharing class PostCheckoutProcessor {
    /*
        * This method processes the post-checkout actions for an order.
        * It applies promotions, updates order adjustments, and calculates the total order amount.
        *it uses a helper method to process promotions based on their level (order or item).
        * It checks if the order object is updateable and retrieves applicable promotions and coupons.

        * @param order The order to process.
        * @param orderItems The list of order items associated with the order.
        * @param couponCodes The list of coupon codes to apply to the order.
        * @throws SecurityException if the Order object is not updateable.
        * @throws IllegalArgumentException if no valid coupons or applicable promotions are found.
    */
    public static void processPostCheckout(order__c order, List<order_item__c> orderItems, List<String> couponCodes){

        //check if order object is updateable
        if(!order__c.SObjectType.getDescribe().isUpdateable()){
            throw new SecurityException('Order object is not updateable');
        }

        //get all coupons by coupon codes
        List<coupon__c> coupons = CouponService.getCouponsByCouponCodes(couponCodes);
        if(coupons.isEmpty()){
            throw new IllegalArgumentException('No valid coupons found');
        }
        
        //get auto applicable promotions
        List<promotion__c> autoPromotions = PromotionService.getAutoApplicablePromotions();
        //check if auto promotions are empty
        if(autoPromotions.isEmpty()){
            System.debug('No auto promotions found');
        }
        //add auto applicable promotionIds to a list
        List<Id> promotionIds = new List<Id>();
        for(coupon__c coupon : coupons){
            if(coupon.PromotionId__c != null){
                promotionIds.add(coupon.PromotionId__c);
            }
        }
        //get applicable promotions by promotionIds
        List<promotion__c> applicablePromotions = new List<promotion__c>();
        applicablePromotions = PromotionService.getPromotionsByIds(promotionIds);
        if(applicablePromotions.isEmpty()){
            System.debug('No applicable promotions found inside processPostCheckout');
            throw new IllegalArgumentException('No applicable promotions found');
        }

        //map promotionId to coupon
        Map<Id, coupon__c> promoToCoupon = new Map<Id, coupon__c>();
        for (coupon__c c : coupons) {
            if (c.PromotionId__c != null) {
                promoToCoupon.put(c.PromotionId__c, c);
            }
        }
        //spit promotions into order level and item level
        List<promotion__c> orderLevelPromos = new List<promotion__c>();
        List<promotion__c> itemLevelPromos = new List<promotion__c>();

        for (promotion__c promo : autoPromotions) {
            if (promo.RecordType.Name == 'order_level') {orderLevelPromos.add(promo);}
            else if (promo.RecordType.Name == 'item_level') {itemLevelPromos.add(promo);}
        }
        for(promotion__c promo : applicablePromotions){
            if (promo.RecordType.Name == 'order_level') {orderLevelPromos.add(promo);}
            else if (promo.RecordType.Name == 'item_level') {itemLevelPromos.add(promo);}
        }
        //call processPromotions for order level promotions
        ProcessPromotionsDTO orderLevelDTO = new ProcessPromotionsDTO();
        orderLevelDTO.order = order;
        orderLevelDTO.orderItems = orderItems;
        orderLevelDTO.promotions = orderLevelPromos;
        orderLevelDTO.promoToCoupon = promoToCoupon;
        orderLevelDTO.promotionType = 'order_level';
        processPromotions(orderLevelDTO);
        //call processPromotions for item level promotions
        ProcessPromotionsDTO itemLevelDTO = new ProcessPromotionsDTO();
        itemLevelDTO.order = order;
        itemLevelDTO.orderItems = orderItems;
        itemLevelDTO.promotions = itemLevelPromos;
        itemLevelDTO.promoToCoupon = promoToCoupon;
        itemLevelDTO.promotionType = 'item_level';
        processPromotions(itemLevelDTO);
        //calculate total order adjustments
        order.NetTotal__c = OrderService.adjustTotalAmount(order.SubTotal__c, (order.Total_order_adjustments__c != null ? order.Total_order_adjustments__c : 0));
        try {
            update order;
        } catch (DmlException e) {
            System.debug('Error updating order: ' + e.getMessage());
            throw new DmlException('Error updating order: ' + e.getMessage());
        }

    }

    /*
        * This method processes promotions based on the provided ProcessPromotionsDTO.
        * It evaluates the eligibility of each promotion, applies adjustments, and updates coupons.
        * It uses a factory to get the appropriate handler for the promotion level.
        *
        * @param processPromotionsDTO The DTO containing order, order items, promotions, and coupon mapping.
        * @throws SecurityException if the coupon or order adjustment objects are not accessible or updatable.
    */
    public static void processPromotions(ProcessPromotionsDTO processPromotionsDTO){

        //check accessibility and updatibility of coupons and adjustments
        if(!coupon__c.SObjectType.getDescribe().isUpdateable() || !order_adjustment__c.SObjectType.getDescribe().isUpdateable()){
            throw new SecurityException('Coupon or Order Adjustment objects are not accessible or updatable');
        }

        order__c order = processPromotionsDTO.order;
        List<order_item__c> orderItems = processPromotionsDTO.orderItems;
        List<promotion__c> promotions = processPromotionsDTO.promotions;
        Map<Id, coupon__c> promoToCoupon = processPromotionsDTO.promoToCoupon;
        List<order_adjustment__c> allAdjustments = new List<order_adjustment__c>();
        List<coupon__c> couponsToUpdate = new List<coupon__c>();
        if(promotions.isEmpty()){
            System.debug('No promotions found');
            return;
        }
        String promotionType = processPromotionsDTO.promotionType;
        IPromotionLevelHandler handler = PromotionLevelHandlerFactory.getPromotionLevelHandler(promotionType);
        AdjustmentDTO adjustmentDTO;
        for(promotion__c promo : promotions){
           adjustmentDTO = new AdjustmentDTO(order, orderItems, promo, promoToCoupon.get(promo.Id));
           PromotionEligibilityResult result = handler.evaluateEligibility(adjustmentDTO);
            if (!result.isEligible) {continue;}
            List<order_adjustment__c> adjustments = handler.getAdjustments(adjustmentDTO);
            if (!adjustments.isEmpty()) { allAdjustments.addAll(adjustments); }
            
            handler.applySideEffects(adjustmentDTO);

            if(adjustmentDTO.coupon != null){
                adjustmentDTO.coupon.UsageCount__c = (adjustmentDTO.coupon.UsageCount__c != null ? adjustmentDTO.coupon.UsageCount__c : 0) + 1;
                couponsToUpdate.add(adjustmentDTO.coupon);
            }
        }
        if(!couponsToUpdate.isEmpty()){
            try{
                update couponsToUpdate;
                update allAdjustments;
            }catch(DmlException e){
                System.debug('Error updating coupons: ' + e.getMessage());
            }
        }

    }

}