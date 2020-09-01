public class ACE_Enquiry_ScheduleTestDrive_Controller {
    //Edited by Krishnan
    @AuraEnabled
    public static OppWrapper getAllOppModels(String oppId){
        System.debug('oppID is '+oppId);
        List<opportunity> lstCon=[SELECT Id, name, Contact__r.city__C FROM opportunity where id =:oppId];
        //List<OpportunityContactRole> lstOppContactRole=[SELECT ID, OpportunityId, ContactId FROM OpportunityContactRole WHERE OpportunityId =:oppId];
        //System.debug('lstOppContactRole is '+lstOppContactRole);
        //List<Contact> lstCon=[select id,name,City__c from contact where id =:lstOppContactRole[0].ContactId];
        System.debug('lstCon is '+lstCon+lstCon[0].Contact__r.city__c);

        OppWrapper retunvalue =  new OppWrapper();
        retunvalue.lstOpp =[select id,name,Dealer__c,Dealer__r.Name,(select id,product2.name from Opportunitylineitems) from opportunity  where id =:oppId ];
        retunvalue.city = lstCon[0].Contact__r.city__c;
        system.debug(retunvalue);
       return retunvalue;
    }
    public class OppWrapper {
        @AuraEnabled
        public Opportunity lstOpp;
        @AuraEnabled
        public String city;
    }
}