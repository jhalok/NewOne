({
    doInit : function(component, event, helper) {
        let quoteId = component.get("v.recordId");
        let action = component.get("c.getOppID");
		action.setParams({
			"quoteId": quoteId
		});

		action.setCallback(this, function (response){
            let state = response.getState();
            if(state == "SUCCESS"){
                let quote =  response.getReturnValue();
                console.log("quote is in EditQuoteController ",quote);
                component.set("v.oppId",quote.OpportunityId);
                let quoteLineItems  = quote.QuoteLineItems;
                let quoteCharges    = quote;
                let beforeSaveQuote = quote;
                let defaultMap      = new Map();
                let accVal          = [];
                console.log('@@@@@ quoteLineItems ',quoteLineItems);
                if(quoteLineItems != undefined){
                    for(let i = 0; i < quoteLineItems.length; i++){
                        if(quoteLineItems[i].Product2.Type__c != 'Accessories'){
                            let obj = {'id':quoteLineItems[i].Product2.Id,'default':quoteLineItems[i].UnitPrice};
                            defaultMap.set(quoteLineItems[i].Product2.Type__c,obj);
                        }
                        else{
                            let obj = {'id':quoteLineItems[i].Product2.Id,'default':quoteLineItems[i].UnitPrice};
                            accVal.push(obj);
                            defaultMap.set(quoteLineItems[i].Product2.Type__c,accVal);
                        }
                        
                    }
                    console.log("defaultMap is ",defaultMap);
                }
                
                component.set("v.defaultMap",defaultMap);
                component.set("v.quoteCharges",quoteCharges);
                component.set("v.beforeSaveQuote",beforeSaveQuote);
                console.log(">>>> beforeQuote ",beforeSaveQuote);
                console.log("@@@ beforeQuote ",component.get("v.beforeSaveQuote"));
                component.set("v.renderChild","true");

            }else{
                alert("Error in EDIT");
            }
        });
        $A.enqueueAction(action);
    }
})