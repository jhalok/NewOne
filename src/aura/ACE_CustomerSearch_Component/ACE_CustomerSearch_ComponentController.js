({
    doInit : function(component, event, helper) {
        var str = window.location.href
        var res = str.split("/");
        if(res[5] == 'Lead'){
            component.set('v.showMultiList', false);
        }
       else{
        component.set('v.showMultiList', true);
       }
        var sPageURL = window.location.href;
        var dcodedUrl=decodeURIComponent(sPageURL);
        console.log('dcodedUrl='+dcodedUrl);
        var idx=dcodedUrl.indexOf("?")+1;
        if(idx>1){
            var urlParams=dcodedUrl.substring(idx);
            console.log('urlParams='+urlParams);
            var sURLVariables = urlParams.split('&');
            console.log('sURLVariables='+sURLVariables);
            var paramMap=new Map();
            
            for (var i = 0; i < sURLVariables.length; i++) {
                if(sURLVariables[i].indexOf('=')>0){
                    var rowDataList = sURLVariables[i].split('=');
                    console.log('rowDataList='+rowDataList);
                    paramMap.set(rowDataList[0],rowDataList[1]);
                }
            }
            
            if(paramMap.size>0){
                var emailId='';
                var mobile='';
                if(paramMap.has('c__email')){
                    console.log('PARAM email==='+paramMap.get('c__email'));
                    emailId=paramMap.get('c__email');
                }
                if(paramMap.has('c__mobile')){
                    console.log('PARAM mobile==='+paramMap.get('c__mobile'));
                    mobile=paramMap.get('c__mobile');
                }
                if(emailId!=null && emailId!='' && mobile!=null && mobile!=''){
                    component.set('v.searchText',mobile);
                    helper.SearchMultiHelper(component, event,emailId);
                }
                else if(mobile!=null && mobile!=''){
                    component.set('v.searchText',mobile);
                    helper.SearchMultiHelper(component, event,null);
                }
                else if(emailId!=null && emailId!=''){
                    component.set('v.searchText',emailId);
                    helper.SearchMultiHelper(component, event,null);
                }
            }
        }
    },
    Search: function(component, event, helper) {
        //alert('Search single');
        var isSearchMutli= component.get('v.showMultiList');
        //var actions = [{ label: 'Show details', name: 'show_details' }];
        var searchText = component.get('v.searchText');
        //helper.clearLinkEvtParams(component, event);
        if(searchText){
            if(isSearchMutli!=true){
                helper.SearchHelper(component, event);
            }
            else{
                helper.SearchMultiHelper(component, event,null);
            }
        }else{
            helper.showErrorMsg(component, event,"Please enter text before clicking search.");
        }
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var Addvalue = row.Name;
        helper.clearLinkEvtParams(component, event);
        //   alert("Showing opportunity " + Addvalue);
        component.set("v.SelectMessage", true);
        component.set("v.selectedAccount", Addvalue);
        // if(currentvalue)
        // helper.showRowDetails (component, row, event);       
    },
    linkContact:function (component, event, helper) {
        var contactId = event.target.id; 
        var contactName = event.target.value;
        console.log('--after linking--');
        console.log(contactId,'---',contactName);
        var str = window.location.href
        var res = str.split("/");
        console.log(res[6]);
        var leadId = res[6];
        if(leadId != undefined){
                
            var action = component.get("c.updateLeadContact");
            action.setParams({
                'leadId': leadId,
                'contactId': contactId,
                
            });
            action.setCallback(this, function(response) {
                // hide spinner when response coming from server 
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "Success",
                        title: "Success!",
                        message: "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    window.location.reload();
                }else if (state === "INCOMPLETE") {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "Error",
                        title: "Error!",
                        message: "Response is Incompleted"
                    });
                    toastEvent.fire();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type : "Error",
                                title: "Error!",
                                message:  errors[0].message
                            });
                            toastEvent.fire();
                        }
                    } else {
                        
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type : "Error",
                            title: "Error!",
                            message:  "Unknown error"
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        } else{
            var data = [];
            data.push(contactId);
            data.push(contactName);
            var relatedContact = $A.get("e.c:ACE_AssignContact");
         
                relatedContact.setParams({"type" :'relatedContact',
                                            "payload" :data
                                        });
                relatedContact.fire();
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Success",
                title: "Success!",
                message:  contactName+" contact has been linked"
            });
            toastEvent.fire();
          
        }
        
    },
    
    
    linkContactToChatForm:function (component, event, helper) {
        var idStr=event.target.id;
        var delemeterIndex= idStr.indexOf("_");
        if(delemeterIndex>0){
            var contactId = idStr.slice(0, delemeterIndex);
            var contactName = idStr.substr(delemeterIndex+1);
            console.log('contactId'+contactId+'::contact-->'+contactName);
            var linkObjEvt = $A.get("e.c:ACE_LinkSObjectEvent");
            linkObjEvt.setParams({"sObjectName":"Contact","sObjRecId":contactId,"sObjRecName":contactName});
            linkObjEvt.fire();
        }else{
            alert('Invalid Contact.');
        }
    },
    linkLeadToChatForm:function (component, event, helper) {
        var idStr=event.target.id;
        console.log('LeadRec:::>'+idStr);
        var delemeterIndex= idStr.indexOf("_");
        if(delemeterIndex>0){
            var leadId = idStr.slice(0, delemeterIndex);
            var leadName = idStr.substr(delemeterIndex+1);
            console.log('leadId'+leadId+'::lead-->'+leadName);
            var linkObjEvt = $A.get("e.c:ACE_LinkSObjectEvent");
            linkObjEvt.setParams({"sObjectName":"Lead",
            "sObjRecId":leadId,"sObjRecName":leadName
            });
            linkObjEvt.fire();
        }else{
            alert('Invalid Lead.');
        }
    },
    openLinkedRecordTab: function(component, event, helper) {
        var recId= event.target.id;
        console.log('openLinkedRecordTab--->'+recId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId":recId,
                    "actionName":"view"
                },
                "state": {}
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({tabId: response
        }).then(function(tabInfo) {
            console.log("The recordId for this tab is: " + tabInfo.recordId);
        });
        }).catch(function(error) {
            console.log(error);
        });
    },

})