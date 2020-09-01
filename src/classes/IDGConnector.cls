public class IDGConnector {
   public static String IDGMakeCall(String CLI) {
       system.debug('get IDGMakeCall info called');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://122.160.24.159:9004/api/cti/GetAgentHostId?loginId=agent1');
        request.setMethod('GET');
        String JSONString = '';
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            /*Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Integer ResultCode =  (Integer)m.get('ResultCode');
            System.debug('ResultCode:' + ResultCode);
            String ResultString = (String)m.get('ResultString');
            System.debug('ResultString:' + ResultString);
            IDGResult idgResult = new IDGResult();            
            idgResult.ResultCode = ResultCode;
            idgResult.ResultString = ResultString;
            JSONString = JSON.serialize(idgResult);*/
            JSONString = response.getBody();
        }
        return JSONString;
    }
   public static String GetUserInfo() {
        User currentuser=new User();
        currentuser=[Select UserName,Extension from User where Id=:userinfo.getuserId()];
        return JSON.serialize(currentuser);
    }
    public static string GetContactInfo(String cli,string callData) {
        ACE_MRC_TeckInfoCTIAPI.cls_callDetails callLog = (ACE_MRC_TeckInfoCTIAPI.cls_callDetails)JSON.deserialize(callData,ACE_MRC_TeckInfoCTIAPI.cls_callDetails.class);
        string salesforceId = '';
        salesforceId=   callLog.AddOn; // salesforce id passed during push of leads from sf to dialer
        string callType = callLog.CallTypeName; // Inbound / Outbound
        string callNumber = callLog.CLI; // phone no
        system.debug(callLog);
        string url = null;
        List<ACE_Inbound_Call__e> navigationList = new List<ACE_Inbound_Call__e>();
        
        Id contactId = null;
        Id leadId = null;
        
        for(Lead record: [select Id from lead where (phone =:callNumber or MobilePhone =:callNumber or Phone =:callNumber) and status not in('Closed - Not Converted','Qualified')]){
            leadId = record.Id;
        }
        for(contact record:[select Id,accountId from contact where (phone =:callNumber or MobilePhone =:callNumber  or Phone =:callNumber)]){
                contactId = record.Id;
        }
        system.debug(leadId);
        system.debug(contactId);
        system.debug(callType);
        if(callType == 'Inbound')
        {
            boolean found = false;
            if(contactId!=null){
                navigationList.add(new ACE_Inbound_Call__e(URL__c = contactId,UserId__c=UserInfo.getUserId()));
                found = true;
            }
            if(leadId!=null && !found){
                navigationList.add(new ACE_Inbound_Call__e(URL__c = leadId,UserId__c=UserInfo.getUserId()));
                found = true;
            }
            
            if(!found)
            navigationList.add(new ACE_Inbound_Call__e(URL__c = 'New_Inbound_Call',Mobile__c=Decimal.valueOf(callNumber),UserId__c=UserInfo.getUserId()));
        }
        else
        {
            if(salesforceId!=null){
                navigationList.add(new ACE_Inbound_Call__e(URL__c = salesforceId,UserId__c=UserInfo.getUserId()));
            }
        }
        
        if(navigationList.size()>0){
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(navigationList);
            
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }       
            }
            
        }
        return '';
      }

    /*To be managed by PWC Team*/
    public void  GetCallInfo(String callData) {
        system.debug('get call info called');
        
    }
}