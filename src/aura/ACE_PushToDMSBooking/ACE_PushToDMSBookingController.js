({
	doinit : function(component, event, helper) {
		//helper.showspinner(component);
        var bookingId = component.get("v.recordId");
        var action = component.get("c.getBookingDetails");
        action.setParams({BookingId: bookingId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result-->',result);
            if (response.getState() === "SUCCESS") {            
                if (result.statusCode === 200 || result.statusCode === 201 && result.status === 'OK'|| result.status === 'Created' && result.isSuccessful == '1') {                              
                        helper.showSuccessToast(component, result.message);
                        $A.get("e.force:closeQuickAction").fire(); 
                        $A.get('e.force:refreshView').fire();
                }
                else {
                    helper.showErrorToast(component,result.message);
                    $A.get("e.force:closeQuickAction").fire(); 
                }
            }else {
                var errors = response.getError();
                console.log(errors);
                if (Array.isArray(errors) && errors.length && errors[0] && errors[0].message) {                        
                    helper.showErrorToast(cmp,errors[0].message);
                    $A.get("e.force:closeQuickAction").fire(); 
                }
            }      
            //helper.hidespinner(component); 
        });
		$A.enqueueAction(action);
	}
})