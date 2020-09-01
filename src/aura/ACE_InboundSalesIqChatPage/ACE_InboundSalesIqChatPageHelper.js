({
	goToContactRecord : function(component,response) {
        var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
        console.log("success recId=" + responseObj.Id);
		var navLink = component.find("goToLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Contact',
                recordId : responseObj.Id
            }
        };
        navLink.navigate(pageRef, true);
        console.log('NAVIGATE TO CONTACT RECORD');
	},
    goToLeadRecord : function(component,response) {
        var responseObj = JSON.parse(JSON.stringify(response.getReturnValue()));
        console.log("success recId=" + responseObj.Id);
        var navLink = component.find("goToLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Lead',
                recordId : responseObj.Id
            }
        };
        navLink.navigate(pageRef, true);
        console.log('NAVIGATE TO LEAD RECORD');
	}
})