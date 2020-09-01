({
    doInit: function (component, event, helper) {

        var getAlldata = component.get('c.getAllData');

        component.set('v.RecordPerPage', [{
                label: '5',
                fieldName: '5',
                type: 'number'
            },
            {
                label: '10',
                fieldName: '10',
                type: 'number'
            },
            {
                label: '25',
                fieldName: '25',
                type: 'number'
            },
            {
                label: '50',
                fieldName: '50',
                type: 'number'
            }
        ]);

        // searchData.setParams({name : userName, mobileNumber : mobileNumber});
        getAlldata.setCallback(this, function (response) {
            // hide spinner when response coming from server 
            var state = response.getState();

            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var allData = response.getReturnValue();
                component.set('v.callCenter', allData.callCenter);
                component.set('v.allUserRole', allData.allRole);
                component.set('v.team', allData.allTeams);
                component.set('v.allServiceList', allData.allServiceList);
            }
        });
        $A.enqueueAction(getAlldata);


        var searchBy = '';
        var searchOn = '';
        var status = '';
        var searchData = component.get('c.getSearchData');
        searchData.setParams({
            searchBy: searchBy,
            searchOn: searchOn
        });
        searchData.setCallback(this, function (response) {
            // hide spinner when response coming from server 
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set('v.dataLength', true);
                }

                component.set("v.AllRecord", storeResponse);
                for (var i = 0; i < storeResponse.length; i++) {
                    storeResponse[i].selected = false;
                }
                component.set('v.spinner', 'display:none;');
                component.set("v.data", storeResponse);

                component.set("v.allRecords", storeResponse);
                component.set("v.totalRecords", storeResponse.length);
                helper.showAndHidebtn(component, event, helper);
                helper.chagePageSize(component, event, helper);




            } else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error Message',
                    message: 'Response is Incompleted',

                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: errors[0].message,

                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error Message',
                        message: "Unknown error",

                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
            component.set('v.spinner', 'display:none;');
        });
        $A.enqueueAction(searchData);


    },
    searchUser: function (component, event, helper) {
        var searchBy = component.get('v.searchBy');
        var searchOn = component.get('v.searchOn');
        var status = component.get('v.searchStatus');

        if (searchBy != null && searchOn != null) {
            component.set('v.spinner', 'display:block');
            var searchData = component.get('c.getSearchData');
            searchData.setParams({
                searchBy: searchBy,
                searchOn: searchOn,
                status: status
            });
            searchData.setCallback(this, function (response) {
                // hide spinner when response coming from server 
                var state = response.getState();

                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse.length == 0) {
                        component.set('v.dataLength', true);
                    }
                    else{
                        component.set('v.dataLength', false);
                    }
                    for (var i = 0; i < storeResponse.length; i++) {
                        storeResponse[i].selected = false;
                    } 
                    component.set('v.spinner', 'display:none;');
                    component.set("v.data", storeResponse);

                    component.set("v.allRecords", storeResponse);
                    component.set("v.totalRecords", storeResponse.length);
                    helper.showAndHidebtn(component, event, helper);
                    helper.chagePageSize(component, event, helper);

                } else if (state === "INCOMPLETE") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error Message',
                        message: 'Response is Incompleted',

                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error Message',
                                message: errors[0].message,

                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: "Unknown error",

                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                component.set('v.spinner', 'display:none;');
            });
            $A.enqueueAction(searchData);

        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error Message',
                type: 'Error',
                message: "Please Enter " + searchOn + " In Search Field",
            });
            toastEvent.fire();
        }
    },
    updateData: function (component, event, helper) {

        var userRecord = event.target.className;
        var allUser = component.get("v.data");

        var selectedUser = [];
        var userServiceMap = [];
        for (var i = 0; i < allUser.length; i++) {
            if (allUser[i].selected == true) {
                console.log(allUser[i]);
                selectedUser.push(allUser[i].userData);
                var mapping = allUser[i].userService;
                mapping.Lookup_To_User__c = allUser[i].userData.Id;
                userServiceMap.push(mapping);
            }
        }

        if (selectedUser.length > 0) {
            component.set('v.spinner', 'display:block');

            var updateUserRecord = component.get("c.updateUserRecord");

            updateUserRecord.setParams({
                selectedUser: selectedUser,
                AllData: JSON.stringify(component.get("v.AllRecord")),
                serviceMAp12: userServiceMap,
            });
            updateUserRecord.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    if (response.getReturnValue() == null) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: 'Success',
                            title: "Success!",
                            message: "The record has been updated successfully."
                        });
                        toastEvent.fire();
                        location.reload();
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: 'error',
                            title: "Error!",
                            message: response.getReturnValue()
                        });
                        toastEvent.fire();
                    }

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error Message',
                                message: errors[0].message,

                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: "Unknown error",

                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                component.set('v.spinner', 'display:none;');
            });

            $A.enqueueAction(updateUserRecord);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                title: "Error!",
                message: 'Zero Row Selected'
            });
            toastEvent.fire();
        }



    },
    createUser: function (component, event, helper) {
        var newUser = component.get('v.newUser');
        newUser.CallCenterId = component.get('v.callCenter').Id;
        component.set('v.spinner', 'display:block;');
        var insertNewUser = component.get("c.insertNewUser");
        insertNewUser.setParams({
            userData: newUser,
            serviceId: component.get("v.ServiceId")
        });
        insertNewUser.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                if (response.getReturnValue() == null) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Success',
                        title: "Success!",
                        message: "The User has been Created successfully."
                    });
                    toastEvent.fire();
                    location.reload();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error Message',
                        message: response.getReturnValue(),

                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error Message',
                    message: 'Response is Incompleted',

                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: errors[0].message,

                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error Message',
                        message: "Unknown error",

                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
            component.set('v.spinner', 'display:none;');
        });

        $A.enqueueAction(insertNewUser);
    },
    onGroup: function (component, event, helper) {
        var selected = event.getSource().get("v.value");
        console.log("selected value is ", selected);
        if (selected == 'Dialer_User_ID__c ') {
            component.set('v.valueInPlaceHolder', 'Enter the Dealer Id');
        } else if (selected == 'Name') {
            component.set('v.valueInPlaceHolder', 'Enter the Agent Name');
        } else if (selected == 'Service__c') {
            component.set('v.valueInPlaceHolder', 'Enter the service code or name');
        } else if (selected == 'Team__c') {
            component.set('v.valueInPlaceHolder', 'Enter the Agent Team Name');
        }
        //component.set('v.searchOn',selected);

    },
    openUserCreate: function (component, event, helper) {
        component.set("v.isUserCreateOpen", true);
    },
    closeUserCreate: function (component, event, helper) {
        component.set("v.isUserCreateOpen", false);
    },
    openBulkUser: function (component, event, helper) {
        component.set("v.isBulkUserOpen", true);
    },
    closeBulkUser: function (component, event, helper) {
        component.set("v.isBulkUserOpen", false);
    },
    getChecked: function (component, event, helper) {
        console.log('Enter in getChecked method ');
        //var slct=document.getElementById("allSelect").checked;

        console.log('@@@@@@@', component.get('v.isAllSelected'));
        var id = event.currentTarget.id;
        var selected = component.find('allSelect').get('v.value');
        console.log('selected is', selected);
        var allUser = component.get("v.data");
        if (selected)
            component.set('v.isAllSelected', true);
        else
            component.set('v.isAllSelected', false);
        if (selected != false) {
            allUser.forEach(function (element) {
                element.selected = true;
            });
        } else {
            allUser.forEach(function (element1) {
                element1.selected = false;
            });
        }
        console.log('selected @@@ is', selected);
        component.set("v.data", allUser);
    },
    getCheckedRow: function (component, event, helper) {

        var index = event.target.id
        var allUser = component.get("v.data");
        allUser[index].selected = !allUser[index].selected;
        component.set("v.data", allUser);
        var allSelected = [];

        for (var i = 0; i < allUser.length; i++) {
            if (allUser[i].selected == true) {
                allSelected.push(allUser[i]);
            }
        }
        if (allSelected.length == allUser.length) {
            component.set('v.isAllSelected', true);
        } else {
            component.set('v.isAllSelected', false);
        }
    },
    createUserName: function (component, event, helper) {
        var user = component.get('v.newUser');
        if (user.FirstName != '' && user.LastName != '') {
            var userName = user.FirstName.replace(/\s/g, '') + '.' + user.LastName.replace(/\s/g, '') + '@' + component.get('v.callCenter').Name.toLowerCase() + '.com';
            component.set('v.userName', userName);
            user.Username = userName;
            component.set('v.newUser', user);
        }
    },
    ResetPassword: function (component, event, helper) {
        var allUser = component.get("v.data");
        var selectedUser = [];
        for (var i = 0; i < allUser.length; i++) {
            console.log(allUser[i].selected);
            if (allUser[i].selected == true) {
                selectedUser.push(allUser[i].userData);
            }
        }
        if (selectedUser.length > 0) {
            component.set('v.spinner', 'display:block');
            var resetPassword = component.get("c.resetPassword");
            resetPassword.setParams({
                selectedUser: selectedUser
            });
            resetPassword.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue() == null) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: 'Success',
                            title: "Success!",
                            message: "Password Reset successfully."
                        });
                        toastEvent.fire();
                        window.location.reload
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: 'error',
                            title: "Error!",
                            message: response.getReturnValue()
                        });
                        toastEvent.fire();
                    }

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Error Message',
                                message: errors[0].message,

                                duration: ' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: "Unknown error",

                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                }
                component.set('v.spinner', 'display:none;');
            });

            $A.enqueueAction(resetPassword);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                title: "Error!",
                message: 'Zero Row Selected'
            });
            toastEvent.fire();
        }

    },
    changeStatus: function (component, event, helper) {
        console.log(event.target.id);

        /*   var index = event.target.id
        var allUser = component.get("v.data"); 
        
        var userdata = allUser[index].userData;
        console.log('>>>>   '+event.target.value);
        userdata.IsActive = event.target.value;
        allUser[index].userData = userdata;
        
        component.set("v.data",allUser); */
        var allUser = component.get("v.data");
        var index = event.target.id;
        var selectedValue = event.target.value;
        var selectUser = [];
        for (var i = 0; i < allUser.length; i++) {
            if (allUser[i].selected === true) {
                selectUser.push(allUser[i]);
            }
        }
        console.log('agter selected record count', selectUser.length);
        var txt;
        if (selectUser.length > 0) {
            console.log('inside the length if  ', event.target.value);

            var r = confirm("Do you want to change status value of crrunt page selected record ?");
            if (r == true) {
                for (var i = 0; i < allUser.length; i++) {
                    // console.log('<<<>>>>   ',allUser[i]);
                    if (allUser[i].selected === true) {
                        //   console.log('allUser[i].userdata   ',allUser[i].userData);
                        if (selectedValue == 'true') {
                            allUser[i].userData.IsActive = true;
                        } else {
                            allUser[i].userData.IsActive = false;
                        }

                    }
                }
                component.set("v.data", allUser);
                console.log('dddddd  >>', component.get("v.data"));
            }
            console.log('selectedValue  >> ' + selectedValue);
        }

    },
    changeService: function (component, event, helper) {
        console.log('changeService called');
        var allUser = component.get("v.data");
        console.log('hhh   ', allUser.selected);
        var selectedValue = event.getSource().get("v.value");
        var selectUser = [];
        for (var i = 0; i < allUser.length; i++) {
            if (allUser[i].selected === true) {
                selectUser.push(allUser[i]);
            }
        }
        var txt;
        if (selectUser.length > 0) {
            var r = confirm("Do you want to change service value of crrunt page selected record as " + selectedValue + " ?");
            if (r == true) {
                for (var i = 0; i < allUser.length; i++) {
                    if (allUser[i].selected === true) {
                        allUser[i].userService.Lookup_To_Service__c = selectedValue;
                    }
                }
                component.set("v.data", allUser);
            }
            console.log('selectedValue  >> ' + selectedValue);
        }

    },
    firstPage: function (component, event, helper) {
        helper.first(component, event, helper);
    },
    previousPage: function (component, event, helper) {
        helper.previous(component, event, helper);
    },
    nextPage: function (component, event, helper) {
        helper.next(component, event, helper);
    },

    lastPage: function (component, event, helper) {
        helper.last(component, event, helper);
    },
    handlepgbtnclick: function (component, event, helper) {
        helper.shiftPgno(component, event, helper);
    },
    chagePageSizectrl: function (component, event, helper) {
        helper.chagePageSize(component, event, helper);
    },

})