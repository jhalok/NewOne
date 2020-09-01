public class GenerateInfobipScenarioKeyController {
    
    //Retrives Scenario Key
    public void doGetScenarioKey(){
        String baseUrl = 'https://192191.api.infobip.com/omni/1/scenarios';
        String userName = 'Mahindra.test';
        String passWord = 'Mahindra@2020';
        
        Httprequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint( baseUrl);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf( userName + ':' + password )));
        
        String body = '{'+
            '"name": "My WHATSAPP-SMS scenario",'+
                '"flow": ['+
                    '{'+
                        '"from": "447491163530",'+
                            '"channel": "WHATSAPP"'+
                                '},'+
                    '{'+
                        '"from": "InfoSMS",'+
                            '"channel": "SMS"'+
                                '}'+
                '],'+
                    '"default": true'+
                        '}'  ;
        req.setBody(body);
        Http h = new http();
        Httpresponse res = h.send(req);
        if(res.getStatusCode() == 201){
            String scenarioKey = parse(res.getBody()).key;
            List<Infobip_Scenario_Key__c> scenarioKeys = [SELECT Id, key__c FROM Infobip_Scenario_Key__c WHERE NOT key__c = null LIMIT 1];
            if(scenarioKeys.isEmpty()){
                insert new Infobip_Scenario_Key__c(name = 'Infobip scenario key', key__c = scenarioKey);
            }else{
                Infobip_Scenario_Key__c sk = scenarioKeys[0];
                sk.key__c = scenarioKey;
                update sk;
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Scenario Key :' + scenarioKey));
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error : ' + res.getStatusCode() + ', ' + res.getStatus()));
        }
    }
    
    public class ScenarioKeyWrapper{
        String key;
    }
    
    public ScenarioKeyWrapper parse(String jsonString){
        return (ScenarioKeyWrapper) JSON.deserialize(jsonString, ScenarioKeyWrapper.class);
    }
}