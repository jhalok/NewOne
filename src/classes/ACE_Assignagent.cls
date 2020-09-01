/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : AssignAgent button Functionality creation in dealer Account record Type.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Saikrishna   <saikrishna.omkaram@in.pwc.com>
* @modifiedBy     Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @maintainedBy   Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @version        1.0
* @created        2019-11-13
* @modified       2019-11-13
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/





public class ACE_Assignagent {
    
    @AuraEnabled //get Account Industry Picklist Values
    public static Map<String, String> getUsers(){
        Map<String, String> users = new Map<String, String>();
        List<User> usersList = [select Id,Name,Team__c from user where Team__c='Dealer Follow up'];
        for (User u: usersList) {
            //Put Picklist Value & Label in Map
            users.put(u.Id, u.Name);
        }
        return users;
    }
    
    @AuraEnabled
    public static List<Account> getAccountList(String accountName){
        //System.debug('=accountName='+accountName);
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer Account').getRecordTypeId();
        //System.debug('=dealerRecordTypeId='+dealerRecordTypeId);
        List<Account> accountList = new List<Account>();
        accountList = [select id,Name from Account where Name LIKE:'%'+accountName+'%' AND RecordTypeId=:dealerRecordTypeId AND Assigned_Agent__c=null];    
        return accountList;
    }
    
    @AuraEnabled
    public static boolean assignUser(String accountRecordId,String useID){
        Boolean updatedStatus = false;
        List<Opportunity> opList = new List<Opportunity>();
        try{
            Account acc = [select Id,Assigned_Agent__c from Account where Id=:accountRecordId];
            List<Opportunity> oppList = [select Id,Assigned_Agent__c from Opportunity where accountId=:accountRecordId AND StageName!='Closed Won' AND Assigned_Agent__c=null];
            //opportunity opp = [select Id,Assigned_Agent__c from opportunity where parentId=:accountRecordId];
            acc.Assigned_Agent__c = useID;
            
            for(Opportunity op:oppList){
                op.Assigned_Agent__c = useID;
                opList.add(op);
            }
            
            
            update acc;
            update opList;
            updatedStatus =true;
        }
        catch(Exception ex){
            System.debug('=Exception='+ex);
        }
        return updatedStatus;
        
    }
}