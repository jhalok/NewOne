({
	FetchChat : function(component, event, helper) {
        //var recordId = component.get("v.recordId");
        //console.log('calling fetchchat --ParentId='+recordId);
        var pId=component.get("v.parentRecId");
        var cId=component.get("v.chatSiqId");
        var phnNum=component.get("v.phoneNum");
        component.set("v.ChatDtl.chatId",cId);
        component.set("v.ChatDtl.parentId",pId);
        component.set("v.ChatDtl.contactNo",phnNum);
        var cDtl = component.get("v.ChatDtl");
        console.log('cDtl-->'+cDtl);
        var action = component.get("c.FetchChatTranscriptById");
        console.log('cId=>'+cId+'--pId=>'+pId+'--phnNum=>'+phnNum);
        action.setParams({ 
            "chatDtl": cDtl
        });
        console.log('param='+action.getParams);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response='+response+'--state='+state);
            if (state === "SUCCESS") {               
                var respObj = response.getReturnValue();
                console.log("respObj--->" + JSON.stringify(respObj));
                var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log("success" + responseObj);
                //component.set("v.chatTranscript",responseObj);//JSON.stringify(respObj)
                //component.set('v.recordUIList',responseObj);
                component.set('v.pdfViewUrl','/apex/ACE_ChatTranscriptPDFview?cId='+cId+'&pId='+pId+'&phnNum='+phnNum);
                //hide button code tbd####################
                var doneMsg='Chat transcript fetched and attached successfully.';
                helper.showSuccessMsg(component, event, doneMsg);
                console.log('Fetch Complete!!!');
            }
            else if (state === "ERROR"){
                var errMsg='Error occurred while fetching chat transcript. Please contact your system administrator.';
                helper.showErrorMsg(component, event, errMsg);
                //alert("Failed to fetch record!");
            }
        });
        $A.enqueueAction(action);
    },
    
    ResetToken :function(component, event, helper){
        var action = component.get("c.refreshConnection");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response='+response+'--state='+state);
            if (state === "SUCCESS") {               
                var respObj = response.getReturnValue();
                console.log("respObj--->" + JSON.stringify(respObj));
                var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log("success" + responseObj);
                component.set("v.chatTranscript",JSON.stringify(respObj));//JSON.stringify(respObj)
                alert('Reset !!!');
            }
            else if (state === "ERROR"){
                alert("Failed to fetch record!");
            }
        });
        $A.enqueueAction(action);
    }                           
})