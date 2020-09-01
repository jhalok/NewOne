({
    searchRecordsHelper: function (component, event, helper, value) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
        // Calling Apex Method
        console.log("value ",value);
        var action = component.get('c.getProds');
        action.setParams({
            'searchString': searchString,
        });
        action.setCallback(this, function (response) {

            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log("result is ",result);
                //component.set("v.recordsList",result);
                if( $A.util.isEmpty(value) ) {
                    component.set('v.recordsList',result);        
                } else {
                    component.set('v.selectedRecord', result[0]);
                }

            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if ($A.util.isEmpty(value))
                $A.util.addClass(component.find('resultsDiv'), 'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    }
})