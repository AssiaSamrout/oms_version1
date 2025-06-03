public with sharing class PromotionRuleCacheHelper {
    private static final Map<String,IPromotionRule> RULECACHE = new Map<String,IPromotionRule>();
    /*
     * Retrieves an instance of the promotion rule class from the cache or creates a new instance if not cached.
     * 
     * @param ruleName The name of the promotion rule class.
     * @return An instance of the IPromotionRule interface.
     */
    public static IPromotionRule getRuleInstance(String ruleClassName){
        if(ruleClassName == null || String.isBlank(ruleClassName)){
            throw new IllegalArgumentException('Rule class name cannot be null or empty');
        }

        if(RULECACHE.containsKey(ruleClassName)){
            return RULECACHE.get(ruleClassName);
        }
        try{
            Type ruleType = Type.forName(ruleClassName);
            if(ruleType == null){
                throw new IllegalArgumentException('Rule class not found: ' + ruleClassName);
            }
            IPromotionRule ruleInstance = (IPromotionRule) ruleType.newInstance();
            RULECACHE.put(ruleClassName, ruleInstance);
            System.debug('Rule instance created and cached for: ' + ruleClassName);
            return ruleInstance;
        }catch(Exception e){
            System.debug('Exception in PromotionRuleCacheHelper: ' + e.getMessage());
            throw new PromoException('Error retrieving rule instance: ' + e.getMessage());
        }

        
    }
}