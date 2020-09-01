({
    doInit: function (cmp, event, helper) {
        var Existing_Vehicle__c = {
            'sobjectType': 'ACE_Existing_Vehicle__c',
            'Name': '',
            'ACE_Make__c': '',
            'ACE_Model__c': '',
            'ACE_Is_Exchange_Vehicle__c': false,
            'ACE_Lead__c': '',
            'ACE_KMs_Reading__c': '',
            'ACE_Vehicle_Usage__c': '',
            'ACE_Registration_Number__c': '',
            'ACE_Registered_Year__c': '',
            'ACE_Registered_Month__c': '',

        };
        var existing_Vehicle__cArray = cmp.get('v.existingVehicleList');
        existing_Vehicle__cArray.push(Existing_Vehicle__c);
        cmp.set('v.existingVehicleList', existing_Vehicle__cArray);

        var str = window.location.href
        var res = str.split("/");
        console.log(res[6]);

        var action = cmp.get("c.getLeadRecord");
        action.setParams({
            Id: res[6]
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {

                cmp.set('v.leadRecord', response.getReturnValue());

            }
            //helper.competitorList(component,event,helper);


        });

        $A.enqueueAction(action);

        var ExistingVehicle = cmp.get("c.getExistingVehicle");
        ExistingVehicle.setParams({
            Id: res[6]
        });

        ExistingVehicle.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var response = response.getReturnValue();
                var allRegistrationNumber = [];
                for (var i = 0; i < response.length; i++) {

                    if (response[i].ACE_Registration_Number__c != '' || response[i].ACE_Registration_Number__c != undefined) {
                        allRegistrationNumber.push(response[i].ACE_Registration_Number__c);
                    }

                }
                cmp.set('v.allRegistrationNumber', allRegistrationNumber);
                cmp.set('v.allExisting_Vehicle', response);

                cmp.set('v.startingIndex', response.length);

            }

        });

        $A.enqueueAction(ExistingVehicle);
        //  alert('heloo');
        //helper.competitorList(component,event,helper);
        // alert('hey');


        //start1
        var getAllCompetitorsList = cmp.get("c.getAllCompetitorsList");
        //alert('2');
        getAllCompetitorsList.setParams({
            LeadId: res[6]
        });
        getAllCompetitorsList.setCallback(this, function (response) {
            var state = response.getState();
            //alert(state);
            //alert(cmp.isValid());
            if (cmp.isValid() && state == "SUCCESS") {
                // alert('success2');
                var allDataOfCompetitors = response.getReturnValue();
                // alert(allDataOfCompetitors);
                //cmp.set('v.existingLength',allDataOfCompetitors.allExistingCompetitors.length);
                cmp.set('v.CompetitorsList', allDataOfCompetitors);
                //alert('=allDataOfCompetitors='+JSON.stringify(allDataOfCompetitors));
            }

        });

        $A.enqueueAction(getAllCompetitorsList);
        //end1

        //start2
        var getAllCompetitorsList = cmp.get("c.getAllCompetitorsList");
        getAllCompetitorsList.setParams({
            LeadId: res[6]
        });
        getAllCompetitorsList.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var CompetitorsList = {
                    'sobjectType': 'Competitors_Considered__c',
                    'Make__c': '',
                    'Model__c': '',
                    'Lead__c': '',
                    //  'disable':true
                };
                var allDataOfCompetitors = response.getReturnValue();
                allDataOfCompetitors.allNewCompetitors[0].allModels = [];
                allDataOfCompetitors.allNewCompetitors[0].Competitor = CompetitorsList;
                cmp.set('v.existingLength', allDataOfCompetitors.allExistingCompetitors.length);
                cmp.set('v.CompetitorsList', allDataOfCompetitors)
            }

        });

        $A.enqueueAction(getAllCompetitorsList);
        //End2
        //Map of make and model

        var makeModel = cmp.get("c.makeModelMap");

        makeModel.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*    
                alert(JSON.stringify(response.getReturnValue()));
                var makeModelRes = response.getReturnValue();
                var makeModelMap=[];
                for(var key in makeModelRes){
                    makeModelMap.push({value:makeModelRes[key], key:key});
                }
                alert('jhsdgjfhd');
                alert('=makeModelMap='+JSON.stringify(makeModelMap));
                                cmp.set("v.makeModelMap1",makeModelMap);
