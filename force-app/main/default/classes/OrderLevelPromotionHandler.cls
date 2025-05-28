public with sharing class OrderLevelPromotionHandler implements IPromotionLevelHandler {

    public PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO) {
        return PromotionService.isEligible(adjustmentDTO.order, adjustmentDTO.orderItems, adjustmentDTO.promotion);
    }

    public Decimal calculateDiscount(AdjustmentDTO adjustmentDTO) {
        return PromotionService.calculateDiscount(adjustmentDTO.order, adjustmentDTO.orderItems, adjustmentDTO.promotion);
    }

    public List<order_adjustment__c> getAdjustments(AdjustmentDTO adjustmentDTO) {
        Decimal discount = calculateDiscount(adjustmentDTO);
        Id orderLevelRT = Schema.SObjectType.order_adjustment__c
                            .getRecordTypeInfosByDeveloperName()
                            .get('order_level')
                            .getRecordTypeId();

        order_adjustment__c adjustment = new order_adjustment__c();
        adjustment.orderName__c = adjustmentDTO.order.Id;
        adjustment.order_item_Name__c = null;
        adjustment.promotionName__c = adjustmentDTO.promotion.Id;
        adjustment.couponName__c = (adjustmentDTO.coupon!= null ? adjustmentDTO.coupon.Id : null);
        adjustment.Amount__c = discount;
        adjustment.RecordTypeId = orderLevelRT;

        return new List<order_adjustment__c> { adjustment };
    }

    public void applySideEffects(AdjustmentDTO adjustmentDTO) {
        Decimal discount = calculateDiscount(adjustmentDTO);
        adjustmentDTO.order.Total_order_adjustments__c = 
            (adjustmentDTO.order.Total_order_adjustments__c != null 
            ? adjustmentDTO.order.Total_order_adjustments__c 
            : 0) + discount;
    }
}
