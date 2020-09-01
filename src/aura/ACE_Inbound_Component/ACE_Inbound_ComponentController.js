({
    SaveLead : function(component, event, helper) {

        var piComp = component.find("cPIComponent");
        var piList = component.get('v.interestsForLead');
        var relatedcon = component.get("v.relatedContactDetails");
        var relatedLeadDetails = component.get("v.relatedContactDetails");

        var newLead =  {'sobjectType': 'Lead',
        'FirstName': '',
        'LastName':'',
        'City': '',
        'Email': '',
        'Comments__c': '',
        'Related_Contact__c':'',
        'MobilePhone': '',
        'Phone ': '',
        'Call_Type__c': '',
        'Call_Center__c': '',
        'Service__c ': '',};
        if(component.get('v.leadId') != undefined){
            var leadId =  component.get('v.leadId');
        }else{
            var leadId = '';
        }
       
        if(relatedLeadDetails != undefined && component.get('v.leadId')  != undefined){
            newLead.Phone = component.get("v.MobilePhone");
           
        }
        if(component.get('v.leadId')  == undefined){
            newLead.MobilePhone = component.get("v.MobilePhone");
        }
         if(relatedcon != undefined  ){
            newLead.Related_Contact__c = relatedcon.Id;
        }
        if(component.get("v.FirstName")  != ''  ){
            newLead.FirstName =  component.get("v.FirstName");
        }
        if(component.get("v.LastName") != ''){
            newLead.LastName = component.get("v.LastName");
        }
        if(component.get("v.email") != ''){
            newLead.Email = component.get("v.email");
        }
        if(component.get("v.City") != ''){
            newLead.City = component.get("v.City");
        }
        if(component.get("v.comment") != ''){
            newLead.Comments__c = component.get("v.comment");
        }
     
        var action = component.get("c.LeadSave");
        var linkRec = '';
        action.setParams({ 
            "cus": newLead,
            "linkedRec":linkRec,
            "piList":piList,
            'leadId' : leadId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var name = response.getReturnValue();
                if(name != null){
                    var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                    var navLink = component.find("navLink");
                    var pageRef = {
                        type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            objectApiName: 'Lead',
                            recordId : responseObj.Id
                        },
                    };
                    navLink.navigate(pageRef, true);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: 'Error Occured !',
                        type : 'Error',
                      
                    });
                    toastEvent.fire();
                }
              
            }
            else if (state === "ERROR"){
                alert("Failed to save record!");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    SaveCase : function(component, event, helper) {
        var piComp = component.find("cPIComponent");
        var piList = component.get('v.interestsForLead');
        var relatedcon = component.get("v.relatedContactDetails");
        var relatedLeadDetails = component.get("v.relatedContactDetails");

        var newLead =  {'sobjectType': 'Lead',
        'FirstName': '',
        'LastName':'',
        'City': '',
        'Email': '',
        'Comments__c': '',
        'Related_Contact__c':'',
        'MobilePhone': '',
        'Phone ': '',
        'Call_Type__c': '',
        'Call_Center__c': '',
        'Service__c ': '',};
        if(component.get('v.leadId') != undefined){
            var leadId =  component.get('v.leadId');
        }else{
            var leadId = '';
        }
       
        if(relatedLeadDetails != undefined && component.get('v.leadId')  != undefined){
            newLead.Phone = component.get("v.MobilePhone");
           
        }
        if(component.get('v.leadId')  == undefined){
            newLead.MobilePhone = component.get("v.MobilePhone");
        }
         if(relatedcon != undefined  ){
            newLead.Related_Contact__c = relatedcon.Id;
        }
        if(component.get("v.FirstName")  != ''  ){
            newLead.FirstName =  component.get("v.FirstName");
        }
        if(component.get("v.LastName") != ''){
            newLead.LastName = component.get("v.LastName");
        }
        if(component.get("v.email") != ''){
            newLead.Email = component.get("v.email");
        }
        if(component.get("v.City") != ''){
            newLead.City = component.get("v.City");
        }
        if(component.get("v.comment") != ''){
            newLead.Comments__c = component.get("v.comment");
        }
     
        var action = component.get("c.CaseSave");
        var linkRec = '';
        action.setParams({ 
            "cus": newLead,
            "linkedRec":linkRec,
            "piList":piList,
            'leadId' : leadId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var name = response.getReturnValue();
                if(name != null){
                     //alert("success");
                    var name = response.getReturnValue();
                    // alert("name--->" + JSON.stringify(name));
                    var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                //   alert("success" + responseObj.Id);
                    var CaseID = responseObj.Id;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Sucess',
                        message: 'Case Created !',
                        type : 'Sucess',
                      
                    });
                    toastEvent.fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+CaseID+"/e"
                    });
                    
                    urlEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: 'Something wants Wrong Please check ! ',
                        type : 'ERROR',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
               
            }
            else if (state === "ERROR")
            {
                alert("Failed");
            }
        });
        $A.enqueueAction(action);
    },
    
    /*Added by Sanchayan*/
    doInit : function(component, event, helper) {
        var relatedcon = component.get("v.relatedContactDetails");
        console.log('relatedcon in init-->',relatedcon);
        var sPageURL = window.location.href;
        var dcodedUrl=decodeURIComponent(sPageURL);
        console.log('dcodedUrl='+dcodedUrl);
        var idx=dcodedUrl.indexOf("?")+1;
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
        
        var cust = component.get("v.NewCustomer");
        
        if(paramMap.size>0){
            if(paramMap.has('c__mobile')){
                console.log('PARAM mobile==='+paramMap.get('c__mobile'));
                cust.MobileNumber=paramMap.get('c__mobile');
            }
            if(paramMap.has('c__email')){
                cust.Email=paramMap.get('c__email');
            }
            if(paramMap.has('c__name')){
                var fullName=paramMap.get('c__name');
                var nmArr = fullName.split(' ');
                if(nmArr.length>0){
                    var len=nmArr.length;
                    cust.FirstName=nmArr[0];
                    cust.LastName=nmArr[(len-1)];
                }else{
                    cust.LastName=nmArr[0];
                }
            }
            if(paramMap.has('c__company')){
                cust.Company=paramMap.get('c__company');
            }
            if(paramMap.has('c__chatId')){
                cust.chatId=paramMap.get('c__chatId');
            }
        }

      
    },
    
    openLinkedRecordTab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recId=component.get("v.linkSObjRecId");
        console.log('openLinkedRecordTab--->'+recId);
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
    
    deLinkItem: function(component, event, helper) {
       console.log('deLinkItem');
       component.set("v.linkSObjName", "");
       component.set("v.linkSObjRecId", null);
       component.set("v.linkSObjRecName", "");
   },
   /*SD-End*/
    
    openPIModal:function(component, event, helper){
        component.set("v.isUpdateProductInterestOpen", true);
    },
    closeUpdateProductInterestModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
       component.set("v.isUpdateProductInterestOpen", false);
    },
    fetchRelatedContact:function(component, event, helper){
        var sObjectName = event.getParam("sObjectName");
        var sObjRecId = event.getParam("sObjRecId");
        var sObjRecName= event.getParam("sObjRecName");
       
        if(sObjectName == 'Contact'){
            var relatedData = component.get('v.relatedContactDetails');
            relatedData.Name = sObjRecName;
            relatedData.Id = sObjRecId;
            component.set('v.relatedContactDetails',relatedData);
        }
        else if(sObjectName == 'Lead'){
            
            var relatedLeadDetails = {'Id':'', 'Name': ''};
            relatedLeadDetails.Name = sObjRecName;
            relatedLeadDetails.Id = sObjRecId;
            
            component.set('v.leadId',sObjRecId);
            component.set('v.relatedLeadDetails',relatedLeadDetails);
        }
        

    },
    getInterestList: function (component, event, helper) {
        var InterestList = event.getParam("interestList"); 
       component.set('v.interestsForLead', InterestList);
        //Set the handler attributes based on event data 
       // cmp.set("v.eventMessage", message + 'Biswajeet');
    },
})