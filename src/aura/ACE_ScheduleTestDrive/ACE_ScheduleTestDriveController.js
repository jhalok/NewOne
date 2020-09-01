({
    doInit: function (component, event, helper) {
        //Edited by Krishnan
        var isNotEnquiry = component.get('v.isNotEnquiry');
        console.log('isNotEnquiry is ', isNotEnquiry);
        if (isNotEnquiry) {
            var str = window.location.href
            var res = str.split("/");
            var objName = res[5]; //Edited by Krishnan
            var leadRecord = {};
            
            //Edited by Krishnan
            var getLead;
            if (objName == 'Lead') {
                getLead = component.get("c.getLead");
            } else if (objName == 'Opportunity') {
                getLead = component.get("c.getOpportunity");
            }
            console.log('res[5]=' + res[5]);
            getLead.setParams({
                Id: res[6]
            });
            var self = this;
            getLead.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    leadRecord = response.getReturnValue();
                    component.set("v.leadRecord", leadRecord);
                    //Edited by Krishnan
                    if (objName == 'Lead') {
                        var selCity=component.get('v.cityVal');
                        if(selCity!=null && selCity!=''){
                            component.set("v.url", '/apex/getRoute?city=' + selCity);
                        }else{
                            component.set("v.url", '/apex/getRoute?city=' + leadRecord.City);
                        }
                    }

                    var getDealer = component.get("c.getDealer");
                    //Edited by Krishnan
                    if (objName == 'Lead') {
                        getDealer.setParams({
                            Id: leadRecord.ACE_Dealer__c
                        });
                    } else if (objName == 'Opportunity') {
                        getDealer.setParams({
                            Id: leadRecord.Dealer__c
                        });
                    }
                    var self = this;
                    getDealer.setCallback(this, function (response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            var DealerData = response.getReturnValue();
                            component.set("v.DealerData", DealerData);
                        } else {
                            console.log('dealer data not found');
                        }
                    });
                    $A.enqueueAction(getDealer);
                    var getModals 
                    if (objName == 'Lead') {
                        getModals = component.get("c.getAllModels");
                    }
                    else if (objName == 'Opportunity') {
                        getModals = component.get("c.getAllModels");
                    }
                    getModals.setParams({
                        LeadId: leadRecord.Id
                    });
                    getModals.setCallback(this, function (response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            component.set('v.Models', response.getReturnValue());
                        } else {
                            console.log('model data not found');
                        }
                    });
                    $A.enqueueAction(getModals);

                }
            });
            $A.enqueueAction(getLead);
        }
        var vfOrigin;
        var vfDomainUrl = $A.get("$Label.c.Visualforce_Domain_Url");
        if(vfDomainUrl!=null && vfDomainUrl!=''){
            component.set("v.vfHost", vfDomainUrl);
            vfOrigin = component.get("v.vfHost");
        }
        else{
            vfOrigin = "https://" + component.get("v.vfHost");
        }
        window.addEventListener("message", $A.getCallback(function(event) {
            if (event.origin !== vfOrigin) {
                console.log('event.origin ='+event.origin );
                return;
            }
            console.log('@#$%&='+event.data);
            var msg=event.data;
            if(msg!=null && msg.indexOf('_;_')>0){
                var strSpltArr=msg.split('_;_');
                component.set('v.latVal',strSpltArr[0]);
                component.set('v.lngVal',strSpltArr[1]);
                if(strSpltArr.length>2 && strSpltArr[2]!=null && strSpltArr[2]!=''){
                    component.set('v.cityVal',strSpltArr[2]);
                }else{
                    component.set('v.cityVal',leadRecord.City);
                }
            }
        }), false);
    },
    goNext: function (component, event, helper) {
        var onFirstStep = component.get('v.onFirstStep');
        var onLastStep = component.get('v.onLastStep');
        var onSecStep = component.get('v.onSecStep');
        if (onFirstStep) {
            var modelSelected = component.get('v.modelName');
            console.log('modelSelected=' + modelSelected);
            if (modelSelected != null && modelSelected != '') {
                component.set('v.onFirstStep', false);
                component.set('v.onSecStep', true);
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-hide");
                var selCity=component.get('v.cityVal');
                var leadCity=component.get('v.leadRecord.City');
                if(selCity!=null && selCity!=''){
                    component.set("v.url", '/apex/getRoute?city=' + selCity);
                }else{
                    component.set("v.url", '/apex/getRoute?city=' + leadCity);
                }
            } else {
                helper.showErrorMsg("Please select a model for test drive.");
            }
        } else if (onSecStep) {
            var selCity=component.get('v.cityVal');
            if(selCity!=null && selCity!=undefined && selCity!='' && selCity!='Invalid Location.'){
                component.set('v.onSecStep', false);
                component.set('v.onLastStep', true);
            }
            else{
                helper.showErrorMsg("Please select valid location for test drive.");
            }
        }
    },
    goPrevious: function (component, event, helper) {
        var onFirstStep = component.get('v.onFirstStep');
        var onLastStep = component.get('v.onLastStep');
        var onSecStep = component.get('v.onSecStep');

        if (onSecStep) {
            var selCity=component.get('v.cityVal');
            if(selCity!=null && selCity!=undefined && selCity!='' && selCity!='Invalid Location.'){
                component.set('v.onSecStep', false);
                component.set('v.onFirstStep', true);
            }
            else{
                helper.showErrorMsg("Please select valid location for test drive.");
            }
        } else if (onLastStep) {
            component.set('v.onLastStep', false);
            component.set('v.onSecStep', true);
            var spinner = component.find("mySpinner");
            $A.util.removeClass(spinner, "slds-hide");
            var selCity=component.get('v.cityVal');
            var leadCity=component.get('v.leadRecord.City');
            if(selCity!=null && selCity!=''){
                component.set("v.url", '/apex/getRoute?city=' + selCity);
            }else{
                component.set("v.url", '/apex/getRoute?city=' + leadCity);
            }
        }
    },

    resetLocation: function (component, event, helper) {
        component.set('v.onSecStep', false);
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var leadCity= component.get('v.leadRecord.City');
        component.set("v.url", '/apex/getRoute?city=' + leadCity);
        //component.set('v.cityVal');
        component.set('v.onSecStep', true);
    },
    
    linkSelDate : function(component, event){
        var sObj = event.getParam("sObjectName");
        var sObjId = event.getParam("sObjRecId");
        var sObjRecName = event.getParam("sObjRecName");
        console.log('sObj='+sObj+'--sObjId='+sObjId+'::sObjRecName='+sObjRecName);
        if(sObj=='Date' && sObjRecName!=null && sObjRecName!=''){
            console.log('Date='+sObjRecName);
            component.set("v.dateVal",sObjRecName);
        }
    },
    
    cancelAction: function (cmp) {
        var cmpEvent = cmp.getEvent("clsPopupEventCTD");
        cmpEvent.fire();
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})