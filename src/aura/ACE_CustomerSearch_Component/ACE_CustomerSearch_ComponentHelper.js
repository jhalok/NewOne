({
    SearchHelper: function(component, event) {
        // show spinner message
        component.set("v.searchResult", []);
        component.find("Id_spinner").set("v.class" , 'slds-show');
       // var actions = [{ label: 'Show details', name: 'show_details' }];
        //component.set('v.columns',[{label: 'Account Name' , fieldName: 'Name', type:'text'}]);
         component.set('v.columns',[{ label: 'Name', fieldName: 'URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }},
                                  	{label: 'Link', type: 'button', initialWidth: 135, typeAttributes: { label: 'Link Account', name: 'view_details', title: 'Click to Link Account'}}]);
        var searchOptVal = component.get("v.searchOptionValue");
        
        var searchObj = [];
        //var allValid = true;
        if(searchOptVal == 'email'){
            try{
               var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                if (allValid) {
                    searchObj.push('Contact');
                    searchObj.push('Lead');
                }else{
                   
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    return;
                }
            } catch(error ){
                console.log('err->',error);
            }

        } else if(searchOptVal == 'mobile'){
            try{
               var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                if (allValid) {
                    searchObj.push('Contact');
                    searchObj.push('Lead');
                }else{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    return;
                }
            } catch(error){
                console.log('err->',error);
            }
           
        } else if(searchOptVal == 'customerId'){
            var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                searchObj.push('Contact');
            }else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        }
        else if(searchOptVal == 'chasisno'){
            var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                searchObj.push('Asset');
            }else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        }else if ( searchOptVal == 'vehicleno'){
            var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                searchObj.push('Asset');
            } else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        }
        else if(searchOptVal == 'roid'){
            var allValid = [].concat(component.find('searchField')).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                searchObj.push('ACE_Repair_Order__c');
            }else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
        }
        if(searchObj.length > 0){
            var action = component.get("c.fetchRecords");
            action.setParams({
                'searchText': component.get("v.searchText"),
                'searchObject': searchObj,
                'searchOptVal':searchOptVal
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    
                    // if storeResponse size is 0 ,display no record found message on screen.
                    if (storeResponse.length == 0) {
                        component.set("v.Message", true);
                    } else {
                        component.set("v.Message", false);
                    }
                    
                    // set searchResult list with return value from server.
                    for (var i = 0; i < storeResponse.length; i++) {
                        var row = storeResponse[i];
                    // if (row.Contact) {
                            row.Name = row.Name;
                            row.URL__c = row.URL;
                        //}
                    }
                        if(searchOptVal == 'mobile'){
                            component.set("v.searchResult", storeResponse); 

                        }
                        else{
                            component.set("v.searchResult", storeResponse); 

                        }
                    
                }else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                errors[0].message);
                        }
                    } else {
                        alert("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else{
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            component.set("v.Message", true);
        }
    
    },
    
    //Added by Sanchayan
    SearchMultiHelper: function(component, event, altSrch) {
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
        // var actions = [{ label: 'Show details', name: 'show_details' }];
        component.set('v.columns',[{ label: 'Name', fieldName: 'URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }},
                                   {label: 'Link', type: 'button', initialWidth: 135, typeAttributes: { label: 'Link Account', name: 'view_details', title: 'Click to Link Account'}}]);
        
        var action = component.get("c.fetchLeadAndContactRecords");
        console.log('====================================1--------');
        var searchOptVal = component.get("v.searchOptionValue");
        var searchObj = [];
        if(searchOptVal == 'email' || searchOptVal == 'mobile'){
            searchObj.push('Contact');
            searchObj.push('Lead');
        }
        else if(searchOptVal == 'customerId'){
            searchObj.push('Contact');
        }
            else if(searchOptVal == 'chasisno' || searchOptVal == 'vehicleno'){
                searchObj.push('Asset');
            }
                else if(searchOptVal == 'roid'){
                    searchObj.push('ACE_Repair_Order__c');
                }
        console.log('====================================2--------');
        action.setParams({
            'searchText': component.get("v.searchText"),
            'searchObject': searchObj,
            'searchOptVal':searchOptVal,
            'altSrch':altSrch
        });
        console.log('====================================3--------');
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            console.log('state--->'+state);
            if (state === "SUCCESS") {
                var rawResponse = response.getReturnValue();
                console.log('====================================4--------');
                // if rawResponse size is 0 ,display no record found message on screen.
                if (rawResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                var altChk='N';
                // set searchResult list with return value from server.
                for (var i = 0; i < rawResponse.length; i++) {
                    var row = rawResponse[i];
                    if (row.altFlag=='Y') {
                        altChk=row.altFlag;
                    }
                }
                if(altChk=='Y'){
                    component.set("v.searchOptionValue",'email');
                    component.set("v.searchText",altSrch);
                }
                
                component.set("v.recordMultiList", rawResponse); 
                console.log('====================================5--------');
            }else if (state === "INCOMPLETE") {
                alert('Response is Incomplete!');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showErrorMsg: function(component, event, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type : "Error",title: "Error!",message: msg});
        toastEvent.fire();
    },
    showSuccessMsg: function(component, event, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type : "Success",title: "Success!",message: msg});
        toastEvent.fire();
    },
    clearLinkEvtParams: function(){
        var linkObjEvt = component.getEvent("linkObjEvt");
        linkObjEvt.setParams({"sObjectName":"Lead","sObjRecId":"","sObjRecName":""});
        linkObjEvt.fire();
    },
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
              for(var cmp in acc) {
              $A.util.toggleClass(acc[cmp], 'slds-show');  
              $A.util.toggleClass(acc[cmp], 'slds-hide');  
         }
      },
})