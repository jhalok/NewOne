({
	doInit : function(component, event, helper) {
		 var  account = component.get('v.accountRecord');
        var str = window.location.href
        var res = str.split("/");
      var  baseUrl = 'https://'+res[2]+'/lightning/r/Account/'+account.Id+'/view/';
        component.set('v.baseUrl',baseUrl);
	}
})