public class ACE_LeadSearch {
 @AuraEnabled
    public static List <Lead> fetchLead (String searchMobileNo, String searchEmail)  {
       // List<Id> AllSearchedAccounts = new List<Id>();
       
            String leadQu = 'SELECT Id, URL__c, Name from Lead';
            system.debug('before.....'+leadQu);
            String whereClasuse = '';
            if(searchMobileNo != null){
                whereClasuse = ' where MobilePhone =\''+searchMobileNo+'\'';
            }
            else if(searchEmail != null){
                whereClasuse = ' where Email =\''+searchEmail+'\'';
                //whereClasuse += (whereClasuse != '' ? 'OR Email =\''+searchEmail+'\'' : 'Email =\''+searchEmail+'\'');
            }
            leadQu = leadQu +whereClasuse;
            system.debug('after.....'+leadQu);
            List<Lead> searchLead = Database.query(leadQu);
           /* for(Lead ld:searchContacts){
                if(!AllSearchedAccounts.contains(ld.Id)){
                    AllSearchedAccounts.add(ld.Id);
                }
            }
            system.debug('Lead SEARCH.....'+AllSearchedAccounts);
 
        return [select id,Name from Lead Where Id IN:AllSearchedAccounts];*/

        return searchLead;
    }
}