/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Handler for UserTrigger to handle all the events on User record.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-11-28
* @modified       2019-11-28
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class ACE_UserTriggerHandler
implements ITrigger
{

// Constructor
    public ACE_UserTriggerHandler ()
    {
    }

    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore()
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

    /**
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
        //Commented by Prerna for demo on 3 Dec, can uncomment after 2 PM on 3 Dec
       ACE_PushUserIntoDiallerBatch userpush = new ACE_PushUserIntoDiallerBatch(newlstObj);
       Database.executeBatch(userpush,50); 
    }

    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj)
    {
    
    }

    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj)
    {
    }
    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally()
    {
    // insert any audit records
        /*if (!m_audits.isEmpty())
        {
        insert m_audits;
        }*/
    }
}