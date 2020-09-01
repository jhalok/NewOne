({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var prodIntCheck = component.get('v.productInterests');
        
        if (prodIntCheck.length == 0) {
            var productInterest = {
                'sobjectType': 'ACE_Product_Interest__c',
                'Product__c': ''
            };
            var productInterests = [];
            productInterests.push(productInterest);
            component.set("v.productInterests", productInterests);
        }
        component.set("v.showSpinner", false);

        /*  var str = window.location.href;
        var res = str.split("/");
        
        var id = '';
        var leadId = component.get("v.leadId");
        console.log(leadId);
        if(leadId != undefined )
        {
            id = leadId;

        }else{
            id = res[6];
        } 
        var action = component.get("c.getLeadRecord");
        action.setParams({ leadId : id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                component.set("v.leadRecord",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
      

        var action = component.get("c.getExistingProducts");
        action.setParams({ Id : id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                var allData = response.getReturnValue();
                var allModels = component.get('v.allExistingProducts');
                for(var i=0; i<allData.length; i++){
                    if(allData[i].Product__c != '' || allData[i].Product__c != undefined){
                        allModels.push(allData[i].Product__c);
                    }
                }
                component.set('v.allExistingProducts',allModels);
               
            }
        });
        $A.enqueueAction(action);*/


    },
    saveData: function (component, event, helper) {
        var productInterests = component.get("v.productInterests");
        console.log('product ine6565u657', productInterests);
        var id = '';
        var leadId = component.get("v.leadId");
        let flagError = false;
        let errorMsg = ''

        for (let i = 0; i < productInterests.length; i++) {
            if (productInterests[i].Product__c == '') {
                flagError = true;
                errorMsg = 'Please select the product and try again.'
            }
            // To check multiple occurence of same object.

        }
        /* if(leadId != 'new'){
            var blankValue = true;
            var existing = true;
    
            var allModels = component.get('v.allExistingProducts');
            for(var i=0; i<productInterests.length; i++){
                productInterests[i].Lead__c = component.get("v.leadRecord").Id;
                if(leadId != undefined )
                {
                    productInterests[i].Source__c = 'Employee Referral';
                    productInterests[i].Subsource__c = '';
                }
            
                if(allModels.indexOf(productInterests[i].Product__c) > -1 ){
                    existing = false;
                }
                if( productInterests[i].Product__c == '' || productInterests[i].Product__c == undefined){
                    blankValue = false;
                }
            }
            var leadId = component.get("v.leadId");
            if(blankValue &&  existing ){
                
                    var action = component.get("c.saveInterests");
                    action.setParams({ productInterests : productInterests});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if( state === "SUCCESS"){
                        
                            if(response.getReturnValue() == null){
                                var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        type : "Success",
                                        title: "Success!",
                                        message: "The record has been Created successfully."
                                    });
                                    toastEvent.fire();
                            }
                            else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    type : "Error",
                                    title: "Error!",
                                    message: response.getReturnValue()
                                });
                                toastEvent.fire();
                            }  
                            var cmpEvent = component.getEvent("clsPopupEvent");
                            cmpEvent.fire(); 
                        }
                        else{
                            var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    type : "Error",
                                    title: "Error!",
                                    message: "Error !!!!"
                                });
                                toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);
            
            }
            else if(!blankValue){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type : "Error",
                    title: "Error!",
                    message: "Please Select a product !"
                });
                toastEvent.fire();
            }
            else if(!existing){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type : "Error",
                    title: "Error!",
                    message: "Product Already Existing !"
                });
                toastEvent.fire();
            }
        } */
        if (!flagError) {
            var cmpEvent = component.getEvent("interestList");
            console.log(cmpEvent);
            cmpEvent.setParams({
                "interestList": productInterests
            });
            console.log(productInterests);
            cmpEvent.fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'Success',
                title: "Success!",
                message: "Interest has been  successfully Added."
            });
            toastEvent.fire();
            component.set("v.showModal", false);
            //$A.get("e.force:closeQuickAction").fire(); 

        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",
                message: errorMsg
            });
            toastEvent.fire();
        }
    },

    addRowData: function (component, event, helper) {
        var productInterest = {
            'sobjectType': 'ACE_Product_Interest__c',
            'Product__c': '',
            'Interest_Category__c': 'Other_Interest',
            'Lead__c': '',
            'InterestName': '',
            //  'disable':true
        };
        var productInterestsArray = JSON.parse(JSON.stringify(component.get('v.productInterests')));
        productInterestsArray.push(productInterest);
        component.set('v.productInterests', productInterestsArray);

    },
    delSingleRow: function (component, event, helper) {
        var r = confirm("Are you sure to delete ???");
        if (r == true) {
            var id = event.target.id;
            var productInterestsArray = JSON.parse(JSON.stringify(component.get('v.productInterests')));
            productInterestsArray.splice(id, 1);
            if (id == 0) {
                var productInterest = {
                    'sobjectType': 'ACE_Product_Interest__c',
                    'Product__c': '',
                    //  'disable':true
                };
                productInterestsArray.push(productInterest);
            }
            component.set('v.productInterests', productInterestsArray);
        }
    },
    closeModel: function (cmp) {
        cmp.set("v.showModal", false);
        $A.get("e.force:closeQuickAction").fire()
    },
    productMatch: function (component, event, helper) {

    }

})