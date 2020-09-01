@isTest
public class ACE_leadlistTest {
    
    @IsTest
    static void testSearchOpp(){
        User curntUser = [Select Id, Name From User where Id =:UserInfo.getUserId()];
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = ACE_Test_Util.insertEnquiry();
        opp.Assigned_Agent__c = curntUser.Id;
        opp.Name = curntUser.Name;
        opp.OwnerId = curntUser.Id;
        oppList.add(opp);
        opp = ACE_Test_Util.insertEnquiry();
        opp.Assigned_Agent__c = curntUser.Id;
        opp.Name = curntUser.Name;
        opp.OwnerId = curntUser.Id;
        oppList.add(opp);
        insert oppList;   
        String sobjectName = 'Enquiry';
        test.startTest(); 
        ACE_leadlist.searchForIds(curntUser.Name, sobjectName);
        test.stopTest();
    }
    
    @IsTest
    static void testSearchUser(){
        String sobjectName ='';
        String searchString = 'Mc';
        
        User u1 = ACE_Test_Util.portalUser();
        u1.Anniversary_Date__c = system.today();
        insert u1;
        test.startTest();
        System.runAs(u1){
            Lead ld = ACE_Test_Util.insertLead();
            insert ld;
            Lead leadData =new Lead();
            leadData.LastName='SFDC2';
            leadData.Company='SalesForce';
            leadData.MobilePhone = '9958410000';
            leadData.City__c = 'jaipur';
            leadData.Status = 'Open - Not Contacted';
            leadData.ACE_Action_to_be_Taken__c = 'Exchange';
            insert leadData;
            User curntUser = [Select Id, Name From User where Id =:UserInfo.getUserId()];
            leadData.OwnerId = curntUser.Id;
            ACE_leadlist.searchForIds(searchString, sobjectName);
        }
        test.stopTest();
    }
    
    
    @IsTest
    static void testSearchPortalData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User usrData = ACE_Test_Util.userData();
        usrData.UserRoleId = portalRole.Id;
        usrData.ProfileId = profile1.Id;
        usrData.IsActive = true;
        insert usrData;
        String sobjectName = 'Lead';
        test.startTest();
        ACE_leadlist.searchForIds('Bruce', sobjectName);
        test.stopTest();
    }
    
    
    @IsTest
    static void testChangeOwnerMethod(){
        User curntUser = [Select Id,Name From User where Id =:UserInfo.getUserId()];
        system.runAs(curntUser){
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User usrData = ACE_Test_Util.userData();
            usrData.UserRoleId = portalRole.Id;
            usrData.ProfileId = profile1.Id;
            insert usrData;      
            Opportunity opp = ACE_Test_Util.insertEnquiry();
            opp.Assigned_Agent__c = curntUser.Id;
            opp.Name = curntUser.Name;
            opp.OwnerId = usrData.Id;
            insert opp;  
            test.startTest();
            ACE_leadlist.changeOwnerMethod(opp.Id, curntUser.Name);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testChangeOwnerLead(){
        User curntUser = [Select Id,Name From User where Id =:UserInfo.getUserId()];
        system.runAs(curntUser){
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User usrData = ACE_Test_Util.userData();
            usrData.UserRoleId = portalRole.Id;
            usrData.ProfileId = profile1.Id;
            insert usrData;      
            Lead leadData = ACE_Test_Util.insertLead();
            insert leadData;  
            test.startTest();
            ACE_leadlist.changeOwnerMethod(leadData.Id, curntUser.Name);
            test.stopTest();
        }
    }
    
    @IsTest
    static void testChangeOwner(){
        User curntUser = [Select Id,Name From User where Id =:UserInfo.getUserId()];      
        test.startTest();
        ACE_leadlist.changeOwnerMethod(curntUser.Id , curntUser.Name);
        test.stopTest();
    }
    
    @IsTest
    static void testleadDataRtrv(){
        Lead l = ACE_Test_Util.insertLead();
        insert l;
        Product2 prdData = ACE_Test_Util.insertProduct();
        prdData.Vehicle_Model__c = 'jeeto';
        prdData.Is_Prelaunch__c = true;
        insert prdData;
        System.debug('--prdData--'+prdData);
        ACE_Product_Interest__c prdInt = ACE_Test_Util.insertACE_Product_Interest();
        prdInt.Product__c =prdData.Id;
        prdInt.Lead__c = l.Id;
        insert prdInt;
        test.startTest();
        ACE_leadlist.unAssignedLeadData();
        test.stopTest();
    }
    
    @IsTest
    static void testoppDataRtrv(){
        Opportunity oppData = ACE_Test_Util.insertEnquiry();
        insert oppData;
        List<Product2> prd = new List<Product2>();
        Product2 prdData = ACE_Test_Util.insertProduct();
        prdData.Vehicle_Model__c = 'jeeto';
        prdData.Is_Prelaunch__c = false;
        prd.add(prdData);
        insert prd;
        test.startTest();
        ACE_leadlist.unAssignedOppData();
        test.stopTest();
    }
}