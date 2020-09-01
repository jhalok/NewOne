@isTest
public class ACE_LeadServiceTest {
    @testSetup
    public static void createProducts(){
        List<Product2> products = new List<Product2>();
        products.add(new product2(Name='XUV500'));
        products.add(new product2(Name='XUV300'));
        products.add(new product2(Name='Scorpio'));
        Insert products;
    }
    public static Map<String, String> getSourceSubsourceMap(){
        Map<String, String> sourceSubsourceMap = new Map<String, String>();
        sourceSubsourceMap.put('Advertisement==Cardekho', 'CC1');
        sourceSubsourceMap.put('Advertisement==Carwale', 'CC1');
        sourceSubsourceMap.put('Advertisement==SyouV.com', 'CC2');
        sourceSubsourceMap.put('S3==SS3', 'CC3');
        return sourceSubsourceMap;
    }
    public static ACE_ServiceUtil.leadsPush getLeadPushInstance(String leadName, String leadNumber, String city, String email, String state, String source, String subsource, String groupCode, String model, String partnerAccountId){
        ACE_ServiceUtil.leadsPush ldpush = new ACE_ServiceUtil.leadsPush();
        ldpush.leadName = leadName ;
        ldpush.leadNumber = leadNumber ;
        ldpush.city = city ;
        ldpush.email = email ;
        ldpush.state = state ;
        ldpush.source = source ;
        ldpush.subsource = subsource ;
        ldpush.groupCode = groupCode ;
        ldpush.model = model ;
        ldpush.partnerAccountId = partnerAccountId ;
        return ldpush;
    }
    public static testMethod void testNormalLead(){
        
        List<ACE_ServiceUtil.leadsPush> lds = new List<ACE_ServiceUtil.leadsPush>();
        lds.add(getLeadPushInstance('BM', '1234567890','','','', 'Advertisement', 'Cardekho','','XUV500',''));
        lds.add(getLeadPushInstance('BM', '1111111111','','','', 'Advertisement', 'Cardekho','','XUV300',''));                
        ACE_LeadService.processLeads(lds);
        List<String> queryParameters = new List<String>{'1234567890==CC1', '1111111111==CC1'};
        Map<String, Integer> leadAssertMap = new Map<String,Integer>();
        
        leadAssertMap.put('1234567890==CC1', 1);
        leadAssertMap.put('1234567890==CC1==XUV500', 1);
        leadAssertMap.put('1234567890==CC1==XUV500==Advertisement==Cardekho', 1);
        leadAssertMap.put('1111111111==CC1', 1);
        leadAssertMap.put('1111111111==CC1==XUV300', 1);
        leadAssertMap.put('1111111111==CC1==XUV300==Advertisement==Cardekho', 1);        
		        
        List<Lead> leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	processRecords(leads, leadAssertMap);
        //===================================================================================================================
        lds = new List<ACE_ServiceUtil.leadsPush>();
        lds.add(getLeadPushInstance('BM', '1234567890','Jaipur','bm@gmail.com','', 'Advertisement', 'Cardekho','','Scorpio',''));
        lds.add(getLeadPushInstance('BM', '1111111111','','','', 'Advertisement', 'Cardekho','','Scorpio',''));
        ACE_LeadService.processLeads(lds);
        leadAssertMap.put('1234567890==CC1==Scorpio', 1);
        leadAssertMap.put('1234567890==CC1==Scorpio==Advertisement==Cardekho', 1);
        leadAssertMap.put('1111111111==CC1==Scorpio', 1);
        leadAssertMap.put('1111111111==CC1==Scorpio==Advertisement==Cardekho', 1);
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	processRecords(leads, leadAssertMap);
        //===================================================================================================================
        lds = new List<ACE_ServiceUtil.leadsPush>();
        lds.add(getLeadPushInstance('BM', '1234567890','','','', 'Advertisement', 'Carwale','','Scorpio',''));
        lds.add(getLeadPushInstance('BM', '1111111111','','','', 'Advertisement', 'Carwale','','Scorpio',''));
        ACE_LeadService.processLeads(lds);        
        leadAssertMap.put('1234567890==CC1==Scorpio==Advertisement==Carwale', 1);        
        leadAssertMap.put('1111111111==CC1==Scorpio==Advertisement==Carwale', 1);
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	processRecords(leads, leadAssertMap);
        //===================================================================================================
        lds = new List<ACE_ServiceUtil.leadsPush>();
        lds.add(getLeadPushInstance('BM', '1234567890','','','', 'Advertisement', 'SyouV.com','','Scorpio',''));
        lds.add(getLeadPushInstance('BM', '1111111111','','','', 'Advertisement', 'SyouV.com','','Scorpio',''));
        ACE_LeadService.processLeads(lds);        
        leadAssertMap.put('1234567890==CC2', 1);
        leadAssertMap.put('1234567890==CC2==Scorpio', 1);
        leadAssertMap.put('1234567890==CC2==Scorpio==Advertisement==SyouV.com', 1);
        leadAssertMap.put('1111111111==CC2', 1);
        leadAssertMap.put('1111111111==CC2==Scorpio', 1);
        leadAssertMap.put('1111111111==CC2==Scorpio==Advertisement==SyouV.com', 1);
        
        queryParameters.add('1234567890==CC2');
        queryParameters.add('1111111111==CC2');
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	processRecords(leads, leadAssertMap);
    }
    public static void processRecords(List<Lead> leads, Map<String, Integer> leadAssertMap){
        //system.debug(leads);
        Map<String, List<Lead>> insertedLeadMap = new Map<String, List<Lead>>();
        Map<String, List<ACE_Product_Interest__c>> insertedPIMap = new Map<String, List<ACE_Product_Interest__c>>();
        Map<String,List<ACE_Source_Tracker__c>> insertedProductMap = new Map<String,List<ACE_Source_Tracker__c>>();
        
        Set<Id> setOfPi =  new set<Id>();
        for(Lead ld : leads){
            String cnum = String.isEmpty(ld.MobilePhone) ? ld.phone : ld.MobilePhone;
            if(insertedLeadMap.containsKey(cnum+'=='+ld.Call_Center__c)){
                insertedLeadMap.get(cnum+'=='+ld.Call_Center__c).add(ld);                
            }else{
                insertedLeadMap.put(cnum+'=='+ld.Call_Center__c, new List<Lead>{ld});
            }
            for(ACE_Product_Interest__c PI : ld.Product_Interests__r){
                setOfPi.add(PI.id);
                if(insertedPIMap.containsKey(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name)){
                    insertedPIMap.get(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name).add(PI);
                }else{
                    insertedPIMap.put(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name, new List<ACE_Product_Interest__c>{PI});
                }
            }
        }
		list<ACE_Source_Tracker__c> listOfTracker = [Select id,ACE_Product_Interest__r.Lead__r.Call_Center__c , ACE_Product_Interest__r.Lead__r.mobilephone, ACE_Product_Interest__r.Lead__r.phone, ACE_Source__c, ACE_SubSource__c, ACE_Product_Interest__r.Product__r.Name from ACE_Source_Tracker__c where ACE_Product_Interest__c In: setOfPi];      
        for(ACE_Source_Tracker__c sT : listOfTracker){
            String cnum = String.isEmpty(sT.ACE_Product_Interest__r.Lead__r.mobilephone) ? sT.ACE_Product_Interest__r.Lead__r.phone : sT.ACE_Product_Interest__r.Lead__r.mobilephone;
            String mapKey = cnum+'=='+sT.ACE_Product_Interest__r.Lead__r.Call_Center__c+'=='+sT.ACE_Product_Interest__r.Product__r.Name+'=='+sT.ACE_Source__c+'=='+sT.ACE_SubSource__c;
            if(insertedProductMap.containsKey(mapKey)){
                insertedProductMap.get(mapKey).add(sT);
            }else{
                insertedProductMap.put(mapKey, new List<ACE_Source_Tracker__c>{sT});
            }
        }
        //system.debug(insertedLeadMap.values());
        for(String leadstr : insertedLeadMap.keySet()){
            system.assertEquals(leadAssertMap.containsKey(leadstr), true);
            system.assertEquals(leadAssertMap.get(leadstr), insertedLeadMap.get(leadstr).size());
        }
        //system.debug(insertedPIMap.values());
        for(String intProStr : insertedPIMap.keySet()){            
            system.assertEquals(leadAssertMap.containsKey(intProStr), true);
            system.assertEquals(leadAssertMap.get(intProStr), insertedPIMap.get(intProStr).size());
        }
        //system.debug(insertedProductMap.values());
        for(String sourceTStr : insertedProductMap.keySet()){
            system.assertEquals(leadAssertMap.containsKey(sourceTStr), true);
            system.assertEquals(leadAssertMap.get(sourceTStr), insertedProductMap.get(sourceTStr).size());
        }
        for(String skey: leadAssertMap.keySet()){
            //system.debug(skey);
            Boolean checkFlag = true;
            if(skey.countMatches('==') == 1 && insertedLeadMap.containsKey(skey)){
                checkFlag = false;
            }else if(skey.countMatches('==') == 2 && insertedPIMap.containsKey(skey)){
                checkFlag = false;
            }else if(skey.countMatches('==') == 4 && insertedProductMap.containsKey(skey)){
                checkFlag = false;
            }
            if(checkFlag){
            	system.assertEquals(true, false);
            }
        }
    }
    
}