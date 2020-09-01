({
	showSuccessToast : function(component, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            type: 'success',
            mode: 'dismissible',
            duration:'10000',
            key: 'info_alt'
        });
        toastEvent.fire();
       
	},
    showErrorToast : function(component, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: message,
            type: 'error',
            mode: 'dismissible',
            duration:'10000', 
            key: 'info_alt'
        });
        toastEvent.fire();
    },
    /*showspinner : function(component){
        var showSpinner = component.find('Spinner');
        $A.util.removeClass(showSpinner, 'slds-hide');
    },
    hidespinner : function(component){
        var hideSpinner = component.find('Spinner') ;
        $A.util.addClass(hideSpinner, 'slds-show');
    },*/
    
})