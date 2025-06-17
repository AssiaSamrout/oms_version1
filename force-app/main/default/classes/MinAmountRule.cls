public with sharing class MinAmountRule implements IPromotionRuleChecker {

    public static Boolean isEligible(CartDTO cartDTO, PromotionRule__c assignment) {
        if (cartDTO.totalAmount == null || assignment == null) {
            throw new IllegalArgumentException('CartDTO total amount and PromotionRuleAssignment__c cannot be null inside MinAmountRule');
        }
        
        // Map<String,Object> params = assignment.Parameters__c != null ? (Map<String,Object>) JSON.deserializeUntyped(assignment.Parameters__c) : new Map<String,Object>();
        // Decimal minAmount = (Decimal) params.get('value');
        Decimal minAmount = Decimal.valueOf(assignment.ParameterValue__c);
        System.debug('inside MinAmount Rule:'+minAmount);
        if (minAmount == null || minAmount <= 0) {
            throw new IllegalArgumentException('Minimum amount must be greater than zero inside MinAmountRule');
        }
        
        Decimal totalAmount = cartDTO.totalAmount;
        return totalAmount >= minAmount;
    }
   
}