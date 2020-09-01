public class LeadTriggerHandler {
    
    public static String scenarioKey = getScenarioKey();
    
    public static void handleAfterInsert(List<Lead> newLst){
        for(Lead l : newLst){
            sendMessage(l.Phone12__c, l.FirstName + ' ' + l.lastName, 'Mahindra');
        }
    }
    
    @future(callout=true)
    public static void sendMessage(String phone, String param1, String param2){
        String baseUrl = 'https://192191.api.infobip.com/omni/1/advanced';
        String userName = 'Mahindra.test';
        String passWord = 'Mahindra@2020';
        
        Httprequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint( baseUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf( userName + ':' + password )));
        
        String body = '{'+
            '"scenarioKey": "' + scenarioKey + '",'+
            '"destinations": ['+
            '{'+
            '"to": {'+
            '"phoneNumber": "' + phone + '"'+
            '}'+
            '}'+
            '],'+
            '"whatsApp": {'+
            '"templateName": "infobip_test_hsm",'+
            '"templateNamespace": "whatsapp:hsm:it:infobip",'+
            '"templateData": ['+
            '"' + param1 + '",'+
            '"' + param2 + '"'+
            '],'+
            '"language": "en_GB"'+
            '},'+
            '"sms": {'+
            '"text": "This text will be received via SMS if WhatsApp message is not delivered.",'+
            '"validityPeriod": 1'+
            '}'  +
            '}';
        req.setBody(body);
        Http h = new http();
        Httpresponse res = h.send(req);
        if(res.getStatusCode() == 200){
            system.debug('SUCCESS');
        }else{
           system.debug(res.getStatusCode() + ' : ' + res.getStatus());   
        }
    }
    
    public static String getScenarioKey(){
        List<Infobip_Scenario_Key__c> scenarioKeys = [SELECT Id, key__c FROM Infobip_Scenario_Key__c WHERE NOT key__c = null LIMIT 1];
        if(!scenarioKeys.isEmpty()){
            return scenarioKeys[0].key__c;
        }
        return null;
    }
}