({
    doInit: function(component, event, helper) {
        var getItems = component.get('v.items'); 
        var getElement = component.get('v.element');
        
        //It will not match with undefined. 
        if($A.util.isEmpty(getItems) || $A.util.isEmpty(getElement.trim())) {
            component.set('v.isElementFound',false)
            return;
        };
                
        var getCurrentElementIndex;
        
        //Check type and if it is String then check contains. 
        if(typeof getItems == 'string' && typeof getElement == 'string'){
            if(component.get("v.checkCaseSensitivity")){
                getCurrentElementIndex = getItems.indexOf(getElement);
            }else{
                getCurrentElementIndex = getItems.toLowerCase().indexOf(getElement.toLowerCase());
            }
           
        } else {
            getCurrentElementIndex = getItems.indexOf(getElement);
        }
                
        // if getCurrentElementIndex is not equal to -1 it's means list contains this element. 
        if(getCurrentElementIndex != -1){ 
            component.set('v.isElementFound',true);
        }else{
            component.set('v.isElementFound',false);
        }
    }
})