/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_OAuthUtil - Utility that will actually make Api callout using ACE_APICalloutUtil.apxc
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_OAuthUtil  - call API endpoints
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_OAuthUtil {
	/****************************** TECKINFO & MRC Calls ******************************************/
    /****************************** [      START       ] ******************************************/
       
    public static string handleCustomCallRedirectionSF(string callData){
        ACE_MRC_TeckInfoCTIAPI.cls_callDetails callLog = (ACE_MRC_TeckInfoCTIAPI.cls_callDetails)JSON.deserialize(callData,ACE_MRC_TeckInfoCTIAPI.cls_callDetails.class);
        string salesforceId = '';
        salesforceId=   callLog.AddOn;
        string callType = callLog.CallTypeName;
        string url = null;
        if(callType == 'Inbound')
        {
            url = '/lightning/n/New_Inbound_Call';  
            	
        }
        else
        {
            if(salesforceId!=null){
                 url = '/lightning/'+salesforceId; 
            }
            
        }
        return url;
    }
    
    public static ACE_APICalloutUtil.ApiResponse pushLeads(){
       // string leadjson = '[{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IvbnUAC","cust_no":"7045533587","cust_name":"Sagar Kambli","model_name":"XUV300","priority":"1","batch_name":"","language":""},{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IwQSUA0","cust_no":"9881716261","cust_name":"Anagha","model_name":"XUV500","priority":"1","batch_name":"","language":""},"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IxZ3UAK","cust_no":"9140694958","cust_name":"Saransh","model_name":"XUV500","priority":"1","batch_name":"","language":""}]';
        //string leadjson = '[{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002JevrUAC","cust_no":"9664353167","cust_name":"Sagar Kambli","model_name":"XUV300","priority":"1","batch_name":"","language":""}]';
        //ACE_APICalloutUtil.ApiResponse response1 = ACE_APICalloutUtil.sendRequest('https://mrc.cequitycti.com/sf_data/api/customer/savecustomerdata','','POST',leadjson,'MRC');
        //string leaddataURL = 'https://103.81.88.80/elision-dialer/elisionapi/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=[{"phone_number":"7045533587","list_id":"33333","MobileNo":"7045533587","LeadformURL":"https:\/\/mahindradealerworld--acedev.lightning.force.com\/lightning\/r\/Lead\/00Q5D000002JbHWUA0\/view",Id":"00Q5D000002JbHWUA0","CustomerName":"Sagar Kambli","LeadSubSource":"WEB","LeadSource":"WEB","CustomField1":"00Q5D000002JbHWUA0"}]';
        string leaddataURL = 'https://103.81.88.80/elision-dialer/elisionapi/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=[{"phone_number":"7045533587","list_id":"33333","prospects_id":"00Q5D000002JbHWUA0","CustomerName":"Sagar Kambli","MobileNo":"7045533587","EnquirySource":"FB","EnquiryType":"M2A","WebEnquiryNumber":"XUV300321607","LeadSubSource":"JOINSVE","LeadSource":"FB","LeadformURL":"https:\\/\\/mahindradealerworld--acedev.lightning.force.com\\/lightning\\/r\\/Lead\\/00Q5D000002JbHWUA0\\/view"}]';
        ACE_APICalloutUtil.ApiResponse response1 = ACE_APICalloutUtil.sendRequest(leaddataURL,'','POST','','M2ALL');
        system.debug('Status Code: '+response1.statusCode);
        system.debug('Status: '+response1.status);
        system.debug('JsonBody: '+response1.jsonBody);
        return response1;
    }
    
    
    
    
    public static ACE_APICalloutUtil.ApiResponse closeCall(string dispositionCode, string nextDialTime,
                                  string remarks, string recordId){
        string result = '';
        ACE_APICalloutUtil.ApiResponse callClose;                              
        ACE_APICalloutUtil.ApiResponse accessCode = ACE_APICalloutUtil.sendRequest('https://sfmrc.cequitycti.com/api/cti/GetAgentToken?hostId='+UserInfo.getUserName(),'','POST','','MRC');
        if(accessCode.statusCode == 200){
            ACE_MRC_TeckInfoCTIAPI.CloseCall accessCodeObject = (ACE_MRC_TeckInfoCTIAPI.CloseCall)JSON.deserialize(accessCode.jsonBody,ACE_MRC_TeckInfoCTIAPI.CloseCall.class);
            if(accessCodeObject!=null){
                system.debug(accessCodeObject);
                
                //Step 2
                ACE_APICalloutUtil.ApiResponse callDetails = ACE_APICalloutUtil.sendRequest('https://sfmrc.cequitycti.com/api/cti/GetStatus?runningSeries=0&hostId='+UserInfo.getUserName()+'&tspltoken='+accessCodeObject.ResultString,'','POST','','MRC');
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
                            callClose = ACE_APICalloutUtil.sendRequest('https://sfmrc.cequitycti.com/api/cti/CloseCall?disposition='+dispositionCode+'&nextDialTime='+nextDialTime+'&remarks='+remarks+'&callNumber='+callNumber+'&hostId='+UserInfo.getUserName()+'&extraParameters=USERFIELD16|'+recordId+'&tspltoken='+accessCodeObject.ResultString,'','POST','','MRC');
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
                    callClose = new ACE_APICalloutUtil.ApiResponse();
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
    
    /****************************** [      END         ] ******************************************/
}