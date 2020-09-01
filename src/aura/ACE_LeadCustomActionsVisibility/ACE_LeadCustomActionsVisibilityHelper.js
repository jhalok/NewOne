({
    fetchUserProfileInfo : function(component, event, helper) {
        var action = component.get("c.fetchUserProfileInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userInfo = response.getReturnValue();
                console.log('userInfo-->',userInfo);
                if(userInfo.Profile.Name == 'System Administrator'){
                    var cmpTarget = component.find('testDrive');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                }
            }
            else if (state === "ERROR")
            {
                alert("Failed");
            }
        });
        $A.enqueueAction(action);
    },

    navigateToComponent : function(component, event, helper, compName){
        var recId = component.get('v.recordId');
        try{
        	$A.createComponent(compName, {'recordId':recId},
                           function(modalcmp, status, errors) {
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal({
                                       body: modalBody,
                                       header: "Close Call",
                                       showCloseButton: true,
                                       cssClass: "",
                                       closeCallback: function() {
                                           alert('You closed the alert!');
                                       }
                                   })
                               }
                           });
            
        }
        catch(error){
            console.log(error)
        }
        /*var evt = $A.get("e.force:navigateToComponent");
        console.log('Event '+evt);
        evt.setParams({
            componentDef  : compName
        });
      
        evt.fire();*/
    }
})