public class ACE_ExistingVehicles {
    
    @AuraEnabled
    public static Lead saveExistingRecord(List<ACE_Existing_Vehicle__c> allrecords){
        for(ACE_Existing_Vehicle__c vehRecs : allrecords){
            vehRecs.Name = vehRecs.ACE_Model__c;
        }
        system.debug(allrecords);
        insert allrecords;
        return null;
    }
    @AuraEnabled
    public static Lead getLeadRecord(String Id){
        return [select Name,MobilePhone,City ,Salutation From Lead Where Id=:Id];
    } 
    @AuraEnabled
    public static List<ACE_Existing_Vehicle__c> getExistingVehicle(String Id){
        return [SELECT Enquiry__c, ACE_Lead__c, ACE_Vehicle_Usage__c, ACE_Registration_Number__c, ACE_Registered_Year__c, ACE_Registered_Month__c, ACE_Model__c, ACE_Make__c, ACE_KMs_Reading__c, ACE_Is_Exchange_Vehicle__c, Id, Name FROM ACE_Existing_Vehicle__c  Where ACE_Lead__c=:Id];
    }
    
    @AuraEnabled
    public static void deleteExistingVehicle(String vehicleId){
        
        delete [select Id from ACE_Existing_Vehicle__c where Id=:vehicleId];
        
    }
    //New Addition
    @AuraEnabled
    public static allCompetitorDataWrapper  getAllCompetitorsList(String LeadId){
        System.debug('=LeadId='+LeadId);
        allCompetitorDataWrapper   allCompetitorData  = new allCompetitorDataWrapper();
        try{
            List<Competitor_Model_Data__mdt> allMakes =  [select id,Make__c,Label from Competitor_Model_Data__mdt];
            Set<string> allMokeSet = new Set<String>();
            Map<String,List<string>> allModels  = new  Map<String,List<string>>();
            for(Competitor_Model_Data__mdt mak :allMakes){
                allMokeSet.add(mak.Make__c);
            }
            System.debug('=allMokeSet='+allMokeSet);
            for(String make : allMokeSet){
                List<String> allModelsMakeWise = new List<String>();
                for(Competitor_Model_Data__mdt mak :allMakes){
                    if(mak.Make__c == make){
                        allModelsMakeWise.add(mak.Label);
                    }
                }
                allModels.put(make,allModelsMakeWise);
            }
            System.debug('=allModels='+allModels);
            List<String> allMakeList = new List<String>();
            allMakeList.addAll(allMokeSet);
            allCompetitorData.allMakes = allMakeList;
            System.debug('=allCompetitorData='+allCompetitorData);
            List<allCompetitorsWrapper> allCompetitorsWithModel = new List<allCompetitorsWrapper>();
            for(Competitors_Considered__c Competitor :[select id,Make__c,Model__c from Competitors_Considered__c where Lead__c =:LeadId]){
                
                allCompetitorsWithModel.add(new allCompetitorsWrapper(Competitor,allModels.get(Competitor.Make__c)));
            }
            allCompetitorData.allExistingCompetitors = allCompetitorsWithModel;
            System.debug('=allCompetitorData='+allCompetitorData);
            
            List<allCompetitorsWrapper> allNewCompet = new List<allCompetitorsWrapper>();
            Competitors_Considered__c  Competitor = new Competitors_Considered__c();
            Competitor.Make__c = '';
            Competitor.Model__c = '';
            //Competitor.Lead__c = '';
            Competitor.Lead__c = null;
            allNewCompet.add(new allCompetitorsWrapper(Competitor,new List<String>()));
            System.debug('=allNewCompet='+allNewCompet);
            allCompetitorData.allNewCompetitors = allNewCompet;
            system.debug('dfjhskjfh');
            system.debug('=allCompetitorData='+allCompetitorData);
            
            return allCompetitorData;
        }
        catch(Exception e){
            return   new allCompetitorDataWrapper();
        }
    }
    @AuraEnabled
    public static string dataUpdate(ACE_Existing_Vehicle__c dataUpdate){
        
        System.debug('dataUpdate-->'+dataUpdate);
        try{
            dataUpdate.Name = dataUpdate.ACE_Model__c;
            update dataUpdate;
            return null;
        }
        catch(Exception e){
            return e.getMessage();
        }
        
       
    }
    @AuraEnabled
    public static Map<String,List<String>> makeModelMap(){
        
        List<Competitor_Model_Data__mdt> allMakes =  [select id,Make__c,Label from Competitor_Model_Data__mdt];
            Set<string> allMokeSet = new Set<String>();
            Map<String,List<string>> allModels  = new  Map<String,List<string>>();
            for(Competitor_Model_Data__mdt mak :allMakes){
                allMokeSet.add(mak.Make__c);
            }
            System.debug('=allMokeSet='+allMokeSet);
            for(String make : allMokeSet){
                List<String> allModelsMakeWise = new List<String>();
                for(Competitor_Model_Data__mdt mak :allMakes){
                    if(mak.Make__c == make){
                        allModelsMakeWise.add(mak.Label);
                    }
                }
                allModels.put(make,allModelsMakeWise);
            }
            System.debug('=allModels='+allModels);
        	return allModels;
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