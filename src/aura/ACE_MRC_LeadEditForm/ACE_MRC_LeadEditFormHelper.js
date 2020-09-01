({
    //Save contact record
    saveContact : function(component, event, helper) {
        component.find("leadRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                //To close the component with success message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else if (saveResult.state === "INCOMPLETE") {
                //Show data saved incomplete message
                component.set("v.recordSaveError","Data saved incomplete.");
            } else if (saveResult.state === "ERROR") {
                //Show error message
                var errMsg = "";
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                component.set("v.recordSaveError", errMsg);
            } 
        }));
    },
    
    //Refresh record after update
    recordUpdated : function(component, event, helper){
        var changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            component.find("leadRec").reloadRecord();
        }
    }
})