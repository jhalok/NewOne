@isTest
public class ACE_Assignagent_TEST {
    static testmethod void  ACE_Assignagent_TEST1() {
        
        Account acc = new Account();
        acc.NAme='Salesforce';
        acc.Assigned_Agent__c = UserInfo.getUserId();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SAP';
        opp.StageName='Enquiry';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        // opp.Assigned_Agent__c =u.id;
        //insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserpwc@testorg.com');
        //insert u;
        
        ACE_Assignagent.getUsers();
        ACE_Assignagent.getAccountList('SAP');
        ACE_Assignagent.assignUser(acc.Id,UserInfo.getUserId());
    }
    static testmethod void  ACE_Assignagent_TEST2() {
        
        Account acc = new Account();
        acc.NAme='Salesforce';
        acc.Assigned_Agent__c = UserInfo.getUserId();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SAP';
        opp.StageName='Enquiry';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        // opp.Assigned_Agent__c =u.id;
        //insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserpwc@testorg.com');
        //insert u;
        
        ACE_Assignagent.getUsers();
        ACE_Assignagent.getAccountList('SAP');
        try{
            ACE_Assignagent.assignUser(null,null);
        }catch (QueryException e) {
            System.debug ('all ok');
            return;
        }
        //System.assert(false, 'a NullPointerException was expected but was not thrown');
    }
    
}