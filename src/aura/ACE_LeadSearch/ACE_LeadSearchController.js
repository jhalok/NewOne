({
    Search : function(component, event, helper) {
        helper.SearchHelper(component, event);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var Addvalue = row.Name;
        //   alert("Showing opportunity " + Addvalue);
         component.set("v.SelectMessage", true);
        component.set("v.selectedAccount", Addvalue);
       // if(currentvalue)
        // helper.showRowDetails (component, row, event);       
    }
    
})