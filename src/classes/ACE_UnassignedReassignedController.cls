public with sharing class ACE_UnassignedReassignedController {
    
    
    @AuraEnabled
    public static WrapperFilterClass getEnquiryFilters(String launchType){

        Boolean isCheckedLaunch = false;
        if(launchType == 'PreLaunch') {
            isCheckedLaunch = true ;  
        } else {
            isCheckedLaunch = false ;   
        }
        
        WrapperFilterClass wrapperEnquiry = new WrapperFilterClass();
        List<String> productModelName = new List<String>();
        if(isCheckedLaunch) {
            System.debug('---isCheckedLaunch'+[SELECT Id, Name, IsActive, Vehicle_Model__c, Model__c FROM Product2 WHERE IsActive =: true]);
            for(Product2 product : [SELECT Id, Name, IsActive, Vehicle_Model__c, Model__c FROM Product2 WHERE IsActive =: true AND Is_Prelaunch__c =: isCheckedLaunch]) {
                if(!productModelName.Contains(product.Vehicle_Model__c))
                    productModelName.add(product.Vehicle_Model__c);
            }
        } else {
            System.debug('---else data---'+[SELECT Id, Name, IsActive, Vehicle_Model__c, Model__c FROM Product2 WHERE Is_Prelaunch__c =: isCheckedLaunch]);
             for(Product2 product : [SELECT Id, Name, IsActive, Vehicle_Model__c, Model__c FROM Product2 WHERE Is_Prelaunch__c =: isCheckedLaunch]) {
                if(!productModelName.Contains(product.Vehicle_Model__c))
                    productModelName.add(product.Vehicle_Model__c);
            }
        }
        
        if(productModelName.size() > 0 )
            wrapperEnquiry.ProductName = productModelName;
        
        User user = [SELECT Id, Name, Contact.User_Role_ACE__c, IsPortalEnabled, PortalRole, IsActive FROM User WHERE Id =: UserInfo.getUserId()];
        if(user.Contact.User_Role_ACE__c != null && (user.Contact.User_Role_ACE__c == 'Sales Consultant' || user.Contact.User_Role_ACE__c == 'Digital Manager')) {
        	wrapperEnquiry.IsUnassingedDisplay = true;
        }else {
            wrapperEnquiry.IsUnassingedDisplay = false;
        }
        return wrapperEnquiry;
    }

    public class WrapperFilterClass {
        @AuraEnabled public Boolean IsUnassingedDisplay;
        @AuraEnabled public Boolean IsPreLaunch;
        @AuraEnabled public Boolean IsLaunch;
        @AuraEnabled public List<String> ProductName; 
    }
}