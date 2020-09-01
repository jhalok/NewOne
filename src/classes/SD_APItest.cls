public class SD_APItest {
    public string theCode {get;set;}
    public string theTokenResponse {get;set;}
    public static final String stateVal='1A2B3C4D5E';
    
    public pagereference auth_Step_1(){
        
        String auth_url = 'https://accounts.zoho.in/oauth/v2/auth';
        String params = '?response_type=code&access_type=offline' +
            '&client_id=1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV' +
            '&redirect_uri=https%3A%2F%2Fmahindradealerworld--acedev.my.salesforce.com%2Fservices%2Fauthcallback%2FSalesIQ_Chat'+
            '&scope=SalesIQ.operators.UPDATE' +////SalesIQ.chattranscript.READ
            //'&prompt=consent'+
            //''; 
            '&state='+stateVal;
        pageReference pr = New PageReference(auth_url + params);            
        return pr;
    }
    
    public pagereference auth_Step_2(){
        
        if(apexPages.currentPage().getParameters().get('state') != '1A2B3C4D5E') return null;
        
        theCode = apexPages.currentPage().getParameters().get('code');
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        String auth_url = 'https://accounts.zoho.in/oauth/v2/token';
        String params = '?code=' + theCode +
            '&grant_type=authorization_code' + 
            '&client_id=1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV' +
            '&client_secret=54371b1275d9c086a12576b8f9426977278835a3b0' +
            '&scope=SalesIQ.operators.READ'+////SalesIQ.chattranscript.READ
            '&redirect_uri=https%3A%2F%2Fmahindradealerworld--acedev.my.salesforce.com%2Fservices%2Fauthcallback%2FSalesIQ_Chat';
        
        req.setMethod('POST');
        req.setEndpoint(auth_url + params);
        req.setHeader('Content-Type','application/json');
        
        //req.setHeader('Content-Length',string.valueOf(req.getBody().length()));
        
        HTTPResponse resp = http.send(req);
        
        theTokenResponse = resp.getBody();
        system.debug('theTokenResponse='+theTokenResponse);
        req.setHeader('Authorization', 'Zoho-oauthtoken '+theTokenResponse);
        
        return null;
        
    }
}