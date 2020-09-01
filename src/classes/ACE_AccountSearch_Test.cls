/**
* This class contains unit tests for validating the behavior of Apex classes
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/

/**
*   Description     :   Class used to test the ACE_AccountSearch functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_AccountSearch_Test {
    
           /** 
    *    Description     :      insertCommonData setup method is used to create dummy records  which is used by all test methods for testing
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    
    @testsetup 
    public static void insertCommonData() {
        Product2 Product = new Product2();
        Product.Name='Mahindra Thar';
        Product.Status__c = 'Active';
        Product.Type__c='Vehicle';
        insert Product;
        
        Lead lead =new Lead();
        lead.Email = 'test@gmail.com';
        lead.LastName='SFDC';
        lead.Company='SFDC';
        lead.MobilePhone = '1234567890';
        lead.Vehicle__c = Product.Id;
        insert lead; 
        
            Contact Parent_Contact = new Contact();
         Parent_Contact.LastName = 'TestLead123';
        insert Parent_Contact;
         
         Account newAccount = new Account();
        newAccount.Name='testing';
        insert newAccount; 
        
        Contact newContact = new Contact();
        newContact.AccountId = newAccount.id;
        newContact.Parent_Contact_ACE__c = Parent_Contact.id;
        newContact.Email ='test@gmail.com';
        newContact.LastName = 'TestLead12';
       	newContact.ACE_Customer_Id__c = '';
        newContact.MobilePhone = '1234567890';
        newContact.Phone = '123456789';
        insert newContact;
        
        ACE_Repair_Order__c newRepair = new ACE_Repair_Order__c();
        newRepair.Contact__c = newContact.id;
        insert newRepair;
        
       
        Asset newAst = new Asset();
        newAst.Name ='testing';
        newAst.Chassis_Number__c = 'CHF0099009201';
        newAst.ContactId = newContact.id;
        insert newAst;
    }
      /** 
    *    Description     :      ACE_PI_PrioritizationController_TEST1 
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    static testmethod void ACE_AccountSearch_TEST1(){
        List<String> allObject = new List<String>();
        allObject.add('Contact');
        allObject.add('Lead');
        ACE_AccountSearch.fetchRecords('1234567890',allObject,'mobile');
        
        
        Lead lead = [select id,Name from lead limit 1];
        Contact con = [select id,name from contact limit 1];
        
        ACE_AccountSearch.updateLeadContact(lead.id,con.id);
        ACE_AccountSearch.fetchLeadAndContactRecords('1234567890',allObject,'mobile', '1234567890');
    }
    static testmethod void ACE_AccountSearch_TEST2(){
        List<String> allObject = new List<String>();
        allObject.add('Contact');
        allObject.add('Lead');
        ACE_AccountSearch.fetchRecords('test@gmail.com',allObject,'email');
          ACE_AccountSearch.fetchLeadAndContactRecords('test@gmail.com',allObject,'email', 'test@gmail.com');
    }
    static testmethod void ACE_AccountSearch_TEST3(){
        List<String> allObject = new List<String>();
        allObject.add('Contact');
        allObject.add('Lead');
        ACE_AccountSearch.fetchRecords('Not a Customer',allObject,'customerId');
          ACE_AccountSearch.fetchLeadAndContactRecords('test@gmail123.com',allObject,'email', 'test@gmail.com123');
    }
    static testmethod void ACE_AccountSearch_TEST4(){
        List<String> allObject = new List<String>();
      
        allObject.add('Asset');
        ACE_AccountSearch.fetchRecords('CHF0099009201',allObject,'chasisno');
    }
    static testmethod void ACE_AccountSearch_TEST5(){
        List<String> allObject = new List<String>();
        
        allObject.add('Asset');
        ACE_AccountSearch.fetchRecords('645656',allObject,'vehicleno');
    }
    static testmethod void ACE_AccountSearch_TEST6(){
        List<String> allObject = new List<String>();
      
        allObject.add('ACE_Repair_Order__c');
        ACE_AccountSearch.fetchRecords([select id,Name from ACE_Repair_Order__c limit 1].Name,allObject,'roid');
    }
    
}