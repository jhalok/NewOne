({
  createContact : function(component, event) {
    var newAcc = component.get("v.newContact");
    var action = component.get("c.savecontact");
    action.setParams({ 
        "con": newcon
    });
    action.setCallback(this, function(a) {
           var state = a.getState();
            if (state === "SUCCESS") {
                var name = a.getReturnValue();
               alert("hello from here"+name);
            }
        });
    $A.enqueueAction(action)
}
})