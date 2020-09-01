({
    doInit : function(cmp, event, helper) {
        
        /*  var action = cmp.get("c.getContactRecord");
        //action.setParams({ Id : res[6] });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                cmp.set('v.contactRecord', response.getReturnValue());
                
            }
            
        });
        
        $A.enqueueAction(action); */
        
        var ProductList = { 'sobjectType': 'Product2',
                           'Name': '',
                           
                           //  'disable':true
                          };
        var LeadListArray = [];
        LeadListArray.push(ProductList);
        cmp.set('v.ProductList',LeadListArray);
    },
    
    addRowData :  function(component, event, helper) {
        var ProductList = { 'sobjectType': 'Product2',
                           'Name': '',
                           
                           //  'disable':true
                          };
        var LeadListArray = component.get('v.ProductList');
        LeadListArray.push(ProductList);
        component.set('v.ProductList',LeadListArray);
        
    },
    
    delSingleRow :  function(component, event, helper) {
        var prodListArr = JSON.parse(JSON.stringify(component.get('v.ProductList')));
        var index = event.target.id;
        var rowData = prodListArr[index];
        console.log('curr row',prodListArr[index]);
        var toBeDeleted = confirm("Are you sure to delete ???");
        
        if (toBeDeleted) {
           // var id = event.target.id; 
            //var LeadListArray = JSON.parse(JSON.stringify(component.get('v.ProductList')));
            prodListArr.splice(index, 1);
            component.set('v.ProductList',prodListArr);
        }
    },
    
    saveData : function(component, event, helper) {
        //alert("Hello Button PRessed");
       
        var newcon = component.get("v.recordId");
        var prodList= component.get('v.ProductList');
        var prodListSelected = [];
        for(var i=0;i<prodList.length;i++){
           // var lookupComp = component.get("v.ProductList").find(row => row.Id ==='customlookup'+i);
            var lookupComp = component.find("ccustomlookup");
            console.log('lookupComp-->',lookupComp);
            var pr = lookupComp[i].get('v.selectedRecord');
            prodListSelected.push(pr);
        }
        console.log('prodListSelected-->',prodListSelected);
        var prodData = JSON.stringify(prodListSelected);
        //var lookupComp = component.find("customlookup");
        //var prodList= component.get('v.ProductList');
       // var prodList = lookupComp.get('v.selectedRecord');
       // component.set('v.ProductList',prodList);
      // console.log('prodList-->',prodList);
        console.log('newcon-->',newcon);
        // alert("Hello"+ newcon );'productName':prodList.label,'productId':prodList.value
            
        var action = component.get("c.SaveLead");
        // alert("Hello Button Sucesss");
        action.setParams({
            'contactId': newcon,
            'prodData':prodData
            
        });       
        
        action.setCallback(this, function(response) {
            console.log('response->',response.getReturnValue());
            var state = response.getState();
            if(state === "SUCCESS"){
                //alert("Hello Button Sucesss");
               // helper.proHelper(component, event);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been  successfully Saved."
                });
                toastEvent.fire();
                //Redirect to detail page on success
                var navService = component.find('navService');
                console.log('navService---> ' +navService);
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": response.getReturnValue().Id,
                        "objectApiName": "Lead",
                        "actionName": "view"
                    }
                }
                event.preventDefault();
                navService.navigate(pageReference);

                // window.location.reload(); 
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "The record not saved  successfully."
                });
                toastEvent.fire();
            }
            
        });
        
        $A.enqueueAction(action); 
    },
    closeModel:function(component, event, helper){
        var cmpEvent = component.getEvent("clsPopupEventNewLead");
        cmpEvent.fire();
    }
})