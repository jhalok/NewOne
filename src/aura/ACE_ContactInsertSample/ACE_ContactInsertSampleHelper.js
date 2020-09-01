({
    fetchPickListVal: function(component,objDetails,Compfield) {
        // var checkboolean = component.find("!v.radioGroupRequired").get("v.value");
        //alert('checkboolean-->'+checkboolean);
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": objDetails,
            "fld": Compfield,
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var StoreResponse = response.getReturnValue();
                var opts = [];
                
                for(var i=0;i<StoreResponse.length;i++){
                    opts.push({
                        label:StoreResponse[i],
                        value:StoreResponse[i]
                    })	
                }
                component.set("v.SalutationPick",opts);
            }else{
                alert('Something went wrong..');
            }
        });            
        $A.enqueueAction(action);  
    },
    fetchBuisnessListVal: function(component,objDetails,Compfield) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": objDetails,
            "fld": Compfield,
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var StoreResponse = response.getReturnValue();
                var opts = [];
                opts.push('--- None ---');
                for(var i=0;i<StoreResponse.length;i++){
                    opts.push({
                        label:StoreResponse[i],
                        value:StoreResponse[i]
                    })	
                }
                component.set("v.BusinessUnitPick",opts);
            }else{
                alert('Something went wrong..');
            }
        });            
        $A.enqueueAction(action);  
    },    
    InsertRecord : function(component,objDetails,LeadListArray){
        // alert('Submitted');
        var cm = component.find("radioGroupRequired").get("v.value");
        if(cm == 'YES'){
            var checkboolean = component.get("{!v.Vehicle_Number__c}");
            //alert(checkboolean);
            objDetails.Vehicle_Number__c = checkboolean;
            objDetails.Do_you_own_a_Mahindra_vehicle__c = true;
            //component.set("v.toggleChange",true);
        }
        
        var checkboolean = component.get("{!v.Vehicle_Number__c}");
        //alert(checkboolean);
        objDetails.Vehicle_Number__c = checkboolean;
        var action = component.get("c.saveRecord");
        //alert('=con='+JSON.stringify(objDetails));
        //alert('=Lead='+JSON.stringify(LeadListArray));
        action.setParams({
            'objDetail' : objDetails,
            'ListLead' : LeadListArray
        });
        action.setCallback(this,function(res){
            var state = res.getState();
            if (state === 'SUCCESS'){
                alert('SUCCESS')
                var abcd = res.getReturnValue();
                alert(abcd);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records got inserted successfully.",
                    "type":"Success"
                });
                toastEvent.fire();
                window.location.reload(); 
            }
        });
        $A.enqueueAction(action);
    },
    createObjectData: function(component, event) {
        // get the AccList from component and add(push) New Object to List  
        var rowItemList = component.get("v.LeadList");
        rowItemList.push({
            'sobjectType': 'Lead',
            'LastName': '',
            'MobilePhone': '',
            'Company': 'testing',
            'Status': 'Open - Not Contacted',
            'Contact_Time__c' : '',
            'disable':false
        });
        // set the updated list to attribute (AccList) again    
        component.set("v.LeadList", rowItemList);
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allLeadRows = component.get("v.LeadList");
        for (var indexVar = 0; indexVar < allLeadRows.length; indexVar++) {
            if (allLeadRows[indexVar].Name  == '') {
                isValid = false;
                alert('First Name Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;
    }
    
})