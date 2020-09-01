({
    doinit: function (component, event, helper) {
        if (component.get('v.objectType') == 'Enquiry') {
            component.set('v.Enquiry', true);
            component.set('v.pageNumber', 1);
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");
            helper.getopplistFunction(component, 1, pageSize);
        } else {
            component.set('v.Enquiry', false);
            component.set('v.PageNumber', 1);
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");
            helper.getleadlistFunction(component, 1, pageSize);
        }
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        if (pageNumber < component.get('v.TotalPages')) {
            var pageSize = component.get("v.pageSize");
            component.set('v.PageNumber', pageNumber + 1);
            if (component.get('v.objectType') == 'Enquiry') {
                component.set('v.Enquiry', true);
                helper.getopplistFunction(component, pageNumber + 1, pageSize);
            } else {
                component.set('v.Enquiry', false);
                helper.getleadlistFunction(component, pageNumber + 1, pageSize);
            }
        } else {
            
        }
        
    },
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get('v.pageSize');
        if (component.get('v.PageNumber') >= 1) {
            component.set('v.PageNumber', pageNumber - 1);
            if (component.get('v.objectType') == 'Enquiry') {
                component.set('v.Enquiry', true);
                helper.getopplistFunction(component, pageNumber - 1, pageSize);
            } else {
                component.set('v.Enquiry', false);
                helper.getleadlistFunction(component, pageNumber - 1, pageSize);
            }
        } else {
            
        }
        
    },
    onSelectChange: function (component, event, helper) {
        console.log('In On Change');
        component.set('v.PageNumber', 1);
        
        var pageSize = component.get('v.pageSize');
        console.log('PageSize on change : '+pageSize);   
        var selectedOptionValue = event.getParam("value");
        console.log('selectedOptionValue on change : '+selectedOptionValue);
        if (component.get('v.objectType') == 'Enquiry') {
            
            component.set('v.Enquiry', true);
            helper.getopplistFunction(component, 1, pageSize);
        } else {
            
            component.set('v.Enquiry', false);
            helper.getleadlistFunction(component, 1, pageSize);
        }
    },
    edit: function (component, event, helper) {
        component.set("v.isView", false);
        component.set("v.isEdit", true);
        
        component.set("v.editAccId", event.target.id);
        component.set("v.viewAccId", event.target.id);
    },
    view: function (component, event, helper) {
        component.set("v.isEdit", true);
        component.set("v.viewAccId", event.target.id);
        component.set("v.isView", true);
    },
    handleSavePMAForm: function (component, event, helper) {
        var oppid = event.target.id;
        
        var strRVPName = component.get("v.rvpName");
        var username = strRVPName.name;
        
        var action = component.get("c.changeOwnerMethod");
        action.setParams({
            oppid: oppid,
            userName: username
        });
        action.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
                var rec = response.getReturnValue();
                
                if (response.getReturnValue() == 'SUCCESS') {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success Message',
                        type: "success",
                        message: 'The record Owner has been changed successfully.',
                    });
                    toastEvent.fire();
                } else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning Message',
                        type: "error",
                        message: 'Error : ' + response.getReturnValue(),
                    });
                    toastEvent.fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message: 'Please select a Owner.',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    closeModel: function (component, event, helper) {
        component.set("v.isView", false);
    },
    
    
})