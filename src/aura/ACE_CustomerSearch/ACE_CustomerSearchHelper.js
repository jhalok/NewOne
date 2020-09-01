({
	fetchResults : function(component,searchText) {
        var action = component.get('c.searchRecords');
        action.setParams({searchText: searchText});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var recordList = response.getReturnValue();
                component.set('v.recordList',recordList);
            }
        });
        $A.enqueueAction(action);
	}
})