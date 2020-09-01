({
    SearchHelper: function(component, event) {
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
       // var actions = [{ label: 'Show details', name: 'show_details' }];
        //component.set('v.columns',[{label: 'Account Name' , fieldName: 'Name', type:'text'}]);
         component.set('v.columns',[{ label: 'Name', fieldName: 'URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }},
                                  	{label: 'Link', type: 'button', initialWidth: 135, typeAttributes: { label: 'Link Account', name: 'view_details', title: 'Click to Link Account'}}]);
        
        var action = component.get("c.fetchRecords");
        var searchOptVal = component.get("v.searchOptionValue");
        var searchObj = [];
        if(searchOptVal == 'email' || searchOptVal == 'mobile'){
            searchObj.push('Contact');
            searchObj.push('Lead');
        }
        else if(searchOptVal == 'customerId'){
            searchObj.push('Contact');
        }
        else if(searchOptVal == 'chasisno' || searchOptVal == 'vehicleno'){
            searchObj.push('Asset');
        }
        else if(searchOptVal == 'roid'){
            searchObj.push('ACE_Repair_Order__c');
        }

        action.setParams({
            'searchText': component.get("v.searchText"),
            'searchObject': searchObj,
            'searchOptVal':searchOptVal
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
                for (var i = 0; i < storeResponse.length; i++) {
                    var row = storeResponse[i];
                    if (row.Contact) {
                        row.Name = row.Contact.Name;
                        row.URL__c = row.Contact.URL__c;
                    }
                }
                    
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