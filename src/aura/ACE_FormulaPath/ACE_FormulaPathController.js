({
    doInit : function(component, event, helper) {
        console.log( '@@@@@@ Formula Path doInit CALLED....' );

        var action = component.get( "c.getSobjectAPI_Name" );
        action.setParams({
            "recordId" : component.get( "v.recordId" )
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            console.log( '@@@@@@ state : ', state );
            if( state === "SUCCESS" ) {
                var sobjectAPI_Name = response.getReturnValue();
                console.log( '@@@@@@ sobjectAPI_Name : ', sobjectAPI_Name );
                var passedObjectName = component.get( "v.sObjectApiName" );
                var showPath = false;
                if( passedObjectName == sobjectAPI_Name ) {
                    showPath = true;
                }
                console.log( '@@@@@@ showPath : ', showPath );
                component.set( "v.showPath", showPath );
            } else {
                var error = response.getError();
                console.log( '@@@@@@ error : ', error );
            }
        });
        $A.enqueueAction( action );
    }
})