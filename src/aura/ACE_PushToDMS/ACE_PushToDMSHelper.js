({
	
    showSuccessToast : function(cmp,message) {
        console.log(message);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            type: 'success',
            mode: 'dismissible',
            duration: '10000'
        });
        toastEvent.fire();
    },
    showErrorToast : function(cmp, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:message,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible',
            duration: '10000'
        });
        toastEvent.fire();
    },
    /*showSpinner: function(cmp) {
		var spinnerMain =  cmp.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
        
	},
 
	hideSpinner : function(cmp) {
		var spinnerMain =  cmp.find("Spinner");
		$A.util.addClass(spinnerMain, "slds-hide");
	},*/
})