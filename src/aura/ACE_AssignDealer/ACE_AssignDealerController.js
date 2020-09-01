({
    doInit: function (component, event, helper) {
        var str = window.location.href
        var res = str.split("/");
        var leadRecord;
        var getLead = component.get("c.getLeadRecord");
        getLead.setParams({
            Id: res[6]
        });
        var self = this;
        getLead.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                leadRecord = response.getReturnValue();
                console.log(leadRecord);
                component.set("v.leadRecord", leadRecord);
                var action = component.get("c.getModel");
                action.setParams({
                    Id: res[6]
                });
                var self = this;
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {

                        var allModel = response.getReturnValue();
                        console.log(allModel);
                        for (var i = 0; i < allModel.length; i++) {
                            var Interested = [];

                            if (allModel[i].interestedModel.Interest_Category__c == 'Primary_Interest' || allModel[i].interestedModel.Interest_Category__c == '') {
                                Interested.push({
                                    'data': true
                                }, {
                                    'data': false
                                }, {
                                    'data': false
                                });
                            } else if (allModel[i].interestedModel.Interest_Category__c == 'Other_Interest') {
                                Interested.push({
                                    'data': false
                                }, {
                                    'data': true
                                }, {
                                    'data': false
                                });
                            } else if (allModel[i].interestedModel.Interest_Category__c == 'Not_Interested') {
                                Interested.push({
                                    'data': false
                                }, {
                                    'data': false
                                }, {
                                    'data': true
                                });
                            } else {
                                Interested.push({
                                    'data': false
                                }, {
                                    'data': true
                                }, {
                                    'data': false
                                });
                            }



                            allModel[i].Interested = Interested;

                            allModel[i].distance = 0;
                        }

                        component.set('v.Product_Interest', allModel);

                    }

                });

                $A.enqueueAction(action);
                console.log(leadRecord.City);
                var getDealer = component.get("c.getDealer");
                getDealer.setParams({
                    City: leadRecord.City
                });
                var self = this;
                getDealer.setCallback(this, function (response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {

                        var allDealer = response.getReturnValue();
                        for (var i = 0; i < allDealer.length; i++) {
                            allDealer[i].selectDeler = false;

                            allDealer[i].distance = 0;
                        }
                        component.set('v.allDealer', allDealer);
                    }

                });

                $A.enqueueAction(getDealer);
            }
        });
        $A.enqueueAction(getLead);

    },

    saveData: function (component, event, helper) {

        var Product_Interest = JSON.parse(JSON.stringify(component.get('v.Product_Interest')));
        var allInterestedProduct = [];
        var InterestMoreOne = 0;
        for (var i = 0; i < Product_Interest.length; i++) {
            console.log(Product_Interest[i].Interested);
            for (var j = 0; j < Product_Interest[i].Interested.length; j++) {

                if (Product_Interest[i].Interested[j].data == true && j == 0) {
                    Product_Interest[i].interestedModel.Interest_Category__c = 'Primary_Interest';
                    InterestMoreOne = InterestMoreOne + 1;
                } else if (Product_Interest[i].Interested[j].data == true && j == 1) {
                    Product_Interest[i].interestedModel.Interest_Category__c = 'Other_Interest';

                } else if (Product_Interest[i].Interested[j].data == true && j == 2) {
                    Product_Interest[i].interestedModel.Interest_Category__c = 'Not_Interested';

                }
                Product_Interest[i].Quantity__c = 1;
            }

            allInterestedProduct.push(Product_Interest[i].interestedModel);
        }
        if (InterestMoreOne > 1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Error",
                title: "Error!",

                message: "More then One Interested Model Selected Primary ."
            });
            toastEvent.fire();

        } else {
            var saveProduct_Interest = component.get("c.updateProduct_Interest");
            saveProduct_Interest.setParams({
                Product_Interest: allInterestedProduct
            });
            var self = this;
            saveProduct_Interest.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "Success",
                        title: "Success!",
                        message: "The record has been  successfully Updated."
                    });
                    toastEvent.fire();
                    location.reload();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "Error",
                        title: "Error!",
                        message: "The record has been not  successfully Updated."
                    });
                    toastEvent.fire();
                }
               
            });

            $A.enqueueAction(saveProduct_Interest);
        }

    },
    enableDisable: function (component, event, helper) {
        var buttonName = event.getSource().get("v.id");
        var Allaccounts = component.get('v.accounts');
        Allaccounts[buttonName].selectDeler = !Allaccounts[buttonName].selectDeler
        component.set('v.accounts', Allaccounts);
    },

    checkboxSelect: function (component, event, helper) {
        var thisID = event.target.getAttribute('value');
        var Interestedindex = event.target.getAttribute('id');
        console.log(thisID);
        var Allmodel = JSON.parse(JSON.stringify(component.get('v.Product_Interest')));
        var InterestMoreOne = 0;
        for (var i = 0; i < Allmodel.length; i++) {
            console.log(Allmodel[i].Interested);
            for (var j = 0; j < Allmodel[i].Interested.length; j++) {

                if (Allmodel[i].Interested[j].data == true && j == 0) {
                    InterestMoreOne = InterestMoreOne + 1;
                }
               
            }
        }

        if (InterestMoreOne > 0 && Interestedindex == 0) {
            Allmodel[thisID].Interested[Interestedindex] = {
                'data': false
            };
            var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                type: "Error",
                title: "Error!",

                message: "More then One Interested Model Selected Primary ."
            });
            toastEvent.fire();
            component.set('v.Product_Interest', Allmodel);
        } else {
            for (var i = 0; i < Allmodel[thisID].Interested.length; i++) {
                if (Interestedindex == i) {
                    if(Allmodel[thisID].Interested[i].data == true){
                        Allmodel[thisID].Interested[i] = {
                            'data':false
                        };
                    }
                    else{
                        Allmodel[thisID].Interested[i] = {
                            'data':true
                        };
                    }
                   
                } else {
                    Allmodel[thisID].Interested[i] = {
                        'data': false
                    };
                }
            }
            component.set('v.Product_Interest', Allmodel);
        }


    },
    changeVariant: function (component, event, helper) {

        var VariantId = event.getSource().get("v.value");
        var indexValue = event.getSource().get('v.name');
        var allModels = JSON.parse(JSON.stringify(component.get("v.Product_Interest")));
        var getColorOfVariant = component.get("c.getColorOfVariant");
        getColorOfVariant.setParams({
            VariantId: VariantId
        });
        var self = this;
        getColorOfVariant.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var AllColors = response.getReturnValue();
                allModels[indexValue].selectedColors = AllColors;
                component.set("v.Product_Interest", allModels);

            }
        });

        $A.enqueueAction(getColorOfVariant);

    },
     closeModel : function(cmp) {
        var cmpEvent = cmp.getEvent("clsPopupEvent");
        cmpEvent.fire();
    }
})