({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        if(!$A.util.isUndefinedOrNull(recordId)){
            helper.loadServices(component, event,recordId);
        }
    },
    showSpinner:  function(component, event, helper) {
        $A.util.removeClass(component.find('spinner'), 'slds-hide');
    },
    hideSpinner:  function(component, event, helper) {
        $A.util.addClass(component.find('spinner'), 'slds-hide');
    },
    onServiceSelected: function(component, event, helper) {
        var selectedServiceValue = component.get('v.selectedServiceValue');
        if(!$A.util.isUndefinedOrNull(selectedServiceValue)){
            helper.loadDispositions(component, event,selectedServiceValue);
        }
    },
    
    
    onDispositionSelected : function(component, event, helper) {
        var selectedDispositionValue = component.get('v.selectedDispositionValue');
        var subDispositionMap = component.get('v.subDispositionMap');
        if(!$A.util.isUndefinedOrNull(selectedDispositionValue)){
            var subdispositionlist = subDispositionMap[selectedDispositionValue];
            component.set('v.subDispositionList',subdispositionlist);
            /*if(subdispositionlist.length > 0){
                var defaultSubdispositionValue = component.get('v.defaultSubdispositionValue');
                    window.setTimeout(
                        $A.getCallback( function() {
                            if(!$A.util.isUndefinedOrNull(defaultSubdispositionValue))
                                component.set('v.selectedSubdispositionValue',defaultSubdispositionValue);
                            else
                                component.set('v.selectedDispositionValue','');
                        }));
            }*/
        }
    },
 
	handleRecordUpdated : function(component, event, helper) {
		
    },
    handleCloseCall: function(component, event, helper) {
        helper.closeCall(component,event);
    }
})