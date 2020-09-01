({  
    doInit : function(component, event, helper) {  
        helper.getApprovalList(component);  
    },
    Approve : function(component,event,helper){
        //alert('hey');
        var approvals = component.get("v.approvalList");
        //alert('=checked='+JSON.stringify(approvals));
        
        var selectedApprovals =[];
        
        approvals.forEach(element => {
            if(element.Selected){
            let recordIdToApprove = element.processId;
            selectedApprovals.push(recordIdToApprove);
        }
                          });
        var str = window.location.href
        var res = str.split("/");
        //alert(res[6]);
        var action = component.get("c.approveLead");
       // alert('=selectedApprovals='+selectedApprovals);
        var sel = selectedApprovals.toString();
        action.setParams({  
            "recId": res[6],
            "approvalIds":sel
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert(state);
            if (state === "SUCCESS") {
                component.refresh();             
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
    Reject : function(component,event,helper){
        //alert('hey');
        var rejects = component.get("v.approvalList");
        //alert('=checked='+JSON.stringify(rejects));
        
        var selectedRejects =[];
        
        rejects.forEach(element => {
            //console.log(element);
            if(element.Selected){
            //alert('wow selected');
            let recordIdToReject = element.processId;
            //alert('=recordIdToReject='+recordIdToReject);
            selectedRejects.push(recordIdToReject);
           // alert('=JSON string='+JSON.stringify(recordIdToReject));
            
        }
                        });
        //alert('=JSON string2='+JSON.stringify(selectedRejects));
        //var apps = JSON.stringify();
        var str = window.location.href
        var res = str.split("/");
       // alert(res[6]);
        var action = component.get("c.rejectLead");
        var rej = selectedRejects.toString();
        action.setParams({  
            "recId": res[6],
            "rejectIds":rej
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                component.refresh();                               
            }
        });
        
        $A.enqueueAction(action);
        
    },
    onSelectAllChange : function(component,event,helper){
        //alert(component.get('v.isAllSelected'));
        if(component.get('v.isAllSelected') == false) {
            component.set('v.isAllSelected', true);
            
            const approvalCheckboxes = component.find('approvalCheckboxes'); 
           // alert('=approvalCheckboxes='+approvalCheckboxes.length);
            let chk = (approvalCheckboxes.length == null) ? [approvalCheckboxes] : approvalCheckboxes;
            chk.forEach(checkbox => checkbox.set('v.checked', component.get('v.isAllSelected')));
        }
        else if(component.get('v.isAllSelected') == true) {
            component.set('v.isAllSelected', false);
            
            const approvalCheckboxes = component.find('approvalCheckboxes'); 
           // alert('=approvalCheckboxes='+approvalCheckboxes.length);
            let chk = (approvalCheckboxes.length == null) ? [approvalCheckboxes] : approvalCheckboxes;
            chk.forEach(checkbox => checkbox.set('v.checked', component.get('v.isAllSelected')));
        }
        
    }
    
})