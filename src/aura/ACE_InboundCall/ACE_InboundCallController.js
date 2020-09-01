({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var mobile = myPageRef.state.c__Mobile;
        var callType = component.get("v.callType");
        callType = myPageRef.state.c__callType;
        console.log(mobile);
        document.title = "New Call - "+mobile;
		component.set('v.mobileNumber',mobile);   
        component.set("v.NewCustomer.MobileNumber",mobile);
        component.set("v.NewCustomer.callType",callType);
        var childCmp = component.find("cAccountSearch");
        childCmp.searchRecords();


        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: 'New Inbound Call',
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:call",
                iconAlt: "IncomingCall"
            });
        })
    },
    fetchRelatedContact: function(component, event, helper) {
        //var relatedContact = event.getParam("id");
        console.log('dsfjlkdsjfkl');
        //console.log(relatedContact);
        //component.set('v.contactDetails',relatedContact);

    }
})