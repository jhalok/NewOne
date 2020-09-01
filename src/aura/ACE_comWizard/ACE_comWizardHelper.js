({
    handleSubmitHelper : function(component, event, helper) {
        let productInterests = component.get("v.productInterests");
        console.log('productInterests1 are ', productInterests);
        let curStep = component.get("v.curStep");
        let childCmp;
        let handleSubmit;
        if(curStep==1){
           childCmp = component.find("leadCmp");
           
        }
        else if(curStep==2){
            childCmp = component.find("oppCmp");
        }
        handleSubmit = childCmp.handleSave();
        let flagError = handleSubmit.flagError;
        let leadVals  = handleSubmit.leadFields;
        if (!flagError){
            let curStep = component.get("v.curStep");
            console.log("leadFields ", JSON.stringify(leadVals));
            let insertLead = JSON.stringify(leadVals);
            let action = component.get("c.insertLead");
            console.log('@@@@@@@@@@ productInterests in helper ',productInterests);
            if (curStep == 1) {
                action.setParams({
                    "newLead": insertLead,
                    'insertOpp': false,
                    "lstProdInterest" :productInterests
                });
            }
            else {
              console.log("kkkkk ",leadVals);
                action.setParams({
                    "newLead": insertLead,
                    'insertOpp': true,
                    "lstProdInterest" :productInterests
                });
            }

            $A.enqueueAction(action);
        }
    }
})