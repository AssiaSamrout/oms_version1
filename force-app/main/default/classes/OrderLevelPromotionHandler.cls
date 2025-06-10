    /*
     * This class handles order-level promotions, which apply to the entire order rather than individual items.
     * It evaluates eligibility, calculates discounts, and applies adjustments at the order level.
     */
public with sharing class OrderLevelPromotionHandler implements IPromotionLevelHandler {
    public PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO) {
        CartDTO cartDTO = new CartDTO();
        cartDTO.totalAmount = adjustmentDTO.order.SubTotal__c;
        cartDTO.couponCode = new List<String>();
        cartDTO.couponCode.add(adjustmentDTO.coupon != null ? adjustmentDTO.coupon.Code__c : null);
        cartDTO.items=OrderItemService.convertOrderItemsToDTO(adjustmentDTO.orderItems);
        return PromotionService.isEligible(cartDTO, adjustmentDTO.itemsByProductId, adjustmentDTO.promotion);
        //return PromotionService.isEligible(adjustmentDTO.order, adjustmentDTO.orderItemsByProductId, adjustmentDTO.promotion);
    }

    public Decimal calculateDiscount(AdjustmentDTO adjustmentDTO) {
        return PromotionService.calculateDiscount(adjustmentDTO.order, adjustmentDTO.orderItemsByProductId, adjustmentDTO.promotion);
    }

    public List<Order_adjustment__c> getAdjustments(AdjustmentDTO adjustmentDTO) {
        Decimal discount = calculateDiscount(adjustmentDTO);
        Id orderLevelRT = Schema.SObjectType.Order_adjustment__c
                            .getRecordTypeInfosByDeveloperName()
                            .get('order_level')
                            .getRecordTypeId();

        Order_adjustment__c adjustment = new Order_adjustment__c();
        adjustment.orderName__c = adjustmentDTO.order.Id;
        adjustment.order_item_Name__c = null;
        adjustment.promotionName__c = adjustmentDTO.promotion.Id;
        adjustment.couponName__c = (adjustmentDTO.coupon!= null ? adjustmentDTO.coupon.Id : null);
        adjustment.Amount__c = discount;
        adjustment.RecordTypeId = orderLevelRT;
        adjustment.Description__c = 'Order Level Promotion: ' + adjustmentDTO.promotion.Name;

        System.debug('Order Level Adjustment inside getAdjustments orderlevel handler class: ' + adjustment);

        return new List<Order_adjustment__c> { adjustment };
    }

    public void applySideEffects(AdjustmentDTO adjustmentDTO) {
        Decimal discount = calculateDiscount(adjustmentDTO);
        adjustmentDTO.order.Total_order_adjustments__c = 
            (adjustmentDTO.order.Total_order_adjustments__c != null 
            ? adjustmentDTO.order.Total_order_adjustments__c 
            : 0) + discount;

            System.debug('Total order adjustments after applying side effects: ' + adjustmentDTO.order.Total_order_adjustments__c);
    }
}
