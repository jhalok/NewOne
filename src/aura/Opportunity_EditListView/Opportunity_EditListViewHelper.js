({
    getopplistFunction : function(component,pageNumber,pageSize){
        var i;
        var oppList = [];
        var launch;
        if(component.get('v.launchType') == 'Launch'){
            launch = false;
        }
        else{
            launch = true;
        }
        var action = component.get("c.oppDataRtrv");
        console.log('inside oppDataRtrv-------');
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "modelType": component.get('v.modelType'),
            "launch" : launch
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
                var resultData = result.getReturnValue();
                console.log('inside oppDataRtrv-------'+JSON.stringify(resultData));
                component.set("v.TotalRecords", resultData.opportunities.length);
                 var start = ((pageNumber - 1) * pageSize) ;
               if((pageNumber * pageSize) > component.get('v.TotalRecords'))
                	var end = component.get('v.TotalRecords');
                else
                    var end = pageNumber * pageSize;
                    
                component.set('v.RecordStart',start);
                component.set('v.RecordEnd',end );
                component.set('v.TotalPages',Math.ceil(component.get('v.TotalRecords')/component.get('v.pageSize')));
                for( i = start; i< end ; i++ ){
                    if(resultData.opportunities[i] !== 'undefined' && resultData.opportunities[i] !== ''){
                       oppList.push(resultData.opportunities[i]); 
                    }
                       
                    else{
                        break;
                    }
                        
                }
                component.set("v.oppList",oppList);
               
                
            }
            else{
                console.log('Error : '+JSON.stringify(result.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    getleadlistFunction : function(component,pageNumber,pageSize){
        var i;
        var leadList = [];
        var launch;
        if(component.get('v.launchType') == 'Launch'){
            launch = false;
        }
        else{
            launch = true;
        }
         console.log('inside leadDataRtrv-------');
        var action = component.get("c.leadDataRtrv");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "modelType": component.get('v.modelType'),
            "launch" : launch
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                console.log('inside leadDataRtrv-------'+JSON.stringify(resultData));
                component.set("v.TotalRecords", resultData.Leads.length);
                 var start = ((pageNumber - 1) * pageSize);
                if((pageNumber * pageSize) > component.get('v.TotalRecords'))
                	var end = component.get('v.TotalRecords');
                else
                    var end = pageNumber * pageSize; 
                component.set('v.RecordStart',start);
                component.set('v.RecordEnd',end);
                component.set('v.TotalPages',Math.ceil(component.get('v.TotalRecords')/component.get('v.pageSize')));
                for( i = start; i< end  ; i++ ){
                    if(resultData.Leads[i] !== 'undefined' && resultData.Leads[i] !== ''){
                       leadList.push(resultData.Leads[i]); 
                    }
                    else{
                        break;
                    }     
                }
                component.set("v.oppList",leadList);
                component.set('v.RecordEnd',i );
            }
        });
        $A.enqueueAction(action);
    },
})