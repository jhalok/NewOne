({
	myAction : function(component, event, helper) {
		 /*Added by Raksha*/
        // Get the empApi component
        const empApi = component.find('empApi');
        const channel = component.find('channel').get('v.value');
        console.log('channel'+component.find('channel').get('v.value'));
        // Uncomment below line to enable debug logging (optional)
        empApi.setDebugFlag(true);
        // Replay option to get new events
        const replayId = -1;
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
        });
        // Register error listener and pass in the error handler function
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', error);
        }));
       
	}
})