public class ACE_ObjectAuraController {
    @AuraEnabled
    public static String saveLeads(String ListLead) {
        
        List<ACE_ObjectAuraController.LeadWrapper> leadAndthereInterests = (List<ACE_ObjectAuraController.LeadWrapper>)JSON.deserialize(ListLead, List<ACE_ObjectAuraController.LeadWrapper>.class);
        Map<String,ACE_ObjectAuraController.LeadWrapper>  NewLeadMap = new Map<String,ACE_ObjectAuraController.LeadWrapper>();
        List<lead> allNewLeads = new List<lead>();
       String contactId = '';
        for(ACE_ObjectAuraController.LeadWrapper ld : leadAndthereInterests){
          if(ld.newLead.MobilePhone != ''){
                 NewLeadMap.put(ld.newLead.MobilePhone,ld);
                 contactId = ld.newLead.Referred_By__c; 
                 system.debug(contactId); 
            }
        }
        system.debug(NewLeadMap);
       // insert allNewLeads;
      

        

        Id userId = UserInfo.getUserId(); 
        User curUser = [SELECT Id, Name, City, CallCenterId FROM User where ID =:userId];
        CallCenter callCenter = [SELECT Name, Id, InternalName FROM CallCenter where ID=:curUser.CallCenterId ];

        List<Lead> existingLeads = [SELECT Id, LastName, FirstName, MobilePhone, Call_Center__c FROM Lead where MobilePhone IN:NewLeadMap.keySet() ];
        system.debug(existingLeads);
        List<lead> leadForInsert = new List<Lead>();
        List<String> mobileNumber = new List<String>();

       for(Lead ld : existingLeads){
           if(ld.MobilePhone != ''){
               mobileNumber.add(ld.MobilePhone);
           }
       }
        for(String mobile:NewLeadMap.keySet()){
            if(!mobileNumber.contains(mobile)){
                Lead newLeadInst = NewLeadMap.get(mobile).newLead;
                newLeadInst.Call_Center__c = callCenter.Name;
                 leadForInsert.add(newLeadInst);
                
            }
        }
        if(leadForInsert.size() > 0){
            insert leadForInsert;
        }
        system.debug(leadForInsert);

        List<ACE_Product_Interest__c> allProductFroInsert = new  List<ACE_Product_Interest__c>();
        List<ACE_Source_Tracker__c> allTracker = new List<ACE_Source_Tracker__c>();
        for(lead ld:leadForInsert){
            for(ACE_Product_Interest__c inter: NewLeadMap.get(ld.MobilePhone).allInterest){
                inter.Lead__c = ld.Id;
                allProductFroInsert.add(inter);
            }
        }
         List<String> allProducts = new List<String>();
            for(ACE_Product_Interest__c Interest :allProductFroInsert){
                   allProducts.add(Interest.Product__c) ;
            }
            List<product2> allProductFromObject = [select id,Name from Product2 Where Id IN: allProducts];
          for(product2 product :allProductFromObject){
              for(ACE_Product_Interest__c Interest :allProductFroInsert){
                  if(Interest.Product__c == product.id){
                      Interest.Name = product.Name;
                      Interest.Source__c = 'Employee Referral';
                  }
              }
          }
        if(allProductFroInsert.size() > 0){
            insert allProductFroInsert;
        }
        for(ACE_Product_Interest__c interest :allProductFroInsert){
                ACE_Source_Tracker__c tracker = new ACE_Source_Tracker__c();
                tracker.ACE_Product_Interest__c = interest.Id;
                tracker.ACE_Source__c  = interest.Source__c;
                tracker.ACE_SubSource__c  = 	interest.Subsource__c;
                 tracker.Lead__c = interest.Lead__c;
                allTracker.add(tracker);
            }
            if(allTracker.size() > 0){
            insert allTracker;
            }
        return null;
    }
    @AuraEnabled
    public static Contact getContactRecord(String Id) {
        return [select id, Name From Contact Where Id =: Id];
    }
    @AuraEnabled
    public static List < Lead > getExistingRecords(String Id) {
        return [select LastName, MobilePhone, Vehicle__c, Email, City__c, Next_FollowUp__c From Lead Where Referred_By__c =: Id];
    }

    @AuraEnabled
    public static String updateLeads(Lead LeadData) {
        try {
            update LeadData;
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }

    }
    public class LeadWrapper{
        @AuraEnabled
        public Lead newLead;
        @AuraEnabled
        public  List<ACE_Product_Interest__c> allInterest;
    }

}