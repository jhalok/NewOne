/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : User Trigger to initiate TriggerFactory for handling events on User record.
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

trigger ACE_UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete) {
   // ACE_TriggerFactory.createHandler(User.sObjectType);
}