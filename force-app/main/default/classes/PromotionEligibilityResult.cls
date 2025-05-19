public with sharing class PromotionEligibilityResult {
    public Boolean isEligible { get; set; }
    public List<String> failureReasons { get; set;}

    public PromotionEligibilityResult(Boolean isEligible){
        this.isEligible = isEligible;
        this.failureReasons = new List<String>();
    }

}