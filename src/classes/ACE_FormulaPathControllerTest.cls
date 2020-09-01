/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Test Class for ACE_FormulaPathController.
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
public class ACE_FormulaPathControllerTest {
    public static testMethod void testRecords(){
        test.startTest();
        //Dummy Records
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        system.assert(acc.Id != null);
        //Method call
        //System.assertEquals(acc.Name, 'test account');
        String Name = ACE_FormulaPathController.getSobjectAPI_Name(acc.Id);
        System.assertEquals('Account', Name);
        test.stopTest();        
    }
}