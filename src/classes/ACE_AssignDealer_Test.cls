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
*   Description     :   Class used to test the ACE_AssignDealer functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_AssignDealer_Test {
     
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
         lead.City__c = 'jaipur';
       
        lead.Vehicle__c = Product.Id;
        insert lead; 
        
        ACE_Product_Interest__c newInter = new ACE_Product_Interest__c();
        newInter.lead__c = lead.id;
        insert newInter;
        
        Vehicle_Variant__c newVari = new Vehicle_Variant__c();
      newVari.Color__c = 'black';
        insert newVari;
    }
    public static testmethod void positiveTesting(){
        
        Test.startTest();
       	Lead  testLead =  [SELECT Id, LastName, FirstName, Suffix, Name,ACE_Dealer__c,City__c, PostalCode, Address FROM Lead limit 1 ];
       	ACE_AssignDealer.getModel(testLead.id);
		ACE_AssignDealer.getLeadRecord(testLead.id); 
        ACE_AssignDealer.getDealer(testLead.City__c);
        ACE_AssignDealer.updateProduct_Interest([select id,Name from ACE_Product_Interest__c where Lead__c =:testLead.id]);
        ACE_AssignDealer.getColorOfVariant([select id,Name from Vehicle_Variant__c limit 1].id);
        Test.stopTest();
    }
    
}