/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_PushUserIntoDiallerBatch - Webservice API provided by dialler to push the newly 
            created users into the dialler from Salesforce.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-11-28
* @modified       2019-11-28
* @systemLayer    ACE_PushUserIntoDiallerBatch
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class ACE_PushUserIntoDiallerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global final String ldquery;
    global List<User> userList;
    List<User> updateLeads = new List<User>();
        
    global ACE_PushUserIntoDiallerBatch(List<User> userList){
        this.userList = userList;
    }
    
    global List<User> start(Database.BatchableContext BC){
        return userList;
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
        List<ACE_ServiceUtil.dialerUsers> dialerList = new List<ACE_ServiceUtil.dialerUsers>();
        
        
        for(user userRec:userList){
            ACE_ServiceUtil.dialerUsers userInst = new ACE_ServiceUtil.dialerUsers();
            
            userInst.sfId = userRec.Id;
            userInst.userName = userRec.Username;
            userInst.email = userRec.email;
            if(userRec.userRole != null){
                userInst.role = userRec.userRole.Name;
            } 
            dialerList.add(userInst);

        }
        
        
        String userjson  = '';
         system.debug(dialerList);
        if(dialerList.size()>0)
        {
            /*userjson = JSON.serialize(dialerList);
            System.debug('---------'+userjson );
            ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest('<Endpoint>','','POST',userjson,'M2All');
            system.debug('Status Code: '+response .statusCode);
            system.debug('Status: '+response.status);
            system.debug('JsonBody: '+response.jsonBody);
            if(response!=null && response.status == '200'){
               Map<String, String> responseMap = new Map<String, String>();
               List<ACE_ServiceUtil.userPushResponse> userCreatedList = (List<ACE_ServiceUtil.userPushResponse>)JSON.deserialize(response.jsonBody.toString(),List<ACE_ServiceUtil.userPushResponse>.class);
               for(ACE_ServiceUtil.userPushResponse usrCreated : userCreatedList){
                   responseMap.put(usrCreated.sf_id, usrCreated.dialer_Id);
               }
               for(User userRec : userList){
                   userRec.Dialer_Id__c = responseMap.get(userRec.Id);
               }
               update userList;
            }*/
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}