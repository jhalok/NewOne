({
    doInit : function(component, event, helper) {
        var sobject = component.get('v.record');
        var fieldName = component.get('v.fieldName');
        var formatText = component.find('fielddata');
        console.log('----sobject-----------');
         console.log(sobject);
		formatText.set("v.value",sobject[fieldName]);
    },
    
	redirectDetail : function(component, event, helper) {
		//Redirect to detail page on success
        var navService = component.find('navService');
        console.log('navService---> ' +navService);
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": component.get("v.recordId"),
                "objectApiName": component.get("v.obName"),
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
	},
       
})