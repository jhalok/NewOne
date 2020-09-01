/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Lead, Product Interest, Source Tracker from third party/ CSV upload.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>--
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        18-Dec-2019
* @modified       
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class ACE_LeadServiceUtil {
    public Static Map<String,String> errorRecordsMap = new Map<String,String>();
    public Static Map<Id,Lead> mapOFIDLead = new Map<Id,Lead> (); 
    public static Map<String, Set<String>> getRequiredFields(List<String> sourceSubsource){
        Map<String, Set<String>> requiredFieldsMap = new Map<String, Set<String>>();
        if(sourceSubsource[0] == 'SYouV.com'){
            requiredFieldsMap.put('SYouV.com', new Set<String>());
            requiredFieldsMap.get('SYouV.com').add('leadName');
            requiredFieldsMap.get('SYouV.com').add('leadNumber');
            requiredFieldsMap.get('SYouV.com').add('source');
            requiredFieldsMap.get('SYouV.com').add('subsource');
            requiredFieldsMap.get('SYouV.com').add('model');
            return requiredFieldsMap;
        }
        return null;
    }
    public static RequiredResultNProduct checkRequiredFields(List<ACE_ServiceUtil.leadsPush> leadRecords, Map<String, Set<String>> requiredFieldsMap){
        RequiredResultNProduct obj =  new RequiredResultNProduct();
        //Map<String, List<ACE_ServiceUtil.leadsPush>> checkRequiredResult = new Map<String, List<ACE_ServiceUtil.leadsPush>>();
        obj.requiredCheckResult.put('Valid', new List<ACE_ServiceUtil.leadsPush>());
        obj.requiredCheckResult.put('Invalid', new List<ACE_ServiceUtil.leadsPush>());
        for(ACE_ServiceUtil.leadsPush leadRec : leadRecords){
            Boolean checkflag = false;
            for(String fieldName : requiredFieldsMap.get('SYouV.com')){                
                if(String.isBlank(getFieldValueFromInstance(leadRec, fieldName))){
                    checkflag = true;
                }
            }
            if(checkflag){
                leadRec.status = 'Required fields are missing.';
                obj.requiredCheckResult.get('Invalid').add(leadRec);
            }else{
                obj.requiredCheckResult.get('Valid').add(leadRec);
                obj.contactNums.add(leadRec.leadNumber);
                obj.products.add(leadRec.model);
            }
        }
        return obj;
    }
    public static Map<String, List<ACE_ServiceUtil.leadsPush>> getJsonLeadMap(LIST<ACE_ServiceUtil.leadsPush> jsonLeads, Map<String, String> callCenterMap){
        Map<String, List<ACE_ServiceUtil.leadsPush>> ldAPiRecordsMap = new Map<String, List<ACE_ServiceUtil.leadsPush>>();
        for(ACE_ServiceUtil.leadsPush lead : jsonLeads) {
            if(test.isRunningTest()){
                callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
            }
            String callCenterName = getCallCenter(callCenterMap, lead);
            if(String.isNotEmpty(lead.leadNumber)) {
                if(ldAPiRecordsMap.containsKey(lead.leadNumber+'=='+callCenterName)){
                    ldAPiRecordsMap.get(lead.leadNumber+'=='+callCenterName).add(lead);          
                }else{
                    ldAPiRecordsMap.put(lead.leadNumber+'=='+callCenterName, new List<ACE_ServiceUtil.leadsPush>{lead});
                }
            }                     
        }
        return ldAPiRecordsMap;
    }
    public static Map<String, Id> getProductMap(Set<String> productNames){
        Map<String, Id> proNameIdMap = new Map<String, Id>();
        for(Product2 pro : [Select Id, Name from Product2 where Name IN:productNames]){
            proNameIdMap.put(pro.Name, pro.Id);
        }
        return proNameIdMap;
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
    public static List<Lead> getExistingLeads(Set<String> mobNums){
        LIST<Lead> existingLeads = [SELECT ID,Contact_Num_Call_Center__c,city,Call_Center__c, Vehicle__r.Name, MobilePhone,Phone,OwnerId,Email, ACE_Vehicle_Model__c, (Select Id,Name, Product__c, Lead__c, Product__r.Name from Product_Interests__r) FROM LEAD WHERE Contact_Num_Call_Center__c IN :mobNums];
        return existingLeads;
    }
    public static existingLeadsDetail getexistingLeadsDetail(List<Lead> existingLeads){
        existingLeadsDetail obj = new existingLeadsDetail();
        for(Lead lead : existingLeads){
            String ctnum;
            /*if(String.isNotBlank(lead.mobilePhone)){                        
if(obj.existingLeadsMap.containsKey(lead.MobilePhone+'=='+lead.Call_Center__c)){
obj.existingLeadsMap.get(lead.MobilePhone+'=='+lead.Call_Center__c).add(lead);          
}else{
obj.existingLeadsMap.put(lead.MobilePhone+'=='+lead.Call_Center__c, new List<lead>{lead});
}
ctnum = lead.mobilePhone;
}else if(String.isNotBlank(lead.phone)){
if(obj.existingLeadsMap.containsKey(lead.phone+'=='+lead.Call_Center__c)){
obj.existingLeadsMap.get(lead.phone+'=='+lead.Call_Center__c).add(lead);          
}else{
obj.existingLeadsMap.put(lead.phone+'=='+lead.Call_Center__c, new List<lead>{lead});
}
ctnum = lead.Phone;
}*/
            if(obj.existingLeadsMap.containsKey(lead.Contact_Num_Call_Center__c)){
                obj.existingLeadsMap.get(lead.Contact_Num_Call_Center__c).add(lead);          
            }else{
                obj.existingLeadsMap.put(lead.Contact_Num_Call_Center__c, new List<lead>{lead});
            }
            obj.leadRelatedInterestsMap.put(lead.Id, new Set<String>());
            for(ACE_Product_Interest__c pI : lead.Product_Interests__r){
                obj.leadRelatedInterestsMap.get(lead.Id).add(pI.Product__r.Name);
                //system.debug(obj.leadRelatedInterestsMap);
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
    public static insertionObjectsDetail createInstancesForInsertion(Map<String, List<ACE_ServiceUtil.leadsPush>> leadMap, existingLeadsDetail existingleadDtl, Map<String, Id> proNameIdMap, Map<String, String> callcenterMap, Map<String, Contact> contactMap, String calledFrom){
        InsertionObjectsDetail obj = new insertionObjectsDetail();        
        String preLaunchRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pre-launch Lead').getRecordTypeId();
        String callcenterRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();                
        
        if(test.isRunningTest()){
            callcenterMap = ACE_LeadServiceTest.getSourceSubsourceMap();
        }
        //system.debug(leadMap);
        for(String phoneNumCallC : leadMap.keySet()){                    
            for(ACE_ServiceUtil.leadsPush ld : leadMap.get(phoneNumCallC)){
                //String callcenterName = getCallCenter(callcenterMap, ld);                
                if(String.isNotBlank(ld.model) && System.Label.Pre_launch_Vehicle == ld.model){
                    /*if(existingleadDtl.existingLeadsMap.size() > 0){
integer counter=0;                        
if(existingleadDtl.existingLeadsMap.get(phoneNum+'=='+callcenterMap.get(ld.model)) != null){
for(Lead ldi : existingleadDtl.existingLeadsMap.get(phoneNum+'=='+callcenterMap.get(ld.model))){
if(ldi.Vehicle__c != null && ldi.Vehicle__r.Name == ld.model){                                        
counter++;
}                                    
}
}
if(counter == 0){                                    
obj.leadsToBeInserted.put(phoneNum+'=='+callcenterMap.get(ld.model), getLeadInstance(ld, 'preLaunch', preLaunchRTId, proNameIdMap.get(ld.model), callcenterMap.get(ld.model)));
ld.status = 'Prelaunch lead created.';
}else{
ld.status = 'Prelaunch lead already exist.';
}
}else{
obj.leadsToBeInserted.put(phoneNum+'=='+callcenterMap.get(ld.model), getLeadInstance(ld, 'preLaunch', preLaunchRTId, proNameIdMap.get(ld.model), callcenterMap.get(ld.model)));
ld.status = 'Prelaunch lead created.';
}*/
                }else{
                    system.debug('Inside Lead Creation Section '+phoneNumCallC);                    
                    if(existingleadDtl.existingLeadsMap.containsKey(phoneNumCallC)){
                        for(Lead ldi : existingleadDtl.existingLeadsMap.get(phoneNumCallC)){
                            system.debug(existingleadDtl.existingLeadsMap.get(phoneNumCallC));
                            Map<Boolean, Lead> isLeadUpdatedMap = getupdatedLead(ldi, ld);
                            for(Boolean isUpdated: isLeadUpdatedMap.keyset()){
                                if(isUpdated){
                                    system.debug('Pradhuman');
                                    obj.leadsToBeInserted.put(phoneNumCallC, ldi);
                                    ld.status = 'Lead updated, ';
                                }
                            }
                            //String cnum = String.isNotBlank(ldi.mobilePhone) ? ldi.mobilePhone : ldi.phone ;                                    
                            if(existingleadDtl.leadRelatedInterestsMap.get(ldi.Id).contains(ld.model)){
                                //system.debug('Enter---2');
                                if(! existingleadDtl.proInterestRelatedSourcesMap.get(ldi.Contact_Num_Call_Center__c+'=='+ld.model).contains(ld.source+'-@-@-'+ld.subsource)){
                                    //system.debug('Enter---3');
                                    createTrackerMap(obj.iPsourceTrackerMap, ld, phoneNumCallC);
                                    ld.status += 'Source tracker created.';
                                }
                            }else{
                                createInterestedProductMap(obj.intrestedProductsToBeInserted, proNameIdMap, ld, phoneNumCallC);
                                createTrackerMap(obj.iPsourceTrackerMap, ld, phoneNumCallC);
                                ld.status += 'Product Interest, Source tracker created.';
                            }
                        }
                    }else{
                        system.debug('New Lead---');
                        obj.leadsToBeInserted.put(phoneNumCallC, getLeadInstance(ld, 'callCenter', callcenterRTId, null, phoneNumCallC.split('==')[1], contactMap, calledFrom));                            
                        createInterestedProductMap(obj.intrestedProductsToBeInserted, proNameIdMap, ld, phoneNumCallC);
                        createTrackerMap(obj.iPsourceTrackerMap, ld, phoneNumCallC);
                        ld.status = 'Lead, Product Interest, Source tracker created.';
                    }
                }
            }            
        }
        system.debug(obj.leadsToBeInserted);
        
        return obj;
    }
    public static Map<Boolean, Lead> getupdatedLead(Lead ldi, ACE_ServiceUtil.leadsPush ld){
        Map<Boolean, Lead> isLeadUpdatedMap = new Map<Boolean, Lead>();
        if((String.isNotBlank(ld.city) || String.isNotBlank(ldi.email)) && (String.isBlank(ld.city) || String.isBlank(ldi.email))){
            if(String.isNotBlank(ld.city) && String.isBlank(ldi.city)){
                ldi.City = ld.city;
                isLeadUpdatedMap.put(true, ldi);
            }
            if(String.isNotBlank(ld.email) && String.isBlank(ldi.email)){
                ldi.email = ld.email;
                isLeadUpdatedMap.put(true, ldi);
            }
        }
        return isLeadUpdatedMap;
    }
    public static insertionObjectsDetail insertObjects(insertionObjectsDetail insertionObjs, Map<String, List<Lead>> existingLeadsMap, Map<String, ACE_Product_Interest__c> pInterestStr_RecMap){
        List<Lead> insertedObjList;
        if(insertionObjs.leadsToBeInserted.size() > 0){
            //system.debug('Lead Inserting ');
            insertedObjList= insertionObjs.leadsToBeInserted.values();
            Database.UpsertResult[] InsertionResult = Database.upsert(insertedObjList, false);
            Integer indexcount = 0;
            for(Database.UpsertResult sr : InsertionResult){
                String keyString = insertedObjList[indexcount].MobilePhone+'=='+insertedObjList[indexcount].Call_Center__c;
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(keyString,err.getMessage());
                        break;
                    }
                }
                else{
                    errorRecordsMap.put(keyString,'Success');
                }
                indexcount++;
            }
        }
        if(insertionObjs.intrestedProductsToBeInserted.size() > 0){
            //system.debug('intrestedProductInserting');    
                          
            for(String pIKeys : insertionObjs.intrestedProductsToBeInserted.keySet()){
                //system.debug('Inside---1');
                List<Lead> insertedLeads  = new List<Lead>();
                if(existingLeadsMap.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1])){
                    insertedLeads = existingLeadsMap.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]);
                }else if(insertionObjs.leadsToBeInserted.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1])){
                    Lead templed = insertionObjs.leadsToBeInserted.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]);
                    if(String.isNotBlank(templed.id)){
                        insertedLeads.add(templed);
                    }
                }
                for(Lead led : insertedLeads){
                    //system.debug('Inside---2');
                    //if(String.isNotBlank(led.Id)){}
                    if(String.isBlank(led.ACE_Vehicle_Model__c)){  
                        //system.debug('Inside---3');
                        mapOFIDLead.put(led.Id,led);
                        insertionObjs.intrestedProductsToBeInserted.get(pIKeys).Lead__c = led.Id;                                                                    
                    }
                }
            }
            List<ACE_Product_Interest__c> pIList = insertionObjs.intrestedProductsToBeInserted.values();
            Database.SaveResult[] srListOfPI = Database.Insert(pIList, false);
            Integer IndexCount = 0; 
            for(Database.SaveResult sr : srListOfPI){
                String mkey = pIList[IndexCount].Lead__c;
                mkey = mapOFIDLead.get(mkey).MobilePhone+'=='+mapOFIDLead.get(mkey).Call_Center__c+'=='+pIList[IndexCount].Name;
                system.debug('mkey'+mkey);
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(mkey,err.getMessage());
                        break;
                    }
                } else{
                    errorRecordsMap.put(mkey,'Success');
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
                        pIIDMap.put(pInterestStr_RecMap.get(ipTrack).Id, pInterestStr_RecMap.get(ipTrack));
                        st.ACE_Product_Interest__c = pInterestStr_RecMap.get(ipTrack).Id;
                        sTrackerToBeInserted.add(st);
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
            Database.SaveResult[] srListOfTracker = Database.Insert(sTrackerToBeInserted, false);
            for(Database.SaveResult sr : srListOfTracker){
                String productId = sTrackerToBeInserted.get(indexcount).ACE_Product_Interest__c;
                String leadId = pIIDMap.get(productId).Lead__c;
                String generateKey = mapOFIDLead.get(leadId).MobilePhone+'=='+mapOFIDLead.get(leadId).Call_Center__c+'=='+pIIDMap.get(productId).Name+'=='+sTrackerToBeInserted.get(indexcount).ACE_Source__c+'=='+sTrackerToBeInserted.get(indexcount).ACE_SubSource__c;
                 if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {
                        errorRecordsMap.put(generateKey,err.getMessage());
                        break;
                    }
                }
                else{
                    errorRecordsMap.put(generateKey,'Success');
                }
                indexcount++;
            }
        }
        system.debug(insertionObjs.leadsToBeInserted);
        return insertionObjs;
    }
    public static List<ACE_ServiceUtil.leadsPush> getInsertionResponse(Map<String, List<ACE_ServiceUtil.leadsPush>> apiJsonLeadNProductDetail, InsertionObjectsDetail insertedObjInstanced){
        List<ACE_ServiceUtil.leadsPush> leadResponse = new List<ACE_ServiceUtil.leadsPush>();        
        
        for(String mKey : apiJsonLeadNProductDetail.keySet()){
            if(insertedObjInstanced.leadsToBeInserted.containsKey(mKey)){
                system.debug(insertedObjInstanced.leadsToBeInserted);
                for(ACE_ServiceUtil.leadsPush leadRec: apiJsonLeadNProductDetail.get(mKey)){                    
                    leadRec.leadResponse = new ACE_ServiceUtil.LeadStatus();
                    leadRec.leadResponse.status = errorRecordsMap.get(mKey);
                    leadRec.leadResponse.sfLeadRecId = insertedObjInstanced.leadsToBeInserted.get(mKey).Id;
                    if(insertedObjInstanced.intrestedProductsToBeInserted.containsKey(mKey+'=='+leadRec.model)){    
                        productIntrestProcess(insertedObjInstanced, leadRec,  mKey);
                    }
                    leadResponse.add(leadRec);
                }
            }else{
                for(ACE_ServiceUtil.leadsPush leadRec: apiJsonLeadNProductDetail.get(mKey)){
                    leadRec.leadResponse = new ACE_ServiceUtil.LeadStatus();
                    leadRec.leadResponse.status = 'Already Exsits';
                    if(insertedObjInstanced.intrestedProductsToBeInserted.containsKey(mKey+'=='+leadRec.model)){ 
                        system.debug('-->'+mKey+'=='+leadRec.model);
                        leadRec.leadResponse.productInterests.status = errorRecordsMap.get(mKey+'=='+leadRec.model);
                        leadRec.leadResponse.productInterests.sfProductIntrestRecId = insertedObjInstanced.intrestedProductsToBeInserted.get(mKey+'=='+leadRec.model).Id;
                        if(insertedObjInstanced.iPsourceTrackerMap.containsKey(mKey+'=='+leadRec.model)){                           
                            sourceTrackerProcess(insertedObjInstanced, leadRec, mKey );                     
                        }
                    }else{
                        leadRec.leadResponse.productInterests.status = 'Already Exsits';
                        if(insertedObjInstanced.iPsourceTrackerMap.containsKey(mKey+'=='+leadRec.model+'=='+leadRec.source+'=='+leadRec.subsource)){                           
                            sourceTrackerProcess(insertedObjInstanced, leadRec, mKey );                         
                        }else{
                            system.debug('P1');
                            Boolean checkFlag = true;
                            if(insertedObjInstanced.iPsourceTrackerMap.containsKey(mKey+'=='+leadRec.model+'=='+leadRec.source+'=='+leadRec.subsource)){
                                system.debug('P2');
                                for(ACE_Source_Tracker__c sourceTracker : insertedObjInstanced.iPsourceTrackerMap.get(mKey+'=='+leadRec.model+'=='+leadRec.source+'=='+leadRec.subsource)){
                                    if(sourceTracker.ACE_source__c == leadRec.source && sourceTracker.ACE_subsource__c == leadRec.subsource){
                                        checkFlag = false;
                                        leadRec.leadResponse.productInterests.sourceTrackers.status = errorRecordsMap.get(mKey+'=='+leadRec.model+'=='+leadRec.source+'=='+leadRec.subsource);
                                        leadRec.leadResponse.productInterests.sourceTrackers.sfProductIntrestRecId = sourceTracker.Id;
                                        break;
                                    }
                                }
                                if(checkFlag){
                                    system.debug('P3');
                                    leadRec.leadResponse.productInterests.sourceTrackers.status = 'Already Exsits';
                                }
                            }else{
                                system.debug('P4');
                                leadRec.leadResponse.productInterests.sourceTrackers.status = 'Already Exsits';
                            }
                            
                        }
                    }
                    leadResponse.add(leadRec);
                }
            }            
        }
        return leadResponse;
    }
    public static void productIntrestProcess(InsertionObjectsDetail insertedObjInstanced, ACE_ServiceUtil.leadsPush leadRec, String mKey){
        leadRec.leadResponse.productInterests.status = errorRecordsMap.get(mKey+'=='+leadRec.model);
        leadRec.leadResponse.productInterests.sfProductIntrestRecId = insertedObjInstanced.intrestedProductsToBeInserted.get(mKey+'=='+leadRec.model).Id;
        sourceTrackerProcess(insertedObjInstanced, leadRec, mKey);
    }
    public static void sourceTrackerProcess(InsertionObjectsDetail insertedObjInstanced, ACE_ServiceUtil.leadsPush leadRec, String mKey ){
        for(ACE_Source_Tracker__c sourceTracker : insertedObjInstanced.iPsourceTrackerMap.get(mKey+'=='+leadRec.model)){
            if(sourceTracker.ACE_source__c == leadRec.source && sourceTracker.ACE_subsource__c == leadRec.subsource){                                   
                leadRec.leadResponse.productInterests.sourceTrackers.status = errorRecordsMap.get(mKey+'=='+leadRec.model+'=='+sourceTracker.ACE_source__c+'=='+sourceTracker.ACE_subsource__c);
                leadRec.leadResponse.productInterests.sourceTrackers.sfProductIntrestRecId = sourceTracker.Id;
                break;
            }
        }                           
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
    public static String getCallCenter(Map<String,String> callCenterMap, ACE_ServiceUtil.leadsPush ld){
        if(String.isNotBlank(ld.source) && String.isNotBlank(ld.subsource)){
            return callCenterMap.get(ld.source+'=='+ld.subsource) == 'Model Based' ? callCenterMap.get(ld.model) : callCenterMap.get(ld.source+'=='+ld.subsource);
        }
        return '';
    }
    public static Lead getLeadInstance(ACE_ServiceUtil.leadsPush ld, String recordType, String rtId, String proID, String callcenter, Map<String, Contact> contactMap, String calledFrom){
        Lead leadInst = new lead();
        leadInst.Ext_Id__c = ld.leadName+ld.leadNumber;
        leadInst.LastName = ld.leadName;
        leadInst.Company = ld.leadName+'household';
        leadInst.MobilePhone = ld.leadNumber;
        leadInst.Email =  ld.email;// added
        leadInst.City= ld.city;
        leadInst.State= ld.state;
        leadInst.recordtypeid = rtId;            
        if(recordType == 'prelaunch'){
            leadInst.Vehicle__c = proID;                
        }
        leadInst.Call_Center__c = callcenter;
        //leadInst.Service__c = 'a0E5D000003PwqrUAC';  
        if(calledFrom == 'LeadPush'){
            leadInst.Related_Contact__c = contactMap.containsKey(ld.leadNumber) ? contactMap.get(ld.leadNumber).Id : null;
        }else if(calledFrom == 'referFriend'){
            leadInst.Referred_By__c = contactMap.containsKey(ld.leadNumber) ? contactMap.get(ld.leadNumber).Id : null;
        }
        return leadInst;
    }
    public static Map<String, List<ACE_Source_Tracker__c>> createTrackerMap(Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap, ACE_ServiceUtil.leadsPush ld, String phoneNumCallC){
        if(iPsourceTrackerMap.containskey(phoneNumCallC+'=='+ld.model)){
            iPsourceTrackerMap.get(phoneNumCallC+'=='+ld.model).add(getSourceTrackerInstance(ld));
        }else{
            iPsourceTrackerMap.put(phoneNumCallC+'=='+ld.model, new List<ACE_Source_Tracker__c>{getSourceTrackerInstance(ld)});
        }
        return iPsourceTrackerMap;
    }
    public static Map<String, ACE_product_Interest__c> createInterestedProductMap(Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted, Map<String, Id> proNameIdMap, ACE_ServiceUtil.leadsPush ld, String phoneNumCallC){            
        intrestedProductsToBeInserted.put(phoneNumCallC+'=='+ld.model, getInterestedProductInstance(ld, proNameIdMap));
        return intrestedProductsToBeInserted;
    }
    public static ACE_product_Interest__c getInterestedProductInstance(ACE_ServiceUtil.leadsPush ld, Map<String, Id> proNameIdMap){
        ACE_product_Interest__c pI = new ACE_product_Interest__c();
        pI.Name = ld.model;
        //pI.Lead__c = 
        pI.Prefered__c = true;
        pI.product__c = proNameIdMap.get(ld.model);
        //system.debug(proNameIdMap.get(ld.model));
        return pI;
    }
    public static ACE_Source_Tracker__c getSourceTrackerInstance(ACE_ServiceUtil.leadsPush ld){
        ACE_Source_Tracker__c st = new ACE_Source_Tracker__c();
        st.ACE_Source__c = ld.source;
        st.ACE_SubSource__c = ld.subsource;
        return st;
    }
    public static String getFieldValueFromInstance(ACE_ServiceUtil.leadsPush leadRec, String fieldName){
        if(fieldName == 'leadName'){
            return leadRec.leadName;
        }else if(fieldName == 'leadNumber'){
            return leadRec.leadNumber;
        }else if(fieldName == 'source'){
            return leadRec.source;
        }else if(fieldName == 'subsource'){
            return leadRec.subsource;
        }else if(fieldName == 'model'){
            return leadRec.model;
        }
        return null;
    }
    public class leadAPiRecordsMap{
        public Map<String, List<ACE_ServiceUtil.leadsPush>> ldAPiRecordsMap = new Map<String, List<ACE_ServiceUtil.leadsPush>>();
        public List<String> products = new List<String>();
    }
    public class RequiredResultNProduct{
        public Map<String, LIST<ACE_ServiceUtil.leadsPush>> requiredCheckResult =  new Map<String, LIST<ACE_ServiceUtil.leadsPush>>();
        public Set<String> contactNums = new Set<String>();
        public Set<String> products = new Set<String>();
    }
    public class existingLeadsDetail{
        public Map<String, List<Lead>> existingLeadsMap = new Map<String, List<Lead>>();
        public Map<String, Set<String>> leadRelatedInterestsMap = new Map<String, Set<String>>();
        public Map<String, ACE_Product_Interest__c> pInterestStr_RecMap = new Map<String, ACE_Product_Interest__c>();
        public Map<String, Set<String>> proInterestRelatedSourcesMap = new Map<String, Set<String>>();
    }
    public class InsertionObjectsDetail{
        Map<String, Lead> leadsToBeInserted = new Map<String, Lead>();
        Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted = new Map<String, ACE_product_Interest__c>();
        Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap = new Map<String, List<ACE_Source_Tracker__c>>();
    }
}