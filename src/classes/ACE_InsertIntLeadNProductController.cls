public class ACE_InsertIntLeadNProductController {
    
        
        public static String insertLeads(LIST<ACE_ServiceUtil.leadsPush> newLeads){
                           
            Map<String, List<ACE_ServiceUtil.leadsPush>> leadMap = new Map<String, List<ACE_ServiceUtil.leadsPush>>();            
            List<String> products = new List<String>();
            
            for(ACE_ServiceUtil.leadsPush lead :newLeads) {            
                if(String.isNotEmpty(lead.leadNumber)) {
                    if(leadMap.containsKey(lead.leadNumber)){
                        leadMap.get(lead.leadNumber).add(lead);          
                    }else{
                        leadMap.put(lead.leadNumber, new List<ACE_ServiceUtil.leadsPush>{lead});
                    }
                }
                products.add(lead.model);            
            }
              
            Map<String, Id> proNameIdMap = new Map<String, Id>();
            for(Product2 pro : [Select Id, Name from Product2 where Name IN:products]){
                proNameIdMap.put(pro.Name, pro.Id);
            }
            system.debug(proNameIdMap);
            MAP<ID, Contact> conIDMap;        
            if(leadMap.keySet().size() > 0) {
                conIDMap = new MAP<ID, Contact>([Select Id, MobilePhone,phone, AccountID, (Select Id from ProductInterests__r) FROM Contact where MobilePhone IN :leadMap.keySet() OR phone IN :leadMap.keySet()]);            
            }
            MAP<String, OpportunityContactRole> contactWithOppId = new MAP<String, OpportunityContactRole>();
            List<Opportunity> oppListToInsert = new LIST<Opportunity>();
            LIST<Task> taskListToInsert = new LIST<Task>();
            
            if(conIDMap.keySet().size() > 0) {
                
                for(OpportunityContactRole oppConRole :[SELECT ID, OpportunityId, ContactId FROM OpportunityContactRole WHERE ContactId IN :conIDMap.keySet()]) {                
                    contactWithOppId.put(oppConRole.OpportunityId, oppConRole);
                }            
                if(contactWithOppId.keySet().size() > 0) {
                    for(Opportunity opp :[SELECT ID, PartnerAccountID, OwnerId, Dealer__c, StageName FROM OPPORTUNITY WHERE ID IN :contactWithOppId.keySet()]) {
                        
                        Contact con = conIDMap.get((contactWithOppId.get(opp.id).ContactId));
                        ACE_ServiceUtil.leadsPush lead = leadMap.get(con.MobilePhone)[0];                    
                        if(leadMap.containsKey(con.MobilePhone)){
                            List<ACE_ServiceUtil.leadsPush> furtherLeads = new List<ACE_ServiceUtil.leadsPush>();
                            Integer flag = 0;
                            for(ACE_ServiceUtil.leadsPush ld : leadMap.get(con.MobilePhone)){
                                if(ld.model == System.Label.Pre_launch_Vehicle){
                                    flag = 1;
                                    furtherLeads.add(ld);
                                }                           
                            }
                            if(flag == 1){
                                leadMap.put(con.MobilePhone, furtherLeads);
                            }else{
                                leadMap.remove(con.MobilePhone);
                            }
                        }else if(leadMap.containsKey(con.phone)){
                            List<ACE_ServiceUtil.leadsPush> furtherLeads = new List<ACE_ServiceUtil.leadsPush>();
                            Integer flag = 0;
                            for(ACE_ServiceUtil.leadsPush ld : leadMap.get(con.phone)){
                                if(ld.model == System.Label.Pre_launch_Vehicle){
                                    flag = 1;
                                    furtherLeads.add(ld);
                                }                           
                            }
                            if(flag == 1){
                                leadMap.put(con.phone, furtherLeads);
                            }else{
                                leadMap.remove(con.phone);
                            }
                        } 
                        if(lead.partnerAccountId == opp.Dealer__c) {
                            if(opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_WON || opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_Lost) {                            
                                TASK tsk = ACE_Utility.getTask(opp.OwnerId, opp.id, '', ACE_Constants.TASK_Status_Open);
                                taskListToInsert.add(tsk);                                                       
                            }else {                            
                                Opportunity oppToInsert = ACE_Utility.getOpportunity(lead.leadname, lead.partnerAccountId, ACE_Constants.OPTY_STAGE_Enquiry, date.today().addDays(30), date.today(), userInfo.getUserId() );
                                //oppToInsert.Sales_consultant_Contact_ACE__c = lead.Related_Contact__c;                            
                                oppListToInsert.add(oppToInsert);                            
                            }                        
                        }else {                        
                            Opportunity oppToInsert = ACE_Utility.getOpportunity(lead.leadname, lead.partnerAccountId, ACE_Constants.OPTY_STAGE_Enquiry, date.today().addDays(30), date.today(), userInfo.getUserId());
                            //oppToInsert.Sales_consultant_Contact_ACE__c = lead.Related_Contact__c;                        
                            oppListToInsert.add(oppToInsert);
                        }
                    }
                }
            }
            if(leadMap.keySet().size() > 0){
                LIST<Lead> existingLeads = [SELECT ID,city,Call_Center__c, Vehicle__r.Name, MobilePhone,Phone,OwnerId,Email, ACE_Vehicle_Model__c, (Select Id, Product__c, Product__r.Name from Product_Interests__r) FROM LEAD WHERE MobilePhone IN :leadMap.keySet() OR phone IN :leadMap.keySet()];
                Map<String, List<Lead>> existingLeadsMap = new Map<String, List<Lead>>();
                Map<String, Set<String>> leadIdProductIntrestMap = new Map<String, Set<String>>();          
                Map<String, String> intrestedProductMap = new Map<String, String>();    
                Map<String, Set<String>> pITrackerMap = new Map<String, Set<String>>();
                
                if(existingLeads.size() > 0) {
                    for(Lead lead : existingLeads){
                        String ctnum;
                        if(String.isNotBlank(lead.mobilePhone)){                        
                            if(existingLeadsMap.containsKey(lead.MobilePhone+'=='+lead.Call_Center__c)){
                                existingLeadsMap.get(lead.MobilePhone+'=='+lead.Call_Center__c).add(lead);          
                            }else{
                                existingLeadsMap.put(lead.MobilePhone+'=='+lead.Call_Center__c, new List<lead>{lead});
                            }
                            ctnum = lead.mobilePhone;
                        }else if(String.isNotBlank(lead.phone)){
                            if(existingLeadsMap.containsKey(lead.phone+'=='+lead.Call_Center__c)){
                                existingLeadsMap.get(lead.phone+'=='+lead.Call_Center__c).add(lead);          
                            }else{
                                existingLeadsMap.put(lead.phone+'=='+lead.Call_Center__c, new List<lead>{lead});
                            }
                            ctnum = lead.Phone;
                        }
                        leadIdProductIntrestMap.put(lead.Id, new Set<String>());
                        for(ACE_Product_Interest__c pI : lead.Product_Interests__r){
                            leadIdProductIntrestMap.get(lead.Id).add(pI.Product__r.Name);
                            system.debug(leadIdProductIntrestMap);
                            intrestedProductMap.put(ctnum+'=='+lead.Call_Center__c+'=='+pI.Product__r.Name, pI.Id);
                        }
                    }
                    
                    if(intrestedProductMap.keySet().size() > 0){
                        
                        for(ACE_Source_Tracker__c sourceTracker : [Select ACE_Product_Interest__r.Name, ACE_Product_Interest__r.Lead__r.mobilePhone, ACE_Product_Interest__r.Lead__r.phone, ACE_Product_Interest__r.Lead__c, ACE_Product_Interest__c, ACE_Source__c, ACE_Subsource__c from ace_Source_Tracker__c where ACE_Product_Interest__c IN :intrestedProductMap.values()]){
                            string contNum = String.isNotBlank(sourceTracker.ACE_Product_Interest__r.Lead__r.mobilePhone) ? sourceTracker.ACE_Product_Interest__r.Lead__r.mobilePhone : sourceTracker.ACE_Product_Interest__r.Lead__r.phone;
                            if(pITrackerMap.containsKey(contNum+'=='+sourceTracker.ACE_Product_Interest__r.Name)){
                                pITrackerMap.get(contNum+'=='+sourceTracker.ACE_Product_Interest__r.Name).add(sourceTracker.ACE_Source__c+'-@-@-'+sourceTracker.ACE_SubSource__c);
                            }else{
                                pITrackerMap.put(contNum+'=='+sourceTracker.ACE_Product_Interest__r.Name,new Set<String>{sourceTracker.ACE_Source__c+'-@-@-'+sourceTracker.ACE_SubSource__c});
                            }
                        }                        
                    }
                }
                Map<String, Lead> leadsToBeInserted = new Map<String, Lead>();
                Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted = new Map<String, ACE_product_Interest__c>();
                Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap = new Map<String, List<ACE_Source_Tracker__c>>();
                
                String preLaunchRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pre-launch Lead').getRecordTypeId();
                String callcenterRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();                
                Map<String, String> callcenterMap = getCallCenter();
                
                for(String phoneNum : leadMap.keySet()){                    
                    for(ACE_ServiceUtil.leadsPush ld : leadMap.get(phoneNum)){
                        String callcenterName = getCallCenter(callcenterMap, ld);
                        system.debug(callcenterName);
                        if(String.isNotBlank(ld.model) && System.Label.Pre_launch_Vehicle == ld.model){
                            if(existingLeadsMap.size() > 0){
                                integer counter=0;
                                system.debug(ld.model+'===='+callcenterMap.get(ld.model)+'====='+callcenterMap.get(ld.model));
                                if(existingLeadsMap.get(phoneNum+'=='+callcenterMap.get(ld.model)) != null){
                                    for(Lead ldi : existingLeadsMap.get(phoneNum+'=='+callcenterMap.get(ld.model))){
                                        if(ldi.Vehicle__c != null && ldi.Vehicle__r.Name == ld.model){                                        
                                            counter++;
                                        }                                    
                                    }
                                }
                                if(counter == 0){                                    
                                    leadsToBeInserted.put(phoneNum+'=='+callcenterMap.get(ld.model), getLeadInstance(ld, 'preLaunch', preLaunchRTId, proNameIdMap.get(ld.model), callcenterMap.get(ld.model)));
                                	ld.status = 'Prelaunch lead created.';
                                }else{
                                    ld.status = 'Prelaunch lead already exist.';
                                }
                            }else{
                                leadsToBeInserted.put(phoneNum+'=='+callcenterMap.get(ld.model), getLeadInstance(ld, 'preLaunch', preLaunchRTId, proNameIdMap.get(ld.model), callcenterMap.get(ld.model)));
                            	ld.status = 'Prelaunch lead created.';
                            }
                        }else{
                            system.debug('Inside Lead Creation Section');
                            if(existingLeadsMap.containsKey(phoneNum+'=='+callcenterName)){
                                for(Lead ldi : existingLeadsMap.get(phoneNum+'=='+callcenterName)){
                                    if((String.isNotBlank(ld.city) || String.isNotBlank(ld.email)) && (String.isBlank(ldi.city) || String.isBlank(ldi.email))){
                                        if(String.isNotBlank(ld.city) && String.isBlank(ldi.city)){
                                            ldi.City = ld.city;
                                        }
                                        if(String.isNotBlank(ld.email) && String.isBlank(ldi.email)){
                                            ldi.email = ld.email;
                                        }
                                        leadsToBeInserted.put(phoneNum+'=='+callcenterName, ldi);
                                        ld.status = 'Lead updated, ';
                                    }
                                    String cnum = String.isNotBlank(ldi.mobilePhone) ? ldi.mobilePhone : ldi.phone ;                                    
                                    if(leadIdProductIntrestMap.get(ldi.Id).contains(ld.model)){
                                        system.debug('Enter---2');
                                        if(! pITrackerMap.get(cnum+'=='+ld.model).contains(ld.source+'-@-@-'+ld.subsource)){
                                            system.debug('Enter---3');
                                            createTrackerMap(iPsourceTrackerMap, ld, callcenterName);
                                            ld.status += 'Source tracker created.';
                                        }
                                    }else{
                                        createInterestedProductMap(intrestedProductsToBeInserted, proNameIdMap, ld, callcenterName);
                                        createTrackerMap(iPsourceTrackerMap, ld, callcenterName);
                                        ld.status += 'Product Interest, Source tracker created.';
                                    }
                                }
                            }else{
                                system.debug('New Lead---'+callcenterName);
                                leadsToBeInserted.put(phoneNum+'=='+callcenterName, getLeadInstance(ld, 'callCenter', callcenterRTId, null, callcenterName));                            
                                createInterestedProductMap(intrestedProductsToBeInserted, proNameIdMap, ld, callcenterName);
                                createTrackerMap(iPsourceTrackerMap, ld, callcenterName);
                                ld.status = 'Lead, Product Interest, Source tracker created.';
                            }
                        }
                    }
                }
                /*if(leadsToBeInserted.size() > 0){
                    system.debug('Lead Inserting ');
                    Upsert leadsToBeInserted.values();
                }
                if(intrestedProductsToBeInserted.size() > 0){
                    system.debug('intrestedProductInserting');                    
                    for(String pIKeys : intrestedProductsToBeInserted.keySet()){
                        system.debug('Inside---1');
                        List<Lead> insertedLeads  = new List<Lead>();
                        if(existingLeadsMap.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1])){
                            insertedLeads = existingLeadsMap.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]);
                        }else if(leadsToBeInserted.containsKey(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1])){
                            insertedLeads.add(leadsToBeInserted.get(pIKeys.split('==')[0]+'=='+pIKeys.split('==')[1]));
                        }
                        for(Lead led : insertedLeads){
                            system.debug('Inside---2');
                            if(String.isBlank(led.ACE_Vehicle_Model__c)){  
                                system.debug('Inside---3');
                                intrestedProductsToBeInserted.get(pIKeys).Lead__c = led.Id;                                                                    
                            }
                        }
                    }
                    Insert intrestedProductsToBeInserted.values();
                }
                if(iPsourceTrackerMap.size() > 0){                    
                    List<ACE_Source_Tracker__c> sTrackerToBeInserted = new List<ACE_Source_Tracker__c>();
                    for(String ipTrack : iPsourceTrackerMap.keySet()){
                        if(intrestedProductMap.containsKey(ipTrack)){
                            for(ACE_Source_Tracker__c st : iPsourceTrackerMap.get(ipTrack)){
                                st.ACE_Product_Interest__c = intrestedProductMap.get(ipTrack);
                                sTrackerToBeInserted.add(st);
                            }
                        }else if(intrestedProductsToBeInserted.containsKey(ipTrack)){
                            for(ACE_Source_Tracker__c st : iPsourceTrackerMap.get(ipTrack)){
                                st.ACE_Product_Interest__c = intrestedProductsToBeInserted.get(ipTrack).Id;
                                sTrackerToBeInserted.add(st);
                            }
                        }                        
                    }
                    Insert sTrackerToBeInserted;
                }*/
            }
            if(oppListToInsert.size() > 0) {
                insertOpps(JSON.serialize(oppListToInsert));            
            }
    
            if(taskListToInsert.size() > 0) {            
                insertTasks(JSON.serialize(taskListToInsert));
                        
            }
            return JSON.serialize(leadMap.values());
        }    
        @future
        public static void insertOpps(String oppStringList){
            List<Opportunity> oppListToInsert  = (List<Opportunity>)Json.deserialize(oppStringList,List<Opportunity>.class);
            LIST<Task> tasksListToInsert       = new LIST<Task>();
            insert oppListToInsert;        
            for(Opportunity opp: oppListToInsert){            
                Task tsk = ACE_Utility.getTask(opp.OwnerId, opp.id, ' ', ACE_Constants.TASK_Status_Open);
                tasksListToInsert.add(tsk);
            }
            insertTasks(JSON.serialize(tasksListToInsert));
        }
        
        @future
        public static void insertTasks(String taskStringList) {        
            LIST<Task> taskListsToInsert = (LIST<Task>) JSON.deserialize(taskStringList,LIST<Task>.class);        
            Insert taskListsToInsert;        
        }
        public static Lead getLeadInstance(ACE_ServiceUtil.leadsPush ld, String recordType, String rtId, String proID, String callcenter){
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
            leadInst.Service__c = 'a0E5D000003PwqrUAC';
            return leadInst;
        }
        public static ACE_product_Interest__c getInterestedProductInstance(ACE_ServiceUtil.leadsPush ld, Map<String, Id> proNameIdMap){
            ACE_product_Interest__c pI = new ACE_product_Interest__c();
            pI.Name = ld.model;
            //pI.Lead__c = 
            pI.Prefered__c = true;
            pI.product__c = proNameIdMap.get(ld.model);
            system.debug(proNameIdMap.get(ld.model));
            return pI;
        }
        public static ACE_Source_Tracker__c getSourceTrackerInstance(ACE_ServiceUtil.leadsPush ld){
            ACE_Source_Tracker__c st = new ACE_Source_Tracker__c();
            st.ACE_Source__c = ld.source;
            st.ACE_SubSource__c = ld.subsource;
            return st;
        }
        public static Map<String, ACE_product_Interest__c> createInterestedProductMap(Map<String, ACE_product_Interest__c> intrestedProductsToBeInserted, Map<String, Id> proNameIdMap, ACE_ServiceUtil.leadsPush ld, String callcenter){            
            intrestedProductsToBeInserted.put(ld.leadNumber+'=='+callcenter+'=='+ld.model, getInterestedProductInstance(ld, proNameIdMap));
            return intrestedProductsToBeInserted;
        }
        public static Map<String, List<ACE_Source_Tracker__c>> createTrackerMap(Map<String, List<ACE_Source_Tracker__c>> iPsourceTrackerMap, ACE_ServiceUtil.leadsPush ld, String callcenter){
            if(iPsourceTrackerMap.containskey(ld.leadNumber+'=='+callcenter+'=='+ld.model)){
                iPsourceTrackerMap.get(ld.leadNumber+'=='+callcenter+'=='+ld.model).add(getSourceTrackerInstance(ld));
            }else{
                iPsourceTrackerMap.put(ld.leadNumber+'=='+callcenter+'=='+ld.model, new List<ACE_Source_Tracker__c>{getSourceTrackerInstance(ld)});
            }
            return iPsourceTrackerMap;
        }
        public static Map<String,String> getCallCenter(){
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
    }