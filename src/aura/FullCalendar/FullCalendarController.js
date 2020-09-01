({
    afterScriptsLoaded: function(cmp,evt,helper){
        var events = cmp.get("v.events");
        console.log(events);
        if(!events.length)
        {
            helper.fetchEvents(cmp);
        }
         var str = window.location.href
        var res = str.split("/");
        console.log(res[6]);
	
		  var action = cmp.get("c.getLeadRecord");
        	action.setParams({ Id : res[6] });

            action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
               
               cmp.set('v.recordLead', response.getReturnValue());
             
            }
            
        });

        $A.enqueueAction(action); 
    },
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
       
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
      
       
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    onRecordSuccess: function(component, event, helper) {
        helper.fetchEvents(component);
         jQuery("document").ready(function(){
                 $("#calendar").html('');
             var selectList = $("whatever-selector");
				selectList.find("option:gt(0)").remove();
			});
        component.set("v.isOpen", false);
    },
    
    
})