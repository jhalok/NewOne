public without sharing class ACE_IncomingSiqChatController {
    
    @AuraEnabled
    public static List<ChatTranscript> chatTrnscrptList {get;set;}
    public static List<FormattedTranscript> chatDtlViewList{get;set;}
    public static String headerTxt {get;set;}
    public static String visitorName {get;set;}
    public static String visitorEmail {get;set;}
    public static String visitorPhone {get;set;}
    public static String visitorCity {get;set;}
    public static String visitedWebsite {get;set;}
    public static String visitedCompany {get;set;}
    
    @AuraEnabled
    public static Contact getContactRecord(Map<String, String> cus){
        Contact cntc;
        System.debug('Input mobileNo-->'+cus.get('MobileNumber'));
        if(cus.containsKey('MobileNumber') && cus.get('MobileNumber')!=null){
            List<Contact> cntList = [SELECT Id, Name, Phone, MobilePhone
                                     FROM Contact WHERE Phone =: cus.get('MobileNumber')];
            if(cntList!=null && cntList.size()>0){
                cntc=cntList[0];
            }
        }
        return cntc;
    }
    
    @AuraEnabled
    public static Lead getLeadRecord(Map<String, String> cus){
        Lead ld;
        System.debug('Input phoneNo-->'+cus.get('MobileNumber'));
        if(cus.containsKey('MobileNumber') && cus.get('MobileNumber')!=null){
            List<Lead> ldList = [SELECT Id, Name, Phone, MobilePhone 
                                 FROM Lead WHERE MobilePhone =: cus.get('MobileNumber')];
            if(ldList!=null && ldList.size()>0){
                ld=ldList[0];
            }
        }
        return ld;
    }
    
    @AuraEnabled
    public static Attachment FetchChatTranscriptById(Map<String, String> chatDtl){
        String cId= chatDtl.get('chatId');//'46';
        String pId= chatDtl.get('parentId');//5005D000005ECVwQAO
        system.debug('####cId='+cId+'--pId='+pId);
        Attachment at=generatePDFnAttachToParent(cId, pId);
        return at;
    }
    
    public static Attachment generatePDFnAttachToParent(String cId,String pId){
        PageReference defaultPage = new PageReference('/apex/ACE_ChatTranscriptPDFview'); //page location
        defaultPage.getParameters().put('cId',cId);
        defaultPage.getParameters().put('pId',pId);
        Datetime genDtTime=Datetime.now();
        String formattedDtStr=genDtTime.format('dd/MM/yyyy hh:mm:ss a');
        Blob pdfContent; //variable to hold binary PDF data.
        if(!Test.isRunningTest()){ // for code coverage 
            pdfContent = defaultPage.getContentAsPDF();
        } else {
            pdfContent = Blob.valueOf('This is a test.');
        }
        //create attachment
        system.debug('#####File pdfContent--->'+pdfContent);
        Attachment atch= new Attachment();
        atch.ParentId = pId;
        atch.Name = 'Chat_Transcript_'+cId+'-'+formattedDtStr+'.pdf'; 
        atch.Body = pdfContent;
        atch.contentType = 'application/pdf';
        insert atch;
        system.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ATTACHMENT INSERTED$$$$$$$$$$$');
        return atch;
    }
    
    public static List<FormattedTranscript> processFormatForViewList(List<ChatTranscript> chatList){
        List<FormattedTranscript> formattedChatList=new List<FormattedTranscript>();
        FormattedTranscript ft;
        for(Integer i=0;i<chatList.size();i++){
            ChatTranscript ct=chatList.get(i);
            ft = new FormattedTranscript();
            ft.ctRaw = ct;
            if(i==0){
                visitorName = ct.visitor_name;
                visitorEmail = ct.visitor_email;
                headerTxt = ct.question;
                ft.msgTxt = ct.question;
                ft.sentOn = DateTime.newInstance(Long.valueOf(ct.chatinitiated_time)).format();
                ft.sentBy = ct.visitor_name;
            }else{
                ft.msgTxt = ct.msg;
                if(ct.meta!=null && ct.meta.suggestions!=null && ct.meta.suggestions.size()>0){
                    for(Integer k=0;k<ct.meta.suggestions.size();k++){
                        String s=ct.meta.suggestions.get(k);
                        if(k==0){
                            ft.msgTxt+='\nSuggestions:\n'+s;
                        }else{
                            ft.msgTxt+=', '+s;
                        }
                    }
                }
                if(ct.meta!=null && ct.meta.input_card!=null && ct.meta.input_card.options!=null && ct.meta.input_card.options.size()>0){
                    for(Integer k=0;k<ct.meta.input_card.options.size();k++){
                        String s=ct.meta.input_card.options.get(k);
                        if(k==0){
                            ft.msgTxt+='\nOptions:\n'+s;
                        }else{
                            ft.msgTxt+=', '+s;
                        }
                    }
                }
                ft.sentOn = DateTime.newInstance(Long.valueOf(ct.time_x)).format();
                ft.sentBy = ct.dname;
            }
            formattedChatList.add(ft);
        }
        return formattedChatList;
    }    
    
    public static List<ChatTranscript> parseRawJsonStr(String rawJson){
        if(rawJson==null||String.isBlank(rawJson)){
            rawJson='{"data":[{"question":"I want a test drive for marazzo","chatinitiated_time":"1575062801714",'+
                '"visitor_email":"chatterjee.rajat@gmail.com","visitor_name":"Rajat chatterjee"},'+
                '{"msg":"Hey there! Looking for cars is it? I can help","sender":"15080000000017073","meta":'+
                '{"typing_delay":2,"hand_off":false,"suggestions":["Deals of the day","Great! Tell me more"],"version":1},'+
                '"msgid":"1575062721833","time":"1575062803969","dname":"SyouV_v2"},{"msg":"I want a test drive for marazzo",'+
                '"msgid":"1575062801551","time":"1575062803974","dname":"Rajat chatterjee"},{"msg":"Oops! Please try again",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"version":1},"msgid":"1575062811581",'+
                '"time":"1575062811589","dname":"SyouV_v2"},{"msg":"Want to test drive marazzo","msgid":"1575062831808",'+
                '"time":"1575062835164","dname":"Rajat chatterjee"},{"msg":"May I ask your name?","sender":"15080000000017073",'+
                '"meta":{"typing_delay":2,"hand_off":false,"version":1},"msgid":"1575062836956","time":"1575062836961","dname":"SyouV_v2"}'+
                ',{"msg":"Rajat","msgid":"1575062844476","time":"1575062847797","dname":"Rajat chatterjee"},'+
                '{"msg":"Okay. Let&#39;s book a test drive for you.","sender":"15080000000017073","meta":{"typing_delay":2,'+
                '"hand_off":false,"version":1},"msgid":"1575062849352","time":"1575062849358","dname":"SyouV_v2"},'+
                '{"msg":"Please enter your email address.","sender":"15080000000017073","meta":{"typing_delay":2,'+
                '"hand_off":false,"version":1},"msgid":"1575062849353","time":"1575062849361","dname":"SyouV_v2"},'+
                '{"msg":"chatterjee.rajat@gmail.com","msgid":"1575062863965","time":"1575062867297","dname":"Rajat chatterjee"},'+
                '{"msg":"Please enter your mobile number.","sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,'+
                '"version":1},"msgid":"1575062869457","time":"1575062869465","dname":"SyouV_v2"},{"msg":"9903007112",'+
                '"msgid":"1575062874658","time":"1575062878013","dname":"Rajat chatterjee"},'+
                '{"msg":"Please select the test drive location.","sender":"15080000000017073","meta":{"typing_delay":2,'+
                '"hand_off":false,"version":1},"msgid":"1575062880014","time":"1575062880022","dname":"SyouV_v2"},{"msg":"Mumbai",'+
                '"msgid":"1575062901088","time":"1575062904445","dname":"Rajat chatterjee"},'+
                '{"msg":"Please select the test drive location.","sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,'+
                '"version":1},"msgid":"1575062905780","time":"1575062905786","dname":"SyouV_v2"},{"msg":"Andheri","msgid":"1575062932646",'+
                '"time":"1575062936005","dname":"Rajat chatterjee"},{"msg":"Please select the test drive location.",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"version":1},"msgid":"1575062937331",'+
                '"time":"1575062937337","dname":"SyouV_v2"},{"msg":"Is marazzo available in mumbai","msgid":"1575062971170",'+
                '"time":"1575062974523","dname":"Rajat chatterjee"},'+
                '{"msg":"Are you sure you want to end the test drive  related conversation and start a new conversation?",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"suggestions":["Yes","No"],"version":1},'+
                '"msgid":"1575062977019","time":"1575062977026","dname":"SyouV_v2"},{"msg":"Yes",'+
                '"meta":{"card_data":{"type":"suggestions","value":"Yes"},"version":"1"},"msgid":"1575062979677","time":"1575062983032",'+
                '"dname":"Rajat chatterjee"},{"msg":"I can certainly help you to check the availability of our vehicles.",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"version":1},"msgid":"1575062988311",'+
                '"time":"1575062988318","dname":"SyouV_v2"},{"msg":"Please select a variant of Marazzo.","sender":"15080000000017073",'+
                '"meta":{"typing_delay":2,"hand_off":false,"input_card":{"options":["M8 BS4 DIESEL","M6 BS4 DIESEL","M4 BS4 DIESEL",'+
                '"M2 BS4 DIESEL"],"type":"select"},"version":1},"msgid":"1575062988312","time":"1575062988321","dname":"SyouV_v2"},'+
                '{"msg":"M8 BS4 DIESEL","meta":{"card_data":{"type":"select","value":"M8 BS4 DIESEL"},"version":"1"},'+
                '"msgid":"1575062998496","time":"1575063001848","dname":"Rajat chatterjee"},'+
                '{"msg":"This variant of Marazzo comes with the following options, which one will you prefer?",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"input_card":{"options":'+
                '["7 seater(2WD)","8 seater(2WD)"],"type":"select"},"version":1},"msgid":"1575063004195","time":"1575063004201",'+
                '"dname":"SyouV_v2"},{"msg":"8 seater(2WD)","meta":{"card_data":{"type":"select","value":"8 seater(2WD)"},'+
                '"version":"1"},"msgid":"1575063007726","time":"1575063011086","dname":"Rajat chatterjee"},'+
                '{"msg":"We have the following color options available for Marazzo, which one will you prefer?",'+
                '"sender":"15080000000017073","meta":{"typing_delay":2,"hand_off":false,"input_card":{"options":'+
                '["Aqua marine","Shimmering silver","Poseidon purple","Oceanic black","Mariner maroon","Iceberg white"],'+
                '"type":"select"},"version":1},"msgid":"1575063012614","time":"1575063012620","dname":"SyouV_v2"},'+
                '{"msg":"Poseidon purple","meta":{"card_data":{"type":"select","value":"Poseidon purple"},"version":"1"},'+
                '"msgid":"1575063027154","time":"1575063030510","dname":"Rajat chatterjee"}]}';
        }
        
        //String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(rawJson));
        String formattedJSON = replaceReservedTagsFromJSON(rawJson);
        system.debug('formattedJSON>>>>>>>'+formattedJSON);
        String rawJsonWithoutResrvTag=rawJson.replace('"time":', '"time_x":');
        System.debug('goodRawStr==='+rawJsonWithoutResrvTag);
        JSONParser parser = JSON.createParser(rawJsonWithoutResrvTag);
        
        List<ChatTranscript> chatList=new List<ChatTranscript>();
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        ChatTranscript ct = (ChatTranscript)parser.readValueAs(ChatTranscript.class);
                        chatList.add(ct);
                        system.debug('Name: ' + ct.visitor_name+'--'+ct.dname);
                        // For debugging purposes, serialize again to verify what was parsed.
                        String s = JSON.serialize(ct);
                        system.debug('Serialized val=: ' + s);                        
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }
        system.debug('chatlist size===================='+chatList.size());
        return chatList;
    }
    
    public static String replaceReservedTagsFromJSON(String rawData) {
        // Regex to match the start of the line and the key surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        // Replacement format of the new key surrounded by quotes and ending with a colon
        String replacementFormat = '"{0}" :';
        // A map of existing key to replacement key
        Map<String, String> replacements = new Map<String, String> {'time'=>'time_x'};
            // As JSON can be whatever format as per source, so format it to a known standard
            String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(rawData));
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(regexFormat,new List<String> {key});
            // Generate our replacement
            String replacement = String.format(replacementFormat,new List<String> {replacements.get(key)});
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        return formattedJSON;
    }
    
    //Wrapper-Classes******************START
    public class FormattedTranscript{
        @AuraEnabled
        public ChatTranscript ctRaw{get;set;}
        @AuraEnabled
        public String msgTxt{get;set;}
        @AuraEnabled
        public String sentOn{get;set;}
        @AuraEnabled
        public String sentBy{get;set;}
    }
    public class ChatTranscript {
        public String question {get;set;}
        public String chatinitiated_time {get;set;}
        public String visitor_email {get;set;}
        public String visitor_name {get;set;}
        public String msg {get;set;}
        public String sender {get;set;}
        public String msgid {get;set;}
        public String time_x {get;set;}
        public String dname {get;set;}
        public MetaItems meta {get;set;}
    }  
    public class MetaItems {
        public String typing_delay {get;set;}
        public String hand_off {get;set;}
        public List<String> suggestions {get;set;}
        public String version {get;set;}
        public InputCard input_card {get;set;}
        public CardData card_data {get;set;}
    }
    public class InputCard{
        public List<String> options {get;set;}
    }
    public class CardData{
        public String type {get;set;}
        public String value {get;set;}
    }
    //Wrapper-Classes******************END
    
    //############VFP-Logic################
    public ACE_IncomingSiqChatController(){//ApexPages.StandardController stdController
        String chatId=ApexPages.currentPage().getParameters().get('cId');
        String parentId=ApexPages.currentPage().getParameters().get('pId');
        system.debug('VFP::::chatId---->'+chatId+'::parentId=='+parentId);
        if(String.isNotBlank(chatId) && String.isNotBlank(parentId)){
            FetchChatForVfp(chatId, parentId);
            system.debug('###chatDtlViewList-->'+chatDtlViewList);
        }
    }
    
    public static void FetchChatForVfp(String cId,String pId){
        HttpRequest reqAuth = new HttpRequest();
        String limitCnt='99';
        reqAuth.setEndpoint('callout:SalesIQ_Chat/api/v1/democomp/chats/'+cId+'/transcript?limit='+limitCnt+'&access_type=offline&prompt=consent');
        reqAuth.setMethod('GET');
        Http httpAuth = new Http();
        HTTPResponse resAuth = httpAuth.send(reqAuth);
        System.debug('*************AuthResp-->'+resAuth);
        System.debug('*************AuthResp body-->'+resAuth.getBody());
        if(resAuth.getStatusCode()==200){
            String visitorPhoneNum='1234567890';//Lead's Phone number
            chatTrnscrptList= parseRawJsonStr(resAuth.getBody());
            if(chatTrnscrptList!=null && chatTrnscrptList.size()>0){
                chatDtlViewList=processFormatForViewList(chatTrnscrptList);
            }
        }
    }
    
    public static void RnD(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://my_endpoint.example.com/some_path');
        req.setMethod('GET');
        String username = 'myname';
        String password = 'mypwd';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        // Create a new http object to send the request object
        // A response object is generated as a result of the request  
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    //-------------------Below methods are not used-----------------------------//
    public static void FetchChatForVfp_old(String cId,String pId){
        /*string accessToken='';
        string username=UserInfo.getUserName();
        system.debug('CID: '+cId);
        string payload = 'client_id=' + '1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV' + '&client_secret=' + '54371b1275d9c086a12576b8f9426977278835a3b0' + '&username=' + UserInfo.getUserName() + '&grant_type=client_credentials';
        HttpRequest req = new HttpRequest();
        String limitCnt='99';
        req.setMethod('POST');req.setEndpoint('callout:SalesIQ_Chat/api/v1/democomp/chats/'+cId+'/transcript?limit='+limitCnt);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Content-Length',String.valueOf(payload.length()));
        req.setBody(payload);
        Http binding = new Http();
        HttpResponse res = binding.send(req);
        if (res.getStatusCode() == 200) {
            JSONParser parser = JSON.createParser(res.getBody()); 
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='access_token')){
                    parser.nextToken();
                    accessToken= parser.getText();
                }
            }
        }
        System.debug('accessToken : ' +  accessToken);
        
        */
        
        /*
        String restUrl = 'callout:SalesIQ_Chat/api/v1/democomp/chats/46';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restUrl);
        req.setMethod('GET');
        HttpResponse res = h.send(req);*/
        
        //NamedCredential nc=[SELECT Id FROM NamedCredential WHERE DeveloperName = 'SalesIQ_Chat'];
        //Database.updateAsync((SObject)nc);
        
        HttpRequest reqAuth = new HttpRequest();
        String limitCnt='99';
        //Good
        reqAuth.setEndpoint('callout:SalesIQ_Chat/api/v1/democomp/chats/'+cId+'/transcript?limit='+limitCnt+'&access_type=offline&prompt=consent');
        //Bad
        //reqAuth.setEndpoint('callout:SalesIQ_UsrPwd/api/v1/democomp/chats/'+cId+'/transcript?limit='+limitCnt+'&access_type=offline&prompt=consent');
        reqAuth.setMethod('GET');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('Accept', 'application/json');
        //reqAuth.setHeader('Authorization', 'OAuth {!$SalesIQ_Chat.OAuthToken}');
        //reqAuth.setHeader('Authorization', 'Zoho-oauthtoken {!$SalesIQ_Chat.OAuthToken}');
        Http httpAuth = new Http();
        //String accessToken = Auth.AuthToken.getAccessToken('0SO5D00000000glWAA', 'Open ID Connect');
        //system.debug('Access Token#####'+ accessToken);
        //Map<String, String> responseMap = Auth.AuthToken.refreshAccessToken('0SO5D00000000gl', 'SalesIQ_Chat', accessToken);
        HTTPResponse resAuth = httpAuth.send(reqAuth);
        System.debug('*************AuthResp-->'+resAuth);
        System.debug('*************AuthResp body-->'+resAuth.getBody());
        if(resAuth.getStatusCode()==200){
            String visitorPhoneNum='1234567890';//Lead's Phone number
            chatTrnscrptList= parseRawJsonStr(resAuth.getBody());
            if(chatTrnscrptList!=null && chatTrnscrptList.size()>0){
                chatDtlViewList=processFormatForViewList(chatTrnscrptList);
            }
        }
    }
    public static List<ChatTranscript> FetchChatTranscriptByIdOld(Map<String, String> chatDtl){
        HttpRequest reqAuth = new HttpRequest();
        String cId= chatDtl.get('chatId');//'46';
        String pId= chatDtl.get('parentId');//5005D000005ECVwQAO
        /*Http h = new Http();
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:SalesIQ_Chat/api/v1/democomp/chats/'+cId);
req.setMethod('GET');
HttpResponse res = h.send(req);*/
        
        
        String limitCnt='55';
        reqAuth.setEndpoint('callout:SalesIQ_Chat/api/v1/democomp/chats/'+cId+'/transcript?limit='+limitCnt);
        reqAuth.setMethod('GET');
        Http httpAuth = new Http();
        HTTPResponse resAuth = httpAuth.send(reqAuth);
        System.debug('AuthResp-->'+resAuth);
        System.debug('AuthResp body-->'+resAuth.getBody());
        
        String visitorPhoneNum='1234567890';//Lead's Phone number
        //saveResponsetoDb(cId, pId, resAuth.getBody());
        chatTrnscrptList= parseRawJsonStr(resAuth.getBody());
        if(chatTrnscrptList!=null && chatTrnscrptList.size()>0){
            //generatePdfAndAttachToParent(cId, pId);
            //createAttachment(chatTrnscrptList,pId,cId,visitorPhoneNum);
        }
        return chatTrnscrptList;
    }
    
    @AuraEnabled
    public static void refreshConnection(){
        String clientId='1000.N4NKIJ6LS96675BCLMSCPOKDM0FYOV';
        String clientSecret='54371b1275d9c086a12576b8f9426977278835a3b0';
        String redirectUrl='https://mahindradealerworld--acedev.my.salesforce.com/services/authcallback/SalesIQ_Chat';
        String authScope='SalesIQ.operators.UPDATE';
        String authUrl='https://accounts.zoho.in/oauth/v2/auth?response_type=code'+
            '&client_id='+clientId+'&scope='+authScope+'&redirect_uri='+redirectUrl;
        
        //&access_type=offline&prompt=consent&grant_type=refresh_token
        HttpRequest reqAuth = new HttpRequest();
        reqAuth.setEndpoint(authUrl);
        reqAuth.setMethod('GET');
        Http httpAuth = new Http();
        HTTPResponse resAuth = httpAuth.send(reqAuth);
        System.debug('Auth::Resp-->'+resAuth);
        System.debug('Auth::Resp body-->'+resAuth.getBody());
        System.debug('Auth::Resp hdrkeyset-->'+resAuth.getHeaderKeys());
        System.debug('Auth::Resp status-->'+resAuth.getStatus());
        System.debug('Auth::Resp stsCode-->'+resAuth.getStatusCode());
        for(String k:resAuth.getHeaderKeys()){
            system.debug(k+'-Value='+resAuth.getHeader(k));
        }
        String tokenCode='';
        
        String tokenUrl='https://accounts.zoho.in/oauth/v2/token?code='+tokenCode+
            '&grant_type=authorization_code&client_id='+clientId+'&client_secret='+clientSecret+
            '&redirect_uri='+redirectUrl+'&scope=SalesIQ.operators.READ';
        
        HttpRequest reqTokn = new HttpRequest();
        reqTokn.setEndpoint(tokenUrl);
        reqTokn.setMethod('POST');
        Http httpTokn = new Http();
        //req.setHeader('Authorization', 'Zoho-oauthtoken '+theTokenResponse);
        //req.setHeader('Authorization', 'OAuth {!$Credential.OAuthToken}');
        
    }
    
    public static void createAttachmentOld(List<ChatTranscript> chatList, String atachPrntId,String cId,String phoneNum){
        if(chatList!=null && !chatList.isEmpty()){
            String txtBody='';
            Datetime genDtTime=Datetime.now();
            for(Integer i=0;i<chatList.size();i++){
                ChatTranscript ct=chatList.get(i);
                if(i==0){
                    txtBody+='<h1><strong><u>'+ct.question+'</u></strong><h1>';
                    txtBody+='<h3>Visitor :'+ct.visitor_name+' [Phone: '+phoneNum+'; Email: '+ct.visitor_email+']</h3>';
                    txtBody+='<p>';
                    txtBody+='Message : '+ct.question+'<br/>';
                    if(ct.chatinitiated_time!=null){
                        DateTime dt = DateTime.newInstance(Long.valueOf(ct.chatinitiated_time));
                        txtBody+='Sent On : '+dt+'<br/>';
                    }
                    txtBody+='</p>';
                }else{
                    
                    txtBody+='<p>';
                    txtBody+='Message : '+ct.msg+'<br/>';
                    if(ct.msgid!=null){
                        txtBody+='Message Id : '+ct.msgid+'<br/>';
                    }
                    if(ct.time_x!=null){
                        DateTime dt = DateTime.newInstance(Long.valueOf(ct.time_x));
                        txtBody+='Sent On : '+dt+'<br/>';
                    }
                    txtBody+='Sent By : '+ct.dname+'<br/>';
                    if(ct.sender!=null){
                        txtBody+='Agent ID : '+ct.sender+'<br/>';
                    }
                    txtBody+='</p>';
                }
            }
            system.debug('##File txtBody--->'+txtBody);
            Blob pdfContent=Blob.valueof(txtBody);
            Attachment atch= new Attachment();
            atch.ParentId = atachPrntId;//'0010K00001e2kcG';
            atch.Name = 'Chat_Transcript_'+cId+'_'+genDtTime.getTime()+'.html'; 
            atch.Body = pdfContent;
            atch.contentType = 'application/html';
            //atch.contentType = 'application/pdf';
            insert atch;
        }
    }
    
}