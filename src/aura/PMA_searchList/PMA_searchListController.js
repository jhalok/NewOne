({
    selectRecord: function (component, event, helper) {
        component.set("v.isSearchModelView", true);
        var getSelectRecord = component.get("v.objRec");
        var compEvent = component.getEvent("userEvents");
        compEvent.setParams({
            "recordByEvent": getSelectRecord
        });
        compEvent.fire();
    },
    closeModelSearch: function (component, event, helper) {
        component.set("v.isSearchModelView", false);
    },

    
})