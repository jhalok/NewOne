({
    
    Search: function(component, event, helper) {
        //var actions = [{ label: 'Show details', name: 'show_details' }];
        var searchText = component.get('v.searchText');
        if(searchText){
            helper.SearchHelper(component, event);
        } 
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var Addvalue = row.Name;
        //   alert("Showing opportunity " + Addvalue);
        component.set("v.SelectMessage", true);
        component.set("v.selectedAccount", Addvalue);
        // if(currentvalue)
        // helper.showRowDetails (component, row, event);       
    },
    linkContact:function (component, event, helper) {
        var ContactId = event.target.id; 
        var str = window.location.href
        var res = str.split("/");
        console.log(res[6]);
        var leadId = res[6];
        if(leadId != undefined){
            var action = component.get("c.updateLeadContact");
            action.setParams({
                'leadId': leadId,
                'contactId': ContactId,
                
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "Success",
                        title: "Success!",
                        message: "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    window.location.reload();
                }else if (state === "INCOMPLETE") {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "Error",
                        title: "Error!",
                        message: "Response is Incompleted"
                    });
                    toastEvent.fire();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type : "Error",
                                title: "Error!",
                                message:  errors[0].message
                            });
                            toastEvent.fire();
                        }
                    } else {
                        
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type : "Error",
                            title: "Error!",
                            message:  "Unknown error"
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        } else{
            
            component.set("v.relatedContactId",ContactId);
        }
        
    }
    
})