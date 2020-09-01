/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Lead, Product Interest, Source Tracker from third party/ CSV upload.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        18-Dec-2019
* @modified       20-Dec-2019
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

public class ACE_LeadService {
    
	public static String processLeads(LIST<ACE_ServiceUtil.leadsPush> leadsToBeProcessed  ){        
        system.debug(leadsToBeProcessed);
        Map<String, Set<String>> requiredFieldsMap = ACE_LeadServiceUtil.getRequiredFields(new List<String>{'SYouV.com'});
        
        if(requiredFieldsMap.size() > 0){
            
            ACE_LeadServiceUtil.RequiredResultNProduct checkRequiredResult = ACE_LeadServiceUtil.checkRequiredFields(leadsToBeProcessed, requiredFieldsMap);
            
			Map<String, Id> productMap = ACE_LeadServiceUtil.getProductMap(checkRequiredResult.products);

			Map<String,String> callcenterMap = ACE_LeadServiceUtil.getCallCenterMap();

            Map<String, List<ACE_ServiceUtil.leadsPush>> apiJsonLeadNProductDetail = ACE_LeadServiceUtil.getJsonLeadMap(checkRequiredResult.requiredCheckResult.get('Valid'), callcenterMap);//                        
            
            Map<String, Contact> coNumContMap = ACE_LeadServiceUtil.getContacts(checkRequiredResult.contactNums);
            
            List<Lead> existingLeads = ACE_LeadServiceUtil.getExistingLeads(apiJsonLeadNProductDetail.keySet());
            
            ACE_LeadServiceUtil.existingLeadsDetail existLeadDtl = ACE_LeadServiceUtil.getexistingLeadsDetail(existingLeads);
            //system.debug(existLeadDtl.existingLeadsMap);
            ACE_LeadServiceUtil.insertionObjectsDetail insertObjInstances = ACE_LeadServiceUtil.createInstancesForInsertion(apiJsonLeadNProductDetail, existLeadDtl, productMap, callcenterMap, coNumContMap, 'LeadPush');
            
            ACE_LeadServiceUtil.InsertionObjectsDetail insertedObjInstanced = ACE_LeadServiceUtil.insertObjects(insertObjInstances, existLeadDtl.existingLeadsMap, existLeadDtl.pInterestStr_RecMap);//
            
            List<ACE_ServiceUtil.leadsPush> leadResponse = ACE_LeadServiceUtil.getInsertionResponse(apiJsonLeadNProductDetail, insertedObjInstanced);
            for(ACE_ServiceUtil.leadsPush lead : leadResponse){
            	system.debug(lead.leadResponse);
            }
            //system.debug(leadResponse);
            for(ACE_ServiceUtil.leadsPush rec : leadResponse){
            	system.debug(JSON.serialize(rec.leadResponse));
            }
        	return JSON.serialize(leadResponse);
		}
    	return null;
    }
    public static String processEmpReferredLeads(LIST<ACE_ServiceUtil.ReferLeadFromEmployee> leadsToBeProcessed){
		        
        Set<String> contactNums = new Set<String>();
        Map<String, ACE_ServiceUtil.ReferLeadFromEmployee> referredLeadsMap = new Map<String, ACE_ServiceUtil.ReferLeadFromEmployee>();
        List<ACE_ServiceUtil.leadsPush> referleads = new List<ACE_ServiceUtil.leadsPush>();
        Map<String, String> leadContactPhoneNumMap = new Map<String, String>();
        Set<String> products = new Set<String>();
        for(ACE_ServiceUtil.ReferLeadFromEmployee obj : leadsToBeProcessed){
            for(ACE_ServiceUtil.leadsPush leadRec : obj.referleadsDeatil){
                referleads.add(leadRec);
                products.add(leadRec.model);
                leadContactPhoneNumMap.put(leadRec.leadNumber, obj.contactNumber);
            }
            contactNums.add(obj.contactNumber);
            referredLeadsMap.put(obj.contactNumber, obj);
        }
        Map<String, Contact> contactMap = ACE_LeadServiceUtil.getContacts(contactNums);        
        for(ACE_ServiceUtil.ReferLeadFromEmployee cont: leadsToBeProcessed){            
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
           	Insert contactsToBeInserted.values();
            contactMap.putAll(contactsToBeInserted);
        }
        Map<String, Contact> leadNumContactMap = new Map<String, Contact>();
        for(String leadNum : leadContactPhoneNumMap.keySet()){
            leadNumContactMap.put(leadNum, contactMap.get(leadContactPhoneNumMap.get(leadNum)));
        }
        //---------------------------------------------------------------------------------------------------------------------------------------
        Map<String, Id> productMap = ACE_LeadServiceUtil.getProductMap(products);
        Map<String,String> callcenterMap = ACE_LeadServiceUtil.getCallCenterMap();        
        Map<String, List<ACE_ServiceUtil.leadsPush>> apiJsonLeadNProductDetail = ACE_LeadServiceUtil.getJsonLeadMap(referleads, callcenterMap);
        List<Lead> existingLeads = ACE_LeadServiceUtil.getExistingLeads(apiJsonLeadNProductDetail.keySet());
        ACE_LeadServiceUtil.existingLeadsDetail existLeadDtl = ACE_LeadServiceUtil.getexistingLeadsDetail(existingLeads);
        ACE_LeadServiceUtil.insertionObjectsDetail insertObjInstances = ACE_LeadServiceUtil.createInstancesForInsertion(apiJsonLeadNProductDetail, existLeadDtl, productMap, callcenterMap, leadNumContactMap, 'referFriend');
        ACE_LeadServiceUtil.InsertionObjectsDetail insertedObjInstanced = ACE_LeadServiceUtil.insertObjects(insertObjInstances, existLeadDtl.existingLeadsMap, existLeadDtl.pInterestStr_RecMap);//
    	//---------------------------------------------------------------------------------------------------------------------------------------
        return null;
    }
    public static Contact getContact(ACE_ServiceUtil.ReferLeadFromEmployee cont){
        Contact newContact = new Contact();
        newContact.lastName = cont.name;
        newContact.mobilePhone = cont.contactNumber;
        newContact.Business_Unit__c = cont.businessUnit;
        newContact.Do_you_own_a_Mahindra_vehicle__c = cont.ownMahindraVehicle;
        //newContact.ACE_Own_mahindra_vehicle__c = cont.ownMahindraVehicle;
        //newContact.ACE_Business_Unit__c = cont.businessUnit;        
        return newContact;
    }
    @AuraEnabled
    public static String processCSVRecords(String CSVRecordsJson){
        List<ACE_ServiceUtil.leadsPush> leadsforinsert = (List<ACE_ServiceUtil.leadsPush>)JSON.deserialize(CSVRecordsJson,List<ACE_ServiceUtil.leadsPush>.class);        
        return processLeads(leadsforinsert);
    }
}