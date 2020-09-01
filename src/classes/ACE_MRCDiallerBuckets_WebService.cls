/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MRCDiallerBuckets_WebService - WebService API Consumed by MRC to send Dialer Buckets
            to Salesforce to identify dispositions whether it will require callback or not. If it is yes then
            Dialer CTI will make a call as per the nextdial period mentioned or set in dialer bucket.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_MRC_TeckInfoCTIAPI - Authentication response used for closing the call for CTI
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/MRCDiallerBuckets/*') 
global class ACE_MRCDiallerBuckets_WebService {
    
    @HttpPost
    global static String MRCDiallerBuckets() {
        String jsonResponse = 'NA';
        String exceptionWebService = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.SFServiceResponse> responseList = new List<ACE_ServiceUtil.SFServiceResponse>();
        List<ACE_DialerBucket__c> dialerBucketList = new List<ACE_DialerBucket__c>();
        List<ACE_MRC_TeckInfoCTIAPI.MRCDialerBuckets> mrcDialerBucketList = (List<ACE_MRC_TeckInfoCTIAPI.MRCDialerBuckets>)JSON.deserialize(request.requestBody.toString(),List<ACE_MRC_TeckInfoCTIAPI.MRCDialerBuckets>.class);
        try{
            Map<string,Id> servicemap = new Map<string,Id>();
            for(ACE_Service__c services : [SELECT Id, Service_Code__c from ACE_Service__c]){
                servicemap.put(services.Service_Code__c,services.Id);   
            }
            
            for(ACE_MRC_TeckInfoCTIAPI.MRCDialerBuckets bucket: mrcDialerBucketList){
                ACE_DialerBucket__c sfbucket = new ACE_DialerBucket__c();
                if(bucket.isCallClosed!=null)
                sfbucket.Bucket_Call_Closed__c = bucket.isCallClosed;
                if(bucket.isCallBackNeeded!=null)
                    sfbucket.Bucket_Retry_Type__c = bucket.isCallBackNeeded;
                if(bucket.bucketCode!=null)
                    sfbucket.BucketCode__c = Decimal.valueOf(bucket.bucketCode);
                if(bucket.CallBackMinute!=null)
                    sfbucket.Callback_Minutes__c = Decimal.valueOf(bucket.CallBackMinute);
                if(bucket.bucketName!=null)
                    sfbucket.Name = bucket.bucketName;
                if(bucket.ServiceCode!=null){
                    string serviceCode = string.valueOf(bucket.ServiceCode);
                    if(servicemap.get(serviceCode)!=null){
                        sfbucket.Service__c = servicemap.get(serviceCode);
                    }
                }
                dialerBucketList.add(sfbucket);
                if(dialerBucketList.size()>0){
                    Database.SaveResult[] srList = Database.insert(dialerBucketList,false);
                    Integer index = 0;
                    for (Database.SaveResult result : srList) {
                        if(result.isSuccess()) {
                                ACE_ServiceUtil.SFServiceResponse success_response = new ACE_ServiceUtil.SFServiceResponse();
                                success_response.successMsg = 'Dialer bucket: '+mrcDialerBucketList[index].bucketName +' was created';
                                success_response.sfRecordId =  result.getId();
                                success_response.dmlStatus = 'Created';
                                responseList.add(success_response);
                           
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : result.getErrors()) {
                                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                                System.debug('fields that affected this error: ' + err.getFields());
                                ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
                                error_response.errorMsg = 'Error: '+err.getMessage(); 
                                error_response.errorFields =  err.getFields();
                                responseList.add(error_response);
                            }
                        }
                        index++;
                    }
                }
            }
        }
        catch(Exception e){
            system.debug('----------------- Exception START - ACE_MRCDiallerBuckets_WebService--------------------');
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            exceptionWebService += ''+e.getMessage()+'\n ';
            exceptionWebService += e.getStackTraceString()+'\n';
            ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
            error_response.errorMsg = 'Exception: '+exceptionWebService; 
            responseList.add(error_response);
            system.debug('----------------- Exception END - ACE_MRCDiallerBuckets_WebService--------------------');
        }
        
        if(responseList.size()>0)
            jsonResponse = JSON.serialize(responseList); 
        
        return jsonResponse;
    }
}