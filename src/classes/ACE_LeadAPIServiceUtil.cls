/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Lead, Product Interest, Source Tracker from third party/ CSV upload.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>--
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        26-Dec-2019
* @Last modified       
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* Made By: Amit Chaudhary
* Description: 04-Jan-2020 Pre-Launch records creation logic implemented. 
*                 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class ACE_LeadAPIServiceUtil {
    
    public Static Map<String,String> errorRecordsMap = new Map<String,String>();
    public Static Map<Id,Lead> mapOFIDLead = new Map<Id,Lead> (); 
    
    public static Map<String, Map<String, Set<String>>> getRequiredFields(List<String> sourceSubsource){
        Map<String, Map<String, Set<String>>> requiredFieldsMap = new Map<String, Map<String, Set<String>>>();
        if(sourceSubsource[0] == 'SYouV.com'){
            requiredFieldsMap.put('SYouV.com', new Map<String, Set<String>>{'Lead' => new Set<String>{'LastName', 'MobilePhone'}, 'ACE_Product_Interest__c' => new Set<String>{'Name'}, 'ACE_Source_Tracker__c' => new Set<String>{'ACE_Source__c', 'ACE_SubSource__c'}});
            return requiredFieldsMap;
        }
        return null;
    }
    Public static boolean validateLeadRec(Lead ld, Set<String> requiredFields){
        for(String reqField : requiredFields){
            String fieldValue = (String)ld.get(reqField);
            if(String.isBlank(fieldValue)){
                return true;
            }
        }
        return false;
    }
    public static boolean validateProInterestRec(ACE_Product_Interest__c pI, Set<String> requiredFields){
        for(String reqField : requiredFields){
            String fieldValue = (String)pI.get(reqField);
            if(String.isBlank(fieldValue)){
                return true;
            }
        }
        return false;
    }
    public static boolean validateSourceTrackerRec(ACE_Source_Tracker__c sT, Set<String> requiredFields){
        for(String reqField : requiredFields){
            String fieldValue = (String)sT.get(reqField);
            if(String.isBlank(fieldValue)){
                return true;
            }
        }
        return false;
    }
    public static RequiredResultNProduct checkRequiredFields(List<ACE_ServiceUtil.leadDetail> leadRecords, Map<String,Map<String,Set<String>>> requiredFieldsMap,  Map<String, String> callCenterMap, Map<String, Boolean> proPrelaunchMap){
        Map<String, Set<String>> checkExisted = new Map<String, Set<String>>();
        Map<String ,ACE_ServiceUtil.leadDetail> formattedMap = new Map<String ,ACE_ServiceUtil.leadDetail>();
        Map<String, LIST<ACE_ServiceUtil.leadDetail>> allObjMap = new  Map<String, LIST<ACE_ServiceUtil.leadDetail>>();
        RequiredResultNProduct obj =  new RequiredResultNProduct();
        if(test.isRunningTest()){
            callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
        }   
        for(ACE_ServiceUtil.leadDetail leadRec : leadRecords){
            if(validateLeadRec(leadRec.leadData, requiredFieldsMap.get('SYouV.com').get('Lead'))){
                leadRec.leadStatus = 'Failed';
                leadRec.leadExcetion = 'Required fields missing.';
            }
            Boolean checkFlag = false;
            for(ACE_ServiceUtil.productInterestsDetail proInt: leadRec.relatedProductInterests){
                String ldrecordType = 'Call Center';
                if(proPrelaunchMap.containskey(proInt.productInterest.Name)){
                     ldrecordType = proPrelaunchMap.get(proInt.productInterest.Name) ? 'Pre-launch Lead' : 'Call Center' ;
                }
                if(validateProInterestRec(proInt.productInterest, requiredFieldsMap.get('SYouV.com').get('ACE_Product_Interest__c'))){
                    proInt.productInterestStatus = 'Failed';
                    proInt.productInterestExcetion = 'Required fields missing.';
                }
                obj.products.add(proInt.productInterest.Name);
                for(ACE_ServiceUtil.sourceTrackerDetail sourceT : proInt.relatedSourceTrackers){
                   // system.debug('Inside Source Tracker');
                    if(validateSourceTrackerRec(sourceT.sourceTracker, requiredFieldsMap.get('SYouV.com').get('ACE_Source_Tracker__c'))){
                        checkFlag = true;
                        sourceT.sourceTrackerStatus = 'Failed';
                        sourceT.sourceTrackerExcetion = 'Required fields missing.';
                    }
                    String callCenterName = callCenterMap.get(sourceT.sourceTracker.ACE_Source__c+'=='+leadRec.leadData.Sub_Source__c) == 'Model Based' ? callCenterMap.get(proInt.productInterest.Name) : callCenterMap.get(sourceT.sourceTracker.ACE_Source__c+'=='+sourceT.sourceTracker.ACE_SubSource__c);
                    if(String.isNotBlank(sourceT.sourceTracker.ACE_Source__c) && String.isNotBlank(sourceT.sourceTracker.ACE_SubSource__c)){
                        if(String.isNotEmpty(leadRec.leadData.MobilePhone)) {
                            ACE_ServiceUtil.leadDetail ldRec = (ACE_ServiceUtil.leadDetail)JSON.deserialize(JSON.serialize(leadRec), ACE_ServiceUtil.leadDetail.class);                            
                            if(String.isBlank(callCenterName)){
                                leadRec.leadStatus = 'Failed';
                                leadRec.leadExcetion = 'No Call centre Assigned';                                
                            }                            
                            String kk = leadRec.leadData.MobilePhone+'=='+callCenterName+'=='+ldrecordType;
                            system.debug('kk'+kk);
                            ACE_Source_Tracker__c st = (ACE_Source_Tracker__c)JSON.deserialize(JSON.serialize(sourceT.sourceTracker), ACE_Source_Tracker__c.class);
                            ACE_Product_Interest__c proI = (ACE_Product_Interest__c)JSON.deserialize(JSON.serialize(proInt.productInterest), ACE_Product_Interest__c.class);
                            formatLeadDetails(ldRec.leadData, checkExisted, formattedMap, kk, proI ,sT);                            
                        }
                    }
                }                
            }
            if(checkFlag){
                obj.contactNums.add(leadRec.leaddata.MobilePhone);                
            }
        }     
        for(ACE_ServiceUtil.leadDetail ldd : formattedMap.values()){
            system.debug('#############'+ldd.leaddata.mobilephone+'=='+ldd.leadStatus);
            for(ACE_ServiceUtil.productInterestsDetail pd: ldd.relatedProductInterests){
                system.debug('##########################'+pd.productInterest.Name);
                for(ACE_ServiceUtil.sourceTrackerDetail sTracker : pd.relatedSourceTrackers){
        	    	system.debug('#######################################'+sTracker.sourceTracker.ACE_Source__c+'------'+sTracker.sourceTracker.ACE_SubSource__c);
                }
            }
        }
        obj.requiredCheckResult = formattedMap;
        return obj;
    }
    public static void formatLeadDetails(Lead ld, Map<String, Set<String>> checkExisted, Map<String ,ACE_ServiceUtil.leadDetail> formattedMap, String mapKey, ACE_Product_Interest__c product, ACE_Source_Tracker__c sourceSubSource){
        system.debug(mapKey);
        system.debug(product.Name);
        /*for(ACE_ServiceUtil.leadDetail ldd : formattedMap.values()){
            for(ACE_ServiceUtil.productInterestsDetail pd: ldd.relatedProductInterests){
        	    system.debug(ldd.leadData.mobilePhone+'======================@@@@@==='+  pd.productInterest.Name);
            }
        }*/
        if(formattedMap.containsKey(mapKey)){
            system.debug(product.Name);
            if(checkExisted.get(mapKey).contains(product.Name)){
                system.debug(product.Name+'=='+sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c);
                if(!checkExisted.get(mapKey+'=='+product.Name).contains(sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c)){
                    ACE_ServiceUtil.leadDetail ldDetail = formattedMap.get(mapKey);
                    for(ACE_ServiceUtil.productInterestsDetail obj : ldDetail.relatedProductInterests){
                        if(obj.productInterest.Name == product.Name){
                            ACE_ServiceUtil.sourceTrackerDetail sTracker = new ACE_ServiceUtil.sourceTrackerDetail();
                            sTracker.sourceTracker = sourceSubSource;
                            obj.relatedSourceTrackers.add(sTracker);
                            break;
                        }
                    }
                    checkExisted.get(mapKey+'=='+product.Name).add(sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c);
                }
            }else{
                system.debug(product.Name);
                ACE_ServiceUtil.leadDetail ldDetail = formattedMap.get(mapKey);
                //ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>();
                ACE_ServiceUtil.productInterestsDetail piD = new ACE_ServiceUtil.productInterestsDetail();
                piD.productInterest = product;
                ldDetail.relatedProductInterests.add(piD);
                List<ACE_ServiceUtil.sourceTrackerDetail> sourceTrackers = new List<ACE_ServiceUtil.sourceTrackerDetail>();
                ACE_ServiceUtil.sourceTrackerDetail sTracker = new ACE_ServiceUtil.sourceTrackerDetail();
                sTracker.sourceTracker = sourceSubSource;
                sourceTrackers.add(sTracker);
                piD.relatedSourceTrackers = sourceTrackers;               
                checkExisted.get(mapKey).add(product.Name);
                checkExisted.put(mapKey+'=='+product.Name, new Set<String>{sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c});
                system.debug(product.Name+'=='+sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c);
            }
        }else{
            system.debug(product.Name);
            ACE_ServiceUtil.leadDetail ldDetail = new ACE_ServiceUtil.leadDetail();            
            ldDetail.LeadData = ld.clone(false, false, false, false);
            ldDetail.relatedProductInterests = new List<ACE_ServiceUtil.productInterestsDetail>();
            ACE_ServiceUtil.productInterestsDetail piD = new ACE_ServiceUtil.productInterestsDetail();
            piD.productInterest = product;
            ldDetail.relatedProductInterests.add(piD);
            List<ACE_ServiceUtil.sourceTrackerDetail> sourceTrackers = new List<ACE_ServiceUtil.sourceTrackerDetail>();
            ACE_ServiceUtil.sourceTrackerDetail sTracker = new ACE_ServiceUtil.sourceTrackerDetail();
            sTracker.sourceTracker = sourceSubSource;
            sourceTrackers.add(sTracker);
            piD.relatedSourceTrackers = sourceTrackers;
            //system.debug('mapKey--->'+mapKey);
            formattedMap.put(mapKey, ldDetail);
            checkExisted.put(mapKey, new Set<String>{product.Name});
            checkExisted.put(mapKey+'=='+product.Name, new Set<String>{sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c});
            system.debug(product.Name+'=='+sourceSubSource.ACE_Source__c+'=='+sourceSubSource.ACE_SubSource__c);
        }
    }
    public static Map<String, Id> getProductMap(Set<String> productNames){
        Map<String, Id> proNameIdMap = new Map<String, Id>();
        for(Product2 pro : [Select Id, Name from Product2 where Name IN:productNames]){
            proNameIdMap.put(pro.Name, pro.Id);
        }
        return proNameIdMap;
    }
    public static Map<String,Boolean> getPreLaunchMap(Set<String> productNames){
        Map<String, Boolean> proPrelaunchMap = new Map<String, Boolean>();
        for(Product2 pro : [Select Id, Is_Prelaunch__c, Name from Product2 where Name IN:productNames]){
            proPrelaunchMap.put(pro.Name, pro.Is_Prelaunch__c);
        }
        return proPrelaunchMap;
    }
    
    public static Map<String,String> getCallCenterMap(){
        Map<String,String> allCallCenterForReturn = new Map<String,String>();
        
        for(ACE_Source_Related_Call_Center__mdt callcenter :[select id,ACE_Call_Center__c, ACE_Source__c, ACE_Sub_Source__c from ACE_Source_Related_Call_Center__mdt]){
            allCallCenterForReturn.put(callcenter.ACE_Source__c+'=='+callcenter.ACE_Sub_Source__c, callcenter.ACE_Call_Center__c);
        }
        for(ACE_Model_Related_Call_Center__mdt callcenter :[select id,ACE_Call_Center__c, ACE_Model__c from ACE_Model_Related_Call_Center__mdt]){
            allCallCenterForReturn.put(callcenter.ACE_Model__c, callcenter.ACE_Call_Center__c);
        }
        return allCallCenterForReturn;
    }    
    public static Map<String, Contact> getContacts(Set<String> contactNums){        
        Map<String, Contact> mobnumContactMap = new Map<String, Contact>();
        for(Contact cont: [Select Id, MobilePhone, phone, recordType.developerName FROM Contact where MobilePhone IN :contactNums OR phone IN :contactNums]){            
            if(!String.isEmpty(cont.MobilePhone)){
                mobnumContactMap.put(cont.MobilePhone, cont);
            }else{
                mobnumContactMap.put(cont.phone, cont);
            }
        }
        return mobnumContactMap;
    }
    public static existingLeadsDetail getexistingLeadsDetail(List<Lead> existingLeads){
        existingLeadsDetail obj = new existingLeadsDetail();
        for(Lead lead : existingLeads){            
            obj.existingLeadsMap.put(lead.Contact_Num_Call_Center__c, lead);            
            obj.leadRelatedInterestsMap.put(lead.Id, new Set<String>());
            for(ACE_Product_Interest__c pI : lead.Product_Interests__r){
                obj.leadRelatedInterestsMap.get(lead.Id).add(pI.Product__r.Name);                
                obj.pInterestStr_RecMap.put(lead.Contact_Num_Call_Center__c+'=='+pI.Product__r.Name, pI);
            }            
        }
        if(obj.pInterestStr_RecMap.keySet().size() > 0){                
            for(ACE_Source_Tracker__c sourceTracker : [Select ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c, ACE_Product_Interest__r.Name, ACE_Product_Interest__r.Lead__r.mobilePhone, ACE_Product_Interest__r.Lead__r.phone, ACE_Product_Interest__r.Lead__c, ACE_Product_Interest__c, ACE_Source__c, ACE_Subsource__c from ace_Source_Tracker__c where ACE_Product_Interest__c IN :obj.pInterestStr_RecMap.values()]){
                string contNum = String.isNotBlank(sourceTracker.ACE_Product_Interest__r.Lead__r.mobilePhone) ? sourceTracker.ACE_Product_Interest__r.Lead__r.mobilePhone : sourceTracker.ACE_Product_Interest__r.Lead__r.phone;
                if(obj.proInterestRelatedSourcesMap.containsKey(sourceTracker.ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c+'=='+sourceTracker.ACE_Product_Interest__r.Name)){
                    obj.proInterestRelatedSourcesMap.get(sourceTracker.ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c+'=='+sourceTracker.ACE_Product_Interest__r.Name).add(sourceTracker.ACE_Source__c+'-@-@-'+sourceTracker.ACE_SubSource__c);
                }else{
                    obj.proInterestRelatedSourcesMap.put(sourceTracker.ACE_Product_Interest__r.Lead__r.Contact_Num_Call_Center__c+'=='+sourceTracker.ACE_Product_Interest__r.Name,new Set<String>{sourceTracker.ACE_Source__c+'-@-@-'+sourceTracker.ACE_SubSource__c});
                }
            }                        
        }
        return obj;
    }    
    public static List<Lead> getExistingLeads(Set<String> mobNums){
        LIST<Lead> existingLeads = [SELECT ID,Contact_Num_Call_Center__c,city,Call_Center__c, Vehicle__r.Name, MobilePhone,Phone,OwnerId,Email, ACE_Vehicle_Model__c, (Select Id,Name, Product__c, Lead__c, Product__r.Name from Product_Interests__r) FROM LEAD WHERE Contact_Num_Call_Center__c IN :mobNums];
        return existingLeads;
    }
    public static Map<String, List<ACE_ServiceUtil.leadDetail>> getCallCenter(Map<String,String> callCenterMap, ACE_ServiceUtil.leadDetail ld){
        Map<String, List<ACE_ServiceUtil.leadDetail>> ldAPiRecordsMap = new Map<String, List<ACE_ServiceUtil.leadDetail>>();
        for(ACE_ServiceUtil.productInterestsDetail pID : ld.relatedProductInterests){
            for(ACE_ServiceUtil.sourceTrackerDetail sourceTrackerObj : pID.relatedSourceTrackers){
                String callCenterName = callCenterMap.get(sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+ld.leadData.Sub_Source__c) == 'Model Based' ? callCenterMap.get(pID.productInterest.Name) : callCenterMap.get(sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+sourceTrackerObj.sourceTracker.ACE_SubSource__c);
                if(String.isNotBlank(sourceTrackerObj.sourceTracker.ACE_Source__c) && String.isNotBlank(sourceTrackerObj.sourceTracker.ACE_SubSource__c)){
                    if(String.isNotEmpty(ld.leadData.MobilePhone)) {
                        if(ldAPiRecordsMap.containsKey(ld.leadData.MobilePhone+'=='+callCenterName)){
                            ldAPiRecordsMap.get(ld.leadData.MobilePhone+'=='+callCenterName).add(ld);          
                        }else{
                            ldAPiRecordsMap.put(ld.leadData.MobilePhone+'=='+callCenterName, new List<ACE_ServiceUtil.leadDetail>{ld});
                        }
                    }
                }
            }
        }
        return ldAPiRecordsMap;
    }
    public static insertionObjectsDetail createInstancesForInsertion(Map<String, ACE_ServiceUtil.leadDetail> leadMap, existingLeadsDetail existingleadDtl, Map<String, Id> proNameIdMap, Map<String, String> callcenterMap, Map<String, Contact> contactMap, String calledFrom){
        InsertionObjectsDetail obj = new insertionObjectsDetail();
        String preLaunchRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pre-launch Lead').getRecordTypeId();
        String callcenterRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Call Center').getRecordTypeId(); 
        if(test.isRunningTest()){
            callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
        }
        for(String phoneNumCallC : leadMap.keySet()){
            //system.debug(phoneNumCallC);
            ACE_ServiceUtil.leadDetail ld = leadMap.get(phoneNumCallC);
            if(ld.leadStatus != 'Failed' ){                    
                for(ACE_Booking__c booking: ld.bookings){
                    if(obj.bookingsToBeInserted.containsKey(phoneNumCallC)){                               
                        obj.bookingsToBeInserted.get(phoneNumCallC).add(booking);
                    }else{                               
                        obj.bookingsToBeInserted.put(phoneNumCallC, new List<ACE_Booking__c>{booking});
                    }
                }
                if(existingleadDtl.existingLeadsMap.containsKey(phoneNumCallC)){
                    if(existingleadDtl.existingLeadsMap.containsKey(phoneNumCallC)){
                        Lead ldi = existingleadDtl.existingLeadsMap.get(phoneNumCallC);
                        Map<Boolean, Lead> isLeadUpdatedMap = getupdatedLead(ldi, ld);
                        for(Boolean isUpdated: isLeadUpdatedMap.keyset()){
                            if(isUpdated){
                                obj.leadsToBeInserted.put(phoneNumCallC, ldi);
                                ld.leadStatus = 'Lead updated, ';
                            }
                        }
                        for(ACE_ServiceUtil.productInterestsDetail pID : ld.relatedProductInterests){
                            if(pID.productInterestStatus != 'Failed'){
                                if(existingleadDtl.leadRelatedInterestsMap.get(ldi.Id).contains(pID.productInterest.Name)){
                                    for(ACE_ServiceUtil.sourceTrackerDetail sourceTrrackerObj :  pID.relatedSourceTrackers){
                                        if( existingleadDtl.proInterestRelatedSourcesMap.containskey(ldi.Contact_Num_Call_Center__c+'=='+pID.productInterest.Name)){
                                            if(! existingleadDtl.proInterestRelatedSourcesMap.get(ldi.Contact_Num_Call_Center__c+'=='+pID.productInterest.Name).contains(ld.leadData.Enquiry_Source__c+'-@-@-'+ld.leadData.Sub_Source__c)){
                                                system.debug('Pradhuman--11111');
                                                createTrackerMap(obj.iPsourceTrackerMap, sourceTrrackerObj, phoneNumCallC, pID.productInterest.Name);
                                                ld.leadStatus += 'Source tracker created.';
                                            } 
                                        }
                                    }
                                } else{
                                    system.debug('Pradhuman--22222');
                                    createInterestedProductMap(obj.intrestedProductsToBeInserted, proNameIdMap, pID, phoneNumCallC);
                                    for(ACE_ServiceUtil.sourceTrackerDetail sourceTrrackerObj :  pID.relatedSourceTrackers){
                                        createTrackerMap(obj.iPsourceTrackerMap, sourceTrrackerObj, phoneNumCallC, pID.productInterest.Name);
                                    }
                                    ld.leadStatus += 'Product Interest, Source tracker created.';
                                }
                            }
                        }
                    }
                } else{
                    system.debug('Pradhuman--3333');
                    String rtId = phoneNumCallC.split('==')[2] == 'Pre-launch Lead' ? preLaunchRTId : callcenterRTId ;
                    obj.leadsToBeInserted.put(phoneNumCallC, getLeadInstance(ld, 'callCenter', rtId, null, phoneNumCallC.split('==')[1], contactMap, calledFrom));                                                        
                    for(ACE_ServiceUtil.productInterestsDetail pID : ld.relatedProductInterests){                               
                        system.debug('Pradhuman--3333.2222');
                        createInterestedProductMap(obj.intrestedProductsToBeInserted, proNameIdMap, pID, phoneNumCallC);
                        for(ACE_ServiceUtil.sourceTrackerDetail sourceTrrackerObj :  pID.relatedSourceTrackers){
                            system.debug('Pradhuman--3333.22.22');
                            createTrackerMap(obj.iPsourceTrackerMap, sourceTrrackerObj, phoneNumCallC, pID.productInterest.Name);
                        }
                    }                            
                    ld.leadStatus = 'Lead, Product Interest, Source tracker created.';
                }                    
            }
            
        }        
        for(Lead ld : obj.leadsToBeInserted.values()){
        system.debug(ld.MobilePhone);
        }
        for(String str : obj.intrestedProductsToBeInserted.keySet()){
        system.debug(str+'--------'+obj.intrestedProductsToBeInserted.get(str));
        }
        for(String str : obj.iPsourceTrackerMap.keySet()){
        system.debug(str+'--------'+obj.iPsourceTrackerMap.get(str));
        }
        return obj;
    }
    public static insertionObjectsDetail insertObjects(insertionObjectsDetail insertionObjs, Map<String, Lead> existingLeadsMap, Map<String, ACE_Product_Interest__c> pInterestStr_RecMap, Map<String, Boolean> proPrelaunchMap){
        List<Lead> insertedObjList;        
        if(insertionObjs.leadsToBeInserted.size() > 0){            
            insertedObjList= insertionObjs.leadsToBeInserted.values();
            //system.debug('---->insertedObjList'+insertedObjList);
            Database.UpsertResult[] InsertionResult = Database.upsert(insertedObjList, false);            
            Integer indexcount = 0;
            for(Database.UpsertResult sr : InsertionResult){//Add  null check
                String keyString = insertedObjList[indexcount].MobilePhone+'=='+insertedObjList[indexcount].Call_Center__c;
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(keyString,err.getMessage());
                        break;
                    }
                }else{
                    errorRecordsMap.put(keyString,'Success');
                }
                indexcount++;
            }
        }
        //--------------------------------Pre-Booking---------------------------------
        if(insertionObjs.bookingsToBeInserted.size() > 0){
            String preBookingRecTypeId = Schema.SObjectType.ACE_Booking__c.getRecordTypeInfosByName().get('Pre Booking').getRecordTypeId();
            List<ACE_Booking__c> bookings = new List<ACE_Booking__c>();
            List<Lead> allMatchLead = new List<Lead>();
            for(String bookingKey : insertionObjs.bookingsToBeInserted.keySet()){
                for(ACE_Booking__c booking : insertionObjs.bookingsToBeInserted.get(bookingKey)){
                    if(existingLeadsMap.containsKey(bookingKey)){                       
                        booking.ACE_Lead__c = existingLeadsMap.get(bookingKey).Id;
                    }else if(insertionObjs.leadsToBeInserted.containsKey(bookingKey)){                      
                        booking.ACE_Lead__c = insertionObjs.leadsToBeInserted.get(bookingKey).Id;                       
                    }                    
                    booking.RecordTypeId = preBookingRecTypeId;
                    bookings.add(booking);
                }
            }
            Insert bookings;
        }
        //-----------------------------Pre-Booking---------------------
        if(insertionObjs.intrestedProductsToBeInserted.size() > 0){
            for(String pIKeys : insertionObjs.intrestedProductsToBeInserted.keySet()){              
                List<Lead> insertedLeads  = new List<Lead>();
                if(existingLeadsMap.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]+'=='+pIKeys.split('==')[2])){
                    Lead led = existingLeadsMap.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]+'=='+pIKeys.split('==')[2]);
                    mapOFIDLead.put(led.Id,led);
                    insertionObjs.intrestedProductsToBeInserted.get(pIKeys).Lead__c = led.Id;                    
                }else if(insertionObjs.leadsToBeInserted.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]+'=='+pIKeys.split('==')[2])){
                    Lead led = insertionObjs.leadsToBeInserted.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]+'=='+pIKeys.split('==')[2]);
                    mapOFIDLead.put(led.Id,led);
                    insertionObjs.intrestedProductsToBeInserted.get(pIKeys).Lead__c = led.Id;                    
                }                
            }
            List<ACE_Product_Interest__c> pIList = new List<ACE_Product_Interest__c> () ;
            for(ACE_Product_Interest__c productToInsert : insertionObjs.intrestedProductsToBeInserted.values()){
                
                if(String.isNotBlank(productToInsert.Lead__c) && String.isNotBlank(productToInsert.Product__c)){
                    pIList.add(productToInsert);
                }
            }
            system.debug('---->pIList'+pIList);
            Database.SaveResult[] srListOfPI = Database.Insert(pIList, false);
            Integer IndexCount = 0;
            for(Database.SaveResult sr : srListOfPI){
                String mkey = pIList[IndexCount].Lead__c;
                if(mapOFIDLead.containsKey(mkey)){
                    String ldrecordType =  'Call Center' ;
                    if(proPrelaunchMap.containskey( pIList[IndexCount].Name)){
                      	 ldrecordType = proPrelaunchMap.get( pIList[IndexCount].Name) ? 'Pre-launch Lead' : 'Call Center' ;
                	}
                    mkey = mapOFIDLead.get(mkey).MobilePhone+'=='+mapOFIDLead.get(mkey).Call_Center__c+'=='+ldrecordType+'=='+pIList[IndexCount].Name;
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            system.debug('mkey--'+mkey+'--mssg--'+err.getMessage());
                            errorRecordsMap.put(mkey,err.getMessage());
                            break;
                        }
                    } else{
                        system.debug('mkey--'+mkey);
                        errorRecordsMap.put(mkey,'Success');
                    }
                }
                IndexCount++;
            }
        }
        if(insertionObjs.iPsourceTrackerMap.size() > 0){  
            map<ID,ACE_Product_Interest__c> pIIDMap = new map<ID,ACE_Product_Interest__c>();
            List<ACE_Source_Tracker__c> sTrackerToBeInserted = new List<ACE_Source_Tracker__c>();
            for(String ipTrack : insertionObjs.iPsourceTrackerMap.keySet()){
                if(pInterestStr_RecMap.containsKey(ipTrack)){
                    for(ACE_Source_Tracker__c st : insertionObjs.iPsourceTrackerMap.get(ipTrack)){                      
                        if(String.isNotBlank(pInterestStr_RecMap.get(ipTrack).Id)){
                            pIIDMap.put(pInterestStr_RecMap.get(ipTrack).Id, pInterestStr_RecMap.get(ipTrack));
                            st.ACE_Product_Interest__c = pInterestStr_RecMap.get(ipTrack).Id;
                            sTrackerToBeInserted.add(st);
                        }
                    }
                }else if(insertionObjs.intrestedProductsToBeInserted.containsKey(ipTrack)){
                    for(ACE_Source_Tracker__c st : insertionObjs.iPsourceTrackerMap.get(ipTrack)){
                        if(String.isNotBlank(insertionObjs.intrestedProductsToBeInserted.get(ipTrack).Id)){
                            pIIDMap.put(insertionObjs.intrestedProductsToBeInserted.get(ipTrack).Id, insertionObjs.intrestedProductsToBeInserted.get(ipTrack));
                            st.ACE_Product_Interest__c = insertionObjs.intrestedProductsToBeInserted.get(ipTrack).Id;
                            sTrackerToBeInserted.add(st);
                        }
                    }
                }                        
            }
            Integer indexcount = 0;
            //system.debug('---->sTrackerToBeInserted'+sTrackerToBeInserted);
            Database.SaveResult[] srListOfTracker = Database.Insert(sTrackerToBeInserted, false);
            for(Database.SaveResult sr : srListOfTracker){
                String productId = sTrackerToBeInserted.get(indexcount).ACE_Product_Interest__c;
                if(String.isNotBlank(productId)){
                    String leadId = pIIDMap.get(productId).Lead__c;
                    if(mapOFIDLead.containskey(leadId) && pIIDMap.containskey(productId) ){
                        String ldrecordType = System.Label.Pre_launch_Vehicle == pIIDMap.get(productId).Name ? 'Pre-launch Lead' : 'Call Center' ;
                        String generateKey = mapOFIDLead.get(leadId).MobilePhone+'=='+mapOFIDLead.get(leadId).Call_Center__c+'=='+ldrecordType+'=='+pIIDMap.get(productId).Name+'=='+sTrackerToBeInserted.get(indexcount).ACE_Source__c+'=='+sTrackerToBeInserted.get(indexcount).ACE_SubSource__c;
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()) {
                                errorRecordsMap.put(generateKey ,err.getMessage());
                                break;
                            }
                        }else{
                            system.debug('generateKey=Success'+generateKey);
                            errorRecordsMap.put(generateKey,'Success');
                        }
                    }
                }
                indexcount++;
            }
        }      
        return insertionObjs;
    }
    //----------Response Method------------
    public static List<ACE_ServiceUtil.leadDetail> getInsertionResponse(Map<String, ACE_ServiceUtil.leadDetail> apiJsonLeadNProductDetail, InsertionObjectsDetail insertedObjInstanced){
        List<ACE_ServiceUtil.leadDetail> leadResponse = new List<ACE_ServiceUtil.leadDetail>(); 
        system.debug('errorRecordMap--->'+errorRecordsMap);
        for(String mKey : apiJsonLeadNProductDetail.keySet()){
            ACE_ServiceUtil.leadDetail leadRec = apiJsonLeadNProductDetail.get(mKey);
            if(insertedObjInstanced.leadsToBeInserted.containsKey(mKey)){                
                leadRec.leadExcetion = errorRecordsMap.get(mKey.substringBeforeLast('=='));
                //system.debug('leaderrpMapValue'+errorRecordsMap.get(mKey.substringBeforeLast('==')));
                //System.debug('mKey=='+mKey);
                if(errorRecordsMap.get(mKey.substringBeforeLast('==')) == 'Success'){
                    leadRec.leadStatus = 'Success';
                    leadRec.leadExcetion = 'None';
                } else{
                    leadRec.leadStatus = 'Failed';
                }
                leadRec.leadData = insertedObjInstanced.leadsToBeInserted.get(mKey);
                for(ACE_ServiceUtil.productInterestsDetail productintrestObj : leadRec.relatedProductInterests ){
                    if(insertedObjInstanced.intrestedProductsToBeInserted.containsKey(mKey+'=='+productintrestObj.productInterest.Name)){ 
                        productIntrestProcess(insertedObjInstanced, productintrestObj, mKey);
                    }
                }
                leadResponse.add(leadRec);
                
            } else{                
                if(leadRec.leadStatus != 'Failed'){
                    leadRec.leadExcetion = 'None';
                    leadRec.leadStatus = 'Already Exsits';
                    for(ACE_ServiceUtil.productInterestsDetail productintrestObj : leadRec.relatedProductInterests ){
                        if(insertedObjInstanced.intrestedProductsToBeInserted.containsKey(mKey+'=='+productintrestObj.productInterest.Name)){ 
                            system.debug('mKey for product ---'+mKey);
                            productIntrestProcess(insertedObjInstanced, productintrestObj, mKey );
                        } else{
                            productintrestObj.productInterestExcetion = 'None';
                            productintrestObj.productInterestStatus = 'Already Exsits';
                            for(ACE_ServiceUtil.sourceTrackerDetail sourceTrackerObj  : productintrestObj.relatedSourceTrackers){
                                String newMkey = mKey+'=='+productintrestObj.productInterest.Name;
                                if(insertedObjInstanced.iPsourceTrackerMap.containsKey(newMkey+'=='+sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+sourceTrackerObj.sourceTracker.ACE_SubSource__c)){
                                    sourceTrackerProcess(insertedObjInstanced, sourceTrackerObj, newMkey);
                                }else{
                                    Boolean checkFlag = true;
                                    if(insertedObjInstanced.iPsourceTrackerMap.containsKey(newMkey+'=='+sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+sourceTrackerObj.sourceTracker.ACE_SubSource__c)){
                                        for(ACE_Source_Tracker__c sourceTracker : insertedObjInstanced.iPsourceTrackerMap.get(newMkey+'=='+sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+sourceTrackerObj.sourceTracker.ACE_SubSource__c)){
                                            if(sourceTracker.ACE_source__c == sourceTrackerObj.sourceTracker.ACE_Source__c && sourceTracker.ACE_subsource__c == sourceTrackerObj.sourceTracker.ACE_SubSource__c){
                                                checkFlag = false;
                                                sourceTrackerObj.sourceTrackerExcetion = errorRecordsMap.get(newMkey+'=='+sourceTrackerObj.sourceTracker.ACE_Source__c+'=='+sourceTrackerObj.sourceTracker.ACE_SubSource__c);
                                                if(sourceTrackerObj.sourceTrackerExcetion == 'Success'){
                                                    sourceTrackerObj.sourceTrackerStatus = 'Success';
                                                    sourceTrackerObj.sourceTrackerExcetion = 'None';
                                                } else{
                                                    sourceTrackerObj.sourceTrackerStatus = 'Failed';
                                                }
                                                sourceTrackerObj.sourceTracker= sourceTracker;
                                            }
                                        }
                                        if(checkFlag){
                                            sourceTrackerObj.sourceTrackerStatus = 'Alrady Exists';
                                            sourceTrackerObj.sourceTrackerExcetion = 'None';
                                        }
                                    } else{
                                        sourceTrackerObj.sourceTrackerStatus = 'Alrady Exists';
                                        sourceTrackerObj.sourceTrackerExcetion = 'None';
                                    } 
                                } 
                            }
                        }
                    }
                    leadResponse.add(leadRec);
                } else{
                    leadResponse.add(leadRec);
                }                
            }
        }
        return leadResponse;
    }
    public static Map<String, ACE_product_Interest__c> createInterestedProductMap(Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted, Map<String, Id> proNameIdMap, ACE_ServiceUtil.productInterestsDetail productDetailObj, String phoneNumCallC){         
        if(productDetailObj.productInterestStatus != 'Failed'){
            productDetailObj.productInterest.product__c = proNameIdMap.get(productDetailObj.productInterest.Name);
            intrestedProductsToBeInserted.put(phoneNumCallC+'=='+productDetailObj.productInterest.Name, productDetailObj.productInterest);
        }
        return intrestedProductsToBeInserted;
    }
    public static ACE_product_Interest__c getInterestedProductInstance(ACE_ServiceUtil.leadDetail ld, Map<String, Id> proNameIdMap){
        ACE_product_Interest__c pI = new ACE_product_Interest__c();
        pI.Name = ld.leadData.ACE_Vehicle_Model__c;        
        pI.Prefered__c = true;
        pI.product__c = proNameIdMap.get(ld.leadData.ACE_Vehicle_Model__c);        
        return pI;
    }
    public static Lead getLeadInstance(ACE_ServiceUtil.leadDetail ld, String recordType, String rtId, String proID, String callcenter, Map<String, Contact> contactMap, String calledFrom){        
        ld.leadData.recordtypeid = rtId;        
        ld.leadData.Call_Center__c = callcenter;
        ld.leadData.Company = ld.leadData.lastName+'household';
        if(calledFrom == 'LeadPush'){
            ld.leadData.Related_Contact__c = contactMap.containsKey(ld.leadData.MobilePhone) ? contactMap.get(ld.leadData.MobilePhone).Id : null;
        }else if(calledFrom == 'referFriend'){
            ld.leadData.Referred_By__c = contactMap.containsKey(ld.leadData.MobilePhone) ? contactMap.get(ld.leadData.MobilePhone).Id : null;
        }
        return ld.leadData;
    }
    public static Map<String, List<ACE_Source_Tracker__c>> createTrackerMap(Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap, ACE_ServiceUtil.sourceTrackerDetail sourceTrackerObj, String phoneNumCallC, String productName){        
        if(sourceTrackerObj.sourceTrackerStatus != 'Failed'){
            if(iPsourceTrackerMap.containskey(phoneNumCallC+'=='+productName)){
                iPsourceTrackerMap.get(phoneNumCallC+'=='+productName).add(sourceTrackerObj.sourceTracker);
            }else{
                iPsourceTrackerMap.put(phoneNumCallC+'=='+productName, new List<ACE_Source_Tracker__c>{sourceTrackerObj.sourceTracker});
            }
        }            
        return iPsourceTrackerMap;
    }
    public static ACE_Source_Tracker__c getSourceTrackerInstance(ACE_ServiceUtil.leadDetail ld){
        ACE_Source_Tracker__c st = new ACE_Source_Tracker__c();
        st.ACE_Source__c = ld.leadData.Enquiry_Source__c;
        st.ACE_SubSource__c = ld.leadData.Sub_Source__c;
        return st;
    }
    public static Map<Boolean, Lead> getupdatedLead(Lead ldi, ACE_ServiceUtil.leadDetail ld){
        Map<Boolean, Lead> isLeadUpdatedMap = new Map<Boolean, Lead>();
        if((String.isNotBlank(ld.leadData.City__c) || String.isNotBlank(ldi.email)) && (String.isBlank(ld.leadData.City__c) || String.isBlank(ldi.email))){
            if(String.isNotBlank(ld.leadData.City__c) && String.isBlank(ldi.city)){
                ldi.City = ld.leadData.City__c;
                isLeadUpdatedMap.put(true, ldi);
            }
            if(String.isNotBlank(ld.leadData.Email) && String.isBlank(ldi.email)){
                ldi.email = ld.leadData.Email;
                isLeadUpdatedMap.put(true, ldi);
            }
        }
        return isLeadUpdatedMap;
    }
    public static void productIntrestProcess(InsertionObjectsDetail insertedObjInstanced, ACE_ServiceUtil.productInterestsDetail productintrestObj, String mKey){
        productintrestObj.productInterestExcetion = errorRecordsMap.get(mKey+'=='+productintrestObj.productInterest.Name);
        if( productintrestObj.productInterestStatus != 'Failed'){
            if(errorRecordsMap.get(mKey+'=='+productintrestObj.productInterest.Name) == 'Success'){
                productintrestObj.productInterestStatus = 'Success';
                productintrestObj.productInterestExcetion = 'None';
            } else{
                productintrestObj.productInterestStatus = 'Failed';
                productintrestObj.productInterestExcetion = 'Product Or Lead ID Null';
            }
            productintrestObj.productInterest = insertedObjInstanced.intrestedProductsToBeInserted.get(mKey+'=='+productintrestObj.productInterest.Name);
            for(ACE_ServiceUtil.sourceTrackerDetail sourceTrackerObj : productintrestObj.relatedSourceTrackers){             
                String newMkey = mKey+'=='+productintrestObj.productInterest.Name;             
                if(insertedObjInstanced.iPsourceTrackerMap.containsKey(newMkey)){              
                    sourceTrackerProcess(insertedObjInstanced, sourceTrackerObj, newMkey);
                }
            }
        }
    }
    public static void sourceTrackerProcess(InsertionObjectsDetail insertedObjInstanced, ACE_ServiceUtil.sourceTrackerDetail sourceTrackerObj, String mKey ){       
        for(ACE_Source_Tracker__c sourceTracker : insertedObjInstanced.iPsourceTrackerMap.get(mKey)){
            system.debug(sourceTracker.ACE_source__c +'=='+ sourceTrackerObj.sourceTracker.ACE_Source__c +'&&'+ sourceTracker.ACE_subsource__c +'=='+ sourceTrackerObj.sourceTracker.ACE_SubSource__c);
            if(sourceTracker.ACE_source__c == sourceTrackerObj.sourceTracker.ACE_Source__c && sourceTracker.ACE_subsource__c == sourceTrackerObj.sourceTracker.ACE_SubSource__c){                                              
                sourceTrackerObj.sourceTrackerExcetion = errorRecordsMap.get(mKey+'=='+sourceTracker.ACE_source__c+'=='+sourceTracker.ACE_subsource__c );
                system.debug('mKey-->'+mKey+'map'+errorRecordsMap.get(mKey));
                if(sourceTrackerObj.sourceTrackerExcetion == 'Success'){
                    sourceTrackerObj.sourceTrackerStatus = 'Success';
                    sourceTrackerObj.sourceTrackerExcetion = 'None';
                } else{
                    sourceTrackerObj.sourceTrackerStatus = 'Failed';
                    if(String.isBlank(sourceTrackerObj.sourceTrackerExcetion) ){
                         sourceTrackerObj.sourceTrackerExcetion = 'Product Or Lead Failed';
                    }
                }
                sourceTrackerObj.sourceTracker= sourceTracker;
            }
        }
    }
    public static set<string> getAllProducts(LIST<ACE_ServiceUtil.leadDetail> leadsToBeProcessed){
       set<string> products = new set<string>();
        for(ACE_ServiceUtil.leadDetail ld: leadsToBeProcessed){
            for(ACE_ServiceUtil.productInterestsDetail proInt: ld.relatedProductInterests){
                products.add(proInt.productInterest.Name);
            }
        }
        return products;
    }
    public class existingLeadsDetail{
        public Map<String, Lead> existingLeadsMap = new Map<String, Lead>();
        public Map<String, Set<String>> leadRelatedInterestsMap = new Map<String, Set<String>>();
        public Map<String, ACE_Product_Interest__c> pInterestStr_RecMap = new Map<String, ACE_Product_Interest__c>();
        public Map<String, Set<String>> proInterestRelatedSourcesMap = new Map<String, Set<String>>();
    }
    public class RequiredResultNProduct{
        public Map<String, ACE_ServiceUtil.leadDetail> requiredCheckResult =  new Map<String, ACE_ServiceUtil.leadDetail>();
        public Set<String> contactNums = new Set<String>();
        public Set<String> products = new Set<String>();
    }
    public class InsertionObjectsDetail{
        Map<String, Lead> leadsToBeInserted = new Map<String, Lead>();
        Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted = new Map<String, ACE_product_Interest__c>();
        Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap = new Map<String, List<ACE_Source_Tracker__c>>();
        Map<String, List<ACE_Booking__c>> bookingsToBeInserted = new Map<String, List<ACE_Booking__c>>();
    }
}