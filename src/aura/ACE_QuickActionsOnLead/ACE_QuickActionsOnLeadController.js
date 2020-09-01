({
    doInit: function(component, event, helper) {
        var closeCall = component.find('closeCall');
        if(!$A.util.isUndefinedOrNull(closeCall)){
            closeCall.reload();
        }
        var recordId = component.get("v.recordId");
        console.log('current record id===================>'+recordId);
        if(recordId!=null && recordId.startsWith("00Q")){
            var action = component.get("c.getLeadDtls");
            action.setParams({"recId": recordId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response='+response+'--state='+state);
                if (state === "SUCCESS") {
                    component.set('v.showNewLeadButton', false);
                    component.set('v.showReferFreindButton', false);
                    var leadRecord = response.getReturnValue();
                    if(leadRecord && leadRecord.RecordType && leadRecord.RecordType.DeveloperName === "Prelaunch_Lead"){
                        component.set('v.showExistingVehicle', false);
                        component.set('v.showAssignDealer', false);
                        component.set('v.showTD', false);
                        component.set('v.showAddCompetitor', false);
                        component.set('v.showProductInterest', false);
                    }
                    console.log("leadRecord--->" + JSON.stringify(leadRecord));
                    var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                    console.log("success--->" + responseObj);
                    component.set("v.leadRecord",responseObj);//JSON.stringify(leadRecord)
                    component.set("v.showFecthChat",true);
                    console.log('Fetch Complete!!!');
                }
                else if (state === "ERROR"){
                    alert("Failed to fetch current lead record details!");
                }
            });
            $A.enqueueAction(action);
        }
    },
    doCloseCall: function(component, event, helper) {
        var closeCall = component.find('closeCall');
        closeCall.showSpinner();
        if(!$A.util.isUndefinedOrNull(closeCall)){
            closeCall.closeDialerCall(function(result) {
                console.log(result);
                if(result!=undefined && result!=null)
                { 
                    if(result.statusCode == 200)
                    {
                        closeCall.set("v.recordError",null);
                        component.set("v.isCloseCallOpen", false);
                    }
                    else if(result.exceptionMessage!=null)
                    {
                        closeCall.set("v.recordError", result.exceptionMessage);
                        
                    }
                   
                }
                closeCall.hideSpinner();
                
        });
        }
    },
    updateDNC:function(component, event, helper){
        var dncComp = component.find('cDNC');
        dncComp.updateDNC();
        component.set("v.isDNCOpen", false);
    },
    openAddExistingVehiclesModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isAddExistingVehiclesOpen", true);
    },
    closeAddExistingVehiclesModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isAddExistingVehiclesOpen", false);
    },
    openAssignDealerModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isAssignDealerOpen", true);
    },
    closeAssignDealerModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isAssignDealerOpen", false);
    },
    openScheduleTestdriveModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isScheduleTestdriveOpen", true);
    },
    closeScheduleTestdriveModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isScheduleTestdriveOpen", false);
    },
    openUpdateProductInterestModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isUpdateProductInterestOpen", true);
    },
    closeUpdateProductInterestModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
         component.set("v.isUpdateProductInterestOpen", false);
    },
    openCloseCallModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isCloseCallOpen", true);
    },
    closeCloseCallModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isCloseCallOpen", false);
    },
    openRelatedContact: function(component, event, helper) {
        component.set("v.isRelContactOpen", true);
    },
    closeRelatedContact: function(component, event, helper) {
        component.set("v.isRelContactOpen", false);
    },
    openOthInt: function(component, event, helper) {
        component.set("v.isOthIntOpen", true);
    },
    closeOthInt: function(component, event, helper) {
        component.set("v.isOthIntOpen", false);
    },
    openPrioritization: function(component, event, helper) {
        component.set("v.isPrioritizationOpen", true);
    },
    closePrioritization: function(component, event, helper) {
        component.set("v.isPrioritizationOpen", false);
    },
    openFetchChat: function(component, event, helper) {
        component.set("v.isFetchChatOpen", true);
    },
    closeFetchChat: function(component, event, helper) {
        component.set("v.isFetchChatOpen", false);
    },
    openDNCModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        try{
            component.set("v.isDNCOpen", true);
        }catch(error){
            console.log(error);
        }
        
    },
    closeDNCModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isDNCOpen", false);
    },
    openNewLead : function(component, event, helper) {
        // Set newlead attribute to true 
        component.set("v.isNewLead", true);
    },
    closeNewLead : function(component, event, helper) {
        // Set newlead attribute to false 
        component.set("v.isNewLead", false);
    },
    openReferAFreind : function(component, event, helper){
        // Set isReferAFriend attribute to true 
        component.set("v.isReferAFriend",true);
    },
    closeReferAFreind : function(component, event, helper){
        // Set newlead attribute to false
        component.set("v.isReferAFriend",false);
    },
})