({
	getUsers: function(component, event) {
        
        var addDealer = [];
        addDealer.push({'dealer':'dsfjskfjnk'});
        component.set("v.listSearchDeaer",addDealer);
        var action = component.get("c.getUsers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var userMap = [];
                for(var key in result){
                    userMap.push({key: key, value: result[key]});
                }
                component.set("v.userMap", userMap);
            }
        });
        $A.enqueueAction(action);
    },
    getOpportunities: function(component, event) {
        //alert('fjd');
        var action = component.get("c.getAccountList");
        //alert('heloo');
        let accountName = component.get("v.acName");
        //alert('=='+accountName);
        action.setParams({
            accountName:accountName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('res'+JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                component.set("v.accountList",result);
                //alert('testing');
            }
        });
        $A.enqueueAction(action);
    },
    
    updateAccount:function(component,event,helper){
        //alert('sdhgfjsdhgj');
        let accountRecordId = event.getSource().get("v.value");
        let useID = component.find("userPicklist").get("v.value");                                               
       // alert(accountRecordId);
        //alert(useID);
        
        var action = component.get("c.assignUser");
        action.setParams({
            accountRecordId:accountRecordId,
            useID:useID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               //alert(result);
                component.refresh();
            }
        });
        $A.enqueueAction(action);
    },
    addSearch: function(component,event,helper){
       var addDealer =   component.get("v.listSearchDeaer");
        addDealer.push({'dealer':'dsfjskfjnk'});
        component.set("v.listSearchDeaer",addDealer); 
    }
   
    
})