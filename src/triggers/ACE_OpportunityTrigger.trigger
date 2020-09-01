/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Opportunity Trigger to initiate TriggerFactory for handling events on Opportunity record.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-10-30
* @modified       2019-10-30
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
trigger ACE_OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    ACE_TriggerFactory.createHandler(Opportunity.sObjectType);
}