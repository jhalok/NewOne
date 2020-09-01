({
    doinit : function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        helper.getopplistFunction(component,pageNumber,pageSize);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber++;
        helper.getopplistFunction(component, pageNumber, pageSize);
    },
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getopplistFunction(component, pageNumber, pageSize);
    },
    onSelectChange: function(component, event, helper) {
        var pageNumber = 1
        var pageSize = component.find("pageSize").get("v.value");
        helper.getopplistFunction(component, pageNumber, pageSize);
    },
    edit : function(component, event, helper) {
        component.set("v.isView",false);
        component.set("v.isEdit",true);
        console.log('Edit record ID..'+event.target.id);
        component.set("v.editAccId",event.target.id);
        component.set("v.viewAccId",event.target.id);
    },
    view : function(component, event, helper) {
        component.set("v.isEdit",true);
        component.set("v.viewAccId",event.target.id);
        component.set("v.isView",true);
    },
    handleSavePMAForm: function(component, event, helper) { 
        var oppid=event.target.id;
        console.log('oppid----------'+oppid);
        var strRVPName= component.get("v.rvpName");
        var username=strRVPName.name;
        console.log('---------username---------'+username);
        var action = component.get("c.changeOwnerMethod");
        action.setParams({
            oppid : oppid,
            userName:username
        });
        action.setCallback(this, function(response) {
            console.log('------state------'+response.getState());
            if(response.getState() === "SUCCESS") {
                var rec = response.getReturnValue();
                console.log('----rec------'+rec);
                if(response.getReturnValue() == 'SUCCESS'){
                    console.log('inside if');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        type : "success",
                        message: 'The record Owner has been changed successfully.',
                    });
                    toastEvent.fire();
                }
                else {
                    console.log('inside else');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning Message',
                        type : "error",
                        message: 'Error : '+response.getReturnValue(),
                    });
                    toastEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type : "error",
                    message: 'Please select a Owner.',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    closeModel: function(component, event, helper) {
        component.set("v.isView", false);
    },
})