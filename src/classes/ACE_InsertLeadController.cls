/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Summary : Handler for insertLead Lightning component to insert Lead .
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @modifiedBy     Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @maintainedBy   Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @version        1.0
 * @created        2019-11-13
 * @modified       2019-11-13
 * @systemLayer    Lightning Component
 * @see            ????
 * @see            ????
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @changes
 * vX.X            firstname.lastname@pwc.com
 * YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
 *                 each line should be indented till left aligned with the previous description text.

 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */

public class ACE_InsertLeadController {
    
    @AuraEnabled
    public static MAP<String, LIST<FieldProperties>> getFieldsOnLayout() {
        
        LIST<FieldProperties> columnsFldsList;
        MAP<String, LIST<FieldProperties>> colFldMap = new MAP<String, LIST<FieldProperties>>();
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String>{ 'Lead-Call Center Lead Layout' });
        
        
        Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
        
        for (Metadata.LayoutSection section :layoutMd.layoutSections) {
            columnsFldsList = new LIST<FieldProperties>();
            for (Metadata.LayoutColumn column :section.layoutColumns) {
                if(column.layoutItems != null) {
                    for (Metadata.LayoutItem item :column.layoutItems) {
                        System.debug(item.field + ' & behavior is '+item.behavior);
                        if(String.valueOf(item.behavior) != 'ReadOnly'){
                            
                            FieldProperties props = new FieldProperties(item.field, String.valueOf(section.style),String.valueOf(item.behavior));
                            columnsFldsList.add(props);
                        }
                    }
                }
            }
            if(columnsFldsList.size() > 0){
                colFldMap.put(section.label, columnsFldsList);
            }
            
        }
        System.debug('colFldMap is '+JSON.serialize(colFldMap));
        return colFldMap;
    }
    
    
    //TO handle insertion of Leads.
    @AuraEnabled
    public static void insertLeads(LIST<Lead> newLeads){
        
        System.debug('inside insertLeads '+newLeads);
        Map<String, Contact> existingContactMap = new Map<String, Contact>();
        Map<String, Lead> leadMap = new Map<String, Lead>();
        //LIST<Lead> leadsNotToInsert = new LIST<Lead>();
        MAP<ID, Lead> LeadsToInsertMap = new MAP<ID, Lead>();
        USER curUser  = [SELECT ID, contact.AccountId FROM USER WHERE ID =:UserInfo.getUserId()];
        String leadPartnerAccountId = curUser.contact.AccountId;
        
        Lead existedConLead;
        
        for(Lead lead :newLeads) {
            lead.Company = lead.lastName;
            if(String.isNotEmpty(lead.MobilePhone)) {
                System.debug('lead Mob is '+lead.MobilePhone);
                leadMap.put(lead.MobilePhone, lead);
                //LeadsToInsertMap.put(lead.id, lead);
            } 
            else if(String.isNotEmpty(lead.phone)) {
                leadMap.put(lead.phone, lead);
            }
        }
        
        MAP<ID, Contact> conIDMap;
        // If contact has leads with same ph/mob number.
        if(leadMap.keySet().size() > 0) {
            
            conIDMap = new MAP<ID, Contact>([Select Id, MobilePhone, AccountID,Phone, (Select Id FROM ProductInterests__r) FROM Contact where MobilePhone IN :leadMap.keySet() OR phone IN :leadMap.keySet()]);
            
        }
        System.debug('conIDMap ' + conIDMap);
        
        //<OpportunityID, OppConRole>
        MAP<String, OpportunityContactRole> contactWithOppId = new MAP<String, OpportunityContactRole>();
        List<Opportunity> oppListToInsert = new LIST<Opportunity>();
        LIST<Task> taskListToInsert = new LIST<Task>();
        
        if(conIDMap.keySet().size() > 0) {
            
            for(OpportunityContactRole oppConRole :[SELECT ID, OpportunityId, ContactId FROM OpportunityContactRole WHERE ContactId IN :conIDMap.keySet()]) {
                //oppID.add(oppConRole.OpportunityId);
                contactWithOppId.put(oppConRole.OpportunityId, oppConRole);
            }
            System.debug('contactWithOppId ' + contactWithOppId);
            if(contactWithOppId.keySet().size() > 0) {
                for(Opportunity opp :[SELECT ID, PartnerAccountID, OwnerId, Dealer__c, StageName FROM OPPORTUNITY WHERE ID IN :contactWithOppId.keySet()]) {
                    
                    Contact con = conIDMap.get((contactWithOppId.get(opp.id).ContactId));
                    Lead lead = leadMap.containsKey(con.MobilePhone) ? leadMap.get(con.MobilePhone) :leadMap.get(con.phone);
                   
                    // If no lead is mapped with contact then remove it from the leadMap.

                    if(leadMap.containsKey(con.MobilePhone)){
                        leadMap.remove(con.MobilePhone);
                    }else{
                        leadMap.remove(con.phone);
                    }
                    String partnerAcc = leadPartnerAccountId != null ? leadPartnerAccountId : 'null';
                    System.debug('partnerAcc is '+partnerAcc);
                    // Prevent leads from inserting.
                    //leadsNotToInsert.add(lead);
                    //LeadsToInsertMap.remove(lead.id);
                    
                    //If partner account id of the opportunity = partner account id of lead(associated with contact)
                    if(partnerAcc == String.valueOf(opp.Dealer__c)){
                       
                        if(opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_WON && opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_Lost) {
                            //#TODO: Create a task for this Opp.
                            // Check for OLI = same as product Interest(from lead) then just add a task.
                            // else add new OLI in the same Opp. Also add Task.
                            System.debug('70 it is opp id is ' + opp.id);
                            TASK tsk = ACE_Utility.getTask(opp.OwnerId, opp.id, '', ACE_Constants.TASK_Status_Open);
                            taskListToInsert.add(tsk);
                            
                            
                        }
                        else {
                            System.debug('partnerAccountId is '+partnerAcc);
                            // Insert Opp .
                            Opportunity oppToInsert = ACE_Utility.getOpportunity(lead.lastName, partnerAcc, ACE_Constants.OPTY_STAGE_Enquiry, Date.valueOf(date.today()).addDays(30), date.today(),curUser.Id);
                            oppToInsert.Sales_consultant_Contact_ACE__c = lead.Related_Contact__c;
                            //#TODO: Any other field to pre populate? : Yes, Stage = Enquiry, close date=1 month from creation date,
                            // Enquiry date= lead creation date, prosppect application and type if available in lead, likely purchase from lead, partner account from lead
                            
                            /* @By Krishnan : Resolution comments :
                            * No field as prosppect application on lead.
                            * We don't have type on lead but leadSource.
                            * Partner account id added to dealer__c field on Opportunity.
                            */
                            system.debug(' oppListToInsert '+ oppListToInsert);
                            oppListToInsert.add(oppToInsert);
                            
                        }
                        
                    }
                    else {
                        // Insert Opp.(String name, String dealer, String stage, Date closeDate, Date enquiryDate
                        Opportunity oppToInsert = ACE_Utility.getOpportunity(lead.lastName, partnerAcc, ACE_Constants.OPTY_STAGE_Enquiry, Date.valueOf(date.today()).addDays(30), date.today(),curUser.Id);
                        oppToInsert.Sales_consultant_Contact_ACE__c = lead.Related_Contact__c;
                        //oppToInsert.PartnerAccountID = lead.partnerAccountId;
                        oppListToInsert.add(oppToInsert);
                    }
                }
            }
            else {
                // If no Opportunity Contact Role found.
                // This case is not going to happen as per the schema.
            }
        }
        // If no contact is matched with the lead
        if(leadMap.keySet().size() > 0){
            // Check for product interest within an existing lead. If product interest are same then add Task for that lead
            // else just add a new product interest for that lead.
            // In both the cases add tasks.
            // Check for Product interest: transmission type, fuel type, color, variant, seating capacity.
            LIST<Lead> existingLeads = [SELECT ID,MobilePhone,Phone,OwnerId,Email FROM LEAD WHERE MobilePhone IN :leadMap.keySet() OR phone IN :leadMap.keySet()];
            if(existingLeads.size() > 0) {
                //#ToDo: Create Activity
                System.debug(' >> dublicate lead exists ');
                for(Lead lead : existingLeads){
                    Task tsk = ACE_Utility.getTask(lead.OwnerId, '', lead.id, ACE_Constants.TASK_Status_Open);
                    taskListToInsert.add(tsk);
                    
                    Lead tempLead=leadMap.containsKey(lead.MobilePhone)?leadMap.get(lead.MobilePhone):leadMap.get(lead.phone);
                    //leadsNotToInsert.add(tempLead);
                    //leadMap.remove(tempLead.id);
                    if(leadMap.containsKey(tempLead.MobilePhone)){
                        leadMap.remove(tempLead.MobilePhone);
                    }else{
                        leadMap.remove(tempLead.phone);
                    }
                }
            }
            else {
                //create new lead
                System.debug('newly inserted leads are ');
                
            }
        }
        
        if(leadMap.size() > 0){
            // #TODO Add Product Interest too. Also fill "Total Price"
            Insert leadMap.values();
            System.debug('newly inserted leads ><><>  '+leadMap.values());

        }
        if(oppListToInsert.size() > 0) {
            insertOpps(JSON.serialize(oppListToInsert));
            
        }

        if(taskListToInsert.size() > 0) {
            System.debug('tasks to insert at 135 is 32435465768 '+taskListToInsert);
            insertTasks(JSON.serialize(taskListToInsert));
                    
        }
        /* if(leadsNotToInsert.size()> 0) {
            for(LEAD ld :leadsNotToInsert) {
                //ld.addError('Cannot insert Lead due to duplication');
                lead l;
                if(oppListToInsert.size() > 0) {
                    insertOpps(JSON.serialize(oppListToInsert));
                    
                }
                
                if(taskListToInsert.size() > 0) {
                    System.debug('tasks to insert at 135 is 32435465768 '+taskListToInsert);
                    insertTasks(JSON.serialize(taskListToInsert));
                    
                }
                Savepoint sp = Database.setSavepoint();
                try{
                    throw new DmlException();
                }
                catch(Exception e){
                    System.debug('We do not want to insert lead in these cases');
                    
                    ld.addError('Cannot insert Lead due to duplication');
                    Database.rollback(sp);
                } 
                finally{
                    
                }
            }
        } */
    }
    
    // To insert Opportunities and it's tasks. Written to optimize the trigger code.
    @future
    public static void insertOpps(String oppStringList){
        System.debug('oppStringList are -- '+oppStringList);
        List<Opportunity> oppListToInsert  = (List<Opportunity>)Json.deserialize(oppStringList,List<Opportunity>.class);
        LIST<Task> tasksListToInsert       = new LIST<Task>();
        insert oppListToInsert;

        // Need to query cause we aren't inserting Opportunity
        //LIST<Opportunity> oppList = [SELECT ID, OwnerId FROM Opportunity WHERE ID IN :oppListToInsert];
        // #TODO insert a Opportunity contact role for the newly created Opportunities too.
        for(Opportunity opp: oppListToInsert){
            // insert Tasks for the inserted Opportunities.
            System.debug('ownerId of new opp is '+opp);
            Task tsk = ACE_Utility.getTask(opp.OwnerId, opp.id, '', ACE_Constants.TASK_Status_Open);
            tasksListToInsert.add(tsk);
        }
        Insert tasksListToInsert;
    }
    
    @future
    public static void insertTasks(String taskStringList) {
        System.debug('task need to be inserted ' + taskStringList);
        LIST<Task> taskListsToInsert = (LIST<Task>) JSON.deserialize(taskStringList,LIST<Task>.class);
        System.debug('deserialised tsks are ' + taskListsToInsert);
        Insert taskListsToInsert;
        System.debug('inserted tasks are ' + taskListsToInsert);
    }
        
    // Wrapper class to get fields on layout
    public class FieldProperties{
        
        @AuraEnabled
        public String columnName{get;set;}
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String style;
        @AuraEnabled
        public Boolean required;
        
        public FieldProperties(String fld, String sty, String req){
            fieldName  = fld;
            style      = sty;
            required   = req == 'Required' ? true : false;
        }
    }
}