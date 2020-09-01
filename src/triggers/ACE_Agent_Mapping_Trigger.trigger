trigger ACE_Agent_Mapping_Trigger  on Agent_Mapping__c (before update, before insert) {
    If((trigger.isUpdate || trigger.isInsert  ) && (trigger.isBefore)){
        system.debug(trigger.new);
    }
}