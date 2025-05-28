public with sharing class ItemLevelPromotionHandler implements IPromotionLevelHandler{
    
    public PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO){
        return PromotionService.isEligible(adjustmentDTO.order, adjustmentDTO.orderItems, adjustmentDTO.promotion);
    }

    public Decimal calculateDiscount(AdjustmentDTO adjustmentDTO){
        return PromotionService.calculateDiscount(adjustmentDTO.order, adjustmentDTO.orderItems, adjustmentDTO.promotion);
    }

    public List<order_adjustment__C> getAdjustments(AdjustmentDTO adjustmentDTO){
        Decimal discount = calculateDiscount(adjustmentDTO);
        Id itemLevelRT = order_adjustment__c.SObjectType
                          .getDescribe()
                          .getRecordTypeInfosByDeveloperName()
                          .get('item_level')
                          .getRecordTypeId();
        List<order_adjustment__C> adjustments = new List<order_adjustment__C>();
        for(order_item__c orderItem : adjustmentDTO.orderItems){
        order_adjustment__C adjustment = new order_adjustment__C();
        adjustment.orderName__c = adjustmentDTO.order.Id;
              adjustment.order_item_Name__c = orderItem.Id;
              adjustment.promotionName__c = adjustmentDTO.promotion.Id;
              adjustment.couponName__c = (adjustmentDTO.coupon != null ? adjustmentDTO.coupon.Id : null);
              adjustment.Amount__c = discount;
              adjustment.RecordTypeId = itemLevelRT;
        adjustments.add(adjustment);
        }
        return adjustments;
    }

    public void applySideEffects(AdjustmentDTO adjustmentDTO) {
        order__c order = adjustmentDTO.order;
        List<order_item__c> orderItems = adjustmentDTO.orderItems;
        promotion__c promotion = adjustmentDTO.promotion;

        if (!order_item__c.SObjectType.getDescribe().isAccessible() ||
            !order_item__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Order Item object not accessible');
        }

        Decimal discount = calculateDiscount(adjustmentDTO);
        Decimal totalDiscount = 0;
        List<order_item__c> updatedItems = new List<order_item__c>();

        for (order_item__c orderItem : orderItems) {
            if (promotion.productId__c == orderItem.Product2Id__c) {
                orderItem.AdjustmentsAmount__c = orderItem.total_price__c - discount;
                totalDiscount += discount;
                updatedItems.add(orderItem);
            }
        }

        if (!updatedItems.isEmpty()) {
            try {
                update updatedItems;
            } catch (DmlException e) {
                System.debug('Error updating order items: ' + e.getMessage());
                throw e;
            }
        }

        // Update order total adjustments in memory
        order.Total_order_adjustments__c = (order.Total_order_adjustments__c != null ? order.Total_order_adjustments__c : 0) + totalDiscount;
    }


}