({
  // Client-side function that invokes the subscribe method on the
  // empApi component.
  subscribe: function (component, event, helper) {
    // Get the empApi component.
    const empApi = component.find('empApi');
    // Get the channel from the attribute.
    const channel = component.get('v.channel');
    // Subscription option to get only new events.
    const replayId = -1;
    // Callback function to be passed in the subscribe call.
    // After an event is received, this callback prints the event
    // payload to the console. A helper method displays the message
    // in the console app.
    const callback = function (message) {
        console.log('Event Received : ' + JSON.stringify(message));
        var url = message.data.payload.URL__c;
        //var firstName = message.data.payload.firstName__c;
        //var lastName = message.data.payload.lastName__c;
        var mobileNo = message.data.payload.Mobile__c;
        console.log('Mob: '+mobileNo);
        component.set("v.pageReference", null);
       

        var userId = message.data.payload.UserId__c;
        var loggedInUserId = $A.get( "$SObjectType.CurrentUser.Id" );
        console.log('loggedInUserId: '+loggedInUserId);
        console.log('userId: '+userId);
        if(loggedInUserId == userId){
            try{
                var navService = component.find("navService");
                if(url.includes('Inbound')){
                    console.log('Inbound');
                    var pageReference = {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c__ACE_InboundCall',
                        },
                        state: {
                            c__Mobile: mobileNo,
                            c__callType: 'Inbound'
                        }
                    };
                }
                else
                {
                    console.log('record '+url);
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: url,
                            actionName: 'view'
                        }
                    };
                }
                
                component.set("v.pageReference", pageReference);
                navService.navigate(pageReference);
            }
            catch(error){
                console.log(error);
            }
        }
       
         //helper.onReceiveNotification(component,event, message);
    };
    // Subscribe to the channel and save the returned subscription object.
    empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
      console.log('Subscribed to channel ' + channel);
      component.set('v.subscription', newSubscription);
    }));
  },
  // Client-side function that invokes the unsubscribe method on the
  // empApi component.
  unsubscribe: function (component, event, helper) {
    // Get the empApi component.
    const empApi = component.find('empApi');
    // Get the channel from the component attribute.
    const channel = component.get('v.subscription').channel;
    // Callback function to be passed in the unsubscribe call.
    const callback = function (message) {
      console.log('Unsubscribed from channel ' + message.channel);
    };
    // Unsubscribe from the channel using the subscription object.        
    empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
  },
  // Client-side function that displays the platform event message
  // in the console app and displays a toast if not muted.
    onReceiveNotification: function (component,event, message) {
        // Extract notification from platform event
        
        const newNotification = {
            time: $A.localizationService.formatDateTime(
                message.data.payload.CreatedDate, 'HH:mm'),
            message: message.data.payload.URL__c
        };
        // Save notification in history
        const notifications = component.get('v.notifications');
        notifications.push(newNotification);
        component.set('v.notifications', notifications);
        var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'New_Inbound_Call'
            }
        };
        component.set("v.pageReference", pageReference);
        event.preventDefault();
        navService.navigate(pageReference);
    }
})