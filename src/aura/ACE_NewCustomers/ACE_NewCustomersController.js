({
	 ModuleBoxForBulk: function( component, event, helper ) {
        component.set("v.ShowModuleBoxForBulk", true);
    },
    saveData:function(component, event, helper){
        var dynamicRowComp = component.find("cdynamicRowComp");
        dynamicRowComp.saveData();
    },
    closeModel:function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        var cmpEvent = component.getEvent("modalClose");
        cmpEvent.fire();
    }
})