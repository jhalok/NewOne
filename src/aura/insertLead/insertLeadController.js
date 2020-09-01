({
  doInit: function(component, event, helper) {
    component.set("v.showSpinner", "true");
    component.set("v.showButton", "false");
    let action = component.get("c.getFieldsOnLayout");
    //let fld    = component.get("v.fields");
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.showSpinner", "false");
        let fields = response.getReturnValue();
        component.set("v.fields", fields);
        console.log("fields are ", fields);
        let arrayMapKeys = [];
        for (var key in fields) {
          arrayMapKeys.push({ key: key, value: fields[key] });
        }
        component.set("v.fields", arrayMapKeys);
        console.log("map is ", arrayMapKeys);
      }
    });
    $A.enqueueAction(action);
  },
  handleLoad: function(component, event, helper) {
    component.set("v.showSpinner", "true");
    let fieldsValue = component.get("v.fields");
    if (fieldsValue != null) {
      component.set("v.showSpinner", "false");
      component.set("v.showButton", "true");
    }
  },
  handleSubmit: function(component, event, helper) {
    console.log("inside handleSubmit");
    helper.handleSubmitHelper(component, event, helper);
    
  },
  handleSuccess: function(component, event, helper) {
    component.set("v.showSpinner", "true");
    let fieldsValue = component.get("v.fields");
    if (fieldsValue != null) {
      component.set("v.showSpinner", "false");
      component.set("v.showButton", "true");
    }
  },
  cancelDialog: function(component, event, helper) {
    var homeEvt = $A.get("e.force:navigateToObjectHome");
    homeEvt.setParams({
      scope: "Lead"
    });
    homeEvt.fire();
  }
});