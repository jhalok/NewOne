({
    handleKeyUp: function (component, event) {
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            let phSearch = component.find('search').get('v.value');
            let action = component.get("c.phoneRecord");
            action.setCallback(this, function(response){

            });
            $A.enqueueAction(action);
        }
    }
})