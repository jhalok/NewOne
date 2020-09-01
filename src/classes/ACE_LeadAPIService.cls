/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Lead, Product Interest, Source Tracker from third party/ CSV upload.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        26-Dec-2019
* @modified       26-Dec-2019
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
public class ACE_LeadAPIService {
    
    public Static String recordtype = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee Contact').getRecordTypeId();
    public static String processLeads(LIST<ACE_ServiceUtil.leadDetail> leadsToBeProcessed  ){
        
        Map<String,Map<String,Set<String>>> requiredFieldsMap = ACE_LeadAPIServiceUtil.getRequiredFields(new List<String>{'SYouV.com'});
        if(requiredFieldsMap.size() > 0){
			system.debug('Inside Process Leads');
			Map<String,String> callcenterMap = ACE_LeadAPIServiceUtil.getCallCenterMap();
            
			set<string> productSet = ACE_LeadAPIServiceUtil.getAllProducts(leadsToBeProcessed);
            
            Map<String, Boolean> proPrelaunchMap = ACE_LeadAPIServiceUtil.getPreLaunchMap(productSet);
            
            ACE_LeadAPIServiceUtil.RequiredResultNProduct checkRequiredResult = ACE_LeadAPIServiceUtil.checkRequiredFields(leadsToBeProcessed, requiredFieldsMap, callcenterMap, proPrelaunchMap);
            
            Map<String, Id> productMap = ACE_LeadAPIServiceUtil.getProductMap(checkRequiredResult.products); 
            
            //Map<String, List<ACE_ServiceUtil.leadDetail>> apiJsonLeadNProductDetail = ACE_LeadAPIServiceUtil.getJsonLeadMap(checkRequiredResult.requiredCheckResult.get('Valid'), callcenterMap);
        	
            Map<String, Contact> coNumContMap = ACE_LeadAPIServiceUtil.getContacts(checkRequiredResult.contactNums);
            
            List<Lead> existingLeads = ACE_LeadAPIServiceUtil.getExistingLeads(checkRequiredResult.requiredCheckResult.keySet());
            
            ACE_LeadAPIServiceUtil.existingLeadsDetail existLeadDtl = ACE_LeadAPIServiceUtil.getexistingLeadsDetail(existingLeads);
            
            ACE_LeadAPIServiceUtil.insertionObjectsDetail insertObjInstances = ACE_LeadAPIServiceUtil.createInstancesForInsertion(checkRequiredResult.requiredCheckResult, existLeadDtl, productMap, callcenterMap, coNumContMap, 'LeadPush');
			//system.debug(insertObjInstances);
            ACE_LeadAPIServiceUtil.InsertionObjectsDetail insertedObjInstanced = ACE_LeadAPIServiceUtil.insertObjects(insertObjInstances, existLeadDtl.existingLeadsMap, existLeadDtl.pInterestStr_RecMap, proPrelaunchMap);
        
        	List<ACE_ServiceUtil.leadDetail> leadResponse = ACE_LeadAPIServiceUtil.getInsertionResponse(checkRequiredResult.requiredCheckResult, insertedObjInstanced);
            //for(ACE_ServiceUtil.leadDetail leadDetailObj : leadResponse){
               // system.debug(leadDetailObj);
            //}
            String responseStr=JSON.serialize(leadResponse);
            system.debug('responseStr==>'+responseStr);
            return responseStr;
        }
        return null;
    }
    @AuraEnabled
    public static String processCSVRecords(String CSVRecordsJson){
        List<ACE_ServiceUtil.leadDetail> leadsforinsert = (List<ACE_ServiceUtil.leadDetail>)JSON.deserialize(CSVRecordsJson,List<ACE_ServiceUtil.leadDetail>.class);   
        //system.debug('leadsforinsert-->'+leadsforinsert);
        return processLeads(leadsforinsert);
    }
    public static String processEmpReferredLeads(LIST<ACE_ServiceUtil.ReferLeadFromEmployeeDetail> leadsToBeProcessed){
		 
        Set<String> contactNums = new Set<String>();
        Map<String, ACE_ServiceUtil.ReferLeadFromEmployeeDetail> referredLeadsMap = new Map<String, ACE_ServiceUtil.ReferLeadFromEmployeeDetail>();
        List<ACE_ServiceUtil.leadDetail> referleads = new List<ACE_ServiceUtil.leadDetail>();
        Map<String, String> leadContactPhoneNumMap = new Map<String, String>();
        Set<String> products = new Set<String>();
        for(ACE_ServiceUtil.ReferLeadFromEmployeeDetail obj : leadsToBeProcessed){
            for(ACE_ServiceUtil.leadDetail leadObj : obj.referleadsDeatil){
                referleads.add(leadObj);
				leadContactPhoneNumMap.put(leadObj.leadData.MobilePhone, obj.contactNumber);
				for(ACE_ServiceUtil.productInterestsDetail productObj : leadObj.relatedProductInterests ){
					 products.add(productObj.productInterest.Name);
				}
            }
            contactNums.add(obj.contactNumber);
            referredLeadsMap.put(obj.contactNumber, obj);
        }
        system.debug('contact --'+contactNums);
        Map<String, Contact> contactMap = ACE_LeadAPIServiceUtil.getContacts(contactNums); 
        system.debug('contact map--'+contactMap);
        for(ACE_ServiceUtil.ReferLeadFromEmployeeDetail cont: leadsToBeProcessed){       
            //System.debug('contains--'+contactMap.containsKey(cont.contactNumber)+'get--'+contactMap.get(cont.contactNumber).recordType.developerName);
            if(contactMap.containsKey(cont.contactNumber) && contactMap.get(cont.contactNumber).recordType.developerName != 'Employee Contact'){
				contactMap.remove(cont.contactNumber);
                referredLeadsMap.remove(cont.contactNumber);
            }
        }
        Map<String, Contact> contactsToBeInserted = new Map<String, Contact>();
        for(String referLd : referredLeadsMap.keyset()){
            if(!contactMap.containsKey(referLd)){
                contactsToBeInserted.put(referLd, getContact(referredLeadsMap.get(referLd)));
            }
        }
        if(contactsToBeInserted.size() > 0){
            List<Database.SaveResult> saveresultList = Database.insert( contactsToBeInserted.values(), false); 
            contactMap.putAll(contactsToBeInserted);
        }
        Map<String, Contact> leadNumContactMap = new Map<String, Contact>();
        for(String leadNum : leadContactPhoneNumMap.keySet()){
            leadNumContactMap.put(leadNum, contactMap.get(leadContactPhoneNumMap.get(leadNum)));
        }
        //---------------------------------------------------------------------------------------------------------------------------------------        
        Map<String,String> callcenterMap = ACE_LeadAPIServiceUtil.getCallCenterMap(); 
        Map<String,Map<String,Set<String>>> requiredFieldsMap = ACE_LeadAPIServiceUtil.getRequiredFields(new List<String>{'SYouV.com'});
        set<string> productSet = ACE_LeadAPIServiceUtil.getAllProducts(referleads);
        Map<String, Boolean> proPrelaunchMap = ACE_LeadAPIServiceUtil.getPreLaunchMap(productSet);
		ACE_LeadAPIServiceUtil.RequiredResultNProduct checkRequiredResult = ACE_LeadAPIServiceUtil.checkRequiredFields(referleads, requiredFieldsMap, callcenterMap, proPrelaunchMap);
		Map<String, Id> productMap = ACE_LeadAPIServiceUtil.getProductMap(products);
        //Map<String, List<ACE_ServiceUtil.leadDetail>> apiJsonLeadNProductDetail = ACE_LeadAPIServiceUtil.getJsonLeadMap(referleads, callcenterMap);
        List<Lead> existingLeads = ACE_LeadAPIServiceUtil.getExistingLeads(checkRequiredResult.requiredCheckResult.keySet());
        ACE_LeadAPIServiceUtil.existingLeadsDetail existLeadDtl = ACE_LeadAPIServiceUtil.getexistingLeadsDetail(existingLeads);
        ACE_LeadAPIServiceUtil.insertionObjectsDetail insertObjInstances = ACE_LeadAPIServiceUtil.createInstancesForInsertion(checkRequiredResult.requiredCheckResult, existLeadDtl, productMap, callcenterMap, leadNumContactMap, 'referFriend');
        ACE_LeadAPIServiceUtil.InsertionObjectsDetail insertedObjInstanced = ACE_LeadAPIServiceUtil.insertObjects(insertObjInstances, existLeadDtl.existingLeadsMap, existLeadDtl.pInterestStr_RecMap, proPrelaunchMap);//
    	
        //---------------------------------------------------------------------------------------------------------------------------------------
        return null;
    }
    public static Contact getContact(ACE_ServiceUtil.ReferLeadFromEmployeeDetail cont){
        Contact newContact = new Contact();
        newContact.lastName = cont.name;
        newContact.mobilePhone = cont.contactNumber;
        newContact.Business_Unit__c = cont.businessUnit;
        newContact.Do_you_own_a_Mahindra_vehicle__c = cont.ownMahindraVehicle;
		newContact.RecordTypeId = recordtype;
        //newContact.ACE_Own_mahindra_vehicle__c = cont.ownMahindraVehicle;
        //newContact.ACE_Business_Unit__c = cont.businessUnit;        
        return newContact;
    }
}