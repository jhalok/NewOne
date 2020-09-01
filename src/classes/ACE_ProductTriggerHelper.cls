/*
* Triggre helper class for ACE_ProductTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @version        1.0
* @created        2020-01-07
* @systemLayer    Trigger
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class ACE_ProductTriggerHelper {
    /* 
     * Function for update the record type id of leads from pre-launch to call center
     * this function is performing the lead update
     */
    public static void updateLeadRecordType(List < Product2 > newProducts) {
        List < String > allProductsNotPreLounch = new List < String > ();
        for (Product2 produ: newProducts) {
            if (produ.Is_Prelaunch__c == false) {
                allProductsNotPreLounch.add(produ.id);
            }
        }
        if (allProductsNotPreLounch.size() > 0) {
			List < ACE_Product_Interest__c > allProductOfInter = [select id, Name, Lead__c,
                Lead__r.MobilePhone, Lead__r.RecordTypeId from ACE_Product_Interest__c where Product__c IN: allProductsNotPreLounch];
            String recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();
            Map < String, List < ACE_Product_Interest__c >> leadProductMap = new Map < String, List < ACE_Product_Interest__c >> ();
            List < Lead > allPreLounchLeads = new List < Lead > ();
            for (ACE_Product_Interest__c pidata: allProductOfInter) {
                Lead preLounchLead = new Lead();
                preLounchLead.ID = pidata.Lead__c;
                preLounchLead.MobilePhone = pidata.Lead__r.MobilePhone;
                preLounchLead.RecordTypeId = recordTypeId;
                if (!allPreLounchLeads.contains(preLounchLead)) {
                    allPreLounchLeads.add(preLounchLead);
                }
                if (leadProductMap.containsKey(pidata.Lead__r.MobilePhone)) {
                    List < ACE_Product_Interest__c > piList = leadProductMap.get(pidata.Lead__r.MobilePhone);
                    piList.add(pidata);
                    leadProductMap.put(pidata.Lead__r.MobilePhone, piList);
                } else {
                    List < ACE_Product_Interest__c > piList = new List < ACE_Product_Interest__c > ();
                    piList.add(pidata);
                    leadProductMap.put(pidata.Lead__r.MobilePhone, piList);
                }
            }
            List<Lead> Exleads = [Select id,Name,MobilePhone,RecordTypeId,(select id,Name From Product_Interests__r)
                                                from lead where MobilePhone IN : leadProductMap.keySet() and RecordTypeId =: recordTypeId];
            List<Lead> leadsForInsert = new List<Lead>();
            for(Lead ld :allPreLounchLeads){
                Boolean added = false;
                for(Lead exLead:Exleads){
                    if(exLead.MobilePhone == ld.MobilePhone){
                            exLead.Product_Interests__r.addAll(leadProductMap.get(ld.MobilePhone));
                            added = true;
                           leadsForInsert.add(exLead);
                    }
                }
                if(!added){
                     leadsForInsert.add(ld);
                }
            }
            System.debug(leadsForInsert);
            if (leadsForInsert.size() > 0) {
                System.debug(leadsForInsert);
                update allPreLounchLeads;
            }
        }
    }
}