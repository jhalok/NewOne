({
    toggle: function (component, event, helper) {
        var cm = component.find("radioGroupRequired").get("v.value");
        //alert(cm);
       //alert(component.get("v.toggleChange"));
        if(cm == 'YES'){
            component.set("v.toggleChange",true);
        }
        else
        {
            component.set("v.toggleChange",false);
        }
  

    }
})
({
    doInit : function(component, event, helper) { 
        // get the fields API name and pass it to helper function
        var objDetails = component.get("v.objDetail");   
        var Salutation = component.get("v.Salutation");
        helper.fetchPickListVal(component,objDetails,Salutation);         
    }, 
    save : function(component,event,helper) {
        alert('save');
        var objDetails = component.get("v.objDetail");
        helper.InsertRecord(component,objDetails);
            
    }
    
})