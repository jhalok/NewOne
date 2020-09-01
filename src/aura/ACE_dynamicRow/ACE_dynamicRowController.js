({
    doInit: function (cmp, event, helper) {
        var str = window.location.href
        var res = str.split("/");
        console.log(res[6]);
        var action = cmp.get("c.getContactRecord");
        action.setParams({
            Id: res[6]
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set('v.contactRecord', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

        var getExistingRecords = cmp.get("c.getExistingRecords");
        getExistingRecords.setParams({
            Id: res[6]
        });
        getExistingRecords.setCallback(this, function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var exData = response.getReturnValue();
                for (var i = 0; i < exData.length; i++) {
                    exData[i].isOthIntOpen = false;
                }
                
                 cmp.set('v.exLeadsLength', exData.length);
                cmp.set('v.exLeads', exData);
            }
        });
        $A.enqueueAction(getExistingRecords);

        var LeadList = {
            'sobjectType': 'Lead',
            'LastName': '',
            'MobilePhone': '',
            'Company': 'testing',
            'Status': 'Open - Not Contacted',
            'Contact_Time__c': '',
            'Referred_By__c': '',
            'disable': false,
            'isOthIntOpen': false,
           
        };
        var LeadListArray = [];
        LeadListArray.push(LeadList);
        cmp.set('v.LeadList', LeadListArray);
    },

    addRowData: function (component, event, helper) {
        var LeadList = {
            'sobjectType': 'Lead',
            'LastName': '',
            'MobilePhone': '',
            'Company': 'testing',
            'Status': 'Open - Not Contacted',
            'Contact_Time__c': '',
            'Referred_By__c': '',
            'disable': false,
            'isOthIntOpen': false,
           
        };
        var LeadListArray = component.get('v.LeadList');
        LeadListArray.push(LeadList);
        component.set('v.LeadList', LeadListArray);
    },

    delSingleRow: function (component, event, helper) {
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.LeadList')));
        var index = event.target.id;
        var rowData = leadListArr[index];
        console.log('curr row', leadListArr[index]);
        var toBeDeleted = false;
        if (rowData.LastName != "" ||
            rowData.MobilePhone != "" ||
            rowData.Contact_Time__c != "" ||
            rowData.Referred_By__c != "") {
            toBeDeleted = confirm("Are you sure to delete ???");
        } else {
            toBeDeleted = true
        }
        if (toBeDeleted) {
            //var id = event.target.id; 
            //var LeadListArray = JSON.parse(JSON.stringify(component.get('v.LeadList')));
            leadListArr.splice(index, 1);
            if(leadListArr.length == 0){
                var LeadList = {
                    'sobjectType': 'Lead',
                    'LastName': '',
                    'MobilePhone': '',
                    'Company': 'testing',
                    'Status': 'Open - Not Contacted',
                    'Contact_Time__c': '',
                    'Referred_By__c': '',
                    'disable': false,
               'isOthIntOpen': false
                };
                leadListArr.push(LeadList);
            } 
        }
        component.set('v.LeadList', leadListArr);
    },

    addInterest: function (component, event, helper) {
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.exLeads')));
        var index = event.target.id;

        leadListArr[index].isOthIntOpen = true;
        component.set('v.exLeads', leadListArr);
    },
    addInterestinNew:function (component, event, helper) {
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.LeadList')));
        var index = event.target.id;
        leadListArr[index].isOthIntOpen = true;
        
        component.set('v.newLeadIndex', index);
        component.set('v.LeadList', leadListArr);
    },
    closeOthInt: function (component, event, helper) {
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.exLeads')));
        var index = event.getSource().get("v.value");

        leadListArr[index].isOthIntOpen = false;

        component.set('v.exLeads', leadListArr);
    },
    closeOthIntnew:function (component, event, helper) {
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.LeadList')));
        var index = event.getSource().get("v.value");

        leadListArr[index].isOthIntOpen = false;

        component.set('v.LeadList', leadListArr);
    },
    updateLeadData: function (component, event, helper) {
        var index = event.target.className;
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.exLeads')));
        var preValue = component.get('v.currentSelected');
        if(preValue.LastName != leadListArr[index].LastName || preValue.MobilePhone != leadListArr[index].MobilePhone ||
            preValue.Email != leadListArr[index].Email || preValue.City__c !=  leadListArr[index].City__c ||
            preValue.Next_FollowUp__c != leadListArr[index].Next_FollowUp__c){
                var action = component.get("c.updateLeads");
                action.setParams({
                    LeadData: leadListArr[index]
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {

                        if (response.getReturnValue() == null) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: 'Success',
                                title: "Success!",
                                message: "The record has been  successfully Updated."
                            });
                            toastEvent.fire();
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type: 'Error',
                                title: "Error!",
                                message: response.getReturnValue()
                            });
                            toastEvent.fire();
                        }
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: 'Error',
                            title: "Error!",
                            message: "The record not saved  successfully."
                        });
                        toastEvent.fire();
                    }

                });

                $A.enqueueAction(action);
        }
        

    },
    saveData: function (cmp, event, helper) {
        var LeadListArray = cmp.get('v.LeadList');
        var AllData = [];
        var isBlank = false;
        for (var i = 0; i < LeadListArray.length; i++) {
            LeadListArray[i].Referred_By__c = cmp.get('v.contactRecord').Id;
            if ((LeadListArray[i].LastName == '' || LeadListArray[i].LastName == undefined) ||(LeadListArray[i].MobilePhone == '' || LeadListArray[i].MobilePhone == undefined)) {
                isBlank = true;
            }
            else{
                var interest = LeadListArray[i].interLest;
                delete LeadListArray[i].interLest;
              var  newInst = {'newLead':LeadListArray[i],'allInterest': interest };
              AllData.push(newInst);
            }
        }
        if (!isBlank) {
            var action = cmp.get("c.saveLeads");
            //delete AllData.newLead.sobjectType;
            console.log(AllData);
            action.setParams({
                ListLead: JSON.stringify(AllData)
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {


                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Success',
                        title: "Success!",
                        message: "The record has been  successfully Saved."
                    });
                    toastEvent.fire();

                    window.location.reload();

                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Error',
                        title: "Error!",
                        message: "The record not saved  successfully."
                    });
                    toastEvent.fire();
                }

            });

            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'Error',
                title: "Error!",
                message: "Blank Row not Allowed For insert."
            });
            toastEvent.fire();
        }

    },
    getInterestList: function (component, event, helper) {
        var InterestList = event.getParam("interestList"); 
       var newLeadIndex = component.get('v.newLeadIndex');
       var allNewLeads =   component.get('v.LeadList');
       allNewLeads[newLeadIndex].interLest = InterestList;
       console.log(allNewLeads);
       component.set('v.LeadList', allNewLeads);
        //Set the handler attributes based on event data 
       // cmp.set("v.eventMessage", message + 'Biswajeet');
    },
    trackChange:function (component, event, helper) {
        var index = event.target.className;
        var leadListArr = JSON.parse(JSON.stringify(component.get('v.exLeads')));
        component.set('v.currentSelected', leadListArr[index]);
    }
})