({
    SearchHelper: function(component, event) {
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
        
        //  component.set('v.columns',[{ label: 'Account Name', fieldName: 'URL', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }}]);
        //component.set('v.columns',[{label: 'Lead Name' , fieldName: 'Name', type:'text'}]);
        component.set('v.columns',[{ label: 'Lead Name', fieldName:  'URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }},
                                  	{label: 'Link', type: 'button', initialWidth: 135, typeAttributes: { label: 'Link Lead', name: 'view_details', title: 'Click to Link Lead'}}]);
        var action = component.get("c.fetchLead");
        action.setParams({
            'searchMobileNo': component.get("v.searchMobileNo"),
            'searchEmail': component.get("v.searchEmail")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        
        
        $A.enqueueAction(action);
    },

})