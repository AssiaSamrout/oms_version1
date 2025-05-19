public with sharing class PromotionRulesEngine {
    
    public static PromotionEligibilityResult isEligible(order__c order, List<order_item__c> orderItems, promotion__c promotion) {
        PromotionEligibilityResult result = new PromotionEligibilityResult(true);
        System.debug('inside promotionengine first log');
        System.debug(promotion.RecordType.Name);
        System.debug(promotion.RecordTypeId);

        if(order == null || orderItems == null || promotion == null){
            throw new IllegalArgumentException('Order, OrderItems and Promotion cannot be null');
        }

        if(!Schema.SObjectType.promotion__c.isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
		System.debug('before getting the rules');
        List<PromotionEligibilityRules__mdt> rules = getAllRules(promotion);
		System.debug('fetched rules inside promotionRulesEngine'+rules[0]);
        for(PromotionEligibilityRules__mdt promorule : rules){
            System.debug('inside the loop');
            Type ruleType = Type.forName(promorule.ClassName__c);
            if(ruleType == null) {
                result.isEligible = false;
                result.failureReasons.add('Class not found: ' + promorule.ClassName__c);
                continue; // Skip this rule, continue checking others
            }

            IPromotionRule ruleInstance = (IPromotionRule) ruleType.newInstance();
            System.debug('rule class instance:'+ruleInstance);
            if(!ruleInstance.isEligible(order, orderItems, promotion)){
                result.isEligible = false;
                result.failureReasons.add(promorule.RuleName__c + ' is not applicable on this order');
                System.debug('i entered to not eligible condition');
                return result;
            }
        }

        return result;
    }

    public static List<PromotionEligibilityRules__mdt> getAllRules(promotion__c promotion){
        if(!Schema.SObjectType.PromotionEligibilityRules__mdt.isAccessible()) {
            throw new SecurityException('Promotion Eligibility Rules object not accessible');
        }
        return [SELECT RuleName__c, ClassName__c, PromotionLevel__c
                FROM PromotionEligibilityRules__mdt
                WHERE PromotionLevel__c IN :new List<String>{promotion.RecordType.Name, 'Both'}
                AND IsActive__c = true];
    }
}