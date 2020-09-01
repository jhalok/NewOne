public class ACE_AccountSearch {
    @AuraEnabled
    public static List <objectWrapper> fetchRecords (String searchText, List<String> searchObject, String searchOptVal)  {
        List<String> AllSearchedAccounts = new List<String>();
        
        User u = [select id,Name,CallCenterId,UserRoleId from User where id =: userInfo.getUserId()];
        CallCenter callCenter = [select id,Name  from CallCenter where id =: u.CallCenterId];
        
        String ldquery = '';
        String query = 'SELECT Id, Name,';
        
        if(searchOptVal == 'email'){
            query += ' URL__c, Email, MobilePhone from '+searchObject[0] +' where Email =\''+searchText+'\'';
            
            ldquery = 'SELECT Id, Name, Email,Related_Contact__c, MobilePhone, URL__c from '+searchObject[1];
            ldquery += ' where Email =\''+searchText+'\' AND Call_Center__c = \''+callCenter.Name+'\'';
            
        }else if(searchOptVal == 'mobile') {
            query += ' URL__c, Email, MobilePhone from '+searchObject[0] + ' where MobilePhone =\''+searchText+'\'';
            
            ldquery = 'SELECT Id, Name, Email,Related_Contact__c, MobilePhone, URL__c from '+searchObject[1];
            ldquery += ' where MobilePhone =\''+searchText+'\'';
        }
        
        else if(searchOptVal == 'customerId'){
            query += ' URL__c, Email, MobilePhone from '+searchObject[0] +' where ACE_Customer_Id_Formula__c =\''+searchText+'\'';
        }
        else if(searchOptVal == 'chasisno'){
            query += ' ContactId, Contact.Name, Contact.URL__c from '+searchObject[0] +' where Chassis_Number__c =\''+searchText+'\'';
        }
        else if(searchOptVal == 'vehicleno'){
            query += 'ContactId, Contact.Name, Contact.URL__c from '+searchObject[0] +' where Registration_Number__c =\''+searchText+'\'';
        }
        else if(searchOptVal == 'roid'){
            query += 'Contact__r.Name, Contact__r.URL__c from '+searchObject[0] +' where Name=\''+searchText+'\'';
        }
        
        List<SObject> queriedRecs = new List<SObject>();
        queriedRecs.addAll((List<sObject>)Database.query(query));
        
        List<String> emailConList = new List<String>();
        List<String> phoneConList = new List<String>();
        
        if(searchObject[0] == 'Contact'){
            for(SObject rec : queriedRecs){
                if((String)rec.get('Email') != null && searchOptVal == 'email')
                    emailConList.add((String)rec.get('Email'));
                if((String)rec.get('MobilePhone') != null && searchOptVal == 'mobile')
                    phoneConList.add((String)rec.get('MobilePhone'));
            }
        }
        
        
        List<SObject> queriedLeadRecs = new List<SObject>();
        
        if(ldquery != ''){
            queriedLeadRecs.addAll((List<sObject>)Database.query(ldquery));
            
            if(!queriedLeadRecs.isEmpty()){
                for(SObject rec : queriedLeadRecs){
                    if(!emailConList.contains((String)rec.get('Email')) && !phoneConList.contains((String)rec.get('MobilePhone'))){
                        //queriedLeadRecs.remove(rec);
                        queriedRecs.add(rec);
                    }
                }
            }
        }
        List<objectWrapper> allContact = new List<objectWrapper>();
        
        for(SObject rec : (List<sObject>)Database.query(query)){
            String sObjName = rec.Id.getSObjectType().getDescribe().getName();
            if(sObjName == 'Contact'  ){
                objectWrapper wrapperInst = new objectWrapper();
                Contact con = (Contact)rec;
                wrapperInst.Id = con.id;
                wrapperInst.Name = con.Name;
                wrapperInst.URL = con.URL__c;
                allContact.add( wrapperInst);
            }
            else if(sObjName == 'Lead'){
                objectWrapper wrapperInst = new objectWrapper();
                Lead leadInst = (Lead)rec;
                wrapperInst.Id = leadInst.Related_Contact__c;
                wrapperInst.Name = leadInst.Related_Contact__r.Name;
                wrapperInst.URL = leadInst.Related_Contact__r.URL__c;
                allContact.add( wrapperInst);
                
            }
            else if(sObjName == 'Asset'){
                objectWrapper wrapperInst = new objectWrapper();
                Asset assetInst = (Asset)rec;
                wrapperInst.Id = assetInst.ContactId;
                wrapperInst.Name = assetInst.Contact.Name;
                 wrapperInst.URL = assetInst.Contact.URL__c;
                allContact.add( wrapperInst);
            }
            else if(sObjName == 'ACE_Repair_Order__c'){
                objectWrapper wrapperInst = new objectWrapper();
                ACE_Repair_Order__c repObjInst = (ACE_Repair_Order__c)rec;
                wrapperInst.Id = repObjInst.Contact__c;
                wrapperInst.Name = repObjInst.Contact__r.Name;
                wrapperInst.URL = repObjInst.Contact__r.URL__c;
                allContact.add( wrapperInst);
            }
        }
        system.debug(queriedRecs);
        return allContact;
        //[select id,Name, URL__c from Account Where Id IN:AllSearchedAccounts];
    }
    @AuraEnabled
    public static void updateLeadContact(String  leadId,String contactId){
        
        Lead leadForUpdate = [select id,Name,Related_Contact__c From Lead where Id =: leadId];
        system.debug([select id,Name from contact where id=:contactId]);
        leadForUpdate.Related_Contact__c = contactId;
       List<Asset> listpurchased = [SELECT Id, Name, Chassis_Number__c,Product2Id, Registration_Number__c, Engine_Number__c, Key_Number__c, 
        Registration_Date__c, ContactId FROM Asset where ContactId =: contactId  ];

        List<ACE_Existing_Vehicle__c> ExistingVehiclesForInsert = new list<ACE_Existing_Vehicle__c>();
            for(Asset purcheased:listpurchased){
                ACE_Existing_Vehicle__c newExdata = new ACE_Existing_Vehicle__c();
                newExdata.ACE_Make__c = 'Mahindra';
                newExdata.ACE_Model__c = purcheased.Name;
                newExdata.ACE_Is_Exchange_Vehicle__c = false;
                 newExdata.ACE_Lead__c = leadForUpdate.id;
                ExistingVehiclesForInsert.add(newExdata);
            }
        try{
            insert ExistingVehiclesForInsert;
            System.debug(ExistingVehiclesForInsert);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }

        
        update leadForUpdate;
    }
      @AuraEnabled
    public static lead getLeadData(String Id ){
        return [SELECT City, FirstName, LastName, Id, Email FROM Lead where id=: Id];
    }
    public class objectWrapper{
        @AuraEnabled
        public  String Name;
        @AuraEnabled
        public  String Id;
        @AuraEnabled
        public  String URL;
    }
    
    //Added by Sanchayan
    public class SObjectResult {
        @AuraEnabled
        public String objName;
        @AuraEnabled
        public String altFlag;
        @AuraEnabled
        public List<objectWrapper> soList;
        
        public SObJectResult(String objNameTemp, List<objectWrapper> soLisTemp,String altFlagTmp/*,String fieldNameTemp*/) {
            objName = objNameTemp;
            soList = soLisTemp;
            altFlag = altFlagTmp;
            //fieldName = fieldNameTemp;
        }
    }
    
    @AuraEnabled
    public static List<SObjectResult> fetchLeadAndContactRecords (String searchText, List<String> searchObject,String searchOptVal, String altSrch) 
    {
        system.debug('fetchLeadAndContactRecords#############################');
        List<SObjectResult> sObjList=fetchLeadsAndContactsHelper(searchText, searchObject, searchOptVal,'N');
        if(sObjList==null||sObjList.size()<=0){
            searchOptVal='email';
            searchText=altSrch;
            sObjList=fetchLeadsAndContactsHelper(searchText, searchObject, searchOptVal,'Y');
        }
        return sObjList;
    }
    
    private static List<SObjectResult> fetchLeadsAndContactsHelper(String searchText, List<String> searchObject,String searchOptVal,String altFlag)
    {
        List<SObjectResult> sObjList=new List<SObjectResult>();
        List<objectWrapper> allContact= fetchRecords(searchText, searchObject, searchOptVal);
        String ldquery = '';
        if(searchOptVal == 'email'){            
            ldquery = 'SELECT Id, Name, Email,Related_Contact__c, MobilePhone, URL__c from '+searchObject[1];
            ldquery += ' where Email =\''+searchText+'\'';
        }
        else if(searchOptVal == 'mobile') {
            ldquery = 'SELECT Id, Name, Email,Related_Contact__c, MobilePhone, URL__c from '+searchObject[1];
            ldquery += ' where MobilePhone =\''+searchText+'\'';
        }
        List<SObject> queriedLeadRecs = new List<SObject>();
        List<objectWrapper> allLeads=new List<objectWrapper>();
        if(ldquery != ''){
            queriedLeadRecs.addAll((List<sObject>)Database.query(ldquery));
            system.debug('queriedLeadRecs---->'+queriedLeadRecs);
            for(SObject rec : queriedLeadRecs){
                String sObjName = rec.Id.getSObjectType().getDescribe().getName();
                if(sObjName == 'Lead'){
                    objectWrapper wrapperInst = new objectWrapper();
                    Lead leadInst = (Lead)rec;
                    wrapperInst.Id = leadInst.Id;
                    wrapperInst.Name = leadInst.Name;
                    allLeads.add( wrapperInst);
                }
            }
        }
        if(allContact!=null && !allContact.isEmpty()){
            sObjList.add( new SObjectResult('Contact',allContact,altFlag));
        }
        if(!allLeads.isEmpty()){
            sObjList.add( new SObjectResult('Lead',allLeads,altFlag));
        }
        system.debug('sObjList size---->'+sObjList.size());
        return sObjList;
    }
}