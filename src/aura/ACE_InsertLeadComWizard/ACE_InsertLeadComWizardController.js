({
    doInit : function(component, event, helper) {
        console.log( '@@@@ doInit called' );

        document.onload = function() {
            console.log( '@@@@ window.onload called' );
            var ele = document.getElementsByClassName( "cACE_InsertLeadComWizard" );
            console.log( '@@@@ ele : ', ele );

            var ele1 = document.getElementsByClassName( "test-lvmForceActionsContainer" );
            console.log( '@@@@ ele1 : ', ele1 );

            var ele2 = document.getElementsByClassName( "contentRegion" );
            console.log( '@@@@ ele2 : ', ele2 );
        };
        
        window.onload = function() {
            console.log( '@@@@ window.onload called' );
            var ele = document.getElementsByClassName( "cACE_InsertLeadComWizard" );
            console.log( '@@@@ ele : ', ele );

            var ele1 = document.getElementsByClassName( "test-lvmForceActionsContainer" );
            console.log( '@@@@ ele1 : ', ele1 );

            var ele2 = document.getElementsByClassName( "contentRegion" );
            console.log( '@@@@ ele2 : ', ele2 );
        };

	},
	handleClick : function(component, event, helper) {
        component.set("v.showProds", true);
		
	},
    closeModel :function(component, event, helper) {
        component.set("v.showProds", false);
    }
})