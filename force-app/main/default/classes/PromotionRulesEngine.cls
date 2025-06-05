public with sharing class PromotionRulesEngine {
    /*
        * This class evaluates the eligibility of an order for a given promotion based on defined rules.
        * It retrieves the rules from custom metadata and applies them to the order and its items.
        * the retrieved rules are fetched based on the promotion's record type.(order level or item level)
    */
    public static PromotionEligibilityResult isEligible(Order__c order,Map<Id,List<Order_item__c>> orderItemsByProduct, Promotion__c promotion) {
       
        PromotionEligibilityResult result = new PromotionEligibilityResult(true);
        System.debug('inside promotionengine first log');
        System.debug(promotion.RecordType.Name);
        System.debug(promotion.RecordTypeId);

        if(order == null || orderItemsByProduct == null || promotion == null){
            throw new IllegalArgumentException('Order, OrderItems and Promotion cannot be null');
        }

        if(!Schema.SObjectType.Promotion__c.isAccessible()) {
            throw new SecurityException('Promotion object not accessible');
        }
        try{
		System.debug('before getting the rules');
        List<PromotionEligibilityRules__mdt> rules = getAllRules(promotion);
		System.debug('fetched rules inside promotionRulesEngine'+rules[0]);
        for(PromotionEligibilityRules__mdt promorule : rules){
            System.debug('inside the loop');
            IPromotionRule ruleInstance = PromotionRuleCacheHelper.getRuleInstance(promorule.ClassName__c);
            if(ruleInstance == null) {
                System.debug('Class not found inside PromotionRulesEngine: ' + promorule.ClassName__c);
                throw new PromoException('Class not found: ' + promorule.ClassName__c); 
            }
            System.debug('rule class instance:'+ruleInstance);
            if(!ruleInstance.isEligible(order, orderItemsByProduct, promotion)){
                //here is the bug 
                if(promotion.IsAutomatic__c){
                    System.debug('Promotion is automatic, skipping eligibility check for: ' + promorule.RuleName__c);
                    continue; // Skip this rule if the promotion is automatic
                }
                result.isEligible = false;
                result.failureReasons.add(promorule.RuleName__c + ' is not applicable on this order');

                System.debug('i entered to not eligible condition');
                return result;
            }
        }
    }catch(Exception e){
        System.debug('Exception in PromotionRulesEngine: ' + e.getMessage());
        throw new PromoException('Error evaluating promotion eligibility: ' + e.getMessage());
    }

        return result;
    }

    /*
        * Retrieves all active promotion eligibility rules for the given promotion.
        * The rules are filtered based on the promotion's record type and whether they are active.
        * 
        * @param promotion The promotion object for which to retrieve the rules.
        * @return A list of active PromotionEligibilityRules__mdt records applicable to the promotion.
    */

    public static List<PromotionEligibilityRules__mdt> getAllRules(Promotion__c promotion){
        if(!Schema.SObjectType.PromotionEligibilityRules__mdt.isAccessible()) {
            throw new SecurityException('Promotion Eligibility Rules object not accessible');
        }
        return [SELECT RuleName__c, ClassName__c, PromotionLevel__c
                FROM PromotionEligibilityRules__mdt
                WHERE PromotionLevel__c IN :new List<String>{promotion.RecordType.Name, 'Both'}
                AND IsActive__c = true];
    }
}