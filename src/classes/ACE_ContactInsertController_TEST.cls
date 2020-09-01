@isTest
public class ACE_ContactInsertController_TEST {
     static testmethod void ACE_ContactInsertController_TEST(){
         Lead l = (Lead)Lead.sObjectType.newSObject(null, true);
         l.LastName='SFDC';
         l.Company='SFDC';
		 insert l;
         Contact c = new Contact();
         c.LastName='PWC';
         c.Salutation = 'Mr';
         c.Customer_Type__c = 'Individual';
         c.Communicate_To__c = 'Residence';
         
         Contact c1 = new Contact();
         c1.LastName='PWC';
         c1.Salutation = 'Mr';
         c1.Customer_Type__c = 'Individual';
         c1.Communicate_To__c = 'Residence';
         
         insert c1;
         List<Lead> leadList1 = new List<Lead>();
         for(integer j=0;j<5;j++){
         	Lead ld = new Lead();
             ld.LastName = 'SAP';
             ld.Company = 'SAP';
            leadList1.add(ld);
         }
         //insert leadList;
         
         List<Lead> leadList2 = new List<Lead>();
         for(integer j=0;j<5;j++){
         	Lead ld = new Lead();
             ld.LastName = 'Salesforce';
             ld.Company = 'Salesforce';
            leadList2.add(ld);
         }
         
        ACE_ContactInsertController.getselectOptions(l,'LeadSource');
        ACE_ContactInsertController.saveRecord(c,leadList1);
        ACE_ContactInsertController.saveLeads(leadList2);
        ACE_ContactInsertController.getContactRecord(c1.Id);
         
    }
    
}