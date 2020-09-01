/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_CallActivityManager - WebService API Consumed by M2All to send Dialer newly 
			created / update Tasks for Abandoned/ Number not contactable/ Dialer Failure calls in 
            Salesforce under the matching Lead or Contact or Case as per caller contact number. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-11-26
* @modified       2019-11-26
* @systemLayer    ACE_CallActivityManager - Retrived new dispositions from M2All
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource(urlMapping='/Dispositions/*') //failured calls and non-contacttable calls,abondoned call
global with sharing class ACE_CallActivityManager {
    @HttpPost
    global static String logCallActivityinSF() {
        String jsonResponse = '';
        String exceptionWebService = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        List<ACE_ServiceUtil.serviceResponse> responseList = new List<ACE_ServiceUtil.serviceResponse>();
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.disposedCallDetails> dialerTaskList = (List<ACE_ServiceUtil.disposedCallDetails>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.disposedCallDetails>.class);
     	List<Task> tasklist = new List<Task>();
        Set<String> serviceCodes = new Set<String>();
        Set<String> dispositionCodes = new Set<String>();
        Set<String> subdispositionCodes = new Set<String>();
        List<String> callerNumbers = new List<String>();
        
        Map<string, List<ACE_Disposition__c>>  serviceDispositionMap= new Map<string, List<ACE_Disposition__c>>();
        for(ACE_ServiceUtil.disposedCallDetails dialerTsk: dialerTaskList){
            if(dialerTsk.service_code!=null)
                serviceCodes.add(dialerTsk.service_code);
            if(dialerTsk.disposition!=null)
                dispositionCodes.add(dialerTsk.disposition);
        }
        Map<String,Id> serviceMap = new Map<String,Id>();
        if(serviceCodes.size()>0){
            for(ACE_Service__c serviceRecord: [select id,Service_Code__c from ACE_Service__c where Service_Code__c in:serviceCodes])
            {
                serviceMap.put(serviceRecord.Service_Code__c,serviceRecord.Id);
            }
            for(ACE_ServiceDisposition__c serviceDispo : [select id,ServiceDisposition__r.Service_Code__c, Disposition__c,Disposition__r.Disposition_Code__c,Disposition__r.Id  from ACE_ServiceDisposition__c where ServiceDisposition__r.Service_Code__c in:serviceCodes and Disposition__r.Disposition_Code__c =: dispositionCodes limit 1]){
                if(serviceDispositionMap.get(serviceDispo.ServiceDisposition__r.Service_Code__c) == null)
                    serviceDispositionMap.put(serviceDispo.ServiceDisposition__r.Service_Code__c,new List<ACE_Disposition__c>{serviceDispo.Disposition__r});
                else
                    serviceDispositionMap.get(serviceDispo.ServiceDisposition__r.Service_Code__c).add(serviceDispo.Disposition__r);
            }
        }
        
        for(ACE_ServiceUtil.disposedCallDetails dialerTsk: dialerTaskList){
            System.debug('@@@@@@@@'+dialerTsk);
            Datetime startdatetime = null;
            Datetime enddatetime = null;
            Datetime followupdatetime = null;
            if(dialerTsk.call_start_time!=null)
                startdatetime = DateTime.valueOf(dialerTsk.call_start_time.replaceAll('T',' '));
            if(dialerTsk.call_end_time!=null)
                enddatetime = DateTime.valueOf(dialerTsk.call_end_time.replaceAll('T', ' '));
            if(dialerTsk.next_followup_time!=null && dialerTsk.next_followup_time!='' )
                followupdatetime = DateTime.valueOf(dialerTsk.next_followup_time.replaceAll('T', ' '));
            
            
            
            Task tsk = new Task();
            tsk.Subject = 'Call - '+dialerTsk.callcenterType+' '+startdatetime.day()+'/'+startdatetime.month()+'/'+startdatetime.year()+' '+startdatetime.hour()+':'+startdatetime.minute()+':'+startdatetime.second();
            tsk.CallDisposition = dialerTsk.disposition;
            if(dialerTsk.sf_id != null && dialerTsk.sf_id != 'NA')
                tsk.WhoId = dialerTsk.sf_id;
            if(serviceMap.get(dialerTsk.service_code)!=null)
                tsk.Service__c = serviceMap.get(dialerTsk.service_code);
            tsk.Description = dialerTsk.comments;
            tsk.Dialer_Id__c = dialerTsk.dialerId;
            tsk.Status = 'Completed'; // As of now we have hard coded later on the one which are abondoned those status must not be completed.
            tsk.CallObject = dialerTsk.callcenterType;
            tsk.CallType = dialerTsk.call_type;
            tsk.Caller_number__c = dialerTsk.caller_no;
            tsk.Description = dialerTsk.comments;
            if(startdatetime!=null)
            tsk.Call_Start_Time__c = startdatetime;
            if(enddatetime!=null)
            tsk.Call_End_Time__c = enddatetime;
            if(followupdatetime!=null && dialerTsk.next_followup_time!='' )
            tsk.Next_Followup_Time__c = followupdatetime;
            if(serviceDispositionMap.get(dialerTsk.service_code)!=null && dialerTsk.disposition!=null){
                for(ACE_Disposition__c disposition: serviceDispositionMap.get(dialerTsk.service_code)){
                    if(disposition.Disposition_Code__c == dialerTsk.disposition){
                        tsk.Disposition__c = disposition.Id;
                    }
                }
            }
            tsk.CallDurationInSeconds = Integer.valueOf(dialerTsk.call_duration);
            tsk.Actual_CallTime__c = Decimal.valueOf(dialerTsk.actual_calltime);
            tsk.Wrapup_Time__c = Integer.valueOf(dialerTsk.wrapup_time);
            tsk.Agent_Id__c = dialerTsk.agent_id;
            taskList.add(tsk);
        }
        if(taskList.size() > 0){
            try{
                Schema.SObjectField externalKey = Task.Fields.Dialer_Id__c;
                Database.SaveResult[] results = Database.INSERT(taskList,false);
                Integer i=0;
                for(Database.SaveResult sr: results){
                    if(sr.isSuccess()){
                        System.debug('Success' +sr.getId());
                        ACE_ServiceUtil.serviceResponse success_response = new ACE_ServiceUtil.serviceResponse();
                        success_response.responseMsg = 'Successfully Inserted: '+sr.getId();
                        //success_response.dialerId = taskList.get(i).Dialer_Id__c;
                        success_response.sfRecordId = sr.getId();
                        responseList.add(success_response);
                    }
                    else{
                        System.debug('Failure!!');
                        // Operation failed, so get all errors 
                        
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                            ACE_ServiceUtil.serviceResponse error_response = new ACE_ServiceUtil.serviceResponse();
                            error_response.responseMsg = err.getMessage();
                            responseList.add(error_response);
                        }
                        
                    }
                    i++;
                }
                
                jsonResponse = JSON.serialize(responseList);
            }
            catch(exception e){
                ACE_ServiceUtil.ServiceResponse srvResp = new ACE_ServiceUtil.ServiceResponse();
                exceptionWebService += ''+e.getMessage()+'\n ';
                exceptionWebService += e.getStackTraceString()+'\n';
                srvResp.responseMsg = exceptionWebService;
                srvResp.responseCode = '9999';
                responseList.add(srvResp);
            }
        }
        return jsonResponse;
    }
    
    /* @HttpPost
    global static String saveDispositionCallsInSF() {
        String jsonResponse = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.taskServices> dialerTaskList = (List<ACE_ServiceUtil.taskServices>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.taskServices>.class);
     	List<Task> tasklist = new List<Task>();
        Set<string> serviceCodes = new Set<string>();
        for(ACE_ServiceUtil.taskServices dialerTsk: dialerTaskList){
            if(dialerTsk.serviceId!=null)
            {
                serviceCodes.add(string.valueOf(dialerTsk.serviceId));
            }
        }
        Map<Decimal,Id> serviceMap = new Map<Decimal,Id>();
        if(serviceCodes.size()>0){
        	for(ACE_Service__c serviceRecord: [select id,service_code__c from ACE_Service__c where service_code__c in:serviceCodes])
            {
                serviceMap.put(Integer.valueOf(serviceRecord.service_code__c),serviceRecord.Id);
            }
        }
        for(ACE_ServiceUtil.taskServices dialerTsk: dialerTaskList){
            System.debug('@@@@@@@@'+dialerTsk);
            Task tsk = new Task();
            tsk.Subject = 'Call';
            tsk.CallDisposition = dialerTsk.disposition;
            tsk.WhoId = dialerTsk.leadid;
            if(serviceMap.get(Integer.valueOf(dialerTsk.serviceId))!=null)
            tsk.Service__c = serviceMap.get(Integer.valueOf(dialerTsk.serviceId));
            tsk.Description = dialerTsk.description;
            tsk.Dialer_Id__c = dialerTsk.dialerId;
            tsk.Status = 'Completed';
            taskList.add(tsk);
        }
        if(taskList.size() > 0){
        	List<Database.SaveResult> results = Database.insert(taskList);
            Integer i=0;
            List<ACE_ServiceUtil.serviceResponse> responseList = new List<ACE_ServiceUtil.serviceResponse>();
            for(Database.SaveResult sr: results){
                
                if(sr.isSuccess()){
                    System.debug('Success' +sr.getId());
                    ACE_ServiceUtil.serviceResponse success_response = new ACE_ServiceUtil.serviceResponse();
                    success_response.responseMsg = 'Successfully Inserted: '+sr.getId();
                    success_response.otherImpObjId = taskList.get(i).Dialer_Id__c;
                    success_response.sfRecordId = sr.getId();
                    responseList.add(success_response);
                }
                else{
                    System.debug('Failure!!');
				 // Operation failed, so get all errors 
				                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        ACE_ServiceUtil.serviceResponse error_response = new ACE_ServiceUtil.serviceResponse();
                        error_response.responseMsg = err.getMessage();
                        error_response.otherImpObjId = taskList.get(i).Dialer_Id__c;
                        responseList.add(error_response);
                    }
						                    
                }
                i++;
            }
            
           jsonResponse = JSON.serialize(responseList); 
        }
        return jsonResponse;
    }       
    */
    
}