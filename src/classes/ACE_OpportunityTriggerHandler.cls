/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Handler for OpportunityTrigger to handle all the events on Opportunity record.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-10-30
* @modified       2019-11-04
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* vX.X            Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* 2019-12-06      calling populateCompletedStagesField(...) method from beforeInsert(...) and beforeUpdate(...)
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class ACE_OpportunityTriggerHandler
implements ITrigger
{

// Constructor
    public ACE_OpportunityTriggerHandler ()
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
        system.debug(newlstObj);
        ACE_OpportunityTriggerHelper.populateAccessFields(newlstObj);
        ACE_OpportunityTriggerHelper.populateCompletedStagesField( newlstObj );
    }

    public void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj)
    {
        System.debug( '>>>> beforeUpdate Called.....' );
        ACE_OpportunityTriggerHelper.populateAccessFields(newlstObj);
        ACE_OpportunityTriggerHelper.populateCompletedStagesField( newlstObj );
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
        Map<Id, Opportunity> closedWonOppMap = new Map<Id, Opportunity>();
        List<String>closedWonOppAccIds = new List<String>();
        for(Opportunity opp :  (List<Opportunity>)newlstObj){
            
            if(opp.StageName == ACE_Constants.OPTY_STAGE_CLOSED_WON){
                closedWonOppMap.put(opp.Id,opp);
                closedWonOppAccIds.add(opp.AccountId);
            }
        }
        if(closedWonOppAccIds.size() > 0)
            ACE_OpportunityTriggerHelper.updateAccountToCustomer(closedWonOppAccIds);
        if(closedWonOppMap.keySet().size() > 0)
            ACE_OpportunityTriggerHelper.generateProductAsset(closedWonOppMap);
    }

    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj)
    {
        Map<Id, Opportunity> closedWonOppMap = new Map<Id, Opportunity>();
        List<String>closedWonOppAccIds = new List<String>();
        for(Opportunity opp :  (List<Opportunity>)newlstObj){
            Map<Id,Opportunity> mpOpp = (Map<Id,Opportunity>)oldMapObj;
            if(opp.StageName != mpOpp.get(opp.ID).StageName && opp.StageName == ACE_Constants.OPTY_STAGE_CLOSED_WON){
                closedWonOppMap.put(opp.Id,opp);
                closedWonOppAccIds.add(opp.AccountId);
            }
        }
        if(closedWonOppAccIds.size() > 0)
            ACE_OpportunityTriggerHelper.updateAccountToCustomer(closedWonOppAccIds);
        if(closedWonOppMap.keySet().size() > 0)
            ACE_OpportunityTriggerHelper.generateProductAsset(closedWonOppMap);
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