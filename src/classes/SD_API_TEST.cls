global class SD_API_TEST extends Auth.AuthProviderPluginClass {
    // Use this URL for the endpoint that the 
    // authentication provider calls back to for configuration.
    public String redirectUrl; 
    private String key;
    private String secret;
    
    // Application redirection to the Concur website for 
    // authentication and authorization.
    private String authUrl;  
    
    // URI to get the new access token from concur using the GET verb.
    private String accessTokenUrl; 
    
    // Api name for the custom metadata type created for this auth provider.
    private String customMetadataTypeApiName; 
    
    // Api URL to access the user in Concur
    private String userAPIUrl; 
    
    // Version of the user api URL to access data from Concur
    private String userAPIVersionUrl; 
    
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    } 
    
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate){ 
        authUrl = 'https://accounts.zoho.in/oauth/v2/auth';
            //authProviderConfiguration.get('Auth_Url__c'); 
        key = '1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV';
            //authProviderConfiguration.get('Key__c'); 
        stateToPropagate='5466400890088961855';
        // Here the developer can build up a request of some sort. 
        // Ultimately, they return a URL where we will redirect the user. 
        String url = authUrl + '?client_id='+ key +'&scope=SalesIQ.chattranscript.READ&redirect_uri='+ 
            redirectUrl + '&response_type=code&access_type=offline&state=' + stateToPropagate;
        PageReference pg=new PageReference(url);
        pg.setRedirect(true);
        return pg; 
    } 
    
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string>authProviderConfiguration, 
                                                         Auth.AuthProviderCallbackState state ) 
    { 
        // Here, the developer will get the callback with actual protocol. 
        // Their responsibility is to return a new object called 
        // AuthProviderTokenResponse. 
        // This will contain an optional accessToken and refreshToken 
        key = '1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV';
            //authProviderConfiguration.get('Key__c'); 
        secret = '54371b1275d9c086a12576b8f9426977278835a3b0';
            //authProviderConfiguration.get('Secret__c'); 
        accessTokenUrl = 'https://accounts.zoho.in/oauth/v2/token';
            //authProviderConfiguration.get('Access_Token_Url__c'); 
        
        Map<String,String> queryParams = state.queryParameters; 
        String code = queryParams.get('code'); 
        String sfdcState = queryParams.get('state'); 
        
        HttpRequest req = new HttpRequest(); 
        String url = accessTokenUrl+'?code='+code+'&client_id='+key+'&client_secret='+ secret; 
        req.setEndpoint(url); 
        req.setHeader('Content-Type','application/json'); 
        req.setMethod('GET'); 
        
        Http http = new Http(); 
        HTTPResponse res = http.send(req); 
        String responseBody = res.getBody();
        system.debug('responseBody=='+responseBody);
        String token = getTokenValueFromResponse(responseBody, 'Token', null); 
        
        return new Auth.AuthProviderTokenResponse('SD_API_TEST', token,'refreshToken', sfdcState); 
    } 
    
    global Auth.UserData getUserInfo(Map<string,string>authProviderConfiguration,
                                     Auth.AuthProviderTokenResponse response) 
    { 
        //Here the developer is responsible for constructing an 
        //Auth.UserData object 
        String token = response.oauthToken; 
        HttpRequest req = new HttpRequest(); 
        userAPIUrl = authProviderConfiguration.get('API_User_Url__c');
        userAPIVersionUrl = authProviderConfiguration.get('API_User_Version_Url__c'); 
        req.setHeader('Authorization', 'OAuth ' + token); 
        req.setEndpoint(userAPIUrl); 
        req.setHeader('Content-Type','application/json'); 
        req.setMethod('GET'); 
        
        Http http = new Http(); 
        HTTPResponse res = http.send(req); 
        String responseBody = res.getBody(); 
        String id = getTokenValueFromResponse(responseBody, 'LoginId',userAPIVersionUrl); 
        String fname = getTokenValueFromResponse(responseBody, 'FirstName', userAPIVersionUrl); 
        String lname = getTokenValueFromResponse(responseBody, 'LastName', userAPIVersionUrl); 
        String flname = fname + ' ' + lname; 
        String uname = getTokenValueFromResponse(responseBody, 'EmailAddress', userAPIVersionUrl); 
        String locale = getTokenValueFromResponse(responseBody, 'LocaleName', userAPIVersionUrl); 
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('what1', 'noidea1'); 
        provMap.put('what2', 'noidea2'); 
        return new Auth.UserData(id, fname, lname, flname, uname, 'what', 
                                 locale, null, 'SD_API_TEST', null, provMap); 
    } 
    
    private String getTokenValueFromResponse(String response,String token, String ns){ 
        Dom.Document docx = new Dom.Document(); 
        docx.load(response); 
        String ret = null; 
        
        dom.XmlNode xroot = docx.getrootelement() ; 
        if(xroot != null){ ret = xroot.getChildElement(token, ns).getText(); 
                         } 
        return ret; 
    } 
    
    public static void AUTH(){
        /*
        MetadataService.NamedCredential credential = new MetadataService.NamedCredential();
        credential.fullName = 'SalesIQ_Chat';
        credential.label = 'SalesIQ_Chat';
        credential.endpoint = 'https://salesiq.zoho.in';
        credential.principalType = 'NamedPrincipal';
        credential.protocol = 'OAuth2.0';*/
        
        String clientId='1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV';
        String clientSecret='54371b1275d9c086a12576b8f9426977278835a3b0';
        String redirectUrl='https%3A%2F%2Fmahindradealerworld--acedev.my.salesforce.com%2Fservices%2Fauthcallback%2FSalesIQ_Chat%2F';
        String auth_url = 'https://accounts.zoho.in/oauth/v2/auth';
        String params = '?response_type=code&access_type=offline' +
            '&client_id='+clientId +'&redirect_uri='+redirectUrl+
            '&scope=SalesIQ.operators.UPDATE' +////SalesIQ.chattranscript.READ
            //'&prompt=consent'+
            '&state='+'123456';
        system.debug('URL='+auth_url+params);
        HttpRequest reqAuth = new HttpRequest();
        reqAuth.setEndpoint(auth_url+params);
        reqAuth.setMethod('GET');
        Http httpAuth = new Http();
        HTTPResponse resAuth = httpAuth.send(reqAuth);
        System.debug('Auth::Resp-->'+resAuth);
        System.debug('Auth::Resp body-->'+resAuth.getBody());
        System.debug('Auth::Resp hdrkeyset-->'+resAuth.getHeaderKeys());
        System.debug('Auth::Resp status-->'+resAuth.getStatus());
        System.debug('Auth::Resp stsCode-->'+resAuth.getStatusCode());
        String tokenCode;
        for(String k:resAuth.getHeaderKeys()){
            system.debug(k+'-##Value='+resAuth.getHeader(k));
            if(k=='Set-Cookie'){
                List<String> cLst=resAuth.getHeader(k).split(';');
                system.debug('cLst='+cLst);
                for(String s:cLst){
                    if(s.startsWith('iamcsr')){
                        tokenCode=s.substringAfter('=');
                        System.debug('tokenCode===>'+tokenCode);
                        break;
                    }
                }
            }
        }
        
        if(tokenCode!=null){
            String tokenUrl='https://accounts.zoho.in/oauth/v2/token?code='+tokenCode+
            '&grant_type=authorization_code&client_id='+clientId+'&client_secret='+clientSecret+
            '&redirect_uri='+redirectUrl+'&scope=SalesIQ.operators.READ';
            
            HttpRequest reqTokn = new HttpRequest();
            reqTokn.setEndpoint(tokenUrl);
            reqTokn.setMethod('POST');
            Http httpTokn = new Http();
            HTTPResponse resTokn = httpTokn.send(reqTokn);
            System.debug('Tokn::Resp-->'+resTokn);
            System.debug('Tokn::Resp body-->'+resTokn.getBody());
            System.debug('Tokn::Resp hdrkeyset-->'+resTokn.getHeaderKeys());
            System.debug('Tokn::Resp status-->'+resTokn.getStatus());
            System.debug('Tokn::Resp stsCode-->'+resTokn.getStatusCode());
        }
    }
}