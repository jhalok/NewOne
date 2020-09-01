({
    closeCall : function(component,event){
        var params = event.getParam('arguments');
        var callback;
        if (params) {
            callback = params.callback;
        }
       var selectedDispositionValue = component.get('v.selectedDispositionValue');
        console.log('selectedDispositionValue: '+selectedDispositionValue);
        var selectedSubdispositionValue = component.get('v.selectedSubdispositionValue');
        console.log('selectedSubdispositionValue: '+selectedSubdispositionValue);
        var comments = component.get('v.comments');
       
                    var action = component.get("c.closeCall");
                    action.setParams({ 
                        dispositionCode : component.get('v.selectedSubdispositionValue'),
                        nextDialTime : component.get('v.nextDialTime'),
                        comments : component.get('v.comments'),
                        recordId : component.get('v.recordId'),
                        dispositionId: component.get('v.selectedDispositionValue'),
                        subdispositionId: component.get('v.selectedSubdispositionValue')
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('------------- SUCCESS --------------------');
                            console.log('*********'+response.getReturnValue());
                            console.log(response.getReturnValue());
							var data = JSON.parse(response.getReturnValue());
                            if (callback) callback(data);
                        }
                        else if (state === "INCOMPLETE") {
                            // do something
                            // 
                            component.set("v.messageType", "info" );
                            component.set("v.message" ,'Some Error occured during the process.' );
                            ////$A.util.removeClass(component.find("alertMessage"), "slds-hide");
                        }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                    errors[0].message);
                                        component.set("v.messageType", "error" );
                                        component.set("v.message" ,errors[0].message );
                                        //$A.util.removeClass(component.find("alertMessage"), "slds-hide");
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                    });
                    $A.enqueueAction(action);   
            
    },   
    showToast : function(component, event,type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },  
    loadServices : function(component,event) {
        var service_action = component.get("c.loadMRCServices");
        component.showSpinner();
        service_action.setParams({ leadId : component.get("v.recordId")});
        service_action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('---------------------');
                console.log( response.getReturnValue());
                var serviceData = JSON.parse(response.getReturnValue());
                if(!$A.util.isUndefinedOrNull(serviceData)){
                    var serviceList = JSON.parse(serviceData.serviceJSON);
                    component.set('v.serviceList',serviceList);
                    // Let DOM state catch up.
                    window.setTimeout(
                        $A.getCallback( function() {
                            // Now set our preferred value
                            /*if(!$A.util.isUndefinedOrNull(serviceData.serviceSelectedValue))
                                component.set('v.selectedServiceValue',serviceData.serviceSelectedValue);
                            else
                                component.set('v.selectedServiceValue','');*/
                            component.set('v.selectedServiceValue','a0E5D000003PwqrUAC');
                            component.hideSpinner();
                        }));
                    
                    
                    
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(service_action);
    },    
    resetDispositionOnServiceChange : function(component, event) {
        component.set('v.selectedDispositionValue',"");
        component.set('v.selectedSubdispositionValue',"");
        var mainDispoList = component.get('v.mainDispositionList');
        if(mainDispoList!=undefined && mainDispoList.length > 0)
        {
            mainDispoList.clear();
            component.set('v.mainDispositionList',new Array());
        }
        var subDispoList = component.get('v.subDispositionList');
        if(subDispoList!=undefined && subDispoList.length > 0)
        {
            subDispoList.clear(); 
            component.set('v.subDispositionList',new Array());
        }
        
        
    },    
    loadDispositions : function(component,event,serviceId){
        var disposition_action = component.get("c.loadMRCDispositions");
        component.showSpinner();
        disposition_action.setParams({ serviceId : serviceId, dispositionType : "Agent",leadId : component.get('v.recordId')});
        disposition_action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('------------- SUCCESS DISPO--------------------');
                var dispositionsData = JSON.parse(response.getReturnValue());
                var dispositionList = dispositionsData.dispositions;
                var subDispositionMap = dispositionsData.subDispositionMap;
                var defaultSubdispositionValue =dispositionsData.selectedSubDispositionValue;
                if(!$A.util.isUndefinedOrNull(defaultSubdispositionValue))
                    component.set('v.defaultSubdispositionValue',defaultSubdispositionValue);
                
                if(!$A.util.isUndefinedOrNull(subDispositionMap)){
                    component.set('v.subDispositionMap',subDispositionMap);
                }
                var selectedDispositionValue = dispositionsData.selectedDispositionValue;
                
                component.set('v.mainDispositionList', dispositionList);
                /*window.setTimeout(
                    $A.getCallback( function() {
                        if(!$A.util.isUndefinedOrNull(dispositionsData.selectedDispositionValue))
                            component.set('v.selectedDispositionValue',dispositionsData.selectedDispositionValue);
                        else
                            component.set('v.selectedDispositionValue','');
                        component.hideSpinner();
                    }));*/
                
            }
            else if (state === "INCOMPLETE") {
                  component.hideSpinner();
                // do something
            }
                else if (state === "ERROR") {
                      component.hideSpinner();
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(disposition_action);
    }
})