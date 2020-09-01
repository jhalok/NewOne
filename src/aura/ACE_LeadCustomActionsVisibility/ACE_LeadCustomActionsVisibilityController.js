({
    doInit : function(component, event, helper) {
       helper.fetchUserProfileInfo(component, event, helper);
        
    },
    callSaveComp : function(component, event, helper) {
        var clickedBtn = event.getSource().getLocalId();
        if(clickedBtn == 'testDrive'){
            helper.navigateToComponent(component, event, helper, "c:ACE_ScheduleTestDrive");
        }
        else if(clickedBtn == 'addDealer'){
            helper.navigateToComponent(component, event, helper, "c:ACE_AssignDealer");
        }
        else if(clickedBtn == 'closeCall'){
            helper.navigateToComponent(component, event, helper, "c:ACE_MRC_LeadDisposition");
        }
        else if(clickedBtn == 'existingVehicle'){
            helper.navigateToComponent(component, event, helper, "c:ACE_ExistingVehicles2");
        }
        else if(clickedBtn == 'updatePI'){
            helper.navigateToComponent(component, event, helper, "c:ACE_Product_Interest_Prioritization");
        }
        console.log('clickedBtn-->',clickedBtn);
    }
})