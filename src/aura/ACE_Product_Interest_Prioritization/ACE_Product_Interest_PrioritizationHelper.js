({
    fetchPIHelper : function(component, event, helper,actions) {
        
        var leadId = component.get("v.recordId");
        var action = component.get("c.fetchProductInterests");
        action.setParams({
            "leadId":leadId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.productInterests", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

})