*/

                var res = response.getReturnValue();
                //alert(res);
                cmp.set("v.makeModelMap1", res);
                //alert('after');
            }

        });

        $A.enqueueAction(makeModel);


    },
    addRowData: function (component, event, helper) {
        var Existing_Vehicle__c = {
            'sobjectType': 'ACE_Existing_Vehicle__c',
            'Name': '',
            'ACE_Make__c': '',
            'ACE_Model__c': '',
            'ACE_Is_Exchange_Vehicle__c': false,
            'ACE_Lead__c': component.get('v.leadRecord').Id,
            'ACE_KMs_Reading__c': '',
            'ACE_Vehicle_Usage__c': '',
            'ACE_Registration_Number__c': '',
            'ACE_Registered_Year__c': '',
            'ACE_Registered_Month__c': '',

        };
        var existing_Vehicle__cArray = component.get('v.existingVehicleList');
        existing_Vehicle__cArray.push(Existing_Vehicle__c);
        component.set('v.existingVehicleList', existing_Vehicle__cArray);

    },
    delSingleRow: function (component, event, helper) {
        // var r = confirm("Are You Sure To Delete?");
        //if (r == true) {
        var id = event.target.id;
        // alert('=id='+id);
        //var k = component.find("p").get("v.value");
        //alert('jdfgjf');
        // alert('=k='+k);
        //}
        var existing_Vehicle__cArray = JSON.parse(JSON.stringify(component.get('v.existingVehicleList')));
        // alert('length'+existing_Vehicle__cArray.length);
        if (id > -1 && existing_Vehicle__cArray.length > 1) {
            existing_Vehicle__cArray.splice(id, 1);
            //   }
            console.log(existing_Vehicle__cArray);
            component.set('v.existingVehicleList', existing_Vehicle__cArray);
            //this.addRowData();
        }

        if (id == 0) {

            this.addRowData();

        }
        this.getModal();

    },
    delExRow: function (component, event, helper) {
        //var r = confirm("Are You Sure To Delete?");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Existing data cannot be deleted!",
            "type": "error"
        });
        toastEvent.fire();

    },
    enableDisable: function (component, event, helper) {
        var buttonName = event.getSource().get("v.id");
        var existing_Vehicle__cArray = JSON.parse(JSON.stringify(component.get('v.existingVehicleList')));
        existing_Vehicle__cArray[buttonName].ACE_Is_Exchange_Vehicle__c = existing_Vehicle__cArray[buttonName].ACE_Is_Exchange_Vehicle__c;
        component.set('v.existingVehicleList', existing_Vehicle__cArray);
    },
    saveData: function (cmp, event, helper) {
        var existing_Vehicle__cArray = cmp.get('v.existingVehicleList');
        var existingNumber = cmp.get('v.allRegistrationNumber');


        var isBlank = true;
        var leadId = cmp.get('v.leadRecord').Id;
        var duplicate = true;
        //alert('1'+leadId);
        for (var i = 0; i < existing_Vehicle__cArray.length; i++) {
            existing_Vehicle__cArray[i].ACE_Lead__c = leadId;
            if ((existing_Vehicle__cArray[i].ACE_Make__c == '' || existing_Vehicle__cArray[i].ACE_Make__c == undefined) ||
                (existing_Vehicle__cArray[i].ACE_Model__c == '' || existing_Vehicle__cArray[i].ACE_Model__c == undefined)) {
                isBlank = false;

            }
            if (existingNumber.indexOf(existing_Vehicle__cArray[i].ACE_Registration_Number__c) > -1) {
                duplicate = false;
            }
        }
        if (isBlank && duplicate) {
            // alert('2');
            var action = cmp.get("c.saveExistingRecord");
            action.setParams({
                allrecords: existing_Vehicle__cArray
            });
            //alert('3');
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "Success",
                        title: "Success!",
                        message: "The record has been  successfully Saved."
                    });
                    toastEvent.fire();
                    window.location.reload();

                } else {
                    response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "Error",
                        title: "Error!",
                        message: "The record not Saved."
                    });
                    toastEvent.fire();
                }

            });

            $A.enqueueAction(action);
        } else if (!isBlank) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",
                message: "Field Value is Blank Please Fill It !"
            });
            toastEvent.fire();
        } else if (!duplicate) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",
                message: "Duplicate Registration Number Not Allowed !"
            });
            toastEvent.fire();
        }

    },
    closeModel: function (cmp) {
        var cmpEvent = cmp.getEvent("clsPopupEvent");
        cmpEvent.fire();
    },
    getModal: function (component, event, helper) {
        var makePos = event.target.className;
        // alert(event.getSource().get("v.value"));
        //alert('makePos'+makePos);
        var CompetitorsListArray = JSON.parse(JSON.stringify(component.get('v.CompetitorsList')));
        //alert('=CompetitorsListArray='+JSON.stringify(CompetitorsListArray[0]));
        //var make = CompetitorsListArray[0].allNewCompetitors[makePos].Competitor.Make__c;
        var make = event.getSource().get("v.value");
        //component.set("v.curMake",make);
        //alert('=make='+make);
        var action = component.get("c.getAllModel");
        action.setParams({
            make: make
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Model success');
                //alert('=model res='+JSON.stringify(response.getReturnValue()));
                CompetitorsListArray[0].allNewCompetitors[makePos].allModels = response.getReturnValue();
                //component.set('v.modelList', response.getReturnValue());
                component.set('v.CompetitorsList', CompetitorsListArray);

            }

        });

        $A.enqueueAction(action);

    },
    validateRegistrationNumber: function (component, event, helper) {
        var validateRegistrationNumbe = event.getSource().get("v.value");
        var existingNumber = component.get('v.allRegistrationNumber');
        console.log(existingNumber.indexOf(validateRegistrationNumbe));
        if (existingNumber.indexOf(validateRegistrationNumbe) < 0) {
           
            console.log(validateRegistrationNumbe);
            console.log(existingNumber);
            component.set('v.allRegistrationNumber', existingNumber);
           
            var action = component.get('c.updateExistingRecord');
            $A.enqueueAction(action);
        } else {
            event.getSource().set('v.value','');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",
                message: "Duplicate Registration Number Not Allowed !"
            });
            toastEvent.fire();
            event.preventDefault();
        }

    },
    updateExistingRecord: function (component, event, helper) {
        var buttonName = event.getSource().get("v.id");
        var existingNumber = component.get('v.allRegistrationNumber');
        var existing_Vehicle__cArray = JSON.parse(JSON.stringify(component.get('v.allExisting_Vehicle')));
        var exdata = existing_Vehicle__cArray[buttonName];

        var preValue = component.get('v.currentSelected');
        if (existingNumber.indexOf(exdata.ACE_Registration_Number__c) < 0 ||
            preValue.ACE_Registration_Number__c != exdata.ACE_Registration_Number__c ||
            preValue.Make__c != exdata.Make__c ||
            preValue.Model__c != exdata.Model__c ||
            preValue.ACE_KMs_Reading__c != exdata.ACE_KMs_Reading__c ||
            preValue.ACE_Registered_Year__c != exdata.ACE_Registered_Year__c ||
            preValue.ACE_Registered_Month__c != exdata.ACE_Registered_Month__c ||
            preValue.ACE_Is_Exchange_Vehicle__c != exdata.ACE_Is_Exchange_Vehicle__c ||
            preValue.ACE_Vehicle_Usage__c != exdata.ACE_Vehicle_Usage__c ||
            preValue.ACE_KMs_Reading__c != exdata.ACE_KMs_Reading__c) {
            var action = component.get("c.dataUpdate");
            action.setParams({
                dataUpdate: exdata
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() == null) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: "success",
                            title: "success!",
                            message: " Record updated !"
                        });
                        toastEvent.fire();
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: "Error",
                            title: "Error!",
                            message: response.getReturnValue()
                        });
                        toastEvent.fire();
                    }
                }

            });

            $A.enqueueAction(action);
        } else if (!existingNumber.indexOf(exdata.ACE_Registration_Number__c) < 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",
                message: "Duplicate Registration Number Not Allowed !"
            });
            toastEvent.fire();
        }

    },
    trackChange: function (component, event, helper) {
        var buttonName = event.getSource().get("v.id");
        var existingNumber = component.get('v.allRegistrationNumber');
        var existing_Vehicle__cArray = JSON.parse(JSON.stringify(component.get('v.allExisting_Vehicle')));
        var exdata = existing_Vehicle__cArray[buttonName];

        component.set('v.currentSelected', exdata);
    }

})