({
	myAction : function(component, event, helper) {
		var linkifyRichText = component.find("linkifyRichText");
        linkifyRichText.set("v.value", "Some important points about the persona: <ul><li><p>Poiint number 1</p></li><li></li><li>http://www.google.com</li><li>salesforce.com</li></ul> and this email address: email@richtext.com.");
    }
})