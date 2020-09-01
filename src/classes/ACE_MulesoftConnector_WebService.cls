/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MulesoftConnector_WebService -This will be consumed by mulesoft to create leads.....etc in salesforce
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-25
* @modified       2019-11-25
* @systemLayer    ACE_MulesoftConnector_WebService - This will be consumed by mulesoft to create leads.....etc in salesforce
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/mulesoftconnector/*') 
global class ACE_MulesoftConnector_WebService {
    
    @HttpPost
    global static string createLeadinSF() {
        String jsonResponse = 'NA';
        String exceptionWebService = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json'); 
        List<ACE_ServiceUtil.ServiceResponse> responseList = new List<ACE_ServiceUtil.ServiceResponse>();
        List<LeadData> mulesoftList = (List<LeadData>)JSON.deserialize(request.requestBody.toString(),List<LeadData>.class);
        List<Lead> sfLeadData = new List<Lead>();
        for(LeadData record: mulesoftList) {
            //if(record.Source!=null){
                //if(record.Source.tolowerCase()==ACE_Constants.ACE_SOURCE_MITRA){
                    Lead sflead = new Lead();
                    if(record.ReferredName!=null)
                    {
                        string[] name = record.ReferredName.split(' ');
                        if(name.size()==2)
                        {
                            sflead.FirstName = name[0];
                            sflead.LastName = name[1];
                        }
                        else if(name.size()==1){
                             sflead.LastName = name[0];
                        }
                        else{
                            
                        }
                    }
                    if(record.MobileNo!=null)
                    sflead.MobilePhone = record.MobileNo;
                    if(ACE_Constants.ACC_MRC!=null)
                    sflead.Company = ACE_Constants.ACC_MRC;
                    if(record.pincode!=null)
                        sfLead.PostalCode = record.pincode;
                    if(record.SystemId!=null)
                        sfLead.Mulesoft_System_ID__c = record.SystemId;
                	if(record.leadSource != null)
                        sflead.LeadSource = record.leadSource;
                	sfLeadData.add(sflead);
                    
                //}
            //}   
        }
        if(sfLeadData.size()>0)
        {
            try{
                List<Database.UpsertResult> results = Database.upsert(sfLeadData,Lead.Mulesoft_System_ID__c,false);
                Integer i=0;
                for(Database.UpsertResult sr: results){
                    if(sr.isSuccess()){
                        System.debug('Success' +sr.getId());
                        ACE_ServiceUtil.ServiceResponse srvResp = new ACE_ServiceUtil.ServiceResponse();
                        srvResp.responseMsg = 'Lead Record Saved Successfully: '+sr.getId();
                        srvResp.sfRecordId = sr.getId();
                        srvResp.responseCode = '200';
                        responseList.add(srvResp);
                    }
                    else{
                        System.debug('Failure!!');
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred-->'+err.getStatusCode() + ': ' + err.getMessage());                    
                            System.debug('Fields that affected this error: ' + err.getFields());
                            ACE_ServiceUtil.ServiceResponse srvResp = new ACE_ServiceUtil.ServiceResponse();
                            srvResp.responseMsg = err.getMessage();
                            srvResp.sfRecordId = sr.getId();
                            srvResp.responseCode = '1001';
                            responseList.add(srvResp);
                        }
                    }
                    i++;
                }
                if(responseList.size()>0){
                    jsonResponse = JSON.serialize(responseList); 
                }
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
    
    
    
    /*
     * Lead - Wrappers
     * This is used to get lead data using mulesoft connector and save it in salesforce
	*/
    global class LeadData{
        public string SystemId {get;set;}
        public string leadSource {get;set;}
        public string MobileNo {get;set;}
        //public string ParentCode {get;set;}
        public string ReferredName {get;set;}
        public string pincode {get;set;}
        public string Model {get;set;}
        public string Remark {get;set;}	
    }
    
}