
public with sharing class PostCheckoutProcessor {

    public static void processPostCheckout(order__c order, List<order_item__c> orderItems, List<String> couponCodes) {
        System.debug('Processing post checkout for order: ' + order.Id);
        if (!order__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Order object is not updateable');
        }

        List<coupon__c> coupons = CouponService.getCouponsByCouponCodes(couponCodes);
        if (coupons.isEmpty()) {
            throw new IllegalArgumentException('No valid coupons found');
        }

        // Get promotion IDs from coupons
        List<Id> promotionIds = new List<Id>();
        for (coupon__c coupon : coupons) {
            if (coupon.PromotionId__c != null) {
                promotionIds.add(coupon.PromotionId__c);
            }
        }
        System.debug('Promotion IDs from coupons: ' + promotionIds);

        // Get applicable and auto promotions together
        List<promotion__c> promotions = PromotionService.getPromotionsByIdWithAutoPromo(promotionIds);
        if (promotions.isEmpty()) {
            throw new IllegalArgumentException('No applicable promotions found');
        }

        System.debug('Found promotions: ' + promotions);

        Map<Id, coupon__c> promoToCoupon = buildPromoToCouponMap(coupons);

        // Split promotions by level
        Map<String, List<promotion__c>> promoMap = splitPromotionsByLevel(promotions);

        // Process each type of promotion
        ProcessPromotionsDTO processDTO = new ProcessPromotionsDTO();
        processDTO.order = order;
        processDTO.orderItems = orderItems;
        processDTO.promoToCoupon = promoToCoupon;
        processDTO.promotions = promoMap.get('order_level');
        processDTO.promotionType = 'order_level';
        processPromotions(processDTO);
        ProcessPromotionsDTO itemLevelDTO = new ProcessPromotionsDTO();
        itemLevelDTO.order = order;
        itemLevelDTO.orderItems = orderItems;
        itemLevelDTO.promoToCoupon = promoToCoupon;
        itemLevelDTO.promotions = promoMap.get('item_level');
        itemLevelDTO.promotionType = 'item_level';
        processPromotions(itemLevelDTO);

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
    }

    private static Map<Id, coupon__c> buildPromoToCouponMap(List<coupon__c> coupons) {
        System.debug('Building promo to coupon map');
        Map<Id, coupon__c> ptcmap = new Map<Id, coupon__c>();
        for (coupon__c c : coupons) {
            if (c.PromotionId__c != null) {
                ptcmap.put(c.PromotionId__c, c);
            }
        }
        return ptcmap;
    }

    private static Map<String, List<promotion__c>> splitPromotionsByLevel(List<promotion__c> promotions) {
        Map<String, List<promotion__c>> result = new Map<String, List<promotion__c>>{
            'order_level' => new List<promotion__c>(),
            'item_level' => new List<promotion__c>()
        };

        for (promotion__c promo : promotions) {
            if (promo.RecordType.Name == 'order_level') {
                result.get('order_level').add(promo);
            } else if (promo.RecordType.Name == 'item_level') {
                result.get('item_level').add(promo);
            }
        }

        return result;
    }

    public static void processPromotions(ProcessPromotionsDTO dto) {
        if (!coupon__c.SObjectType.getDescribe().isUpdateable() || !order_adjustment__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Coupon or Order Adjustment objects are not accessible or updatable');
        }

        if (dto.promotions.isEmpty()) {
            System.debug('No promotions found for type: ' + dto.promotionType);
            return;
        }
        System.debug('Processing promotions for type: ' + dto.promotionType);
        System.debug('Promotions: ' + dto.promotions);
        System.debug('Order: ' + dto.order);
        System.debug('Order Items: ' + dto.orderItems);
        System.debug('Promo to Coupon Map: ' + dto.promoToCoupon);
        IPromotionLevelHandler handler = PromotionLevelHandlerFactory.getPromotionLevelHandler(dto.promotionType);
        List<order_adjustment__c> allAdjustments = new List<order_adjustment__c>();
        List<coupon__c> couponsToUpdate = new List<coupon__c>();
        System.debug('inside processPromotions before the loop');
        for (promotion__c promo : dto.promotions) {
            AdjustmentDTO adjustmentDTO = new AdjustmentDTO(dto.order, dto.orderItems, promo, dto.promoToCoupon.get(promo.Id));
            PromotionEligibilityResult result = handler.evaluateEligibility(adjustmentDTO);

            if (!result.isEligible) {
                continue;
            }
            List<order_adjustment__c> adjustments = handler.getAdjustments(adjustmentDTO);
            if (!adjustments.isEmpty()) {
            allAdjustments.addAll(adjustments);
            }
            handler.applySideEffects(adjustmentDTO);

            if (adjustmentDTO.coupon != null) {
                adjustmentDTO.coupon.UsageCount__c = (adjustmentDTO.coupon.UsageCount__c != null ? adjustmentDTO.coupon.UsageCount__c : 0) + 1;
                couponsToUpdate.add(adjustmentDTO.coupon);
            }
        }

        if (!couponsToUpdate.isEmpty() || !allAdjustments.isEmpty()) {
            try {
                if (!couponsToUpdate.isEmpty()) {
                    System.debug('Updating coupons: ' + couponsToUpdate);
                    update couponsToUpdate;
                }
                if (!allAdjustments.isEmpty()){ 
                    insert allAdjustments;
                }
            } catch (DmlException e) {
                System.debug('Error updating coupons/adjustments: ' + e.getMessage());
                throw new DmlException('Insertion failed in post checkout: ' + e.getMessage());
            }
        }
    }
}
