trigger LeadTrigger on Lead (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.handleAfterInsert(Trigger.new);
}
}