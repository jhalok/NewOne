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
*   Description     :   Class used to test the ACE_ExistingVehicles functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_ExistingVehicles_Test {
    
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
        
        ACE_Existing_Vehicle__c  newExistingRecord = new ACE_Existing_Vehicle__c(ACE_make__c ='Land Rover');
        insert newExistingRecord;
    }
    
     /** 
    *    Description     :      positiveTest  method is used to test all the positive  test cases 
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    
    public static testMethod void positiveTest(){
        Lead newLead = [select id,Name from Lead Where MobilePhone ='12345678912'];
        ACE_ExistingVehicles.getAllCompetitorsList(newLead.id);
        
        List<ACE_Existing_Vehicle__c> newExistingRecordList = new List<ACE_Existing_Vehicle__c>();
       	ACE_Existing_Vehicle__c  newExistingRecord = new ACE_Existing_Vehicle__c(ACE_make__c ='Land Rover');
       
        newExistingRecordList.add(newExistingRecord);
        ACE_ExistingVehicles.saveExistingRecord(newExistingRecordList);
        
        ACE_ExistingVehicles.getLeadRecord(newLead.id);
        
        ACE_ExistingVehicles.getExistingVehicle(newLead.id);
        
        ACE_Existing_Vehicle__c  ExistingRecord =    [select id,Name,ACE_make__c from ACE_Existing_Vehicle__c where  ACE_make__c ='Land Rover' limit 1];
        ACE_ExistingVehicles.deleteExistingVehicle(ExistingRecord.id);
        
        ACE_ExistingVehicles.getAllModel(ExistingRecord.ACE_make__c);
        
        ACE_ExistingVehicles.makeModelMap();
        
        ACE_ExistingVehicles.dataUpdate(ExistingRecord);
        
    }
}