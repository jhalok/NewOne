/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Product Trigger to perform Product conversion operations.
* ──────────────────────────────────────────────────────────────────────────────────────────────────

* @version        1.0
* @created        2020-01-07
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*
*/
trigger ACE_ProductTrigger on Product2 (after update, before insert,after insert) {
      if(trigger.isUpdate && Trigger.isAfter){
      	ACE_ProductTriggerHelper.updateLeadRecordType(trigger.new);
      }
}