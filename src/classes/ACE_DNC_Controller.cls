public with sharing class ACE_DNC_Controller {
    @AuraEnabled
    public static List<String> getLeadDNC()
    {
        List<String> lstData=new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.DNC_Expired_In__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){
        
        lstData.add(s.getLabel());
        
        } 
        return lstData;
    } 
    
    @AuraEnabled
    public static Lead updateDNCExp(String leadId, String DNCExpValue){
       Lead ldRec = [Select Id, DNC_Expired_In__c from Lead where Id =: leadId];
        ldRec.DNC_Expired_In__c = DNCExpValue;
        update ldRec;
        return ldRec;
    }
}