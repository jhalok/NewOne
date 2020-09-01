({
    previous: function (component, event, helper) {
        let oppCmp = component.find("oppCmp");
        let handleSubmit = oppCmp.handleSave();
        console.log("handleSubmit ",JSON.stringify(handleSubmit));
        let flagError = handleSubmit.flagError;
        let leadVals  = handleSubmit.leadFields;
        let curStep = component.get("v.curStep");
        if (curStep > 1) {
            curStep--;
        }
        console.log('leadValus ############ ',leadVals,'curStep ',curStep);
        component.set("v.curStep", curStep.toString());
        component.set("v.showLead", true);
        
        component.set("v.leadFields", leadVals);
        

    },
    addProducts: function (component, event, helper) {
        component.set("v.showProds", true);
    },
    save: function (component, event, helper) {
        let productInterests = component.get("v.productInterests");
        console.log('productInterests are ', productInterests);
        let curStep = component.get("v.curStep");
        // curStep =1 insert lead
        helper.handleSubmitHelper(component, event, helper);
        
    },
    next: function (component, event, helper) {
        console.log('Enter in next method -- ');
        component.set("v.showSpinner", true);
        let leadCmp = component.find("leadCmp");
        let handleSubmit = leadCmp.handleSave();
        console.log("handleSubmit ",JSON.stringify(handleSubmit));
        let flagError = handleSubmit.flagError;
        let leadVals  = handleSubmit.leadFields;
        console.log('leadValus ############ ',leadVals);
        component.set("v.leadFields", leadVals);
        if (!flagError) {
            let curStep = component.get("v.curStep");
            if (curStep < 3) {
                curStep++;
            }
            component.set("v.curStep", curStep.toString());
            component.set("v.showLead", false);
        }
        
        component.set("v.showSpinner", "false");

    },
    closeModel: function (component, event, helper) {
        component.set("v.showSpinner", true);
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.showProds", false);
        component.set("v.showSpinner", false);
        $A.get("e.force:closeQuickAction").fire();
    },

})