({
	 /*Initialize on page load*/
    doInit : function(component, event, helper) {
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
            
            var chkPerson = component.get("v.ChkPerson");
            var actSrchCntc = component.get("c.getContactRecord");
            var actSrchLead = component.get("c.getLeadRecord");
            if(paramMap.size>0){
                if(paramMap.has('c__mobile')){
                    console.log('PARAM mobile===>'+paramMap.get('c__mobile'));
                    chkPerson.MobileNumber=paramMap.get('c__mobile');
                }
            }
            console.log('chkPerson=>'+chkPerson);
            
            actSrchCntc.setParams({"cus": chkPerson});
            actSrchLead.setParams({"cus": chkPerson});
            
            actSrchCntc.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response='+response+'--state='+state);
                if (state === "SUCCESS") {
                    var name = response.getReturnValue();
                    console.log("name--->" + JSON.stringify(name));
                    if(name!=null){
                        helper.goToContactRecord(component,response);
                    }
                    else{
                        console.log ('Contact with mobile number not found!!!');
                        $A.enqueueAction(actSrchLead);
                    }
                }
                else if (state === "ERROR"){
                    alert("Failed to fetch contct record!");
                }
            });
            actSrchLead.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response='+response+'--state='+state);
                if (state === "SUCCESS") {
                    var name = response.getReturnValue();
                    console.log("name--->" + JSON.stringify(name));
                    if(name!=null){
                        helper.goToLeadRecord(component,response);
                    }
                    else{
                        console.log ('Lead with mobile number not found!!!');
                    }
                }
                else if (state === "ERROR"){
                    alert("Failed to fetch lead record!");
                }
            });
            $A.enqueueAction(actSrchCntc);
        }
    }
    ,
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        //var spinner = component.find("mySpinner");
        //$A.util.removeClass(spinner, "slds-hide"); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        //var spinner = component.find("mySpinner");
        //$A.util.addClass(spinner, "slds-hide");
    },
    
    linkToForm : function(component, event){
        var sObj = event.getParam("sObjectName");
        var sObjId = event.getParam("sObjRecId");
        var sObjRecName = event.getParam("sObjRecName");
        console.log('sObj='+sObj+'--sObjId='+sObjId+'::sObjRecName='+sObjRecName);
        // set the handler attributes based on event data
        component.set("v.linkSObj", sObj);
        component.set("v.linkSObjId", sObjId);
        component.set("v.linkSObjName",sObjRecName);
    },
})