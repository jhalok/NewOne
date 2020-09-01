public with sharing class ACE_PI_PrioritizationController {
    
    @AuraEnabled
    public static Lead getLeadRecord(String leadId) {
         return [Select Id,Name From Lead Where Id =:leadId ];
    }
    @AuraEnabled
    public static List<ACE_Product_Interest__c> getExistingProducts(String Id){
        system.debug(Id);
        List<ACE_Product_Interest__c> allProducts =[select id,Product__c,Lead__c From ACE_Product_Interest__c where Lead__c =:Id];
        System.debug(allProducts);
        return allProducts;
    }
    @AuraEnabled
    public static boolean updateProductInterest(List<ACE_Product_Interest__c> allProductInterests, List<ACE_Product_Interest__c> editedPIList){
        try{
            Integer countPreferred = 0;
             for(ACE_Product_Interest__c piExisting : allProductInterests){
                for(ACE_Product_Interest__c piEdited : editedPIList){
                    System.debug('piEdited-->'+piEdited.Prefered__c);
                    if((piExisting.Prefered__c && piEdited.Prefered__c && piExisting.Id != piEdited.Id) || 
                        piEdited.Prefered__c ){
                        countPreferred++;
                    }
                    if((piExisting.Prefered__c && !piEdited.Prefered__c && piExisting.Id == piEdited.Id) ||
                     (!piExisting.Prefered__c && piEdited.Prefered__c && piExisting.Id == piEdited.Id)){
                        countPreferred--;
                    }
                }
                if(countPreferred < 1 && piExisting.Prefered__c){
                    countPreferred++;
                }
             }
             System.debug('countPreferred-->'+countPreferred);
            if(countPreferred == 1) {
                update editedPIList;
                return true;
            } else {
                return false;
            }
        } catch(Exception e){
            return false;
        }
    }
    @AuraEnabled
    public static boolean createProductInterestRecord(String selectedProduct, String currentLead){
        Boolean recordInserted = false;
       try{
        Product2 p = [select Id,Name from Product2 where Id=:selectedProduct];
        ACE_Product_Interest__c pi = new ACE_Product_Interest__c();
        //pi.Name= p.Name; 
        pi.Product__c =  selectedProduct;
        pi.Lead__c = currentLead;
        
        	insert pi;
            recordInserted = true;
        }
        catch(Exception ex){
            System.debug('=Exception='+ex);
            recordInserted = false;
        }
        
        return recordInserted;
    }
    @AuraEnabled
    public static String saveInterests(List<ACE_Product_Interest__c> productInterests){
        List<ACE_Source_Tracker__c> allSourceTrack = new List<ACE_Source_Tracker__c>();
        try{
        List<String> allProducts = new List<String>();
            for(ACE_Product_Interest__c Interest :productInterests){
                   allProducts.add(Interest.Product__c) ;
            }
            List<product2> allProductFromObject = [select id,Name from Product2 Where Id IN: allProducts];
          for(product2 product :allProductFromObject){
              for(ACE_Product_Interest__c Interest :productInterests){
                  if(Interest.Product__c == product.id){
                      Interest.Name = product.Name;
                  }
              }
          }
            insert productInterests;
            for(ACE_Product_Interest__c interest :productInterests){
                ACE_Source_Tracker__c tracker = new ACE_Source_Tracker__c();
                tracker.ACE_Product_Interest__c = interest.Id;
                tracker.ACE_Source__c  = interest.Source__c;
                tracker.ACE_SubSource__c  = 	interest.Subsource__c;
                allSourceTrack.add(tracker);
            }
            insert allSourceTrack;
             return null;
        }
         catch(Exception ex){
             system.debug('ex.getMessage();'+ex.getMessage());
           return ex.getMessage();
        }
       
    }
}