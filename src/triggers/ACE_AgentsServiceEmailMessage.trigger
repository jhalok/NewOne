/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Mark milestone as completed when an email is sent to the case contact. 
  That way, the support agent doesn’t have to manually mark the milestone Completed after they email the case contact..
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-18
* @modified       2019-11-18
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
trigger ACE_AgentsServiceEmailMessage on EmailMessage (after insert) {
    ACE_TriggerFactory.createHandler(EmailMessage.sObjectType); 
}