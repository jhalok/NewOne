public without sharing class ACE_ScheduleTestDrive {
 @AuraEnabled
    public static Lead getLead(String Id){
        
        return [Select Id,Name,ACE_Dealer__c,ACE_Dealer__r.Name,Address,City  from Lead where ID=:Id];
    }
    @AuraEnabled
    public static List<ACE_Product_Interest__c> getAllModels(String LeadId){
        
        return [Select Id,Name from ACE_Product_Interest__c  where Lead__c =:LeadId AND
                (Interest_Category__c = 'Primary_Interest' OR Interest_Category__c = 'Other_Interest')    limit 40000];
    }
    @AuraEnabled
    public static Account getDealer(String Id){
        
        return [Select Id,Name from Account where ID=:Id];
    }
     //Edited by Krishnan
    @AuraEnabled
    public static Opportunity getOpportunity(String Id){
        
        return [Select Id,Name,Dealer__c,Dealer__r.Name from Opportunity where ID=:Id];
    }
    //Edited by Krishnan
    @AuraEnabled
    public static List<opportunity> getAllOppModels(String LeadId){
        
        return [select id,name,(select id,name from Opportunitylineitems) from opportunity  where id =:LeadId  limit 40000];
                
    }
}