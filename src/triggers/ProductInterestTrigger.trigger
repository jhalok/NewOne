trigger ProductInterestTrigger on ACE_Product_Interest__c (after update,after insert) {

    if(trigger.isAfter){
    
        if(trigger.isInsert || Trigger.isUpdate){
        
            
            
                ACE_ProductInterestHandler.updateProductOnLead(trigger.new);
            
                    
        }
    
    }

}