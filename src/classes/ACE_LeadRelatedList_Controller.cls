public class ACE_LeadRelatedList_Controller {
   
    @AuraEnabled
    public static Lead SaveLead(String contactId, String prodData){
        //System.debug('productList-->'+productList);
        List<prodWrapper> prodDataList = (List<prodWrapper>) JSON.deserialize(prodData, List<prodWrapper>.class);
        Contact con = [SELECT Id, LastName, Email, MobilePhone FROM Contact Where Id=:contactId ];
        
        Lead ld = new Lead();
        ld.Related_Contact__c = contactId;
        ld.Email = con.Email;
        ld.LastName =  con.LastName;
        ld.MobilePhone = con.MobilePhone;
         ld.Company='Person';
        ld.Status='Open - Not Contacted';
        database.insert(ld);
      //  insert ld;

      List<ACE_Product_Interest__c> prodIntList = new List<ACE_Product_Interest__c>();
        for(prodWrapper prod : prodDataList){
            ACE_Product_Interest__c proInt = new ACE_Product_Interest__c();
            proInt.Contact__c = ld.Related_Contact__c;
            proInt.Product__c = prod.value;
            proInt.Lead__c = ld.Id;
            proInt.Name = prod.label;

            prodIntList.add(proInt);

        }
        
        insert prodIntList;
        return ld;  
    }
    
    @AuraEnabled
    public static void Saveproduct(String contactId){
       /* Lead ld = new Lead();
        ld = SaveLead(contactId);
        
        
        System.debug('PRODUCT LIST' + contactId);
        ACE_Product_Interest__c pro = new ACE_Product_Interest__c();
        pro.Contact__c = ld.Related_Contact__c;
        pro.Product__c = contactId;
        pro.Lead__c = ld.Id;
        pro.Name = contactId;
        
        
        System.debug('cGebjdsjkande'+ pro);
        database.insert(pro);
        
        //  insert ld;
        return ld;
        */
    }

    public class prodWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }

}