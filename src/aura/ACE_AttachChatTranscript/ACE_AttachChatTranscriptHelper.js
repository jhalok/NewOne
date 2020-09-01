({
	showErrorMsg: function(component, event, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type : "Error",title: "Error!",message: msg});
        toastEvent.fire();
    },
    showSuccessMsg: function(component, event, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type : "Success",title: "Success!",message: msg});
        toastEvent.fire();
    },
})