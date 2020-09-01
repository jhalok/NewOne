public class ACE_TriggerFactory
{
/**
* Public static method to create and execute a trigger handler
*
* Arguments: Schema.sObjectType soType - Object type to process (SObject.sObjectType)
*
* Throws a TriggerException if no handler has been coded.
*/
    public static void createHandler(Schema.sObjectType soType) {
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(soType);
        ITrigger leadhandler = getLeadHandler(soType);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {//Commented by Prerna for demo on 3 Dec, can uncomment after 2 PM on 3 Dec
           // throw new ACE_TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        // Execute the handler to fulfil the trigger
        execute(handler);
    }
    
    /**
    * private static method to control the execution of the handler
    *
    * Arguments: ITrigger handler - A Trigger Handler to execute
    */
    private static void execute(ITrigger handler) {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.beforeDelete(trigger.old,trigger.oldMap);
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert) {
                handler.beforeInsert(trigger.new);
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate) {
                handler.beforeUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.afterDelete(trigger.old,trigger.oldMap);
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert) {
                handler.afterInsert(trigger.new,trigger.newMap);
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate) {
                handler.afterUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /**
    * private static method to get the appropriate handler for the object type.
    * Modify this method to add any additional handlers.
    *
    * Arguments: Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
    *
    * Returns: ITrigger - A trigger handler if one exists or null.
    */
    public static ITrigger getHandler(Schema.sObjectType soType)
    {
        if (soType == Opportunity.sObjectType){
            return new ACE_OpportunityTriggerHandler();
        }
        if (soType == Case.sObjectType){
            return new ACE_ServiceSupportHandler();
        }
    return null;
    }
     
    public static ITrigger getLeadHandler(Schema.sObjectType soType)
    {
        /*if(soType == Lead.sObjectType){
            return new ACE_LeadTriggerHandler();
        }*/
        return null;
    } 
}