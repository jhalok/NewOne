({
    fetchPickListVal: function(component,objDetails,Salutation) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": objDetails,
            "fld": Salutation
        });
        var opts = [];
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var StoreResponse = response.getReturnValue();
                console.log('Retrun-->'+StoreResponse);
                console.log('sucess'); 
                var opts = [];
                for(var i=0;i<StoreResponse.length;i++){
                    opts.push({
                        label:StoreResponse[i],
                        value:StoreResponse[i]
                    })	
                }
                component.set("v.SalutationPick",opts);
              //  component.set("v.options",opts);
            }else{
                alert('Something went wrong..');
            }
        });            
        $A.enqueueAction(action);  
     },
        InsertRecord : function(component,objDetails){
            alert('Submitted');
        var action = component.get("c.saveRecord");
        action.setParams({
            'objDetail' : objDetails     
        });
        action.setCallback(this,function(res){
            var state = res.getState();
            if (state === 'SUCCESS'){
                
                var abcd = res.getReturnValue();
                alert(abcd);
             //   component.set("v.parentvalue",abcd.Id);
             //   var namerec = abcd.Name;
             //   var fetchingvalue = component.get("v.parentvalue");
             //   this.FetchInsertedRecord(component,fetchingvalue); 
            }
        });
        $A.enqueueAction(action);
    }
 
})