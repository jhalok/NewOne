public class FullCalendarController {

    @AuraEnabled
    public static Lead getLeadRecord(String Id){
        Lead newLead = new Lead();
      
        if([select Id,Name from Lead where id =: Id].size() > 0)
        {
            
            newLead.id = Id;
        }
       
        return newLead;
    }
    @AuraEnabled
    public static List<ACE_Test_Drive__c> getEvents(String Id){
        return [SELECT Id,Name,Model__r.Name,End_Date_Time__c,Start_Date_Time__c,Test_Drive_by__c FROM ACE_Test_Drive__c ];
    }
     
}