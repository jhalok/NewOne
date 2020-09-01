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
*   Description     :   Class used to test the ACE_LeadQuickActionsController functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_LeadQuickActionsController_Test {
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
        Lead newLead = new Lead();
        newLead.LastName = 'TestLead12';
        newLead.MobilePhone = '12345678912';
        newLead.Phone = '1234567890';
        newLead.Status = '	Open - Not Contacted';
        newLead.LeadSource = '	Advertisement';
        newLead.Primary_Model__c = 'Thar';
        newLead.ACE_Vehicle_Model__c = 'Thar';
        newLead.Likely_Conversion_Date__c = '15-45 days';
        newLead.Company = 'TestLead11';
       
		insert newLead;
    }
    
      /** 
    *    Description     :      ACE_LeadQuickActionsController_Test1 
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    static testmethod void ACE_LeadQuickActionsController_Test1(){
		ACE_LeadQuickActionsController.getLeadDtls([select id,Name from lead limit 1].id);
        ACE_LeadQuickActionsController.getLeadDtls('');
	}
}