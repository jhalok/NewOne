@isTest(seeAllData = false)
public class ACE_Enquiry_SD_Controller_Test {
    @testsetup
    public static void insertCommonData() {
        //Account Dummy Record
        Account account = ACE_Test_Util.insertAcc();
        insert account;
        System.assert(account.id != null, 'Account not created');
        //Contact Dummy Record
        Contact contact = ACE_Test_Util.insertCon();
        contact.AccountId = account.id;
        insert contact;
        System.assert(contact.id != null, 'Contact not created');
        //Opportunity Dummy Record
        Opportunity opportunity = ACE_Test_Util.insertEnquiry();
        opportunity.AccountId = account.id;
        opportunity.Contact__c = contact.id;
        insert opportunity;
        System.assert(opportunity.id != null, 'opportunity not created');
    }
    public static testmethod void getAllOppModels_Test() {
        ACE_Enquiry_ScheduleTestDrive_Controller.OppWrapper result;
        Opportunity opportunity = [select id,Name from Opportunity limit 1];
        System.debug('opportunity in testMethod is '+opportunity);
        result=ACE_Enquiry_ScheduleTestDrive_Controller.getAllOppModels(opportunity.id);
        System.assert(result != null, 'Method not called');
    }
}