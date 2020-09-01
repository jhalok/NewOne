({
    doinit: function (component, event, helper) {
        var modelData =[];
        var action = component.get("c.getEnquiryFilters");
        action.setParams({
            launchType: component.get("v.launchType")
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                for( var i = 0; i< resultData.ProductName.length; i++){
                    if(resultData.ProductName[i] !== 'None'){
                        modelData.push(resultData.ProductName[i]);
                    }
                }
                component.set("v.modelData", modelData);
               /* var childRef = component.find('childComp1');
                childRef.handleClick();
                var childRefUnAssigned = component.find('childComp2');
                childRefUnAssigned.handleClick();*/
            }
            else{
                console.log('Error'+result.getError());
            }
        });
        $A.enqueueAction(action);
    },
    tabSelected: function (component, event, helper) {
        
    },
    handleClickLaunchType: function (component, event, helper) {
        var action = component.get("c.getEnquiryFilters");
        action.setParams({
            launchType: component.get("v.launchType")
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                component.set("v.modelData", resultData.ProductName);
            }
           /* var childRef = component.find('childComp1');
            childRef.handleClick();*/
            var childRefUnAssigned = component.find('childComp2');
            childRefUnAssigned.handleClick();
        });
        $A.enqueueAction(action);
    },
    onChange: function (component, event, helper) {
        component.set("v.modelType", component.find('select').get('v.value'));
        /*var childRef = component.find('childComp1');
        childRef.handleClick();*/
        var childRefUnAssigned = component.find('childComp2');
        childRefUnAssigned.handleClick();
    },
    handleClick: function (component, event, helper) {
       /* var childRef = component.find('childComp1');
        childRef.handleClick();*/
        var childRefUnAssigned = component.find('childComp2');
        childRefUnAssigned.handleClick();
    }
})