global class ACE_pushLeadsIntoDialerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global final String ldquery;
    global List<Lead> leadList;
    List<Lead> updateLeads = new List<Lead>();
        
    global ACE_pushLeadsIntoDialerBatch(List<lead> leadList){
        this.leadList = leadList;
    }
    
    global List<lead> start(Database.BatchableContext BC){
        return leadList;
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> ldList){
        List<ACE_ServiceUtil.mrcdialerLeads> dialerList = new List<ACE_ServiceUtil.mrcdialerLeads>();
        Set<Id> serviceIds =  new Set<Id>();
        Map<Id,ACE_service__c> serviceMap = new  Map<Id,ACE_service__c>();
        
        system.debug(ldList);
        //select id, Name, Email from User where id in('0055D000002a49hQAA','0055D000002iv8KQAQ','0055D000002a49hQAA','0055D000002ZfpUQAS','0055D000002a49mQAA','0055D000002a49cQAA'
        //Set<Id> userIdSet = new Map<Id,User>([select id, Name, Email from User where id in('0055D000002a49hQAA')]).keyset();
        for(lead leadrec:ldList){
            if(leadrec.Service__c!=null)
            serviceIds.add(leadrec.Service__c);
            else
            serviceIds.add('a0E5D000003PwqrUAC');    
        }
        system.debug(serviceIds);
        
        for(ACE_service__c serviceRecord  : [select Id,Service_Code__c,name from ACE_service__c where Id in:serviceIds]){
            serviceMap.put(serviceRecord.Id,serviceRecord);
        }
        system.debug(serviceMap);
        if(serviceMap.keyset().size()>0){
            for(lead leadrec:ldList){
                ACE_ServiceUtil.mrcdialerLeads leadInst = new ACE_ServiceUtil.mrcdialerLeads();
                if(leadrec.Call_Type__c == null || leadrec.Call_Type__c == '' || leadrec.Call_Type__c.tolowercase()=='outbound'){
                    if(serviceMap.get(leadrec.Service__c)!=null){
                        leadInst.Camp_id = String.valueOf(serviceMap.get(leadrec.Service__c).Id);
                        leadInst.Camp_Name = String.valueOf(serviceMap.get(leadrec.Service__c).Name);
                    }
                    else
                    {
                        leadInst.Camp_id = '52';
                        leadInst.Camp_Name = 'Test_Drive';
                    }
                    leadInst.sfa_id = leadrec.Id;
                    leadInst.cust_no = leadrec.MobilePhone;
                    leadInst.cust_name = 'Test Customer';
                    if(leadrec.ACE_Vehicle_Model__c!=null)
                        leadInst.model_name = leadrec.ACE_Vehicle_Model__c;
                    else
                        leadInst.model_name = 'XUV300';    
                    if(leadrec.Lead_Priority__c!=null)
                        leadInst.priority = String.valueOf(leadrec.Lead_Priority__c);
                    else
                        leadInst.priority ='1';
                    leadInst.batch_name = '';
                    leadInst.language = '';
                    dialerList.add(leadInst);
                    
                    
                }
                
            }
        }
        
        String leadjson  = '';
         system.debug(dialerList);
        if(dialerList.size()>0)
        {
            leadjson = JSON.serialize(dialerList);
            System.debug('---------'+leadjson );
            ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest('https://mrc.cequitycti.com/sf_data/api/customer/savecustomerdata','','POST',leadjson,'MRC');
            system.debug('Status Code: '+response .statusCode);
            system.debug('Status: '+response.status);
            system.debug('JsonBody: '+response.jsonBody);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}