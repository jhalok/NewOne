/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary :Utility class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @modifiedy      Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @maintainedBy   Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @version        1.0
* @created        2019-11-28
* @modified       Susidharthak Mahapatra   <susidharthak.mahapatra@pwc.com>
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v0.1            susidharthak.mahapatra@pwc.com
* 2019-11-28      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
* 
*/

//*****************************************Service*************************************************************

@RestResource(urlMapping='/updateTDinSF/*') 
global class ACE_updateTDDetails{

    @HttpPost
    global static void updateTD(){
        
        String jsonresp = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.updateTD> tdstoUpdate = (List<ACE_ServiceUtil.updateTD>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.updateTD>.class);
        Set<String> tdIdSet = new Set<String>();
        for(ACE_ServiceUtil.updateTD td:tdstoUpdate ){
            tdIdSet.add(td.td_id);
        }
        
        Map<String, Id> tdMap = new Map<String, Id>();
        List<ACE_Test_Drive__c> tdObjList = new List<ACE_Test_Drive__c>();
        for(ACE_Test_Drive__c tdInst: [select id, Name from ACE_Test_Drive__c where Name IN:tdidSet]){
            tdMap.put(tdInst.Name, tdInst.Id);
        }
        
        for(ACE_ServiceUtil.updateTD updTD:tdstoUpdate){
            ACE_Test_Drive__c tdObjct = new ACE_Test_Drive__c();
            tdObjct.Id = tdMap.get(updTD.td_id);
            
            if(updTD.td_status == 'Test Drive Reschedule'){
                tdObjct.Stage__c = updTD.td_status;
                tdObjct.TD_Comments__c = updTD.td_comments;
                tdObjct.TD_Comments__c = updTD.place;
                tdObjct.TD_Comments__c = updTD.start_time;
                tdObjct.TD_Comments__c = updTD.end_time;
            }
            
            else{
                tdObjct.TD_Comments__c = updTD.td_comments;
                tdObjct.Stage__c = updTD.td_status;
            }
           
            tdObjList.add(tdObjct);
        }
        
        if(tdObjList.size()> 0){
            Database.SaveResult [] updateResult = Database.update(tdObjList);
        }
    }
}