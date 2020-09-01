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
*   Description     :   Class used to test the ACE_ScheduleTestDrive_Test functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_ScheduleTestDrive_Test {
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
        lead.LastName='SFDC';
        lead.Company='SFDC';
        lead.MobilePhone = '9874566234';
        lead.Vehicle__c = Product.Id;
        insert lead; 
        
        Account newAccount = new Account();
        newAccount.Name='testing';
        insert newAccount;
        
        Opportunity newOpportunity = new Opportunity();
        
       /* newOpportunity.Name = 'testing';
        newOpportunity.AccountId = newAccount.id;
        newOpportunity.PartnerAccountId = newAccount.id;

        insert newOpportunity;  */
    }
      
       /** 
    *    Description     :      ACE_ScheduleTestDrive_Test1 
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    static testmethod void ACE_ScheduleTestDrive_Test1(){
        Lead LeadData = [select id,Name from lead limit 1];
        ACE_ScheduleTestDrive.getLead(LeadData.id);
        ACE_ScheduleTestDrive.getAllModels(LeadData.id);
        ACE_ScheduleTestDrive.getAllOppModels(LeadData.id);
        Account acc = [select id,Name from Account limit 1];

        Opportunity opp = [select id,Name from Opportunity limit 1];
        ACE_ScheduleTestDrive.getDealer(acc.id);
        ACE_ScheduleTestDrive.getOpportunity(opp.Id);
        
    }

}