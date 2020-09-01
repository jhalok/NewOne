({
    getAllOpp : function (component, event, helper) {
        var action = component.get("c.unAssignedOppData");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.AllEnquiries',resultData);
            }
            else {
                console.log('Error : '+JSON.stringify(result.getError()));
            }
            var pageSize = component.get('v.pageSize');
            var pageNumber = component.get('v.PageNumber');
            this.getopplistFunction(component, pageNumber, pageSize);
        });
        $A.enqueueAction(action);
    },
    
    getopplistFunction : function(component,pageNumber,pageSize){
        console.log('getopplistFunction');
        var i;
        var oppList = [];
        var modelData = [];
        modelData = component.get('v.modelData');
        var prelaunch;
        var tempList = [];
        var resultData = [];
        if(component.get('v.launchType') == 'Launch'){
            prelaunch = false;
        }
        else{
            prelaunch = true;
        }
        resultData = component.get('v.AllEnquiries');
        console.log('resultData : '+JSON.stringify(resultData));
        for( var i = 0; i< resultData.length; i++){
            if(component.get('v.modelType') !== 'None' && component.get('v.modelType') !== 'All' && component.get('v.modelType') !== 'undefined'){
                console.log('In if');
                if(resultData[i].OpportunityLineItems[0].Product2 !== undefined){
                    if(resultData[i].OpportunityLineItems[0].Product2.Vehicle_Model__c === component.get('v.modelType') && resultData[i].OpportunityLineItems[0].Product2.Is_Prelaunch__c === prelaunch){
                        tempList.push(resultData[i]);
                    }
                }
            }
            else {
                console.log('in else')
                if(resultData[i].OpportunityLineItems[0].Product2 !== undefined){
                    if(modelData.includes(resultData[i].OpportunityLineItems[0].Product2.Vehicle_Model__c) && resultData[i].OpportunityLineItems[0].Product2.Is_Prelaunch__c === prelaunch)
                        tempList.push(resultData[i]);
                }
            }
        }
        console.log('TempList : '+JSON.stringify(tempList));
        if(tempList.length > 0){
            if(pageNumber === 0){
                pageNumber = 1;
            }
            
            component.set("v.TotalRecords", tempList.length);
            var start = ((pageNumber - 1) * pageSize);
            if((pageNumber * pageSize) > component.get('v.TotalRecords'))
                var end = component.get('v.TotalRecords');
            else
                var end = pageNumber * pageSize; 
            component.set('v.RecordStart',start + 1);
            component.set('v.RecordEnd',end);
            component.set('v.TotalPages',Math.ceil(component.get('v.TotalRecords')/component.get('v.pageSize')));
            for( i = start; i< end ; i++ ){
                if(tempList[i] !== 'undefined' && tempList[i] !== ''){
                    oppList.push(tempList[i]); 
                }
                else{
                    break;
                }     
            }
            console.log('oppList: '+oppList);
            component.set("v.oppList",oppList); 
        }
        else {
            component.set('v.pageNumber','0');
            component.set('v.RecordStart','0');
            component.set('v.RecordEnd','0');
            component.set('v.TotalPages','0');
            component.set('v.TotalRecords','0');
            component.set("v.oppList",oppList);
        }
        
        
    },
    getAllLead : function (component, event, helper) {
        var action = component.get("c.unAssignedLeadData");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.AllLeads',result.getReturnValue());
                console.log('All Leads : '+JSON.stringify(result.getReturnValue()));
            }
            var pageSize = component.get('v.pageSize');
            var pageNumber = component.get('v.PageNumber');
            this.getleadlistFunction(component, pageNumber, pageSize);
        });
        $A.enqueueAction(action);
    },
    getleadlistFunction : function(component,pageNumber,pageSize){
        console.log('in lead list method');
        var i;
        var leadList = [];
        var modelData = [];
        modelData = component.get('v.modelData');
        var prelaunch;
        var tempList = [];
        var resultData = [];
        if(component.get('v.launchType') == 'Launch'){
            prelaunch = false;
        }
        else{
            prelaunch = true;
        }
        resultData = component.get('v.AllLeads');
        console.log('in lead list method'+JSON.stringify(resultData));
        for( var i = 0; i< resultData.length; i++){
            if(component.get('v.modelType') !== 'None' && component.get('v.modelType') !== 'All' && component.get('v.modelType') !== 'undefined'){
                console.log('in if');
                if(resultData[i].Product_Interests__r[0].Product__r !== undefined){
                    if(resultData[i].Product_Interests__r[0].Product__r.Vehicle_Model__c === component.get('v.modelType') && resultData[i].Product_Interests__r[0].Product__r.Is_Prelaunch__c === prelaunch){
                        tempList.push(resultData[i]);
                        
                    }
                }
            }
            else {
                console.log('in else');
                if(resultData[i].Product_Interests__r[0].Product__r !== undefined){
                    if(modelData.includes(resultData[i].Product_Interests__r[0].Product__r.Vehicle_Model__c) && resultData[i].Product_Interests__r[0].Product__r.Is_Prelaunch__c === prelaunch){
                        tempList.push(resultData[i]);
                    }
                }
            }
        }
        console.log('in lead list method tempList'+JSON.stringify(tempList));
        if(tempList.length > 0){
            component.set("v.TotalRecords", tempList.length);
            var start = ((pageNumber - 1) * pageSize);
            if((pageNumber * pageSize) > component.get('v.TotalRecords'))
                var end = component.get('v.TotalRecords');
            else
                var end = pageNumber * pageSize; 
            component.set('v.RecordStart',start + 1);
            component.set('v.RecordEnd',end);
            component.set('v.TotalPages',Math.ceil(component.get('v.TotalRecords')/component.get('v.pageSize')));
            for( i = start; i< end ; i++ ){
                if(tempList[i] !== 'undefined' && tempList[i] !== ''){
                    leadList.push(tempList[i]); 
                }
                else{
                    break;
                }     
            }
        }
        else{
            component.set('v.RecordStart',0);
            component.set('v.RecordEnd',0);
            component.set('v.TotalPages',0);
            component.set('v.TotalRecords',0);
            component.set('v.PageNumber',0);
            component.set("v.oppList",leadList);
        }
        
        component.set("v.oppList",leadList);
    },
})