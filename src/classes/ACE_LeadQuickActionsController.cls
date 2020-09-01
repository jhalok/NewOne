public class ACE_LeadQuickActionsController {
    @AuraEnabled
    public static Lead getLeadDtls (String recId)  {
        if(String.isNotBlank(recId)){
            Lead ld=[SELECT Id,RecordTypeId,RecordType.DeveloperName,SalesIQ_ChatId__c,MobilePhone 
                     FROM Lead WHERE Id=:recId];
            return ld;
        }
        return null;
    }
}