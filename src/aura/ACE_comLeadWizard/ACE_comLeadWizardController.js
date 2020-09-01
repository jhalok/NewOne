({
    doInit: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var leadFields = component.get("v.leadFields");
        if (leadFields == null ||leadFields==undefined) {
            let action = component.get("c.getFieldsOnLayout");
            action.setParams({
                "layoutName": "Lead-Community QE layout"
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state == "SUCCESS") {
                    let fields = response.getReturnValue();
                    //component.set("v.fields", fields);
                    console.log('fields in doInit @@@@@@@@ ', fields);
                    let arrayMapKeys = [];
                    for (var key in fields) {
                        console.log('ffff ', key);
                        if (key == 'Personal Details') {
                            arrayMapKeys.push({
                                key: key,
                                value: fields[key]
                            });
                        }

                    }
                    var leadFields = component.get("v.leadFields");

                    component.set("v.fields", arrayMapKeys);


                }

            });
            $A.enqueueAction(action);
        }

    },
    handleLoad: function (component, event, helper) {
        component.set("v.showSpinner", false);
    },
    handleSave: function (component, event, helper) {
        console.log("inside handleSubmit", component.get("v.fields"));
        let leadForm = component.find("leadFields");
        console.log('leadForm is ', leadForm);
        let leadFields = component.get("v.leadFields");
        var mapValue = component.get("v.fields");
        let valueObj = {};
        var value;
        let flagError = false;
        Object.keys(mapValue).forEach(function (key) {
            value = mapValue[key];
            for (var i = 0; i < Object.keys(value.value).length; i++) {
                valueObj[value.value[i].fieldName] = value.value[i].val;
                if (value.value[i].required == true && ((leadForm[i].get("v.value")) == "")) {
                    flagError = true;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Please fill the required field " + value.value[i].fieldName
                    });
                    toastEvent.fire();
                    break;
                }
            }

        });
        
        let returnLeadFields = {};
        if(leadFields == undefined ){
            returnLeadFields = valueObj;
        }
        else{
            returnLeadFields = Object.assign(leadFields, valueObj);
        }
        let returnObj = {"flagError":flagError,"leadFields":returnLeadFields};
        return returnObj;
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        let leads = event.getParam("fields");
        console.log("fields in submit are " + leads);
    },
    handleSuccess: function (component, event, helper) {

    }
})