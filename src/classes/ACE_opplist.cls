/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Opportunity Search,Change owner,show count of opportunity
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Ananya Acharya   <Ananya.Acharya@pwc.com>
* @modifiedBy     Ananya Acharya <Ananya.Acharya@pwc.com>
* @maintainedBy   Ananya Acharya   <Ananya.Acharya@pwc.com>
* @version        1.0
* @created        2019-12-02
* @modified       2019-12-02
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/



public without sharing class ACE_opplist {
    
    @AuraEnabled
    public static opporrtunityWrapper oppDataRtrv(Decimal pageNumber, Decimal pageSize, String modelType, Boolean launch) {
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        Integer offset = (pNumber - 1) * pSize;
        
        
        Integer recordEnd = pSize * pNumber;
        opporrtunityWrapper oppData =  new opporrtunityWrapper();  
        oppData.pageSize = pSize;
        oppData.pageNumber = pNumber;
        oppData.recordStart = offset + 1;
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        if(launch == true){
            /*[select Id, Name, StageName,Type,owner.id,(Select Product2.Vehicle_Model__c from OpportunityLineItems limit 1) from opportunity where owner.name=:UserInfo.getName() and StageName ='Enquiry' ORDER BY createdDate DESC LIMIT 50000]
             As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
			*/
		for(Opportunity opp : [select Id, Name, StageName,Type,owner.name,(Select Product2.Vehicle_Model__c,Product2.Is_Prelaunch__c from OpportunityLineItems WHERE Product2.Is_Prelaunch__c = true limit 1) from opportunity where  owner.id =:UserInfo.getUserId() ORDER BY createdDate DESC LIMIT 50000])
        {	if(opp.OpportunityLineItems.size() > 0)
                oppList.add(opp);
        }
        }
        else{
            /*[select Id, Name, StageName,Type,owner.id,owner.name,(Select Product2.Vehicle_Model__c from OpportunityLineItems limit 1) from opportunity where Sales_consultant_Contact_ACE__c =null and StageName ='Enquiry' ORDER BY createdDate DESC LIMIT 50000])
              As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
			*/
            for(Opportunity opp : [select Id, Name, StageName,Type,owner.name,(Select Product2.Vehicle_Model__c,Product2.Is_Prelaunch__c from OpportunityLineItems WHERE Product2.Is_Prelaunch__c = false limit 1) from opportunity where  owner.id =: UserInfo.getUserId() ORDER BY createdDate DESC LIMIT 50000])
        {	if(opp.OpportunityLineItems.size() > 0)
                oppList.add(opp);
        }
        }
        	
        oppData.opportunities = oppList;
        oppData.totalRecords = oppList.size();
        oppData.recordEnd = oppData.totalRecords >= recordEnd ? recordEnd : oppData.totalRecords;
        return oppData;
    }
    
    @AuraEnabled
    public static opporrtunityWrapper leadDataRtrv(Decimal pageNumber, Decimal pageSize, String modelType, Boolean launch) {
        
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        Integer offset = (pNumber - 1) * pSize;
        
        Integer recordEnd = pSize * pNumber;
        opporrtunityWrapper oppData =  new opporrtunityWrapper();  
        oppData.pageSize = pSize;
        oppData.pageNumber = pNumber;
        oppData.recordStart = offset + 1;
        
        
        List<Lead> LeadList = new List<Lead>();
        if(launch){
            /*[select Id, Name, (Select id, Product__r.Model__c from Product_Interests__r WHERE Product__r.Model__c = :modelType AND Product__r.Is_Prelaunch__c = true limit 1 ) from Lead WHERE Status = 'New' ORDER BY CreatedDate DESC LIMIT 50000]
             As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
			*/
           for(Lead ld : [select Id, Name, (Select id, Product__r.Vehicle_Model__c from Product_Interests__r WHERE Product__r.Is_Prelaunch__c = true limit 1 ) from Lead WHERE Status = 'New' AND  owner.id =: UserInfo.getUserId()  ORDER BY CreatedDate DESC LIMIT 50000])
        {
            if(ld.Product_Interests__r.size() > 0)
            	LeadList.add(ld);
        }
        }
        else{
            /*[select Id, Name, (Select id, Product__r.Vehicle_Model__c from Product_Interests__r WHERE Product__r.Vehicle_Model__c = :modelType AND Product__r.Is_Prelaunch__c = false limit 1 ) from Lead WHERE Status = 'New'  ORDER BY CreatedDate DESC LIMIT 5000]
            [select Id, Name, (Select id, Product__r.Model__c from Product_Interests__r WHERE Product__r.Model__c = :modelType AND Product__r.Is_Prelaunch__c = false limit 1 ) from Lead WHERE Status = 'New' ORDER BY CreatedDate DESC LIMIT 50000] 
			As discussed with prerna in order to achieve filter functionality --Tested and commented by ST
			*/
            for(Lead ld : [select Id, Name, (Select id, Product__r.Vehicle_Model__c from Product_Interests__r WHERE Product__r.Is_Prelaunch__c = false limit 1 ) from Lead WHERE Status = 'New' AND  owner.id =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 5000])
        {
            if(ld.Product_Interests__r.size() > 0)
            	LeadList.add(ld);
        }
        }
        
        oppData.Leads = LeadList;  
        oppData.totalRecords = LeadList.size();
        oppData.recordEnd = LeadList.size() >= recordEnd ? recordEnd : LeadList.size();
        return oppData;
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
    public static List<wrapperClass> searchForIds(String searchText) {        
        String userName='';
        String searchString = searchText+'%';
        String rvpName='';
        List<wrapperClass> wrprDatalist = new List<wrapperClass>();
        map<String, Integer> ownerNameWithOppCount = new map<String, Integer>();
         map<String, String> ownerNameWithRating = new map<String, String>();
        Integer counter = 0;
        for(Opportunity opp : [SELECT Id, owner.Name, owner.Id, Contact__r.Rating__c FROM opportunity WHERE owner.Name like: searchString ORDER BY owner.Name ASC limit 10]) {
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
        User user = [SELECT Id, Contact.User_Role_ACE__c FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('----------current user---'+user.Contact.User_Role_ACE__c);
        for(User u:[Select id, UserRole.Name, Contact.User_Role_ACE__c, UserRole.Id, Name, FirstName, LastName, Profile.Name from user where (FirstName like :searchString OR LastName like :searchString) ORDER BY Name ASC Limit 10 ])
        {
            system.debug('----------all user---'+u);
            system.debug(u.Contact.User_Role_ACE__c +'=='+ user.Contact.User_Role_ACE__c);
            if(user.Contact.User_Role_ACE__c != null && u.Contact.User_Role_ACE__c == user.Contact.User_Role_ACE__c) {
                wrapperClass wrprData = new wrapperClass();
                wrprData.lstUser = u;
                
                if(ownerNameWithOppCount.containskey(u.id)){
                    //wrprData.opportunityCount = ownerNameWithOppCount.get(u.name);
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
        for(user usr : [select id,name, email, ContactId from User where name =: userName]) {
            //if (UserInfo.getUserType() == 'PowerPartner'){
                user = usr;
            //}
        }
        
        //Contact c = [select id,firstName, lastName from contact where email =: user.Email];
        system.debug('contact details==>'+user.ContactId);
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