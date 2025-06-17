public with sharing class EligibilityRulesEngine {
   
    public static PromotionEligibilityResult isEligible(CartDTO cartDTO, Promotion__c promotion){
        if(cartDTO == null || promotion == null){
            throw new IllegalArgumentException('CartDTO and Promotion cannot be null');
        }
        PromotionEligibilityResult result = new PromotionEligibilityResult(true);

        try{
            System.debug('before fetching the promotion rule instances');
            //List<PromotionRuleInstance__mdt> rules = getAllInstances(promotion);
            List<PromotionRule__c> rules = getPromotionRules(promotion);
            System.debug('after fetching promotion rule instances:'+ rules);


            for(PromotionRule__c ruleInstance: rules){
               String className = ruleInstance.RuleCondition__c;

                if(String.isBlank(className)){
                     System.debug('Class name is blank for rule instance: ' + ruleInstance.RuleCondition__c);
                     throw new PromoException('Class name cannot be blank for rule instance: ' + ruleInstance.RuleCondition__c);
                }

                IPromotionRuleChecker rule = PromoRuleInstanceCache.getRuleInstance(className);
                if(rule == null) {
                    System.debug('Class not found inside EligibilityRulesEngine: ' + className);
                    throw new PromoException('Class not found: ' + className); 
                }

                System.debug('the rule instance we got:'+ rule);
                Boolean eligible = rule.isEligible(cartDTO, ruleInstance);
                if(!eligible){
                    result.isEligible = false;
                    result.failureReasons.add(ruleInstance.RuleCondition__c + ' is not applicable on this cart');
                    System.debug('Rule not eligible: ' + ruleInstance.RuleCondition__c);
                    return result; // Early exit if any rule fails
                }

            }

        }catch(Exception e){
            System.debug('Exception in EligibilityRulesEngine: ' + e.getMessage());
            result.isEligible = false;
            result.failureReasons.add('Error evaluating promotion eligibility: ' + e.getMessage());
            return result;
        }
        result.isEligible = true;
        result.failureReasons.clear(); // Clear failure reasons if all rules passed
        return result;

   }

   public static List<PromotionRule__c> getPromotionRules(Promotion__c promotion){
        if (!Schema.sObjectType.PromotionRule__c.isAccessible()) {
        throw new PromoException('You do not have access to PromotionRule__c object.');
         }
        List<PromotionRule__c> ruleList = [
        SELECT Id, RuleCondition__c,ParameterValue__c, Promotion__c 
        FROM PromotionRule__c
        WHERE Promotion__c = :promotion.Id
    ];

    if(ruleList.isEmpty()){
        throw new PromoException('No promotion rule instances found for the given promotion');
    }
    return ruleList;

    }

//    public static List<PromotionRuleInstance__mdt> getAllInstances(Promotion__c promotion){
//         if(promotion == null){
//             throw new IllegalArgumentException('Promotion cannot be null');
//         }

//         List<PromotionRuleInstance__mdt> instances = [SELECT RuleCondition__r.ClassName__c,
//                                                         RuleCondition__r.Level__c,
//                                                         RuleCondition__r.Name__c,
//                                                         Parameters__c 
//                                                         FROM PromotionRuleInstance__mdt
//                                                         WHERE Promotion__c = :promotion.Name];
//         if(instances.isEmpty()){
//             throw new PromoException('No promotion rule instances found for the given promotion');
//         }
//         return instances;
//     }

    

}