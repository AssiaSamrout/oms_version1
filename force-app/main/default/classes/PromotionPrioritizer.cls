public with sharing class PromotionPrioritizer {
    public static List<Promotion__c> sortPromotions(List<Promotion__c> promotionsList){
        if(promotionsList == null || promotionsList.isEmpty()) {
            System.debug('no promotions to sort inside PromotionPrioritizer.sortPromotions');
            throw new IllegalArgumentException('Promotions list cannot be null or empty');
        }

        List<Promotion__c> sortedPromotions = new List<Promotion__c> (promotionsList);
        //pass custom comparator class to sort method
        sortedPromotions.sort(new PromotionComparator());
        return sortedPromotions;
    }

    private class PromotionComparator implements Comparator<Promotion__c>{

        public Integer compare(Promotion__c p1, Promotion__c p2){
            Integer result;
            result = comparePromotionLevels(p1.RecordType.Name, p2.RecordType.Name);
            if(result != 0){
                return result;
            }
            result = compareInt((p1.PriorityNumber__c).intValue(), (p2.PriorityNumber__c).intValue());
            if(result != 0){
                return result;
            }
            result = compareDiscountType(p1.Type__c, p2.Type__c);
            if(result != 0){
                return result;
            }

            return String.valueOf(p1.Id).toLowerCase().compareTo(String.valueOf(p2.Id).toLowerCase());


        }

        private Integer compareInt(Integer a, Integer b){
            if(a == null && b == null){
                return 0;
            }
            if(a == null){
                return 1;
            }
            if(b == null){
                return -1; 
            }
            if(a > b){
                return 1;
            }else if(a< b){
                return -1;
            }
            return 0;
        }

        private Integer compareDiscountType(String type1, String type2){
            
            Map<String, Integer> typePriority = new Map<String, Integer>{
                'Fixed amount' => 1,
                'Total Fixed Amount' => 2,
                'Free' => 3,
                'Amount off' => 4,
                'Percentage' => 5,
                'Free Shipping' => 6
            };

            Integer a = typePriority.get(type1);
            Integer b = typePriority.get(type2);
            
            return compareInt(a, b);

        }

        private Integer comparePromotionLevels(String level1,String level2){
            Map<String,Integer> levels = new Map<String,Integer>{
                'item_level' => 1,
                'order_level' => 2
            };
            Integer l1 = levels.get(level1);
            Integer l2 = levels.get(level2);

            return compareInt(l1, l2);


        }

        

    }

}