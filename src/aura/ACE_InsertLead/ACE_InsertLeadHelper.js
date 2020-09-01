({
  handleSubmitHelper: function(component, event, helper) {
    console.log('inside handle submit of helper');
    event.preventDefault();
    let leads = event.getParam("fields");
    console.log("fields in submit are " + leads);
    component.set("v.showSpinner", "true");
    let leadList = [];
    leadList.push(leads);
    let action = component.get("c.insertLeads");
    action.setParams({ newLeads: leadList });
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.showSpinner", "false");
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
          scope: "Lead"
        });
        homeEvt.fire();
      } else {
        alert("ERROR");
        component.set("v.showSpinner", "false");
      }
    });
    $A.enqueueAction(action);
  }
});