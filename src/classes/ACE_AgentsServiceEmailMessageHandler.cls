/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Handler - Mark milestone as completed when an email is sent to the case contact. 
That way, the support agent doesn’t have to manually mark the milestone Completed after they email the case contact.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-18
* @modified       2019-11-18
* @systemLayer    ACE_AgentsServiceEmailMessageHandler
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
public class ACE_AgentsServiceEmailMessageHandler implements ITrigger {
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore()
    {
        if(trigger.isInsert) {
            //Here we will call before insert actions
            
        } else if(trigger.isUpdate) {
            //Here we will call before update actions
        } else if(trigger.isDelete) {
            //Here we will call before delete actions
        } else if(trigger.isUndelete) {
            //Here we will call before undelete actions
        }
    }
    
    public void bulkAfter()
    {
        if(trigger.isInsert) {
            //Here we will call after insert actions
        } else if(trigger.isUpdate) {
            //Here we will call after update actions
        } else if(trigger.isDelete) {
            //Here we will call after delete actions
        } else if(trigger.isUndelete) {
            //Here we will call after undelete actions
        }
    }
    
    public void beforeInsert(List<SObject> newlstObj)
    {
        
    }
    
    public void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj)
    {
        
    }
    
    /*
* beforeDelete
*
* This method is called iteratively for each record to be deleted during a BEFORE
* trigger.
*/
    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj)
    {
        
    }
    
    public void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj)
    {
        ACE_AgentsServiceEmailMessageHelper.completeFirstResponseEmail(newlstObj);
    }
    
    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj)
    {
      
    }
    
    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj)
    {
    }
    
    /*
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally()
    {
    }
}