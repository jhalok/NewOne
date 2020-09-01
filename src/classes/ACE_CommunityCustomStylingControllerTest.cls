/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Test Class for ACE_CommunityCustomStylingController.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @modifiedBy     Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2020-01-16
* @modified       2020-01-16
* @systemLayer    Apex Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ACE_CommunityCustomStylingControllerTest {
    public static testMethod void testRecords(){
        test.startTest();
        //Account Dummy Record
        Account acc = ACE_Test_Util.insertAcc();
        insert acc;
        system.assert(acc.Id != null);       
        //Contact Dummy Record
        Contact con = ACE_Test_Util.insertCon();
        con.AccountId =acc.Id;
        insert con;
        system.assert(con.Id != null);
        //Opportunity Dummy Record   
            Opportunity opp = ACE_Test_Util.insertEnquiry();
            opp.name = 'Test Opp';
            opp.AccountId =acc.Id;
            opp.Contact__c = con.Id;       
            insert opp;
        system.assert(opp.Id != null);
        //method call
        Integer testPosition=ACE_CommunityCustomStylingController.getNavItemPosition(opp.Id);
        System.debug('position is===='+testPosition);
        system.assert(testPosition!= null);
        test.stopTest();
    }
}