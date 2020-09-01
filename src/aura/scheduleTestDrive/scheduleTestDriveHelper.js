({
	showErrorMsg : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type:"Error",title:"Error!",message: msg});
        toastEvent.fire();
	}
})