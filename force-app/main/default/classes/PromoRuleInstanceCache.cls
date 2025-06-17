public with sharing class PromoRuleInstanceCache {
    private static Map<String,IPromotionRuleChecker> ruleCache = new Map<String,IPromotionRuleChecker>();
    /**
     * Retrieves an instance of the promotion rule class from the cache or creates a new instance if not cached.
     * 
     * @param ruleName The name of the promotion rule class.
     * @return An instance of the IPromotionRuleChecker interface.
     */
    public static IPromotionRuleChecker getRuleInstance(String className){
        if(className == null || String.isBlank(className)){
            throw new IllegalArgumentException('Rule class name cannot be null or empty');
        }

        if(ruleCache.containsKey(className)){
            return ruleCache.get(className);
        }
        try{
            Type ruleType = Type.forName(className);
            if(ruleType == null){
                throw new IllegalArgumentException('Rule class not found: ' + className);
            }
            IPromotionRuleChecker ruleInstance = (IPromotionRuleChecker) ruleType.newInstance();
            ruleCache.put(className, ruleInstance);
            System.debug('Rule instance created and cached for: ' + className);
            return ruleInstance;
        }catch(Exception e){
            System.debug('Exception in PromoRuleInstanceCache: ' + e.getMessage());
            throw new PromoException('Error retrieving rule instance: ' + e.getMessage());
        }

}
}