/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_APICalloutUtil - Contains all methods required for connecting to external system 
								using REST API.This are all reusable methods for every developers 
								to use this common utility. Kindly edit this class by following up
								with @modifiedBy parameter.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_APICalloutUtil  - API Method Utility
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_APICalloutUtil {
    
     public static ApiResponse closeCall(string dispositionCode, string nextDialTime,
                                  string remarks, string recordId){
        string result = '';
        ApiResponse callClose;                              
        ApiResponse accessCode = sendRequest('https://sfmrc.cequitycti.com/api/cti/GetAgentToken?hostId='+UserInfo.getUserName(),'','POST','','MRC');
        if(accessCode.statusCode == 200){
            ACE_MRC_TeckInfoCTIAPI.CloseCall accessCodeObject = (ACE_MRC_TeckInfoCTIAPI.CloseCall)JSON.deserialize(accessCode.jsonBody,ACE_MRC_TeckInfoCTIAPI.CloseCall.class);
            if(accessCodeObject!=null){
                system.debug(accessCodeObject);
                
                //Step 2
                ApiResponse callDetails = sendRequest('https://sfmrc.cequitycti.com/api/cti/GetStatus?runningSeries=0&hostId='+UserInfo.getUserName()+'&tspltoken='+accessCodeObject.ResultString,'','POST','','MRC');
                if(callDetails.statusCode == 200){
                    //Step 3
                    String jsonstr = callDetails.jsonBody.replaceAll('\\\\', '');
                    jsonstr = jsonstr.replaceFirst(UserInfo.getUserName().toLowerCase(), 'callDispositionDetails') ;   
                    jsonstr = jsonstr.removeStart('"');
                    jsonstr = jsonstr.removeEnd('"');
                    system.debug('Status Code 2: '+callDetails.statusCode);
                    system.debug('Status 2: '+callDetails.status);
                    system.debug('JsonBody 2: '+jsonstr);
                    ACE_MRC_TeckInfoCTIAPI obj = (ACE_MRC_TeckInfoCTIAPI)JSON.deserialize(string.valueOf(jsonstr), ACE_MRC_TeckInfoCTIAPI.class);
                    
                    if(obj!=null){
                        ACE_MRC_TeckInfoCTIAPI.cls_ResultString resultString =obj.ResultString;
                        ACE_MRC_TeckInfoCTIAPI.callDispositionDetails dispositionDetails= resultString.callDispositionDetails;
                        List<ACE_MRC_TeckInfoCTIAPI.cls_callDetails> callResult = dispositionDetails.callDetails;
                        Integer callNumber = 0;
                        Integer ServiceId = 0;
                        String ServiceName = '';
                        if(callResult!=null && callResult.size()>0){
                            callNumber = callResult[0].CallNumber;
                            ServiceId = callResult[0].ServiceId;
                            ServiceName = callResult[0].ServiceName;
                            system.debug('callNumber: '+callNumber);
                            system.debug('ServiceName: '+ServiceName);
                            system.debug('ServiceId: '+ServiceId);
                            callClose = sendRequest('https://sfmrc.cequitycti.com/api/cti/CloseCall?disposition='+dispositionCode+'&nextDialTime='+nextDialTime+'&remarks='+remarks+'&callNumber='+callNumber+'&hostId='+UserInfo.getUserName()+'&extraParameters=USERFIELD16|'+recordId+'&tspltoken='+accessCodeObject.ResultString,'','POST','','MRC');
                            if(callClose!=null && callClose.statusCode == 200){
                                system.debug('Status Code Final: '+callClose.statusCode);
                                system.debug('Status Final: '+callClose.status);
                                system.debug('End Result: '+callClose.jsonbody);
                                //result = callClose.jsonbody;
                                return callClose;
                            }
                        }
                    }
                    
                }
                else{
                    callClose = new ApiResponse();
                    callClose.statusCode = callDetails.statusCode;
                    callClose.status = callDetails.status;
                    if(callClose.jsonBody!=null)
                        callClose.exceptionMessage = callClose.jsonBody;
                    else
                        callClose.exceptionMessage = 'The User must have not logged in to terminal';
                    return callClose;
                }
            }  
        }
                                     
        
        return callClose;
    }
   
    //Send api request to external system
    //Kindly register endpoint first in your salesforce setup.
    public static ApiResponse sendRequest(string endpointUrl,string param, String action, 
                                          String requestbody, string callcenterType)
    {
        ApiResponse result = new ApiResponse();
        try
        {
            HttpRequest req = new HttpRequest();
            string url = '';
            if(param!=null && param !=''){
                url = endpointUrl + '/'+param;
            }
            else
            {
                url = endpointUrl;
            }
            //url= EncodingUtil.urlEncode(url, 'UTF-8');
			system.debug(url);
            req.setEndpoint(url);
            req.setMethod(action);
            if(action == 'POST'){
                system.debug('Before');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(requestbody);
            }
            Http http = new Http();
            HttpResponse response = http.send(req);
            result.statusCode = response.getStatusCode();
            result.jsonBody = response.getBody();
            result.status = response.getStatus();
            return result;
        }
        catch(Exception ex)
        {
            result.statusCode = 1111;
            result.exceptionStrace = ex.getStackTraceString();
            result.exceptionMessage = ex.getMessage();
        }
        return result;
    }
    
    public class ApiResponse{
        public Integer statusCode {get;set;} //1111 for apex exception
        public String  status {get;set;}
        public string  jsonBody {get;set;}
        public string  exceptionMessage {get;set;}
        public string  exceptionStrace {get;set;}
    }    
}