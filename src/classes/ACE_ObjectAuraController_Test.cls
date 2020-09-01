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
*   Description     :   Class used to test the ACE_ObjectAuraController functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_ObjectAuraController_Test {
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
        
        Contact newContact = new Contact();
        newContact.LastName = 'TestLead12';
        newContact.MobilePhone = '12345678912';
        newContact.Phone = '123456789';
       
        insert newContact;
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
    static testmethod void ACE_ObjectAuraController_Test1(){
         Product2 Product = new Product2();
        Product.Name='Mahindra Thar';
        Product.Status__c = 'Active';
        Product.Type__c='Vehicle';
        insert Product;
        
        Lead lead =new Lead();
        lead.LastName='SFDC';
        lead.Company='SFDC';
        lead.MobilePhone = '8874566234';
        lead.Vehicle__c = Product.Id;
        
        List<ACE_ObjectAuraController.LeadWrapper> listOfwrapperData = new List<ACE_ObjectAuraController.LeadWrapper>();
         ACE_ObjectAuraController.LeadWrapper wrapperData = new ACE_ObjectAuraController.LeadWrapper();
        wrapperData.newLead = lead;
         List<ACE_Product_Interest__c> allInterest = new List<ACE_Product_Interest__c>();
        allInterest.add(new ACE_Product_Interest__c(Name = 'XUV500', Product__c = Product.id));
        wrapperData.allInterest = allInterest;
        listOfwrapperData.add(wrapperData);
        ACE_ObjectAuraController.saveLeads(JSON.serialize(listOfwrapperData));
        
        ACE_ObjectAuraController.getContactRecord([select id,Name from Contact limit 1].id);
        
        Lead leadData = [select id,Name From lead limit 1];
         ACE_ObjectAuraController.getExistingRecords(leadData.id);
        
        ACE_ObjectAuraController.updateLeads(leadData);
    }
}