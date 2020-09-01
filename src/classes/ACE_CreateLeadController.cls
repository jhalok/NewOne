public class ACE_CreateLeadController {

    @AuraEnabled
    public static Lead LeadSave {
        get;
        set;
    }
    @AuraEnabled
    public static Case CaseSave {
        get;
        set;
    }

    @AuraEnabled
    public static Lead LeadSave(Lead cus, String linkedRec, List<ACE_Product_Interest__c > piList, String leadId) {
        if (leadId == '') {
            try {
                List < ACE_Service__c > serviceList;
                cus.Company = cus.FirstName + 'Household';
                System.debug(cus);
                insert cus;

                for (ACE_Product_Interest__c PiData: piList) {
                    PiData.Lead__c = cus.id;
                }
                insert piList;
                return cus;
            } catch (Exception E) {
                return null;
            }

        } else if (leadId != '') {
            try {
                
                Lead leaddata = [select id, FirstName, LastName, City, Email, Comments__c, Related_Contact__c, MobilePhone, Phone from Lead where Id =: leadId];
                System.debug(cus);
                if (cus.MobilePhone != '' && cus.MobilePhone != null) {
                    leaddata.phone = cus.MobilePhone;
                }
                if (cus.FirstName != '' && cus.FirstName != null) {
                    leaddata.FirstName = cus.FirstName;
                }
                if (cus.LastName != '' && cus.LastName != null) {
                    leaddata.LastName = cus.LastName;
                }
                if (cus.Email != '' && cus.Email != null) {
                    leaddata.Email = cus.Email;
                }
                if (cus.Comments__c != '' && cus.Comments__c != null) {
                    leaddata.Comments__c = cus.Comments__c;
                }
                if (cus.City != '' && cus.City != null) {
                    leaddata.City = cus.City;
                }
               
                 System.debug(leaddata);
                update leaddata;
               Map<String,ACE_Product_Interest__c> exProductInterest = new Map<String,ACE_Product_Interest__c>();
               system.debug(piList);

               List<ACE_Product_Interest__c> existingPi = [select id,Name,Product__c from  ACE_Product_Interest__c where Lead__c =:leaddata.id];

                for(ACE_Product_Interest__c pi: existingPi){
                    exProductInterest.put(pi.Product__c, pi);
                }

               List<String> newProductList = new List<String>();

               for(ACE_Product_Interest__c pi:piList){
                   newProductList.add(pi.Product__c);
               }
               List<Product2> allProducts = [select id,Name from Product2 where Id IN : newProductList];

                List<ACE_Product_Interest__c> productsForInsert = new List<ACE_Product_Interest__c>();
                for(ACE_Product_Interest__c pi:piList){
                    if(!exProductInterest.containskey(pi.Product__c)){
                         for(Product2 product:allProducts){
                             if(product.id == pi.Product__c){
                                pi.Lead__c = leaddata.id;
                                pi.Name = product.Name;
                                productsForInsert.add(pi);
                             }
                        }
                    }
                }
                system.debug(productsForInsert);
                insert productsForInsert;
                return leaddata;
            }
            catch(Exception E){
                System.debug(E.getMessage());
                return null;
            } 
        }
        else {
            return null;
        }

    }

    @AuraEnabled
    public static Case CaseSave(Lead cus, String linkedRec, List < ACE_Product_Interest__c > piList, String leadId) {

        Lead ld = new Lead();

        ld = LeadSave(cus, linkedRec, piList, leadId);

        Case cas = new Case();
        cas.Lead__c = ld.Id;
        // cas.Description = cus.get('Comments');
        //Added by Sanchayan
        String linkObjType, linkRecId;
        if (linkedRec != null && String.isNotBlank(linkedRec)) {
            if (linkedRec.indexOf('_') > 0) {
                List < String > spltStrArr = linkedRec.split('_');
                linkObjType = spltStrArr.get(0);
                linkRecId = spltStrArr.get(1);
                if (linkObjType != null && String.isNotBlank(linkObjType) && linkObjType == 'Contact' &&
                    linkRecId != null && String.isNotBlank(linkRecId)) {
                    cas.ContactId = linkRecId;
                }
            }
        }

        insert cas;
        return cas;
    }
    @AuraEnabled
    public static Lead getLeadData(String Id) {
        return [select id, FirstName, LastName, Email, City From Lead Where Id =: Id];
    }


}