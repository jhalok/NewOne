@RestResource(urlMapping='/pushCasesToSF/*') 
global class ACE_CreateCasesAPI {

    @HttpPost
    global static String pushCasesToSF(){
        String jsonresp = null;
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');

		//ACE_ServiceUtil.leadsPush        
        List<casesPush> casesToProcess = (List<casesPush>)JSON.deserialize(request.requestBody.toString(),List<casesPush>.class);

        if(casesToProcess.size()>0){
            jsonresp= processCases(casesToProcess);
            //jsonresp= ACE_LeadService.processLeads(leadsforinsert);
        }
        return jsonresp;
    }
    
    //Support wrapper-class and methods....to be moved to util/service classes.. later
    global class casesPush{
        public String caseSubject{get;set;}
        public String caseDescrptn{get;set;}
        public String phoneNumber{get;set;}
        public String city{get;set;}
        public String email{get;set;}
        public String state{get;set;}
        public String source{get;set;}
        public String subsource{get;set;}
        public String groupCode{get;set;}
        public String model{get;set;}
        public String partnerAccountId{get;set;}
        public String status ='';
        public CaseStatus caseResponse = new CaseStatus();
        public String preferredContactTime;
    }
    
    public Class CaseStatus{
        public String status;
        public String sfCaseRecId;
    }
    
    public static String processCases(LIST<casesPush> casesToBeProcessed  ){        
        system.debug('casesToBeProcessed=='+casesToBeProcessed);
        Map<String, Set<String>> requiredFieldsMap = getRequiredFields(new List<String>{'SYouV.com'});
        
        if(requiredFieldsMap.size() > 0){
            
            RequiredResultNProduct checkRequiredResult = checkRequiredFields(casesToBeProcessed, requiredFieldsMap);
            
			Map<String, Id> productMap = ACE_LeadServiceUtil.getProductMap(checkRequiredResult.products);

			Map<String,String> callcenterMap = ACE_LeadServiceUtil.getCallCenterMap();

            //Map<String, List<casesPush>> apiJsonLeadNProductDetail = getJsonCaseMap(checkRequiredResult.requiredCheckResult.get('Valid'), callcenterMap);
            
            Map<String, Contact> coNumContMap = getContacts(checkRequiredResult.contactDtls);
            InsertionObjectsDetail toBeInstertObj = createInstancesForInsertion(checkRequiredResult.requiredCheckResult.get('Valid'), productMap, callcenterMap, coNumContMap, 'CasePush');
            
            InsertionObjectsDetail insertedObj = insertObjects(toBeInstertObj);//
            
            List<casesPush> csResponse;// = ACE_LeadServiceUtil.getInsertionResponse(apiJsonLeadNProductDetail, insertedObjInstanced);
            //testing only
            for(casesPush c : csResponse){
            	system.debug(c.caseResponse);
            }

            for(casesPush rec : csResponse){
            	system.debug(JSON.serialize(rec.caseResponse));
            }
        	return JSON.serialize(csResponse);
		}
    	return null;
    }
    public static Map<String, Contact> getContacts(Set<String> contactNums){        
        Map<String, Contact> cntObjMap = new Map<String, Contact>();
        for(Contact cont: [SELECT Id, MobilePhone, Phone, Email, recordType.developerName 
                           FROM Contact WHERE (MobilePhone IN:contactNums OR phone IN:contactNums OR Email IN:contactNums)])
        {
            if(!String.isEmpty(cont.MobilePhone)){
                cntObjMap.put(cont.MobilePhone, cont);
            }
            if(!String.isEmpty(cont.Phone)){
                cntObjMap.put(cont.phone, cont);
            }
            if(!String.isEmpty(cont.Email)){
                cntObjMap.put(cont.Email, cont);
            }
        }
        return cntObjMap;
    }
    public static Map<String, Set<String>> getRequiredFields(List<String> sourceSubsource){
        Map<String, Set<String>> requiredFieldsMap = new Map<String, Set<String>>();
        if(sourceSubsource[0] == 'SYouV.com'){
            requiredFieldsMap.put('SYouV.com', new Set<String>());
            requiredFieldsMap.get('SYouV.com').add('caseSubject');
            requiredFieldsMap.get('SYouV.com').add('caseDescrptn');
            requiredFieldsMap.get('SYouV.com').add('source');
            requiredFieldsMap.get('SYouV.com').add('subsource');
            return requiredFieldsMap;
        }
        return null;
    }
    public class RequiredResultNProduct{
        public Map<String, LIST<casesPush>> requiredCheckResult =  new Map<String, LIST<casesPush>>();
        public Set<String> contactDtls = new Set<String>();
        public Set<String> products = new Set<String>();
    }
    
    public static RequiredResultNProduct checkRequiredFields(List<casesPush> rawCasesLst, Map<String, Set<String>> requiredFieldsMap){
        RequiredResultNProduct obj =  new RequiredResultNProduct();
        obj.requiredCheckResult.put('Valid', new List<casesPush>());
        obj.requiredCheckResult.put('Invalid', new List<casesPush>());
        for(casesPush rawCs : rawCasesLst){
            Boolean checkflag = false;
            for(String fieldName : requiredFieldsMap.get('SYouV.com')){                
                if(String.isBlank(getFieldValueFromInstance(rawCs, fieldName))){
                    checkflag = true;
                }
            }
            if(checkflag){
                rawCs.status = 'Required fields are missing.';
                obj.requiredCheckResult.get('Invalid').add(rawCs);
            }else{
                if(String.isBlank(rawCs.phoneNumber) && String.isBlank(rawCs.email)){
                    rawCs.status = 'Required contact-informations are missing.';
                    obj.requiredCheckResult.get('Invalid').add(rawCs);
                }else{
                    obj.requiredCheckResult.get('Valid').add(rawCs);
                    if(String.isNotBlank(rawCs.phoneNumber))
                        obj.contactDtls.add(rawCs.phoneNumber);
                    if(String.isNotBlank(rawCs.email))
                        obj.contactDtls.add(rawCs.email);
                    //obj.products.add(rawCs.model);
                }
            }
        }
        return obj;
    }
    public static String getFieldValueFromInstance(casesPush rawCs, String fieldName){
        if(fieldName == 'caseSubject'){
            return rawCs.caseSubject;
        }else if(fieldName == 'caseDescrptn'){
            return rawCs.caseDescrptn;
        }else if(fieldName == 'source'){
            return rawCs.source;
        }else if(fieldName == 'subsource'){
            return rawCs.subsource;
        }
        return null;
    }
    public static Map<String, List<casesPush>> getJsonCaseMap(LIST<casesPush> jsonLeads, Map<String, String> callCenterMap){
        Map<String, List<casesPush>> csAPiRecordsMap = new Map<String, List<casesPush>>();
        for(casesPush rawCs : jsonLeads) {
            if(test.isRunningTest()){
                callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
            }
            String callCenterName = getCallCenter(callCenterMap, rawCs);
            if(String.isNotEmpty(rawCs.phoneNumber)) {
                if(csAPiRecordsMap.containsKey(rawCs.phoneNumber+'=='+callCenterName)){
                    csAPiRecordsMap.get(rawCs.phoneNumber+'=='+callCenterName).add(rawCs);          
                }else{
                    csAPiRecordsMap.put(rawCs.phoneNumber+'=='+callCenterName, new List<casesPush>{rawCs});
                }
            }                     
        }
        return csAPiRecordsMap;
    }
    public static String getCallCenter(Map<String,String> callCenterMap, casesPush cs){
        if(String.isNotBlank(cs.source) && String.isNotBlank(cs.subsource)){
            return callCenterMap.get(cs.source+'=='+cs.subsource) == 'Model Based' ? callCenterMap.get(cs.model) : callCenterMap.get(cs.source+'=='+cs.subsource);
        }
        return '';
    }
    
    public static InsertionObjectsDetail createInstancesForInsertion(List<casesPush> caseToAddLst, Map<String, Id> proNameIdMap, 
                                                                     Map<String, String> callcenterMap, Map<String, Contact> contactMap, String calledFrom)
    {
        InsertionObjectsDetail obj = new insertionObjectsDetail();
        String qryCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();                
        if(test.isRunningTest()){
            callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
        }

        for(casesPush cs : caseToAddLst){                    
            system.debug('New Case---');
            String phnNumEmail=cs.phoneNumber+';'+cs.email;
            obj.casesToBeInserted.put(phnNumEmail, getCaseInstance(cs, 'Query', qryCaseRTId, null, phnNumEmail, contactMap, calledFrom));                            
            //createInterestedProductMap(obj.intrestedProductsToBeInserted, proNameIdMap, cs, phoneNumCallC);
            //createTrackerMap(obj.iPsourceTrackerMap, cs, phoneNumCallC);
            cs.status = 'Case, Product Interest, Source tracker created.';
        }
        return obj;
    }
    
    public class InsertionObjectsDetail{
        Map<String, Case> casesToBeInserted = new Map<String, Case>();
        Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted = new Map<String, ACE_product_Interest__c>();
        Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap = new Map<String, List<ACE_Source_Tracker__c>>();
    }
    
    public static insertionObjectsDetail insertObjects(insertionObjectsDetail toBeInsrtObjs){
        List<Case> insertedCaseList;
        if(toBeInsrtObjs.casesToBeInserted.size() > 0){
            //system.debug('Lead Inserting ');
            insertedCaseList= toBeInsrtObjs.casesToBeInserted.values();
            Database.UpsertResult[] InsertionResult = Database.upsert(insertedCaseList, false);
            Integer indexcount = 0;
            for(Database.UpsertResult sr : InsertionResult){
                /*String keyString = insertedObjList[indexcount].MobilePhone+'=='+insertedCaseList[indexcount].Call_Center__c;
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(keyString,err.getMessage());
                        break;
                    }
                }
                else{
                    errorRecordsMap.put(keyString,'Success');
                }
                indexcount++;*/
            }
        }
        
        if(toBeInsrtObjs.iPsourceTrackerMap.size() > 0){  
            map<ID,ACE_Product_Interest__c> pIIDMap = new map<ID,ACE_Product_Interest__c>();
            List<ACE_Source_Tracker__c> sTrackerToBeInserted = new List<ACE_Source_Tracker__c>();
            /*for(String ipTrack : toBeInsrtObjs.iPsourceTrackerMap.keySet()){
                if(pInterestStr_RecMap.containsKey(ipTrack)){
                    for(ACE_Source_Tracker__c st : toBeInsrtObjs.iPsourceTrackerMap.get(ipTrack)){
                        pIIDMap.put(pInterestStr_RecMap.get(ipTrack).Id, pInterestStr_RecMap.get(ipTrack));
                        st.ACE_Product_Interest__c = pInterestStr_RecMap.get(ipTrack).Id;
                        sTrackerToBeInserted.add(st);
                    }
                }                       
            }*/
            Integer indexcount = 0;
            Database.SaveResult[] srListOfTracker = Database.Insert(sTrackerToBeInserted, false);
            for(Database.SaveResult sr : srListOfTracker){
                /*String productId = sTrackerToBeInserted.get(indexcount).ACE_Product_Interest__c;
                String leadId = pIIDMap.get(productId).Lead__c;
                /*String generateKey = mapOFIDLead.get(leadId).MobilePhone+'=='+mapOFIDLead.get(leadId).Call_Center__c+'=='+pIIDMap.get(productId).Name+'=='+sTrackerToBeInserted.get(indexcount).ACE_Source__c+'=='+sTrackerToBeInserted.get(indexcount).ACE_SubSource__c;
                 if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(generateKey,err.getMessage());
                        break;
                    }
                }
                else{
                    errorRecordsMap.put(generateKey,'Success');
                }
                indexcount++;*/
            }
        }
        system.debug(toBeInsrtObjs.casesToBeInserted);
        return toBeInsrtObjs;
    }
    
    public static Case getCaseInstance(casesPush cs, String recordType, String rtId, String proID, 
                                       String phnNumEmail, Map<String, Contact> contactMap, String calledFrom)
    {
        Case csInst = new Case();
        csInst.Subject = cs.caseSubject;
        csInst.Description = cs.caseDescrptn;
        csInst.Type = recordType;//cs.phoneNumber;
        //csInst.recordtypeid = rtId;            
        //if(recordType == 'prelaunch'){
            //csInst.Vehicle__c = proID;                
        //}
        //csInst.Call_Center__c = callcenter;
        String cPhone,cEmail;
        if(String.isNotBlank(phnNumEmail) && phnNumEmail.contains(';')){
            List<String> peLst=phnNumEmail.split(';');
            if(peLst!=null && peLst.size()>0){
                if(String.isNotBlank(peLst.get(0)) && peLst.get(0)!='null'){
                    cPhone=peLst.get(0);
                }
                if(peLst.size()>1 && String.isNotBlank(peLst.get(1)) && peLst.get(1)!='null'){
                    cEmail=peLst.get(1);
                }
            }
        }
        if(calledFrom == 'CasePush'){
            if(contactMap.containsKey(cs.phoneNumber)){
                csInst.ContactId = contactMap.get(cs.phoneNumber).Id;
            }else if(contactMap.containsKey(cs.email)){
                csInst.ContactId = contactMap.get(cs.email).Id;
            }
        }
        return csInst;
    }
    
    public static Map<String, List<ACE_Source_Tracker__c>> createTrackerMap(Map<String, List<ACE_Source_Tracker__c>> iPsrcTrkrMap, casesPush cs, String phoneNum){
        if(iPsrcTrkrMap.containskey(phoneNum)){
            iPsrcTrkrMap.get(phoneNum).add(getSourceTrackerInstance(cs));
        }else{
            iPsrcTrkrMap.put(phoneNum, new List<ACE_Source_Tracker__c>{getSourceTrackerInstance(cs)});
        }
        return iPsrcTrkrMap;
    }
    public static ACE_Source_Tracker__c getSourceTrackerInstance(casesPush cs){
        ACE_Source_Tracker__c st = new ACE_Source_Tracker__c();
        st.ACE_Source__c = cs.source;
        st.ACE_SubSource__c = cs.subsource;
        return st;
    }
}