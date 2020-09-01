({
    
	"doInit" : function(cmp, event, helper) {         
        //helper.showSpinner(cmp);
        var oppId  = cmp.get("v.recordId");
        var action = cmp.get("c.getEnquiryDetail");
        action.setParams({ opportunityId : oppId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            console.log('result-->',result);  
            if (response.getState() === "SUCCESS") {
                if (result.statusCode === 201 && result.status === 'Created' && result.isSuccessful == '1') {                              
                    helper.showSuccessToast(cmp, result.message);
                    $A.get("e.force:closeQuickAction").fire(); 
                    $A.get('e.force:refreshView').fire();
            }
            else {
                helper.showErrorToast(cmp,result.message);
                 $A.get("e.force:closeQuickAction").fire(); 
            }
            } else {
                    var errors = response.getError();
                    console.log(errors);
                    if (Array.isArray(errors) && errors.length && errors[0] && errors[0].message) {                        
                        helper.showErrorToast(cmp,errors[0].message);
                        $A.get("e.force:closeQuickAction").fire(); 
                    }
                }          
            
            //helper.hideSpinner(cmp); 
        });
		$A.enqueueAction(action);
	}
})