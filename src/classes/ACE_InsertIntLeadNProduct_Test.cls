/**
*   Description     :   Class used to test the ACE_InsertIntLeadNProductController functionality
*
*  
*
*   Created Date    :   14/11/2019
*
*   Revision Logs   :   V_1.0 – Created
*
*   Code Coverage   :   
*
**/
@isTest(seeAllData = false)
public class ACE_InsertIntLeadNProduct_Test {
    
    
    public static testmethod void insertLeadTestAllAreInserted(){
        //List<Lead> newLeads  = [select id,Name,MobilePhone,Status,LeadSource,Primary_Model__c,(Select Id from Product_Interests__r),Likely_Conversion_Date__c,Company,Phone,ACE_Vehicle_Model__c,partnerAccountId  from Lead];
        
        List<Lead> newLeads = new List<Lead>();
        Lead newLead = new Lead();
        newLead.LastName = 'TestLead12';
        newLead.MobilePhone = '12345678912';
        newLead.Phone = '123456789';
        newLead.Status = '	Open - Not Contacted';
        newLead.LeadSource = '	Advertisement';
        newLead.Primary_Model__c = 'Mahindra Thar';
        newLead.ACE_Vehicle_Model__c = 'Mahindra Thar';
        newLead.Likely_Conversion_Date__c = '15-45 days';
        newLead.Company = 'TestLead11';
        newLeads.add(newLead);
		insert newLeads;
        ACE_InsertIntLeadNProductController.insertLeads(newLeads);
        
    }
    public static testmethod void insertLeadNotInserted(){
        List<Lead> newLeads = new List<Lead>();
        Lead newLead = new Lead();
        newLead.LastName = 'TestLead12';
        newLead.MobilePhone = '12345678912';
        newLead.Phone = '123456789';
        newLead.Status = '	Open - Not Contacted';
        newLead.LeadSource = '	Advertisement';
        newLead.Primary_Model__c = 'Thar';
        newLead.ACE_Vehicle_Model__c = 'Thar';
        newLead.Likely_Conversion_Date__c = '15-45 days';
        newLead.Company = 'TestLead11';
        newLeads.add(newLead);
		insert newLeads;
        Account newAccount = new Account();
        newAccount.Name='testing';
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.LastName = 'TestLead12';
        newContact.MobilePhone = '12345678912';
        newContact.Phone = '123456789';
         newContact.AccountId = newAccount.Id;
        insert newContact;
        
        
        Opportunity newOpportunity = new Opportunity();
        
        newOpportunity.Name = 'testing';
        newOpportunity.AccountId = newAccount.id;
        	
        
        
        
        
        ACE_InsertIntLeadNProductController.insertLeads(newLeads);
    }
    /*
   public static testmethod void insertContactInserted(){
        List<Lead> newLeads = new List<Lead>();
        Lead newLead = new Lead();
        newLead.LastName = 'TestLead12';
        newLead.MobilePhone = '12345678912';
        newLead.Phone = '123456789';
        newLead.Status = '	Open - Not Contacted';
        newLead.LeadSource = '	Advertisement';
        newLead.Primary_Model__c = 'Thar';
        newLead.ACE_Vehicle_Model__c = 'Thar';
        newLead.Likely_Conversion_Date__c = '15-45 days';
        newLead.Company = 'TestLead11';
        newLeads.add(newLead);
        insert newLeads;
        
        Account newAccount = new Account();
        newAccount.Name = 'testing';
        insert newAccount;
        
        
        Contact newContact = new Contact();
        newContact.LastName = 'testing';
        newContact.AccountId = newAccount.id;
        newContact.MobilePhone  = '12345678912';
        insert newContact;
        
        ACE_InsertIntLeadNProductController.insertLeads(newLeads);
    } */

    
    
}