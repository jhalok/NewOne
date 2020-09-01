/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Lead Trigger to perform Lead conversion operations.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Prerna Purwar   <prerna.purwar@pwc.com>
* @modifiedBy     Prerna Purwar   <prerna.purwar@pwc.com>
* @maintainedBy   Prerna Purwar   <prerna.purwar@pwc.com>
* @version        1.0
* @created        2019-10-25
* @modified       2019-10-25
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
Change#     Modified On         Modified By                 Reason/Desrciption
---------------------------------------------------------------------------------------------------
C001        15-Nov-2019         PwC Developer               After Insert logic add
***************************************************************************************************/

trigger ACE_LeadTrigger on Lead (before update, before insert,after insert) {
    List<Lead> convertedLeads = new List<Lead>();
    
    for(Lead lead : System.Trigger.New){
        
        if(lead.isConverted && trigger.isUpdate && ACE_LeadTriggerHandler.runOnce)
        {
           // Added by @Krishnan Mishra. To convert Leads into Opportunity,
           // convertedLeads.add(lead);
           ACE_LeadTriggerHandler.onLeadConversion(trigger.new);

        }
    }
    if(trigger.isInsert && Trigger.isBefore){
        //ACE_LeadTriggerHandler.checkIfLeadsAlreadyExistAsContact(trigger.new);
        //ACE_UpdateSeriveCodeOnLeadTriggerHelper.UpdateUserManager(trigger.new);
    }

    // Trigger for lead conversion.
    /*if(trigger.isUpdate && trigger.isAfter){
        System.debug('Converted Lead is '+trigger.new[0]);
    }*/
    //ACE_TriggerFactory.createHandler(Lead.sObjectType);

    //C001-----Start
   /* if(Trigger.isInsert && Trigger.isAfter){
        ACE_LeadTriggerHandler.onAfterInsert(Trigger.New,Trigger.NewMap);
    }
    //C001-----End*/
    if(trigger.isInsert && Trigger.isAfter){
        ACE_LeadTriggerHandler.callpushleadsBatch(Trigger.New);
    }
    if(trigger.isUpdate && Trigger.isAfter){
          List<Lead> leadsForApprovalNew = Trigger.New;
            List<Lead> leadsForApprovalOld = Trigger.Old;
        if(leadsForApprovalNew[0].DNC_Expired_In__c != leadsForApprovalOld[0].DNC_Expired_In__c && leadsForApprovalNew[0].DoNotCall != false ){
             User curUser = [SELECT Id, Name, City,ManagerId, CallCenterId FROM User where ID =:userInfo.getUserId()]; 
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setObjectId(leadsForApprovalNew[0].Id);
            
            approvalReq.setSubmitterId(curUser.Id);
            approvalReq.setNextApproverIds(new Id[] {curUser.ManagerId });
            Approval.ProcessResult result = Approval.process(approvalReq);
            if(!result.isSuccess()){
                String errorMessage = '';
                for(Database.Error error : result.getErrors()){
                    errorMessage += error.getMessage() +'\n';
                }
                System.debug(errorMessage);
            }
            else{
                System.debug(result);
            }
        }
        
    }
}