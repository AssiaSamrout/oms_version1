public with sharing class ItemLevelPromotionHandler implements IPromotionLevelHandler{
    /*
     * This class handles item-level promotions, which apply to specific products within an order.
     * It evaluates eligibility, calculates discounts, and applies adjustments at the item level.
     */
    public PromotionEligibilityResult evaluateEligibility(AdjustmentDTO adjustmentDTO){
        CartDTO cartDTO = new CartDTO();
        cartDTO.totalAmount = adjustmentDTO.order.SubTotal__c;
        cartDTO.couponCode = new List<String>();
        cartDTO.couponCode.add(adjustmentDTO.coupon != null ? adjustmentDTO.coupon.Code__c : null);
        cartDTO.items=OrderItemService.convertOrderItemsToDTO(adjustmentDTO.orderItems);
        return PromotionService.isEligible(cartDTO, adjustmentDTO.itemsByProductId, adjustmentDTO.promotion);
       // return PromotionService.isEligible(adjustmentDTO.order, adjustmentDTO.orderItemsByProductId, adjustmentDTO.promotion);
    }

    public Decimal calculateDiscount(AdjustmentDTO adjustmentDTO){
        return PromotionService.calculateDiscount(adjustmentDTO.order, adjustmentDTO.orderItemsByProductId, adjustmentDTO.promotion);
    }

    public List<Order_adjustment__C> getAdjustments(AdjustmentDTO adjustmentDTO){
        Decimal discount = calculateDiscount(adjustmentDTO);
        Id itemLevelRT = Order_adjustment__c.SObjectType
                          .getDescribe()
                          .getRecordTypeInfosByDeveloperName()
                          .get('item_level')
                          .getRecordTypeId();
        List<Order_adjustment__C> adjustments = new List<Order_adjustment__C>();
        for(Order_item__c orderItem : adjustmentDTO.orderItems){
        Order_adjustment__C adjustment = new Order_adjustment__C();
        adjustment.OrderName__c = adjustmentDTO.order.Id;
              adjustment.Order_item_Name__c = orderItem.Id;
              adjustment.PromotionName__c = adjustmentDTO.promotion.Id;
              adjustment.CouponName__c = (adjustmentDTO.coupon != null ? adjustmentDTO.coupon.Id : null);
              adjustment.Amount__c = discount;
              adjustment.RecordTypeId = itemLevelRT;
              adjustment.Created_date__c = System.now().date();
                adjustment.Description__c = 'Item Level Promotion: ' + adjustmentDTO.promotion.Name + ' on Product: ' + orderItem.Product2Id__c;
        adjustments.add(adjustment);
        }
        return adjustments;
    }

    public void applySideEffects(AdjustmentDTO adjustmentDTO) {
        Order__c order = adjustmentDTO.order;
        List<Order_item__c> orderItems = adjustmentDTO.orderItems;
        promotion__c promotion = adjustmentDTO.promotion;

        if (!Order_item__c.SObjectType.getDescribe().isAccessible() ||
            !Order_item__c.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException('Order Item object not accessible');
        }

        Decimal discount = calculateDiscount(adjustmentDTO);
        Decimal totalDiscount = 0;
        List<Order_item__c> updatedItems = new List<Order_item__c>();

        // for (Order_item__c orderItem : orderItems) {
        //     if (promotion.productId__c == orderItem.Product2Id__c) {
        //         orderItem.AdjustmentsAmount__c = orderItem.Total_price__c - discount;
        //         totalDiscount += discount;
        //         updatedItems.add(orderItem);
        //     }
        // }

        List<Order_item__c> matchingItems = adjustmentDTO.orderItemsByProductId.get(promotion.ProductId__c);
        if (matchingItems != null) {
         for (Order_item__c orderItem : matchingItems) {
            orderItem.AdjustmentsAmount__c = orderItem.Total_price__c - discount;
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