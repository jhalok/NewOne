({
    doInit: function (component, event, helper) {
        //Edited by Krishnan
        
            var id = component.get('v.recordId');
            if(id==null || id==undefined){
                console.log('Enter in if in id');
                id='0065D000004rjnDQAQ';
            }
            var OppRecord = {};
            //Edited by Krishnan
            var getLead;
            getLead = component.get("c.getAllOppModels");
            getLead.setParams({
                oppId: id
            });
            var self = this;
            getLead.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state is ',state);
                if (component.isValid() && state === "SUCCESS") {
                    OppRecord = response.getReturnValue();
                    console.log('OppRecord is ',response.getReturnValue(),'city is ',OppRecord.lstOpp.OpportunityLineItems,'size is ',OppRecord.lstOpp.OpportunityLineItems.length);

                    component.set("v.OppRecord", OppRecord);
                    var i;
                    //var res=OppRecord.lstOpp.
                    //var res = str.substring(str.length - 1, str.length);
                    //Edited by Krishnan
                    component.set("v.url", '/apex/getRoute?city=' + OppRecord.City);
                    
                    
                }
            });
            $A.enqueueAction(getLead);
       


    },
    goNext: function (component, event, helper) {
        var onFirstStep = component.get('v.onFirstStep');
        var onLastStep = component.get('v.onLastStep');
        var onSecStep = component.get('v.onSecStep');
        if (onFirstStep) {
            var modelSelected = component.get('v.modelName');
            console.log('modelSelected=' + modelSelected);
            if (modelSelected != null && modelSelected != '') {
                component.set('v.onFirstStep', false);
                component.set('v.onSecStep', true);
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-hide");
            } else {
                //alert('Please select a model for test drive!');
                helper.showErrorMsg("Please select a model for test drive.");
            }
        } else if (onSecStep) {
            component.set('v.onSecStep', false);
            component.set('v.onLastStep', true);
        }
    },
    goPrevious: function (component, event, helper) {
        var onFirstStep = component.get('v.onFirstStep');
        var onLastStep = component.get('v.onLastStep');
        var onSecStep = component.get('v.onSecStep');

        if (onSecStep) {
            component.set('v.onSecStep', false);
            component.set('v.onFirstStep', true);
        } else if (onLastStep) {
            component.set('v.onLastStep', false);
            component.set('v.onSecStep', true);
        }
    },

    cancelAction: function (cmp) {
        var cmpEvent = cmp.getEvent("clsPopupEventCTD");
        cmpEvent.fire();
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})