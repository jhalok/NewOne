({
    sendMessage : function(component, event) {
        var isSigned = false;
        console.log('1: '+component.find("mobileNumber").get("v.value"));
        console.log('2: '+component.find("message").get("v.value"));
        var action = component.get("c.sendMessage");
        action.setParams({
            "mobileno": component.find("mobileNumber").get("v.value"),
            "message": component.find("message").get("v.value")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS');
            }
            else{
                console.log('Failed: '+response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})