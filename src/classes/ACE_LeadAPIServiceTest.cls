/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Lead, Product Interest, Source Tracker from third party/ CSV upload.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        27-Dec-2019
* @Last modified       
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* Made By: Amit Chaudhary
* Description: 04-Jan-2020 Pre-Launch Pre-Launch related test-cases added. 
*                 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ACE_LeadAPIServiceTest {
    
    @testSetup
    public static void createProducts(){
        List<Product2> products = new List<Product2>();
        products.add(new product2(Name='XUV500'));
        products.add(new product2(Name='XUV300'));
        products.add(new product2(Name='Scorpio'));
        products.add(new product2(Name='Mahindra Thar',Is_Prelaunch__c=true));
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
    public static ACE_ServiceUtil.leadDetail getLeadInstance(String leadName, String leadNumber, String city, String email, String state){
        ACE_ServiceUtil.leadDetail ldpush = new ACE_ServiceUtil.leadDetail();
        ldpush.leadData = new Lead();       
        ldpush.leadData.lastName = leadName ;
        ldpush.leadData.mobilePhone = leadNumber ;
        ldpush.leadData.city = city ;   
        ldpush.leadData.email = email ;
        ldpush.leadData.state = state ;
        return ldpush;
    }
    public static ACE_ServiceUtil.ReferLeadFromEmployeeDetail getReferLead(String salutaion, String contactName, Boolean ownMahindraVehicle, String businessUnit, String mobile){
        ACE_ServiceUtil.ReferLeadFromEmployeeDetail referDetailObj = new ACE_ServiceUtil.ReferLeadFromEmployeeDetail();
		referDetailObj.Salutation = salutaion;
        referDetailObj.Name = contactName;
        referDetailObj.contactNumber = mobile;
        referDetailObj.ownMahindraVehicle = ownMahindraVehicle;
        referDetailObj.businessUnit = businessUnit;
	 	return referDetailObj;
    }
    public static ACE_ServiceUtil.productInterestsDetail getProductInterestInstance(String model){
        ACE_ServiceUtil.productInterestsDetail proInterest = new ACE_ServiceUtil.productInterestsDetail();
        proInterest.productInterest = new ACE_Product_Interest__c(Name = model);
        return proInterest;
    }
    public static ACE_ServiceUtil.sourceTrackerDetail getSourceTrackerInstance(String source, String subsource){
        ACE_ServiceUtil.sourceTrackerDetail sourceTracker = new ACE_ServiceUtil.sourceTrackerDetail();
        sourceTracker.sourceTracker = new ACE_Source_Tracker__c(ACE_Source__c = source, ACE_SubSource__c = subsource);
        return sourceTracker;
    }
    public static testmethod void testPreLaunchLead(){
    	List<ACE_ServiceUtil.leadDetail> lds = new List<ACE_ServiceUtil.leadDetail>();
        Map<String, Integer> objRecordsCount;
        List<ACE_ServiceUtil.sourceTrackerDetail> sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        ACE_ServiceUtil.productInterestsDetail pIDetail = getProductInterestInstance('XUV500');
        pIDetail.relatedSourceTrackers = sTdetails;
        ACE_ServiceUtil.leadDetail ldDetail = getLeadInstance('BM', '2222222222','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        pIDetail = getProductInterestInstance('Mahindra Thar');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '3333333333','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};
        pIDetail = getProductInterestInstance('XUV500');
        sTdetails.add(getSourceTrackerInstance('Advertisement', 'SyouV.com'));
        pIDetail.relatedSourceTrackers = sTdetails;
        
        ldDetail.relatedProductInterests.add(pIDetail);
        lds.add(ldDetail);
        
        system.debug(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        List<String> queryParameters = new List<String>{'2222222222==CC1==Call Center', '3333333333==CC1==Pre-launch Lead','3333333333==CC2==Call Center', '3333333333==CC1==Call Center'};
        Map<String, Integer> leadAssertMap = new Map<String,Integer>(); 
        leadAssertMap.put('2222222222==CC1==Call Center', 1);
        leadAssertMap.put('2222222222==CC1==Call Center==XUV500', 1);
        leadAssertMap.put('2222222222==CC1==Call Center==XUV500==Advertisement==Cardekho', 1);
        leadAssertMap.put('3333333333==CC1==Call Center', 1);
        leadAssertMap.put('3333333333==CC1==Call Center==XUV500', 1);
        leadAssertMap.put('3333333333==CC1==Call Center==XUV500==Advertisement==Cardekho', 1); 
        leadAssertMap.put('3333333333==CC1==Pre-launch Lead', 1);
        leadAssertMap.put('3333333333==CC1==Pre-launch Lead==Mahindra Thar', 1);
        leadAssertMap.put('3333333333==CC1==Pre-launch Lead==Mahindra Thar==Advertisement==Cardekho', 1);
        leadAssertMap.put('3333333333==CC2==Call Center', 1);
        leadAssertMap.put('3333333333==CC2==Call Center==XUV500', 1);
        leadAssertMap.put('3333333333==CC2==Call Center==XUV500==Advertisement==SyouV.com', 1); 
        
        List<Lead> leads = [Select recordType.DeveloperName, Contact_Num_Call_Center__c, Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>4, 'Source Tracker'=>4};
            for(Lead ld : leads){
            	system.debug(ld.Name+'===='+ld.RecordType.developerName);            
            }
        processPrelaunchRecords(leads, leadAssertMap, objRecordsCount);
    }
    public static void processPrelaunchRecords(List<Lead> leads, Map<String, Integer> leadAssertMap, Map<String, Integer> objRecCountMap){
        //system.debug(leads);
        Map<String, List<Lead>> insertedLeadMap = new Map<String, List<Lead>>();
        Map<String, List<ACE_Product_Interest__c>> insertedPIMap = new Map<String, List<ACE_Product_Interest__c>>();
        Map<String,List<ACE_Source_Tracker__c>> insertedProductMap = new Map<String,List<ACE_Source_Tracker__c>>();
        
        Set<Id> setOfPi =  new set<Id>();
        system.assertEquals(objRecCountMap.get('Lead'), leads.size());
        Integer proInterestCount = 0;
        for(Lead ld : leads){
            //system.debug(ld.Contact_Num_Call_Center__c);
            //String cnum = String.isEmpty(ld.MobilePhone) ? ld.phone : ld.MobilePhone;
            if(insertedLeadMap.containsKey(ld.Contact_Num_Call_Center__c)){
                insertedLeadMap.get(ld.Contact_Num_Call_Center__c).add(ld);                
            }else{
                insertedLeadMap.put(ld.Contact_Num_Call_Center__c, new List<Lead>{ld});
            }
            //system.debug(ld.Product_Interests__r);
            for(ACE_Product_Interest__c PI : ld.Product_Interests__r){
                system.debug(ld.Contact_Num_Call_Center__c+'=='+PI.Product__r.Name);
                proInterestCount++;
                setOfPi.add(PI.id);
                if(insertedPIMap.containsKey(ld.Contact_Num_Call_Center__c+'=='+PI.Product__r.Name)){
                    insertedPIMap.get(ld.Contact_Num_Call_Center__c+'=='+PI.Product__r.Name).add(PI);
                }else{
                    insertedPIMap.put(ld.Contact_Num_Call_Center__c+'=='+PI.Product__r.Name, new List<ACE_Product_Interest__c>{PI});
                }
            }
        }
        system.assertEquals(objRecCountMap.get('Product Interest'), proInterestCount);
        list<ACE_Source_Tracker__c> listOfTracker = [Select id,ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c , ACE_Product_Interest__r.Lead__r.mobilephone, ACE_Product_Interest__r.Lead__r.phone, ACE_Source__c, ACE_SubSource__c, ACE_Product_Interest__r.Product__r.Name from ACE_Source_Tracker__c where ACE_Product_Interest__c In: setOfPi];      
        system.assertEquals(objRecCountMap.get('Source Tracker'), listOfTracker.size());
        for(ACE_Source_Tracker__c sT : listOfTracker){
            //String cnum = String.isEmpty(sT.ACE_Product_Interest__r.Lead__r.mobilephone) ? sT.ACE_Product_Interest__r.Lead__r.phone : sT.ACE_Product_Interest__r.Lead__r.mobilephone;
            String mapKey = sT.ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c+'=='+sT.ACE_Product_Interest__r.Product__r.Name+'=='+sT.ACE_Source__c+'=='+sT.ACE_SubSource__c;
            if(insertedProductMap.containsKey(mapKey)){
                insertedProductMap.get(mapKey).add(sT);
            }else{
                insertedProductMap.put(mapKey, new List<ACE_Source_Tracker__c>{sT});
            }
        }
       // system.debug(insertedLeadMap.values());
        for(String leadstr : insertedLeadMap.keySet()){
            system.assertEquals(leadAssertMap.containsKey(leadstr), true);
            system.assertEquals(leadAssertMap.get(leadstr), insertedLeadMap.get(leadstr).size());
        }
       // system.debug(insertedPIMap.values());
        for(String intProStr : insertedPIMap.keySet()){   
            //system.debug(intProStr);
            system.assertEquals(leadAssertMap.containsKey(intProStr), true);
            system.assertEquals(leadAssertMap.get(intProStr), insertedPIMap.get(intProStr).size());
        }
       // system.debug(insertedProductMap.values());
        for(String sourceTStr : insertedProductMap.keySet()){
           // system.debug(sourceTStr);
            system.assertEquals(leadAssertMap.containsKey(sourceTStr), true);
            system.assertEquals(leadAssertMap.get(sourceTStr), insertedProductMap.get(sourceTStr).size());
        }
        for(String skey: leadAssertMap.keySet()){
           // system.debug('PS');
            Boolean checkFlag = true;
            if(skey.countMatches('==') == 2 && insertedLeadMap.containsKey(skey)){
                checkFlag = false;
            }else if(skey.countMatches('==') == 3 && insertedPIMap.containsKey(skey)){
                checkFlag = false;
            }else if(skey.countMatches('==') == 5 && insertedProductMap.containsKey(skey)){
                checkFlag = false;
            }            
            if(checkFlag){
                system.assertEquals(true, false);
            }
        }
    }
    public static testMethod void testNormalLead(){
        List<ACE_ServiceUtil.leadDetail> lds = new List<ACE_ServiceUtil.leadDetail>();
        Map<String, Integer> objRecordsCount;
        List<ACE_ServiceUtil.sourceTrackerDetail> sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        ACE_ServiceUtil.productInterestsDetail pIDetail = getProductInterestInstance('XUV500');
        pIDetail.relatedSourceTrackers = sTdetails;
        ACE_ServiceUtil.leadDetail ldDetail = getLeadInstance('BM', '1234567890','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111111111','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};
        lds.add(ldDetail);
        lds = new List<ACE_ServiceUtil.leadDetail>();
        ACE_LeadAPIService.processLeads(lds);
        List<String> queryParameters = new List<String>{'1234567890==CC1==Call Center', '1111111111==CC1==Call Center'};
        Map<String, Integer> leadAssertMap = new Map<String,Integer>(); 
        leadAssertMap.put('1234567890==CC1', 1);
        leadAssertMap.put('1234567890==CC1==XUV500', 1);
        leadAssertMap.put('1234567890==CC1==XUV500==Advertisement==Cardekho', 1);
        leadAssertMap.put('1111111111==CC1', 1);
        leadAssertMap.put('1111111111==CC1==XUV300', 1);
        leadAssertMap.put('1111111111==CC1==XUV300==Advertisement==Cardekho', 1);
        
        List<Lead> leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>2, 'Product Interest'=>2, 'Source Tracker'=>2};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('1 Pass');
        //=======================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111111111','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        ACE_LeadAPIService.processLeads(lds);
        leadAssertMap.put('1234567890==CC1==Scorpio', 1);
        leadAssertMap.put('1234567890==CC1==Scorpio==Advertisement==Cardekho', 1);
        leadAssertMap.put('1111111111==CC1==Scorpio', 1);
        leadAssertMap.put('1111111111==CC1==Scorpio==Advertisement==Cardekho', 1);
        objRecordsCount = new Map<String, Integer>{'Lead'=>2, 'Product Interest'=>4, 'Source Tracker'=>4};
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('2 Pass');
        //================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Carwale')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Carwale')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111111111','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
                
        ACE_LeadAPIService.processLeads(lds);        
        leadAssertMap.put('1234567890==CC1==Scorpio==Advertisement==Carwale', 1);        
        leadAssertMap.put('1111111111==CC1==Scorpio==Advertisement==Carwale', 1);
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	objRecordsCount = new Map<String, Integer>{'Lead'=>2, 'Product Interest'=>4, 'Source Tracker'=>6};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('3 Pass');
        //========================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111111111','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        leadAssertMap.put('1234567890==CC2', 1);
        leadAssertMap.put('1234567890==CC2==Scorpio', 1);
        leadAssertMap.put('1234567890==CC2==Scorpio==Advertisement==SyouV.com', 1);
        leadAssertMap.put('1111111111==CC2', 1);
        leadAssertMap.put('1111111111==CC2==Scorpio', 1);
        leadAssertMap.put('1111111111==CC2==Scorpio==Advertisement==SyouV.com', 1);
        queryParameters.add('1234567890==CC2==Call Center');
        queryParameters.add('1111111111==CC2==Call Center');
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
    	objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('4 Pass');
        //=================================================================================================================================
        Integer lastLeadCount = leads.size();
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('Scorpio');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234564','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
		objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('5 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('XUV3000');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('6 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Add', 'SyouV.com')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('7 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'S.com')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('8 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Add', 'S.com')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('9 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('');
        pIDetail.relatedSourceTrackers = sTdetails; 
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('10 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', '')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1234567890','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('11 Pass');
        //=================================================================================================================================
        lds = new List<ACE_ServiceUtil.leadDetail>();
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        //Call-Center: CC1
        
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>4, 'Product Interest'=>6, 'Source Tracker'=>8};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('12 Pass');
        //-----------------------------------------------------------------------------------------------------------
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        sTdetails.add(getSourceTrackerInstance('Advertisement', 'Cardekho'));    
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '4444444444','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};
        pIDetail = getProductInterestInstance('XUV500');
        sTdetails.add(getSourceTrackerInstance('Advertisement', 'Cardekho'));
        sTdetails.add(getSourceTrackerInstance('Advertisement', 'Cardekho'));
        pIDetail.relatedSourceTrackers = sTdetails;
        
        ldDetail.relatedProductInterests.add(pIDetail);
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        queryParameters = new List<String>{'4444444444==CC1==Call Center'};
        leadAssertMap.put('4444444444==CC1', 1);
        leadAssertMap.put('4444444444==CC1==XUV500', 1);
        leadAssertMap.put('4444444444==CC1==XUV500==Advertisement==Cardekho', 1);
        leadAssertMap.put('4444444444==CC1==XUV300', 1);
        leadAssertMap.put('4444444444==CC1==XUV300==Advertisement==Cardekho', 1);
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>1, 'Product Interest'=>2, 'Source Tracker'=>2};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('13 Pass');
        //===========================================================================================
        sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        sTdetails.add(getSourceTrackerInstance('Advertisement', 'Carwale'));    
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '5555555555','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};
        pIDetail = getProductInterestInstance('XUV500');
        //sTdetails.add(getSourceTrackerInstance('Advertisement', 'Cardekho'));
        //sTdetails.add(getSourceTrackerInstance('Advertisement', 'Carwale'));
        pIDetail.relatedSourceTrackers = sTdetails;
        
        ldDetail.relatedProductInterests.add(pIDetail);
        lds.add(ldDetail);
        ACE_LeadAPIService.processLeads(lds);
        queryParameters = new List<String>{'5555555555==CC1==Call Center'};
        leadAssertMap.put('5555555555==CC1', 1);
        leadAssertMap.put('5555555555==CC1==XUV500', 1);
        leadAssertMap.put('5555555555==CC1==XUV500==Advertisement==Cardekho', 1);
        leadAssertMap.put('5555555555==CC1==XUV500==Advertisement==Carwale', 1);
        leadAssertMap.put('5555555555==CC1==XUV300', 1);
        leadAssertMap.put('5555555555==CC1==XUV300==Advertisement==Cardekho', 1);
        leadAssertMap.put('5555555555==CC1==XUV300==Advertisement==Carwale', 1);
        leads = [Select Name, Call_Center__c, MobilePhone, Phone, Email, City, (Select Id, Product__c, Product__r.Name from Product_Interests__r) from Lead where Contact_Num_Call_Center__c IN:queryParameters];                
        objRecordsCount = new Map<String, Integer>{'Lead'=>1, 'Product Interest'=>2, 'Source Tracker'=>4};
        processRecords(leads, leadAssertMap, objRecordsCount);
        system.debug('14 Pass');
    }
    public static void processRecords(List<Lead> leads, Map<String, Integer> leadAssertMap, Map<String, Integer> objRecCountMap){
        //system.debug(leads);
        Map<String, List<Lead>> insertedLeadMap = new Map<String, List<Lead>>();
        Map<String, List<ACE_Product_Interest__c>> insertedPIMap = new Map<String, List<ACE_Product_Interest__c>>();
        Map<String,List<ACE_Source_Tracker__c>> insertedProductMap = new Map<String,List<ACE_Source_Tracker__c>>();
        
        Set<Id> setOfPi =  new set<Id>();
        system.assertEquals(objRecCountMap.get('Lead'), leads.size());
        Integer proInterestCount = 0;
        for(Lead ld : leads){
            String cnum = String.isEmpty(ld.MobilePhone) ? ld.phone : ld.MobilePhone;
            if(insertedLeadMap.containsKey(cnum+'=='+ld.Call_Center__c)){
                insertedLeadMap.get(cnum+'=='+ld.Call_Center__c).add(ld);                
            }else{
                insertedLeadMap.put(cnum+'=='+ld.Call_Center__c, new List<Lead>{ld});
            }
            for(ACE_Product_Interest__c PI : ld.Product_Interests__r){
                proInterestCount++;
                setOfPi.add(PI.id);
                if(insertedPIMap.containsKey(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name)){
                    insertedPIMap.get(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name).add(PI);
                }else{
                    insertedPIMap.put(cnum+'=='+ld.Call_Center__c+'=='+PI.Product__r.Name, new List<ACE_Product_Interest__c>{PI});
                }
            }
        }
        system.assertEquals(objRecCountMap.get('Product Interest'), proInterestCount);
        list<ACE_Source_Tracker__c> listOfTracker = [Select id,ACE_Product_Interest__r.Lead__r.Call_Center__c , ACE_Product_Interest__r.Lead__r.mobilephone, ACE_Product_Interest__r.Lead__r.phone, ACE_Source__c, ACE_SubSource__c, ACE_Product_Interest__r.Product__r.Name from ACE_Source_Tracker__c where ACE_Product_Interest__c In: setOfPi];      
        system.assertEquals(objRecCountMap.get('Source Tracker'), listOfTracker.size());
        for(ACE_Source_Tracker__c sT : listOfTracker){
            String cnum = String.isEmpty(sT.ACE_Product_Interest__r.Lead__r.mobilephone) ? sT.ACE_Product_Interest__r.Lead__r.phone : sT.ACE_Product_Interest__r.Lead__r.mobilephone;
            String mapKey = cnum+'=='+sT.ACE_Product_Interest__r.Lead__r.Call_Center__c+'=='+sT.ACE_Product_Interest__r.Product__r.Name+'=='+sT.ACE_Source__c+'=='+sT.ACE_SubSource__c;
            if(insertedProductMap.containsKey(mapKey)){
                insertedProductMap.get(mapKey).add(sT);
            }else{
                insertedProductMap.put(mapKey, new List<ACE_Source_Tracker__c>{sT});
            }
        }
       // system.debug(insertedLeadMap.values());
        for(String leadstr : insertedLeadMap.keySet()){
            system.assertEquals(leadAssertMap.containsKey(leadstr), true);
            system.assertEquals(leadAssertMap.get(leadstr), insertedLeadMap.get(leadstr).size());
        }
       // system.debug(insertedPIMap.values());
        for(String intProStr : insertedPIMap.keySet()){   
            //system.debug(intProStr);
            system.assertEquals(leadAssertMap.containsKey(intProStr), true);
            system.assertEquals(leadAssertMap.get(intProStr), insertedPIMap.get(intProStr).size());
        }
       // system.debug(insertedProductMap.values());
        for(String sourceTStr : insertedProductMap.keySet()){
           // system.debug(sourceTStr);
            system.assertEquals(leadAssertMap.containsKey(sourceTStr), true);
            system.assertEquals(leadAssertMap.get(sourceTStr), insertedProductMap.get(sourceTStr).size());
        }
        for(String skey: leadAssertMap.keySet()){
           // system.debug('PS');
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
    //refer A friend==========================================================================================
   /*@isTest
    public static void referFreindTest(){
        List<ACE_ServiceUtil.ReferLeadFromEmployeeDetail> referDetailList = new List<ACE_ServiceUtil.ReferLeadFromEmployeeDetail> ();
        List<ACE_ServiceUtil.leadDetail> lds = new List<ACE_ServiceUtil.leadDetail>();
        Map<String, Integer> objRecordsCount;
        List<ACE_ServiceUtil.sourceTrackerDetail> sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        ACE_ServiceUtil.productInterestsDetail pIDetail = getProductInterestInstance('XUV500');
        pIDetail.relatedSourceTrackers = sTdetails;
        ACE_ServiceUtil.leadDetail ldDetail = getLeadInstance('BM', '1234567890','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        ACE_ServiceUtil.ReferLeadFromEmployeeDetail referLead = getReferLead('Mr.','Pradhuman', True, 'Mahindra Holidays','1234567890');
        referLead.referleadsDeatil = new List<ACE_ServiceUtil.leadDetail>{ldDetail};
        referDetailList.add(referLead);
        String result =  ACE_LeadAPIService.processEmpReferredLeads(referDetailList);
        
        //=============================================================================
      	sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('XUV300');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111222222','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail}; 
        referLead = getReferLead('Mr.','Pradhuman', True, 'Mahindra Swaraj','0987654321');
        referLead.referleadsDeatil = new List<ACE_ServiceUtil.leadDetail>{ldDetail};
        referDetailList.add(referLead);
        result =  ACE_LeadAPIService.processEmpReferredLeads(referDetailList);
        //==============================================================================
        //=============================================================================
      	sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'SyouV.com')};
        pIDetail = getProductInterestInstance('XUV500');
        pIDetail.relatedSourceTrackers = sTdetails;
        ldDetail = getLeadInstance('BM', '1111222222','Jaipur','bm@gmail.com','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail}; 
        referLead = getReferLead('Mr.','Pradhuman', True, 'Mahindra Swaraj','1234567890');
        referLead.referleadsDeatil = new List<ACE_ServiceUtil.leadDetail>{ldDetail};
        referDetailList.add(referLead);
        result =  ACE_LeadAPIService.processEmpReferredLeads(referDetailList);
    }
    @istest
    public static void csvTest(){
        List<ACE_ServiceUtil.leadDetail> lds = new List<ACE_ServiceUtil.leadDetail>();
        Map<String, Integer> objRecordsCount;
        List<ACE_ServiceUtil.sourceTrackerDetail> sTdetails = new List<ACE_ServiceUtil.sourceTrackerDetail>{getSourceTrackerInstance('Advertisement', 'Cardekho')};
        ACE_ServiceUtil.productInterestsDetail pIDetail = getProductInterestInstance('XUV500');
        pIDetail.relatedSourceTrackers = sTdetails;
        ACE_ServiceUtil.leadDetail ldDetail = getLeadInstance('BM', '1234567890','','','');
        ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>{pIDetail};     
        lds.add(ldDetail);
        String pseudoCsvData = JSON.serialize(lds);
        String response = ACE_LeadAPIService.processCSVRecords(pseudoCsvData);
    }*/
}