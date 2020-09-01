/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MRCCampaigns_WebService - WebService API Consumed by MRC to send Dialer newly 
			created / update Campaigns in Salesforce.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_MRCCampaigns_WebService - Service(Dialler Campaigns synced to Salesforce)
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/MRCCampaigns/*') 
global without sharing class ACE_MRCCampaigns_WebService{
    
    @HttpPost
    global static String MRCCampaigns() {
        String jsonResponse = 'NA';
        String exceptionWebService = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.SFServiceResponse> responseList = new List<ACE_ServiceUtil.SFServiceResponse>();
        List<ACE_Service__c> sfServiceCreate = new List<ACE_Service__c>();
        List<ACE_Service__c> sfServiceUpdate = new List<ACE_Service__c>();
        List<ACE_MRC_TeckInfoCTIAPI.MRCService> mrccampaignlist = (List<ACE_MRC_TeckInfoCTIAPI.MRCService>)JSON.deserialize(request.requestBody.toString(),List<ACE_MRC_TeckInfoCTIAPI.MRCService>.class);
        try{
            if(mrccampaignlist.size()>0){
                Set<string> service_codes = new Set<string>();
                for(ACE_MRC_TeckInfoCTIAPI.MRCService mrcService: mrccampaignlist){
                    if(mrcService.ServiceName!=null && mrcService.ServiceCode!=null)
                        service_codes.add(mrcService.ServiceCode);
                }
                
                Map<string,Id> exisitingServiceMap = new Map<string,Id>();
                if(service_codes.size()>0){
                    for(ACE_Service__c existingService : [SELECT Id,Service_Code__c FROM ACE_Service__c where Service_Code__c =:service_codes]){
                        exisitingServiceMap.put(existingService.Service_Code__c,existingService.Id);
                    }
                }
                
                for(ACE_MRC_TeckInfoCTIAPI.MRCService mrcService: mrccampaignlist){
                    ACE_Service__c service = new ACE_Service__c();
                    if(mrcService.ServiceName!=null && mrcService.ServiceCode!=null)
                    { 
                        if(mrcService.ServiceName!=null)
                            service.Name = mrcService.ServiceName;
                        if(mrcService.ServiceCode!=null){
                            service.Service_Code__c= mrcService.ServiceCode;
                            if(exisitingServiceMap.keyset().contains(mrcService.ServiceCode))
                            {
                                service.Id = exisitingServiceMap.get(mrcService.ServiceCode);
                                sfServiceUpdate.add(service);
                            }
                            else
                            {
                                sfServiceCreate.add(service);
                            }
                        }
                        
                    }
                }   
                if(sfServiceCreate.size()>0){
                    insert sfServiceCreate;
                }
                if(sfServiceUpdate.size()>0){
                    Database.saveResult[] result=Database.update(sfServiceUpdate, false);
                    Integer index = 0;
                    for(Database.saveResult r: result){
                        if(r.isSuccess()){
                            ACE_ServiceUtil.SFServiceResponse success_response = new ACE_ServiceUtil.SFServiceResponse();
                            success_response.successMsg = 'Service: '+mrccampaignlist[index].ServiceName+' updated successfully';
                            success_response.sfRecordId =  r.getId();
                            success_response.dmlStatus = 'Updated';
                            responseList.add(success_response);
                        }
                        else{
                            for(Database.Error err : r.getErrors()){
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Contact fields that affected this error: ' + err.getFields());
                                ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
                                error_response.errorMsg = 'Error: '+mrccampaignlist[index].ServiceName+' - '+err.getMessage(); 
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
            system.debug('----------------- Exception START - ACE_MRCCampaigns_WebService--------------------');
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            exceptionWebService += ''+e.getMessage()+'\n ';
            exceptionWebService += e.getStackTraceString()+'\n';
            ACE_ServiceUtil.SFServiceResponse error_response = new ACE_ServiceUtil.SFServiceResponse();
            error_response.errorMsg = 'Exception: '+exceptionWebService; 
            responseList.add(error_response);
            system.debug('----------------- Exception END- ACE_MRCCampaigns_WebService--------------------');
            
        }
        
         if(responseList.size()>0)
            jsonResponse = JSON.serialize(responseList); 
        
      	return jsonResponse;
    }
}