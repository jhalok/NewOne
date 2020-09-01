({
	doinit : function(component, event, helper) {
		var url = $A.get('$Resource.ACE_Mahindra_Rise_Logo');
        component.set('v.logoImageURL', url);
	}
})