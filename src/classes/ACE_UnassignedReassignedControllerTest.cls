@IsTest
public class ACE_UnassignedReassignedControllerTest {
    
    @IsTest
    static void testGetEnquiryFilters(){
        String launchType = 'PreLaunch';
        Product2 prod = ACE_Test_Util.insertProduct();
        insert prod;
        test.startTest();
        ACE_UnassignedReassignedController.getEnquiryFilters(launchType);
        test.stopTest();
    }
    
    @IsTest
    static void testGetEnquiryFilters1(){
        String launchType = 'Launch';
        Product2 prod = ACE_Test_Util.insertProduct();   
        prod.IsActive = false;
        prod.Is_Prelaunch__c = false;
        insert prod;
        test.startTest();
 	       ACE_UnassignedReassignedController.getEnquiryFilters(launchType);
        test.stopTest();
    }
}