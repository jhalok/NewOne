({
	handleSaveLead : function(component, event, helper) {
        helper.saveLead(component, event, helper);
    },
     
    handleRecordUpdated : function(component, event, helper) {
        helper.recordUpdated(component, event, helper);
    },
     
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})