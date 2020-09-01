({
	getLinkedRecParam : function(component, event) {
		var linkSObjName=component.get("v.linkSObjName");
        var linkSObjRecId=component.get("v.linkSObjRecId");
        var linkSObjRecName=component.get("v.linkSObjRecName");
        if(linkSObjRecId!=null && linkSObjName!=null && linkSObjName!=''){
            return linkSObjName+'_'+linkSObjRecId;
        }
        return null;
	}
})