({
    doInit : function(cmp, event, helper) {
        var str = window.location.href;
        var res = str.split("/");

        var id = '';
        var leadId = cmp.get("v.leadId");
        console.log(leadId);
        if(leadId != undefined )
        {
            id = leadId;

        }else{
            id = res[6];
        }
        var getAllCompetitorsList = cmp.get("c.getAllCompetitorsList");
        getAllCompetitorsList.setParams({ LeadId : id});
        getAllCompetitorsList.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                var CompetitorsList = { 'sobjectType': 'Competitors_Considered__c',
                'Make__c': '',
                'Model__c': '',
                'Lead__c': '',
               //  'disable':true
              };
               var allDataOfCompetitors =  response.getReturnValue();
               allDataOfCompetitors.allNewCompetitors[0].allModels = [];
               allDataOfCompetitors.allNewCompetitors[0].Competitor = CompetitorsList;
                cmp.set('v.existingLength',allDataOfCompetitors.allExistingCompetitors.length);
                cmp.set('v.CompetitorsList',allDataOfCompetitors)
            }
            
        });
        
        $A.enqueueAction(getAllCompetitorsList);

    },
    
    addRowData :  function(component, event, helper) {
        var CompetitorsList = { 'sobjectType': 'Competitors_Considered__c',
                            'Make__c': '',
                            'Model__c': '',
                            'Lead__c': '',
                           //  'disable':true
                          };
        var CompetitorsListArray = component.get('v.CompetitorsList');
        CompetitorsListArray[0].allNewCompetitors.push(CompetitorsList);
        component.set('v.CompetitorsList',CompetitorsListArray);
        
    },
    
    delSingleRow :  function(component, event, helper) {
        var r = confirm("Are you sure to delete ???");
        if (r == true) {
            var id = event.target.id; 
            var CompetitorsListArray = JSON.parse(JSON.stringify(component.get('v.CompetitorsList')));
            CompetitorsListArray[0].allNewCompetitors.splice(id, 1);
            if(id == 0){
                var CompetitorsList = { 'sobjectType': 'Competitors_Considered__c',
                'Make__c': '',
                'Model__c': '',
                'Lead__c': '',
               //  'disable':true
              };
                CompetitorsListArray[0].allNewCompetitors.push(CompetitorsList);
            }
            component.set('v.CompetitorsList',CompetitorsListArray);
        } 
    },
    getModal : function(component, event, helper) {
        var makePos = event.target.className;
        var CompetitorsListArray = JSON.parse(JSON.stringify(component.get('v.CompetitorsList')));
        var make = CompetitorsListArray[0].allNewCompetitors[makePos].Competitor.Make__c;
        var action = component.get("c.getAllModel");
        action.setParams({ make :  make});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                CompetitorsListArray[0].allNewCompetitors[makePos].allModels =  response.getReturnValue();
                component.set('v.CompetitorsList', CompetitorsListArray);
            }
        });
      $A.enqueueAction(action); 
    
    },
    getModelForExisting : function(component, event, helper) {
        var makePos = event.target.className;
        var CompetitorsListArray = JSON.parse(JSON.stringify(component.get('v.CompetitorsList')));
        var make = CompetitorsListArray[0].allExistingCompetitors[makePos].Competitor.Make__c;
        var action = component.get("c.getAllModel");
        action.setParams({ make :  make});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                CompetitorsListArray[0].allExistingCompetitors[makePos].allModels =  response.getReturnValue();
                component.set('v.CompetitorsList', CompetitorsListArray);
            }
        });
      $A.enqueueAction(action); 
    
    },
    saveData : function(component, event, helper) {
        var str = window.location.href;
        var res = str.split("/");
        var insertAbleComp = [];
        var id = '';
        var leadId = component.get("v.leadId");
        if(leadId != '' && leadId != undefined )
        {
            id = leadId;

        }else{
            id = res[6];
        }
        var isBlank = true;
        var CompetitorsListArray = JSON.parse(JSON.stringify(component.get('v.CompetitorsList')))[0].allNewCompetitors;
        for(var i=0; i<CompetitorsListArray.length; i++){
        CompetitorsListArray[i].Competitor.Lead__c = id;
        insertAbleComp.push(CompetitorsListArray[i].Competitor);
            if((CompetitorsListArray[i].Competitor.Make__c == '' || CompetitorsListArray[i].Competitor.Make__c == undefined) || (CompetitorsListArray[i].Competitor.Model__c == '' || CompetitorsListArray[i].Competitor.Model__c == undefined)){
                isBlank = false; 
            }
        }
        if(isBlank){
            var action = component.get("c.SaveCompetitors");
            action.setParams({ competitorsList : insertAbleComp});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if( state === "SUCCESS"){
                    component.set('v.allModel', response.getReturnValue());
                    if(response.getReturnValue() == null){
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type : "Success",
                                title: "Success!",
                                message: "The record has been created successfully."
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
                    var leadId = component.get("v.leadId");
                    if(leadId == '' || leadId == undefined )
                    {
                        location.reload();
            
                    }
                   
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
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "Field Value is Blank Please Fill It !"
            });
            toastEvent.fire();
          }
         
       
         
      
    },
    
    closeModel : function(cmp) {
        var cmpEvent = cmp.getEvent("clsPopupEvent");
        cmpEvent.fire();
    },
    delExisSingleRow : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : "Error",
            title: "Error!",
            message: "Existing data cannot be deleted!"
        });
        toastEvent.fire();
    },
    existCompetitorsCompare : function(component, event, helper)  {
        var index = event.target.className;
      
        var newCompetitorsList = component.get('v.CompetitorsList');
        var allNewCom = newCompetitorsList[0].allNewCompetitors;
       var CompetitorsList = component.get('v.CompetitorsList');
        var existCompetitorsList = CompetitorsList[0].allExistingCompetitors;
       var duplicate = false;
       for(var i=0; i<existCompetitorsList.length; i++){
            if(existCompetitorsList[i].Competitor.Make__c == allNewCom[index].Competitor.Make__c && existCompetitorsList[i].Competitor.Model__c == allNewCom[index].Competitor.Model__c){
                duplicate = true;
            }
       }
       if(duplicate){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "Model or Make already Existing!"
            });
            toastEvent.fire();
            allNewCom[index].Competitor.Model__c = '';
       }
       component.set('v.CompetitorsList',newCompetitorsList);
    },
    updateInterast : function(component, event, helper)  {
        var index = event.target.className;
        var newCompetitorsList = component.get('v.CompetitorsList');
        var allNewCom = newCompetitorsList[0].allNewCompetitors;
       var CompetitorsList = component.get('v.CompetitorsList');
        var existCompetitorsList = CompetitorsList[0].allExistingCompetitors;
        var duplicate = false;
       for(var i=0; i<existCompetitorsList.length; i++){
            if((i!=index)&&(existCompetitorsList[i].Competitor.Make__c == existCompetitorsList[index].Competitor.Make__c && existCompetitorsList[i].Competitor.Model__c == existCompetitorsList[index].Competitor.Model__c)){
                duplicate = true;
            }
       }
       for(var i=0; i<allNewCom.length; i++){
            if(allNewCom[i].Competitor.Make__c == existCompetitorsList[index].Competitor.Make__c && allNewCom[i].Competitor.Model__c == existCompetitorsList[index].Competitor.Model__c){
                duplicate = true;
            }
        }
        if(!duplicate){
            var comp = existCompetitorsList[index].Competitor;
            console.log(comp);
            var action = component.get("c.dataUpdateForComp");
            action.setParams({ Competitors :comp});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if( state === "SUCCESS"){
                    component.set('v.allModel', response.getReturnValue());
                    if(response.getReturnValue() == null){
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type : "Success",
                                title: "Success!",
                                message: "The record has been created successfully."
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
                    location.reload();
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
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "Model or Make already Existing!"
            });
            toastEvent.fire();
            existCompetitorsList[index].Competitor.Model__c = '';
        }

    }
})