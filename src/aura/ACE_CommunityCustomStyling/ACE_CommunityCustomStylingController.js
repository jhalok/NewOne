({
    doInit : function(component, event, helper) {

        var recordId = component.get( "v.recordId" );
        if( recordId ) {
            var action = component.get( "c.getNavItemPosition" );
            action.setParams({
                "recordId" : recordId
            });
            action.setCallback( this, function( response ) {
                var state = response.getState();
                console.log( '@@@@@@ state : ', state );
                if( state === "SUCCESS" ) {
                    var itemPosition = response.getReturnValue();
                    console.log( '@@@@@@ itemPosition : ', itemPosition );
                    component.set( "v.navItemNumber", itemPosition );
                } else {
                    var error = response.getError();
                    console.log( '@@@@@@ error : ', error );
                }
            });
            $A.enqueueAction( action );
        } else {
            component.set( "v.navItemNumber", null );
        }
    }
})