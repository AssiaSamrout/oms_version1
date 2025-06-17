public with sharing class OrderLFixedAmountPromotionStrategy implements IPromotionApplicationStrategy {

    public void applyDiscount(AdjustmentDTO adjustmentDTO,OrderSummaryDTO orderData) {
        if (adjustmentDTO.promotion.DiscountValue__c == null) {
            throw new IllegalArgumentException('Discount value cannot be null');
        }
        if (adjustmentDTO.promotion.Percentage__c != null) {
            throw new IllegalArgumentException('Percentage cannot be set for fixed discount strategy');
        }
        if (adjustmentDTO.promotion.DiscountValue__c < 0) {
            throw new IllegalArgumentException('Discount value cannot be negative');
        }
       
        Decimal discountAmount= adjustmentDTO.promotion.DiscountValue__c;

        applySideEffects(adjustmentDTO,orderData, discountAmount);

    }

    public void applySideEffects(AdjustmentDTO adjustmentDTO,OrderSummaryDTO orderData,Decimal discountAmount) {
        // Implement any side effects specific to fixed amount discounts if needed
        // For example, updating order summary or logging
        System.debug('Applying side effects for fixed amount discount strategy');
        if(discountAmount == null || discountAmount <= 0) {
            System.debug('Invalid discount amount in order summary in fixedAmountDiscountStrategy: ' + discountAmount);
            throw new IllegalArgumentException('Invalid discount amount in order summary');
        }

        orderData.totalAdjustments += discountAmount;
        if(!adjustmentDTO.promotion.IsAutomatic__c){
            orderData.couponUsage += 1;
        }
        System.debug('Total adjustments after applying side effects: ' + orderData.totalAdjustments);
        System.debug('Coupon usage after applying side effects: ' + orderData.couponUsage);
        //create order adjustment record
        Id orderLevelRT = Schema.SObjectType.Order_adjustment__c
                            .getRecordTypeInfosByDeveloperName()
                            .get('order_level')
                            .getRecordTypeId();
        Order_adjustment__c adjustment = new Order_adjustment__c();
        adjustment.orderName__c = adjustmentDTO.order.Id;
        adjustment.order_item_Name__c = null;
        adjustment.promotionName__c = adjustmentDTO.promotion.Id;
        adjustment.couponName__c = (adjustmentDTO.coupon!= null ? adjustmentDTO.coupon.Id : null);
        adjustment.Amount__c = discountAmount;
        adjustment.RecordTypeId = orderLevelRT;
        adjustment.Description__c = 'Order Level Promotion: ' + adjustmentDTO.promotion.Name;
        orderData.addOrderAdjustment(adjustment);
        System.debug('Order adjustment created: ' + adjustment);
        
    }

}