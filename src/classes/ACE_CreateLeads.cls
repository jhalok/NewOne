/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary :For creating leads from Aggregators/ Websites.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @modifiedy      Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @maintainedBy   Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @version        1.0
* @created        2019-11-08
* @modified       Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v0.1            susidharthak.mahapatra@pwc.com
* 2019-11-14      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
* 
*/

//*****************************************Service*************************************************************

@RestResource(urlMapping='/pushLeadsintoSF/*') 
global class ACE_CreateLeads {
    
    @HttpPost
    global static String pushLeadsintoSF(){
        String jsonresp = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        

        List<String> listSource = new List<String>();
        List<String> listSubsource = new List<String>();
        List<String> exLeadMobileNumber = new List<String>();
        
        Map<String,Lead> mapOfAllExistingLeads = new Map<String,Lead>();
      
            List<ACE_ServiceUtil.leadDetail> leadsforinsert = (List<ACE_ServiceUtil.leadDetail>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.leadDetail>.class);

        if(leadsforinsert.size()>0){
            //ACE_InsertIntLeadNProductController.insertLeads(leadsforinsert);
            return ACE_LeadAPIService.processLeads(leadsforinsert);
        }
        return null;
    }
   
    
}