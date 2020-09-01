({
    doInit: function (component, event, helper) {
        //component.set("v.showSpinner", true);
        let fields     = component.get("v.fields");
        let leadFields = component.get("v.leadFields");
        console.log('########### leadFields ', JSON.stringify(leadFields));
        if (fields == null || fields == undefined) {

            let action = component.get("c.getFieldsOnLayout");
            action.setParams({
                "layoutName": "Lead-Community Enq Layout"
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state == "SUCCESS") {
                    let fields = response.getReturnValue();
                    component.set("v.fields", fields);
                    console.log('Fields are --- ', fields);
                    let arrayMapKeys = [];
                    for (var key in fields) {
                        console.log('ffff ', fields[key], key);
                        if (key == 'Additional Details') {
                            arrayMapKeys.push({
                                key: key,
                                value: fields[key]
                            });
                        }

                    }
                    component.set("v.fields", arrayMapKeys);
                    console.log("map is ", arrayMapKeys);
                }
            });
            $A.enqueueAction(action);
        }
    },

    handleLoad: function (component, event, helper) {
        component.set("v.showSpinner", false);
    },
    handleSubmit: function (component, event, helper) {
        console.log("inside handleSubmit");


    },
    handleSuccess: function (component, event, helper) {

    },
    handleSave: function (component, event, helper) {
        console.log("inside handleSubmit ",JSON.stringify(component.get("v.leadFields")));
        let leadFields = component.get("v.leadFields");
        var mapValue = component.get("v.fields");
        let valueObj = {};
        var value;
        let flagError = true;
        Object.keys(mapValue).forEach(function (key) {
            value = mapValue[key];
            for (var i = 0; i < Object.keys(value.value).length; i++) {
                valueObj[value.value[i].fieldName] = value.value[i].val;

                if (value.value[i].val != '') {
                    flagError = false;
                }
            }
        });

        let returnObj = {
            "flagError": flagError,
            "leadFields": Object.assign(leadFields, valueObj)
        };
        console.log('returnObj is ####### ', returnObj);
        return returnObj;
    }
})