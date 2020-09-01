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
*   Description     :   Class used to test the ACE_CreateAndUpdateAnAgent functionality
*
*   Revision Logs   :   V_1.0 – Created
*
**/
@isTest(seeAllData = false)
public class ACE_CreateAndUpdateAnAgent_Test {
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
       
        ACE_Service__c newService = new ACE_Service__c();
        newService.Name = 'test';
        newService.Call_Center__c = 'openCti';
        newService.Service_Code__c = '55';
        insert newService;
    }
     /** 
    *    Description     :      ACE_CreateAndUpdateAnAgent_Test1
    *
    *    Arguments       :      No Arguments
    *     
    *    Return Types    :      void
    *
    *    Revision Logs   :      V_1.0 - Created
    *                        
    **/
    static testmethod void ACE_CreateAndUpdateAnAgent_Test1(){
        ACE_CreateAndUpdateAnAgent.getSearchData('test','Name', 'true');
        ACE_CreateAndUpdateAnAgent.getSearchData('55','Service__c', 'ALL');
        ACE_CreateAndUpdateAnAgent.getAllData();
		ACE_Service__c testService = [SELECT Id, Name, Call_Center__c FROM ACE_Service__c limit 1];
        User newUserForInsert  = new User();
        newUserForInsert.FirstName = 'test';
        newUserForInsert.LastName = 'demo';
        newUserForInsert.Username  = 'john@acme12334.com';
        ACE_CreateAndUpdateAnAgent.insertNewUser(newUserForInsert,  testService.id);
        List<Agent_Mapping__c> allMappingData = new List<Agent_Mapping__c>();
        User u = [Select id,Name,IsActive from user limit 1];
        List<User> allUserList = new List<User>();
        allUserList.add(u);
       	Agent_Mapping__c testtingMapping =   new Agent_Mapping__c(Lookup_To_Service__c = testService.id, Lookup_To_User__c =u.id);
        //insert testtingMapping;
        allMappingData.add(testtingMapping);
        system.debug(allUserList);
       	
        //ACE_CreateAndUpdateAnAgent.resetPassword(allUserList);
        
     	List<ACE_CreateAndUpdateAnAgent.allUserDataWrapper> AlldataString = new List<ACE_CreateAndUpdateAnAgent.allUserDataWrapper>();
        AlldataString.add(new ACE_CreateAndUpdateAnAgent.allUserDataWrapper());
        
        ACE_CreateAndUpdateAnAgent.updateUserRecord(allUserList, JSON.serialize(AlldataString),allMappingData);
         ACE_CreateAndUpdateAnAgent.updateMapping(system.JSON.serialize(allMappingData));
        
        
    }
}