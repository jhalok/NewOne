public without sharing class ACE_leadlist {
    @AuraEnabled
    public static List<Opportunity> unAssignedOppData() {
        List<Opportunity> oppList = new List<Opportunity>();
        
            /*[select Id, Name, StageName, Contact__r.Name, Type,owner.id,(Select Product2.Vehicle_Model__c from OpportunityLineItems limit 1) from opportunity where StageName !='Closed Won' and StageName !='Closed Lost' ORDER BY CreatedDate DESC  LIMIT 50000]
             * 
            As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
			*/
        User user = [SELECT Id, Name, Contact.Account.Dealer_Code__c From User Where Id =: UserInfo.getUserId()];
        for(Opportunity opp : [select Id, Name, StageName,Type,owner.id, Dealer__r.Dealer_Code__c, (Select Product2.Vehicle_Model__c,Product2.Is_Prelaunch__c from OpportunityLineItems limit 1) from opportunity where StageName !='Closed Won' and StageName !='Closed Lost' and owner.id =: UserInfo.getUserId() AND Dealer__r.Dealer_Code__c =: user.Contact.Account.Dealer_Code__c ORDER BY CreatedDate DESC  LIMIT 50000])
        { 
            if(opp.OpportunityLineItems.size() > 0)
                oppList.add(opp);
        }
        return oppList;
    }
    
    @AuraEnabled
    public static List<Lead> unAssignedLeadData() {
        List<Lead> LeadList = new List<Lead>();       
        /*[select Id, Name, Related_Contact__r.Name, (Select id, Product__r.Vehicle_Model__c from Product_Interests__r  limit 1 ) from Lead WHERE Status != 'Qualified' and Status != 'Closed - Not Converted' and Status != 'Unqualified' ORDER BY CreatedDate DESC LIMIT 50000]
             * 
            	As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
		*/
        for(Lead ld : [select Id, Name, Related_Contact__r.Name,owner.id, (Select id, Product__r.Vehicle_Model__c ,Product__r.Is_Prelaunch__c from Product_Interests__r  limit 1) from Lead WHERE Status != 'Qualified' and Status != 'Closed - Not Converted' and Status != 'Unqualified' and owner.id =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 50000])
        {
            if(ld.Product_Interests__r.size() > 0)
                LeadList.add(ld);
        }
        return LeadList;
    }
    
    
    public class opporrtunityWrapper {
        @AuraEnabled
        public Integer pageSize;
        @AuraEnabled
        public Integer pageNumber;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public Integer recordStart;
        @AuraEnabled
        public Integer recordEnd;
        @AuraEnabled
        public List<opportunity> opportunities;
        @AuraEnabled
        public List<Lead> Leads;
    }
    
     @AuraEnabled
    public static List<wrapperClass> searchForIds(String searchText, String objectType) {  
        
        String userName='';  String searchString = searchText+'%'; String rvpName='';Integer counter = 0;
        List<wrapperClass> wrprDatalist = new List<wrapperClass>();
        map<String, Integer> ownerNameWithOppCount = new map<String, Integer>();
        map<String, String> ownerNameWithRating = new map<String, String>();
        
        if(objectType == 'Enquiry') {
            
            for(Opportunity opp : [SELECT Id, owner.Name, owner.Id, Contact__r.Rating__c FROM opportunity WHERE owner.Name like: searchString ORDER BY owner.Name ASC LIMIT 49000]) {
               system.debug('OPP:'+opp);
                if(ownerNameWithOppCount.containsKey(opp.owner.Id)){
                    counter = ownerNameWithOppCount.get(opp.owner.Id);
                    counter = counter + 1;
                    ownerNameWithOppCount.put(opp.owner.Id, counter);
                    ownerNameWithRating.put(opp.owner.Id, opp.Contact__r.Rating__c);
                } else {
                    ownerNameWithOppCount.put(opp.owner.Id, 1);
                    ownerNameWithRating.put(opp.owner.Id, opp.Contact__r.Rating__c);
                }    
            }
        } else {
            for(Lead lead : [SELECT Id, Name, owner.Id, owner.Name,ConvertedContact.rating__c FROM Lead WHERE owner.Name like: searchString ORDER BY owner.Name ASC LIMIT 49000]) {
                if(ownerNameWithOppCount.containsKey(lead.ownerId)){
                    counter = ownerNameWithOppCount.get(lead.ownerId);
                    counter = counter + 1;
                    ownerNameWithOppCount.put(lead.ownerId, counter);
                    ownerNameWithRating.put(lead.ownerId, lead.ConvertedContact.rating__c);
                } else {
                    ownerNameWithOppCount.put(lead.ownerId, 1);
                    ownerNameWithRating.put(lead.ownerId, lead.ConvertedContact.rating__c);
                }    
            }
        }
        
        User user = [SELECT Id, Name, user.Contact.Name, Contact.User_Role_ACE__c FROM User WHERE Id =: UserInfo.getUserId()];
        for(User u:[Select id, UserRole.Name, Contact.User_Role_ACE__c, UserRole.Id, Name, FirstName, LastName, Profile.Name from user where IsPortalEnabled =: true AND IsActive =: true AND UserType =: 'PowerPartner' AND (FirstName like :searchString OR LastName like :searchString) ORDER BY Name ASC LIMIT 49000]) {
            if(user.Contact.User_Role_ACE__c != null && u.Contact.User_Role_ACE__c == user.Contact.User_Role_ACE__c && UserInfo.getUserId() != u.id) {
                wrapperClass wrprData = new wrapperClass();
                wrprData.lstUser = u;
                if(ownerNameWithOppCount.containskey(u.id)){
                    wrprData.opportunityCount = ownerNameWithOppCount.get(u.id);
                    wrprData.rating = ownerNameWithRating.get(u.id);
                } else {
                    wrprData.opportunityCount = 0;
                    wrprData.rating = ownerNameWithRating.get(u.id);
                }
                wrprDatalist.add(wrprData); 
            }
        }
        return wrprDatalist;
    }
   
    @AuraEnabled
    public static String changeOwnerMethod(Id oppid, String userName) {
        
        User user = new User();
        for(user usr : [select id,name, email, ContactId from User where name =: userName AND IsPortalEnabled =: true AND IsActive =: true AND UserType =: 'PowerPartner']) {
            user = usr;
        }
        try{
            if(oppid != null) {
                if(getObjectNameDynamic(oppid) == 'Opportunity'){
                    List<opportunity> updateOpp = new List<opportunity>();
                    opportunity l = [SELECT OwnerId, Sales_consultant_Contact_ACE__c FROM opportunity WHERE Id = :oppid];
                    if(l.Ownerid != user.Id){
                        Opportunity opp = new Opportunity();
                        opp = l;
                        opp.Ownerid = user.Id;
                        opp.Sales_consultant_Contact_ACE__c = user.ContactId;
                        updateOpp.add(opp);
                        
                    }
                    update updateOpp;
                    return 'SUCCESS';
                } else {
                    Lead l = [SELECT OwnerId FROM Lead WHERE Id = :oppid];
                    if(l.Ownerid != user.Id){
                        l.Ownerid = user.Id;
                    }
                    update l;
                    return 'SUCCESS';
                }
            }
        }catch(Exception ex) {
            return ex.getMessage();  
        }
        return null;
    }

    private static string getObjectNameDynamic(String Ids) {
        String keyCode  = Ids.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String objectName;
        for(Schema.SObjectType objectInstance : gd.values()) {
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode) { //do your processing with the API name what you want
                objectName =  objectInstance.getDescribe().getName();
            }
        }
        return objectName;
    }
    
    public class wrapperClass{
        @AuraEnabled 
        public User lstUser;
        @AuraEnabled 
        public Integer opportunityCount;
        @AuraEnabled 
        public String rating;
    }
}