({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        var action = component.get("c.getLeadDNC");
            
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
               // component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result=JSON.parse(JSON.stringify(response.getReturnValue())); 
                    component.set("v.expDurationList",result);
                }
            });
            $A.enqueueAction(action);
    },

    showSpinner:  function(component, event, helper) {
        $A.util.removeClass(component.find('spinner'), 'slds-hide');
    },
    hideSpinner:  function(component, event, helper) {
        $A.util.addClass(component.find('spinner'), 'slds-hide');
    },
    updateDNC:function(component, event, helper){
       // $A.util.removeClass(component.find('spinner'), 'slds-hide');
        console.log(component.get("v.selectedExpirationValue"));
        var DNCExpValue = component.get("v.selectedExpirationValue");
        var leadId = component.get('v.recordId');
        var action = component.get("c.updateDNCExp");
            action.setParams({
                'leadId': leadId,
                'DNCExpValue': DNCExpValue,
                
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                //component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    window.reload();
                   // $A.util.addClass(component.find('spinner'), 'slds-hide');
                }
            });
            $A.enqueueAction(action);
    }
})