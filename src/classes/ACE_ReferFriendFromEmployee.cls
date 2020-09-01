/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to create Contact, Lead, Product Interest, Source Tracker from third party while any emp refer his/her friend.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @modifiedBy     Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @maintainedBy   Amit Chaudhary   <amit.c.tpr@in.pwc.com>
* @version        1.0
* @created        20-Dec-2019
* @modified       
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource(urlMapping='/pushEmployeeReferredLeadsintoSF/*')
Global class ACE_ReferFriendFromEmployee {
    @HttpPost
	global static String pushEmpReferredLeadsintoSF(){
    	RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        
        List<ACE_ServiceUtil.ReferLeadFromEmployeeDetail> leadsforinsert = (List<ACE_ServiceUtil.ReferLeadFromEmployeeDetail>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.ReferLeadFromEmployeeDetail>.class);
        if(leadsforinsert.size() > 0){
            return ACE_LeadAPIService.processEmpReferredLeads(leadsforinsert);
        }
        return null;
    }
}