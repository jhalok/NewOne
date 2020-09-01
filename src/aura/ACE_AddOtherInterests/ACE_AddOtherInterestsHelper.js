({
    proHelper : function(component, event) {
        //alert("Hello Button PRessed in Helper");
        
        var newpro = component.get("v.ProductList")
        //alert("Hello"+ newpro );
        var action = component.get("c.Saveproduct");
        //alert("Hello Button Sucesss Helper");
        action.setParams({
            'contactId': newpro
        });       
        
    }
    
    /*   action.setCallback(this, function(response) {
    var state = response.getState();
    alert(state);
    if (state === "SUCCESS") {  
    alert("Accounts Inserted Succesfully"); 
}
 else if (state === "ERROR") {
    var errors = response.getError();
    if (errors) {
        if (errors[0] && errors[0].message) {
            console.log("Error message: " + 
                        errors[0].message);
        }
        else {
            console.log("Unknown error");
            alert('Unknown');
        }
    }
    
}
}*/
    
})