public class ACE_AddOtherInterests_Controller {
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
    public static String SaveCompetitors(List<Competitors_Considered__c> competitorsList){
     try{
          insert competitorsList;
           return null;
     }
     catch(Exception e){
      return   e.getMessage();
     }
    }
    @AuraEnabled
    public static String dataUpdateForComp(Competitors_Considered__c Competitors){
     try{
          update Competitors;
           return null;
     }
     catch(Exception e){
      return   e.getMessage();
     }
    }
     @AuraEnabled
    public static allCompetitorDataWrapper  getAllCompetitorsList(String LeadId){
     allCompetitorDataWrapper   allCompetitorData  = new allCompetitorDataWrapper();
     try{
          List<Competitor_Model_Data__mdt> allMakes =  [select id,Make__c,Label from Competitor_Model_Data__mdt];
        Set<string> allMokeSet = new Set<String>();
        Map<String,List<string>> allModels  = new  Map<String,List<string>>();
        for(Competitor_Model_Data__mdt mak :allMakes){
            allMokeSet.add(mak.Make__c);
        }
           for(String make : allMokeSet){
               List<String> allModelsMakeWise = new List<String>();
               for(Competitor_Model_Data__mdt mak :allMakes){
                   if(mak.Make__c == make){
                       allModelsMakeWise.add(mak.Label);
                   }
               }
               allModels.put(make,allModelsMakeWise);
           }
            List<String> allMakeList = new List<String>();
            allMakeList.addAll(allMokeSet);
        allCompetitorData.allMakes = allMakeList;
        
         List<allCompetitorsWrapper> allCompetitorsWithModel = new List<allCompetitorsWrapper>();
          for(Competitors_Considered__c Competitor :[select id,Make__c,Model__c from Competitors_Considered__c where Lead__c =:LeadId]){
             
              allCompetitorsWithModel.add(new allCompetitorsWrapper(Competitor,allModels.get(Competitor.Make__c)));
          }
           allCompetitorData.allExistingCompetitors = allCompetitorsWithModel;
        Competitors_Considered__c wrapCompetitorsIn = new Competitors_Considered__c();
         List<allCompetitorsWrapper> newComp = new List<allCompetitorsWrapper>();
         allCompetitorsWrapper singalCompet = new allCompetitorsWrapper(wrapCompetitorsIn, new List<string>());
         newComp.add(singalCompet);
          allCompetitorData.allNewCompetitors = newComp;
           return allCompetitorData;
     }
     catch(Exception e){
      return   new allCompetitorDataWrapper();
     }
    }

   
    @AuraEnabled
    public static List<String> getAllModel(String make){
        List<Competitor_Model_Data__mdt> allModal =  [select id,Make__c,Label from Competitor_Model_Data__mdt where Make__c=:make];
        List<string> allModel = new List<String>();
        for(Competitor_Model_Data__mdt modal :allModal){
            allModel.add(modal.Label);
        }
        System.debug(allModel);
        return allModel;
    }
    public class prodWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    public class allCompetitorDataWrapper {
        @AuraEnabled
        public List<allCompetitorsWrapper> allNewCompetitors;
        @AuraEnabled
        public  List<allCompetitorsWrapper> allExistingCompetitors;
         @AuraEnabled
        public  List<String> allMakes;
    }
    public class allCompetitorsWrapper {
        @AuraEnabled
        public  Competitors_Considered__c Competitor;
        @AuraEnabled
        public List<String> allModels;
      public   allCompetitorsWrapper(Competitors_Considered__c com,  List<String> mod){
            this.Competitor = com;
            this.allModels = mod;
        }
    }
    


}