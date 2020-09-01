/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Employee Referral Contact Form Creation.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Saikrishna   <saikrishna.omkaram@in.pwc.com>
* @modifiedBy     Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @maintainedBy   Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @version        1.0
* @created        2019-11-8
* @modified       2019-11-8
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

public class ACE_ContactInsertController {
    @AuraEnabled
    public static List <String> getselectOptions(sObject objObject, string fld) {
       
        List <String> allOpts = new list <String> ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }
    @AuraEnabled
    public static id saveRecord(contact objDetail,list<lead> ListLead)
    {
        system.debug('entered from controller');
        id cont;
        list<lead> leads = new list<lead>();
        if(objDetail !=  null){
             Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee Contact').getRecordTypeId();
            contact con = objDetail;
            con.RecordTypeId = devRecordTypeId;
            insert con;
            cont = con.id;
            system.debug('con.id-->'+con.id);
            system.debug('size--->'+ListLead.size());
            if(ListLead.size()> 0){
                for(Lead ls:ListLead){
                    ls.Referred_By__c = con.id;
                    leads.add(ls);                    
                }
                if(leads.size()> 0){
                    insert leads;
                }
            }
        }        
        return cont;  
    }
    @AuraEnabled
    public static List<Lead> saveLeads(List<Lead> ListLead) {
        system.debug(ListLead);
        insert ListLead;
        return ListLead;
    }
    @AuraEnabled
    public static Contact getContactRecord(String Id){
        return [select id,Name From Contact Where Id=:Id];
    } 
    
}