public class ACE_ApprovalComponent{  
    
    @AuraEnabled
    public Static List<wrapApprovals> approvals1(){
        //System.debug('=recId='+recId);
        List<wrapApprovals> wrapApproval = new List<wrapApprovals>();
        List<Lead> leadRecords = [select Id,Name,Status,Owner.Name from Lead];
        //List<ProcessInstance> processInstanceList =[select Id,TargetObjectId,(SELECT Id,StepStatus FROM StepsAndWorkitems order by CreatedDate DESC) FROM ProcessInstance where TargetObjectId =:recId and Status!='Approved' order by CreatedDate DESC];
        
        String pdId = [select Id, Name from ProcessDefinition where State = 'Active' and Name='DNC Approval'].Id;
        //System.debug('==pdId=='+pdId);
        List<ProcessInstance> processInstanceList =[select Id,TargetObjectId,ProcessDefinitionId,(SELECT Id,StepStatus,ActorId FROM StepsAndWorkitems where ActorId=:UserInfo.getUserId() order by CreatedDate DESC) FROM ProcessInstance where Status!='Approved' and Status!='Rejected' and ProcessDefinitionId=:pdId order by CreatedDate DESC];
        
       // System.debug('=processInstanceList='+processInstanceList);
        for(Lead l:leadRecords){
            for(ProcessInstance pi:processInstanceList){
                if(l.Id == pi.TargetObjectId){
                    for(ProcessInstanceHistory saw:pi.StepsAndWorkitems){
                        if(saw.StepStatus == 'Pending'){
                            wrapApprovals wA = new wrapApprovals();                    
                            wA.processId = saw.Id;
                            wA.leadRec = l;
                            wA.selected = false;
                            wrapApproval.add(wA);
                        }
                    }
                }
            }
        }
        //System.debug('=wrapApproval='+wrapApproval);
        return wrapApproval;
    }
    
    @AuraEnabled
    Public static void approveLead(String recId,String approvalIds){
        
        //System.debug('=recId='+recId);
        //System.debug('=approvalIds='+approvalIds);
        List<String> recToApprove = approvalIds.split(',');
       // System.debug('=recToApprove='+recToApprove);
        
        List<ProcessInstance> processInstanceList =[select Id,Status,TargetObjectId,ProcessDefinitionId,(SELECT Id,StepStatus FROM StepsAndWorkitems order where Id IN:recToApprove order by CreatedDate DESC) FROM ProcessInstance where Status!='Approved' and Status!='Rejected' order by CreatedDate DESC];
        for(ProcessInstance pi:processInstanceList){
            for(ProcessInstanceHistory saw:pi.StepsAndWorkitems){
                Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                req.setWorkItemId(saw.Id);
                req.setAction('Approve');
                req.setComments('Approved.');
                Approval.ProcessResult result = Approval.process(req);
            }
        }
        
    }
    
    @AuraEnabled
    Public static void rejectLead(String recId,String rejectIds){
        
        //System.debug('=recId='+recId);
        //System.debug('=rejectIds='+rejectIds);
        List<String> recToReject = rejectIds.split(',');
       // System.debug('=recToReject='+recToReject);
        
        List<ProcessInstance> processInstanceList =[select Id,Status,TargetObjectId,(SELECT Id,StepStatus FROM StepsAndWorkitems order where Id IN:recToReject order by CreatedDate DESC) FROM ProcessInstance where Status!='Approved' and Status!='Rejected' order by CreatedDate DESC];
        for(ProcessInstance pi:processInstanceList){
            for(ProcessInstanceHistory saw:pi.StepsAndWorkitems){
                Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
                req.setWorkItemId(saw.Id);
                req.setAction('Reject');
                req.setComments('Approved.');
                Approval.ProcessResult result = Approval.process(req);
            }
        }
        
    }
    
    public class wrapApprovals{
        @AuraEnabled
        public String processId{get;set;}
        @AuraEnabled 
        public Boolean selected{get;set;}
        @AuraEnabled 
        public Lead leadRec{get;set;}
        
    }
}