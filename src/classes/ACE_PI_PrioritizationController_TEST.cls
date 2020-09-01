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
*   Description     :   Class used to test the ACE_PI_PrioritizationController functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_PI_PrioritizationController_TEST{
    
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
        
        
        ACE_Product_Interest__c pi = new ACE_Product_Interest__c();
        pi.Name = 'XUV300';
        pi.Lead__c = lead.id;
        pi.Product__c = Product.id;
        pi.Not_Interested__c =TRUE;
        pi.Other_Interest__c =TRUE;
        pi.Prefered__c = true;
        insert pi;
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
    static testmethod void ACE_PI_PrioritizationController_TEST1(){
        
        List<ACE_Product_Interest__c> piList = new List<ACE_Product_Interest__c>();
        piList.add([select id,Name,Product__c,Prefered__c From ACE_Product_Interest__c where name='XUV300' limit 1]);
        
        Product2 product = [select id,name from product2 where Name = 'Mahindra Thar' limit 1 ];
        
        List<ACE_Product_Interest__c> piListEdit = new List<ACE_Product_Interest__c>();
        ACE_Product_Interest__c newPI = new ACE_Product_Interest__c();
        newPI.Name ='XUV300';
         newPI.Product__c = Product.id;
        piListEdit.add(newPI);
        ACE_PI_PrioritizationController.updateProductInterest( piList,piList);
         ACE_PI_PrioritizationController.updateProductInterest( piList,piListEdit);
        Lead leadData = [select id,Name from lead Where LastName='SFDC' limit 1];
       
        
        ACE_PI_PrioritizationController.createProductInterestRecord(product.id,leadData.id);
        ACE_PI_PrioritizationController.createProductInterestRecord(product.id,'test');
        
        ACE_PI_PrioritizationController.saveInterests(piListEdit);
        ACE_PI_PrioritizationController.saveInterests(piList);
        
        ACE_PI_PrioritizationController.getLeadRecord(leadData.id);
        
        ACE_PI_PrioritizationController.getExistingProducts(leadData.id);
        
    }
    
    
}