public with sharing class PromotionsProcessor {
    public static PromotionsCheckoutResult processPromotionsEligibility(CartDTO cartDTO, List<Promotion__c> promotions){
        PromotionsCheckoutResult checkoutResult = new PromotionsCheckoutResult();
       // CartDTO cartDTO = new CartDTO();
        /*recheck promotions eligibility
         to make sure that nothing changes between the time of applying promotion to the cart 
         and the time of checkout.*/
        for(Promotion__c promotion : promotions){
            PromotionEligibilityResult result = EligibilityRulesEngine.isEligible(cartDTO, promotion);
            if(!result.isEligible){
                checkoutResult.isValid = false;
                checkoutResult.failureReasons = result.failureReasons;
                checkoutResult.statusCode =401;
                checkoutResult.successMessage = null;
                return checkoutResult;
            }
        }
        checkoutResult.isValid = true;
        checkoutResult.failureReasons = null;
        checkoutResult.statusCode = 200;
        checkoutResult.successMessage = 'all promotions are eligible';
        return checkoutResult;
    }

    public static OrderSummaryDTO applyPromotions(ProcessPromotionsDTO dto){
        List<Promotion__c> sortedPromotions = PromotionPrioritizer.sortPromotions(dto.promotions);
        System.debug('inside applyPromotions in promotionsProcessor:'+sortedPromotions);
        OrderSummaryDTO orderSummary = new OrderSummaryDTO();
        AdjustmentDTO adjustmentDTO;
        try{
        for(Promotion__c promotion : sortedPromotions){
             IPromotionApplicationStrategy strategy = PromotionStrategyFactory.getStrategy(promotion);
             System.debug('fetch strategy of the promotion:'+strategy);
             adjustmentDTO = new AdjustmentDTO(dto.order, dto.orderItems, promotion, dto.promoToCoupon.get(promotion.Id));
             strategy.applyDiscount(adjustmentDTO, orderSummary);
        }
    }catch(Exception e){
        throw new IllegalArgumentException('exception occured during apply promotions:'+e.getMessage());
    }

    System.debug('inside applyPromotions order summary result:'+orderSummary);

        return orderSummary;

    }


}