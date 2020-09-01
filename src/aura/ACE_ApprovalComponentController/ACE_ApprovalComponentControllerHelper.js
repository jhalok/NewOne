({  
      getApprovalList : function(component) { 
          var str = window.location.href
        var res = str.split("/");
       // alert(res[6]);
     var action = component.get("c.approvals1");  
         
     action.setParams({  
       "recId": res[6] 
     });  
     action.setCallback(this, function(response) {
            var state = response.getState();
         //alert(state);
            if (state === "SUCCESS") {
               // alert('=='+JSON.stringify(response.getReturnValue()));
				component.set("v.approvalList",response.getReturnValue());                
            }
        });

     $A.enqueueAction(action);  
      }  
 })