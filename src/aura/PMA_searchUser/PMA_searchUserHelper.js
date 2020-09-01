({
    searchHelper : function(component,event,getInputkeyWord) {
        var storeResponse = [];
        var action = component.get("c.searchForIds");       
        action.setParams({
            'searchText': getInputkeyWord, 
            'objectType': component.get('v.objectType')
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                for(var i = 0 ; i < response.getReturnValue().length ; i++){
                    if(response.getReturnValue()[i].lstUser.FirstName = response.getReturnValue()[i].lstUser.FirstName == null || response.getReturnValue()[i].lstUser.FirstName == 'undefined' ? '' : response.getReturnValue()[i].lstUser.FirstName){
                        storeResponse.push({'name':response.getReturnValue()[i].lstUser.FirstName+' '+response.getReturnValue()[i].lstUser.LastName, 'count':response.getReturnValue()[i].opportunityCount, 'rating':response.getReturnValue()[i].rating});   
                    }else if(response.getReturnValue()[i].lstUser.LastName = response.getReturnValue()[i].lstUser.LastName == null || response.getReturnValue()[i].lstUser.LastName == 'undefined' ? '' : response.getReturnValue()[i].lstUser.LastName){
                        storeResponse.push({'name':response.getReturnValue()[i].lstUser.LastName, 'count':response.getReturnValue()[i].opportunityCount, 'rating':response.getReturnValue()[i].rating});   
                    }
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
})