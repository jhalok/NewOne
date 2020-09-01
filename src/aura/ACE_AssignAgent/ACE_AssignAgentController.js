({
    doInit : function(component, event, helper) {
        helper.getUsers(component, event);
        
    },
    handleKeyUp : function(component, event, helper) {
        //alert('up');
        helper.getOpportunities(component, event);
        
    },
    assignUserID: function(component,event,helper){
        // alert('hey');
        helper.updateAccount(component, event);
        
        
    },
    addSearchSection :function(component,event,helper){
        helper.addSearch(component, event);
    },
    delSingleRow :  function(component, event, helper) {
        var id = event.target.id; 
        var listSearchDeaerArray = JSON.parse(JSON.stringify(component.get('v.listSearchDeaer')));
        if (id > -1) {
            listSearchDeaerArray.splice(id, 1);
        }
        console.log(listSearchDeaerArray);
        component.set('v.listSearchDeaer',listSearchDeaerArray);
    },
    
})