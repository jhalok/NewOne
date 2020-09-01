@isTest
public class ACE_ApprovalComponent_TEST {
    static testmethod void  ACE_ApprovalComponent_TEST() {
        Lead l =new Lead();
        l.LastName='SFDC';
        l.Company='SFDC';
        l.MobilePhone = '9874566234';
        //l.Vehicle__c = p.Id;
        insert l; 
        
        User user1 = [SELECT Id FROM User WHERE Alias='smaha'];

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
       req1.setObjectId(l.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user1.Id); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('04a5D0000008fCdQAI');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
       
        ACE_ApprovalComponent.approvals1();
        ACE_ApprovalComponent.approveLead(l.Id,l.Id);
        ACE_ApprovalComponent.rejectLead(l.Id,l.Id);
       
        
    }
    

}