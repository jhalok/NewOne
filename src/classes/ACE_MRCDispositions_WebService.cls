/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MRCDispositions_WebService - WebService API Consumed by MRC to send Dialer newly 
			created / update Dispositions in Salesforce. Update exisitng dispositions as inactive if
			updated as inactive in dialler. Sync all updated (CTI dialer & agent) - service and sales
            call dispositions in Salesforce from MRC.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_MRCDispositions_WebService - Retrived new and updated dispositions from MRC - Active / InActive
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/MRCDispositions/*') 
global class ACE_MRCDispositions_WebService {
     
    @HttpPost
    global static String MRCDispositions() {
        String jsonResponse = 'NA';
        String exceptionWebService = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json'); 
        List<ACE_Disposition__c> sfDispositionList= new List<ACE_Disposition__c>();
        List<ACE_SubDisposition__c> sfSubDispositionList= new List<ACE_SubDisposition__c>();
        List<ACE_ServiceUtil.SFServiceResponse> responseList = new List<ACE_ServiceUtil.SFServiceResponse>();
        List<ACE_MRC_TeckInfoCTIAPI.MRCDisposition> mrcDispositionlist = (List<ACE_MRC_TeckInfoCTIAPI.MRCDisposition>)JSON.deserialize(request.requestBody.toString(),List<ACE_MRC_TeckInfoCTIAPI.MRCDisposition>.class);
        try{
            Map<string,Id> servicemap = new Map<string,Id>();
            for(ACE_Service__c services : [SELECT Id, Service_Code__c from ACE_Service__c]){
                servicemap.put(services.Service_Code__c,services.Id);   
            }
            
            if(mrcDispositionlist.size()>0){
                //Process Dispositions
                for(ACE_MRC_TeckInfoCTIAPI.MRCDisposition mrcDisposition: mrcDispositionlist){
                    ACE_Disposition__c disposition = new ACE_Disposition__c();
                    if(mrcDisposition.CallCenter!=null)
                    disposition.Call_Center__c = mrcDisposition.CallCenter;
                    if(mrcDisposition.DispositionCode!=null)
                    disposition.Disposition_Code__c = mrcDisposition.DispositionCode;
                    if(mrcDisposition.DispositionType!=null)
                    disposition.DispositionType__c = mrcDisposition.DispositionType;
                    if(mrcDisposition.Inbound!=null)
                    disposition.Inbound__c = mrcDisposition.Inbound;
                    if(mrcDisposition.IsActive!=null)
                    disposition.IsActive__c = mrcDisposition.IsActive;
                    if(mrcDisposition.DispositionName!=null)
                    disposition.Name = mrcDisposition.DispositionName;
                    if(mrcDisposition.DispositionSystemId!=null)
                    disposition.Disposition_External_Id__c = mrcDisposition.DispositionSystemId;
                    /*if(mrcDisposition.ServiceCode!=null){
                        string serviceCode = string.valueOf(mrcDisposition.ServiceCode);
                        if(servicemap.get(serviceCode)!=null){
                            disposition.Service__c = servicemap.get(serviceCode);
                        }
                    }*/
                    sfDispositionList.add(disposition);
                }
                
                Map<Decimal,Id> bucketCodeMap = new Map<Decimal,Id>();
                for(ACE_DialerBucket__c dialerBucket : [SELECT Id, BucketCode__c from ACE_DialerBucket__c]){
                    bucketCodeMap.put(dialerBucket.BucketCode__c,dialerBucket.Id);   
                }
                //Insert or update dispositions
                if(sfDispositionList.size()>0){
                    Schema.SObjectField externalKey = ACE_Disposition__c.Fields.Disposition_External_Id__c;
                    Database.UpsertResult[] srList = Database.upsert(sfDispositionList,externalKey,false);
                    Integer index = 0;
                    List<ACE_ServiceDisposition__c> serviceDispositionObjects = new List<ACE_ServiceDisposition__c>(); 
                    for (Database.UpsertResult result : srList) {
                        if(result.isSuccess()) {
                            if(result.isCreated()) 
                            {
                                ACE_ServiceDisposition__c junctionObject = new  ACE_ServiceDisposition__c();
                                if(mrcDispositionlist[index].subdispositions!=null && mrcDispositionlist[index].subdispositions.size()>0){
                                    for(ACE_MRC_TeckInfoCTIAPI.MRCSubDisposition mrcSubDisposition: mrcDispositionlist[index].subdispositions){
                                        ACE_SubDisposition__c subdisposition  = new ACE_SubDisposition__c();
                                        subdisposition.Name = mrcSubDisposition.SubDispositionName;
                                        subdisposition.SubDisposition_Code__c = mrcSubDisposition.SubDispositionCode;
                                        Decimal bCode = 0;
                                        bCode = Decimal.valueOf(mrcSubDisposition.BucketCode);
                                        if(bucketCodeMap.get(bCode)!=null)  
                                            subdisposition.DialerBucket__c = bucketCodeMap.get(bCode);
                                        subdisposition.Disposition__c = result.getId();
                                        sfSubDispositionList.add(subdisposition);
                                    }
                                    
                                }
                                if(mrcDispositionlist[index].ServiceCode!=null){
                                    string serviceCode = string.valueOf(mrcDispositionlist[index].ServiceCode);
                                    if(servicemap.get(serviceCode)!=null){
                                        junctionObject.Disposition__c = result.getId();
                                        junctionObject.ServiceDisposition__c = servicemap.get(serviceCode);
                                        serviceDispositionObjects.add(junctionObject);
                                    }
                                }
                                ACE_ServiceUtil.SFServiceResponse success_response = new ACE_ServiceUtil.SFServiceResponse();
                                success_response.successMsg = 'Disposition '+mrcDispositionlist[index].DispositionCode +' was created';
                                success_response.sfRecordId =  result.getId();
                                success_response.dmlStatus = 'Created';
                                responseList.add(success_response);
                            } 
                            else 
                            {
                                
                                ACE_ServiceUtil.SFServiceResponse success_response = new ACE_ServiceUtil.SFServiceResponse();
                                success_response.successMsg = 'Disposition '+mrcDispositionlist[index].DispositionCode +' was created';
                                success_response.sfRecordId =  result.getId();
                                success_response.dmlStatus = 'Updated';
                                responseList.add(success_response);
                            }
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : result.getErrors()) {
                                System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                                System.debug('fields that affected this error: ' + err.getFields());
                                ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
                                error_response.errorMsg = 'Error: '+mrcDispositionlist[index].DispositionCode +' '+err.getMessage(); 
                                error_response.errorFields =  err.getFields();
                                responseList.add(error_response);
                            }
                        }
                        index++;
                    }
                    if(serviceDispositionObjects.size()>0)
                    {
                        insert serviceDispositionObjects;
                    }
                    
                }
            }
        }
        catch(Exception e){
            system.debug('----------------- Exception START - ACE_MRCDispositions_WebService--------------------');
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            exceptionWebService += ''+e.getMessage()+'\n ';
            exceptionWebService += e.getStackTraceString()+'\n';
            ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
            error_response.errorMsg = 'Exception: '+exceptionWebService; 
            responseList.add(error_response);
            system.debug('----------------- Exception END - ACE_MRCDispositions_WebService--------------------');
            
        }
        
        if(responseList.size()>0)
            jsonResponse = JSON.serialize(responseList); 
        
        return jsonResponse;
    }
}