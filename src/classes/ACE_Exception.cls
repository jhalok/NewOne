/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Creates logs and store it in Exception Log object for all the catched Exceptions.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-10-31
* @modified       2019-10-31
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_Exception extends Exception {
    public static void LogException(Exception e){
        try{
            ACE_Exception_Log__c exc = new ACE_Exception_Log__c();
            exc.Error_Message__c = e.getMessage();
            exc.Exception_Type__c = e.getTypeName();
            exc.Line_Number__c = e.getLineNumber();
            exc.Stack_Trace__c = e.getStackTraceString();
            database.insert(exc);            
        } catch (Exception exc) {
        }            
    } //end method
} //end class