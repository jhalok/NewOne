@RestResource(urlMapping='/SyncSfUsers/*') //Sync MRC/M2All User from Dialers
global with sharing class ACE_SyncSFUsersApi {

    public static String invalidInputErrMsgStr;
/* Request JSON Input Structure:
[{
"fName":"Ankur",
"lName":"Biswas",
"email":"ankur.biswas@pwc.com",
"usrName":"ankur.biswas@pwc.com",
"nickName":"ankur.biswas@pwc.com",
"emilEncodingKey":"ISO-8859-1",
"alias":"abiswas",
"timeZoneSidKey":"America/Los_Angeles",//Asia/Kolkata
"localeSidKey":"en_US",
"languageLocaleKey":"en_US",
"profileName":"MRC Administrator",
"roleName":"Test"
}]
 * profileName = MRC Administrator / M2All Administrator??...roleName???
 * alias,usrName can be derived field
 * emilEncodingKey,timeZoneSidKey,localeSidKey,languageLocaleKey can be static field
*/    
    @HttpPost
    global static String saveModifiedCtdInSF() {
        String jsonResponse = '';
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        List<ACE_ServiceUtil.ServiceResponse> responseList = new List<ACE_ServiceUtil.ServiceResponse>();
        ACE_ServiceUtil.ServiceResponse srvResp;
     	List<ACE_ServiceUtil.SfUserInfo> usrRawList = (List<ACE_ServiceUtil.SfUserInfo>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.SfUserInfo>.class);
        
        Set<String> profileNameSet=new Set<String>();
        Set<String> roleNameSet=new Set<String>();
        Set<String> usrSfIdSet=new Set<String>();
        Set<String> qNameSet=new Set<String>();
        Map<String,String> profileNameIdMap=new Map<String,String>();
        Map<String,String> roleNameIdMap=new Map<String,String>();
        Map<String,User> oldUsrDtlMap=new Map<String,User>();
        Map<String,String> qNameIdMap=new Map<String,String>();
        Map<String,String> d_UsrId_qIdMap=new Map<String,String>();
        //SandBoxInfo currSandBox=new SandBoxInfo();
        Organization org = [select Name,IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        String sandBoxName=UserInfo.getUserName().substringAfterLast('.');
        
        if(usrRawList!=null && !usrRawList.isEmpty()){
            for(ACE_ServiceUtil.SfUserInfo item: usrRawList){
                if(item.profileName!=null)	profileNameSet.add(item.profileName);
                if(item.roleName!=null)	roleNameSet.add(item.roleName);
                if(item.sfUserId!=null)	usrSfIdSet.add(item.sfUserId);
                if(item.queueName!=null)	qNameSet.add(item.queueName);
            }
        }
        
        if(!profileNameSet.isEmpty()){
            for(Profile p:[Select Name,Id From Profile Where Name IN:profileNameSet]){
                profileNameIdMap.put(p.Name,p.Id);
            }
        }
        if(!roleNameSet.isEmpty()){
            for(UserRole r:[Select Name,Id From UserRole Where Name IN:roleNameSet]){
                roleNameIdMap.put(r.Name,r.Id);
            }
        }
        if(!usrSfIdSet.isEmpty()){
            oldUsrDtlMap = fetchExistingUserDetails(usrSfIdSet);
        }
        if(!qNameSet.isEmpty()){
            qNameIdMap = fetchQueuesByNames(qNameSet);
        }
        
        List<User> userUpsertList = new List<User>();
        User usrObj;

        for(ACE_ServiceUtil.SfUserInfo rawUsr: usrRawList){
            usrObj=null;
            if(String.isNotBlank(rawUsr.sfUserId) && !oldUsrDtlMap.isEmpty() && oldUsrDtlMap.containsKey(rawUsr.sfUserId))
            {
                usrObj=oldUsrDtlMap.get(rawUsr.sfUserId);
            }
            if(usrObj==null){
                usrObj = new User();
            }
            
            if(rawUsr.fName!=null)	usrObj.FirstName = rawUsr.fName;
            if(rawUsr.lName!=null)	usrObj.LastName = rawUsr.lName;
            
            if(rawUsr.usrName!=null && isValidEmailFormat(rawUsr.usrName)){
                //u.Username = rawUsr.usrName+'.'+currSandBox.sandboxName;
                if(org.IsSandbox){
                    usrObj.Username = rawUsr.usrName+'.'+sandboxName;
                }else{
                    usrObj.Username = rawUsr.usrName;
                }
            }
            if(rawUsr.email!=null){
                usrObj.Email = rawUsr.email;
                if(String.isBlank(usrObj.Username)){
                    if(org.IsSandbox){
                        usrObj.Username = rawUsr.Email+'.'+sandboxName;
                    }else{
                        usrObj.Username = rawUsr.Email;
                    }
                }
            }
            if(rawUsr.profileName!=null && profileNameIdMap.containsKey(rawUsr.profileName)){
                usrObj.ProfileId = profileNameIdMap.get(rawUsr.profileName);
            }
            if(rawUsr.roleName!=null && roleNameIdMap.containsKey(rawUsr.roleName)){
                usrObj.UserRoleId = roleNameIdMap.get(rawUsr.roleName);
            }
            if(rawUsr.dialerUserId!=null){
                usrObj.Dialer_User_ID__c= rawUsr.dialerUserId;
                if(rawUsr.queueName!=null && !qNameIdMap.isEmpty() && qNameIdMap.containsKey(rawUsr.queueName)){
                    d_UsrId_qIdMap.put(usrObj.Dialer_User_ID__c,qNameIdMap.get(rawUsr.queueName));
                }
            }
            
            usrObj.CommunityNickname= (rawUsr.nickName!=null)?rawUsr.nickName:usrObj.Username;
            usrObj.Alias = (rawUsr.alias!=null)?rawUsr.alias:generateAliasName(rawUsr.fName,rawUsr.lName);
            usrObj.EmailEncodingKey = (rawUsr.emilEncodingKey!=null)?rawUsr.emilEncodingKey:'ISO-8859-1';
            usrObj.TimeZoneSidKey = (rawUsr.timeZoneSidKey!=null)?rawUsr.timeZoneSidKey:'Asia/Kolkata';
            usrObj.LocaleSidKey = (rawUsr.localeSidKey!=null)?rawUsr.localeSidKey:'en_US';
            usrObj.LanguageLocaleKey = (rawUsr.languageLocaleKey!=null)?rawUsr.languageLocaleKey:'en_US';
            usrObj.IsActive = (rawUsr.isActive!=null && rawUsr.isActive=='true')?true:false;
            
            if(isValidUserWithRequiredVals(usrObj)){
                system.debug('Valid User Details--->'+usrObj);
                //TestOnly-----START
                usrObj.IsActive=false;//Delete this line later
                //TestOnly-----END
                userUpsertList.add(usrObj);
            }else{
                system.debug('Invalid User Details--->'+usrObj);
                srvResp = new ACE_ServiceUtil.ServiceResponse();
                srvResp.responseMsg = invalidInputErrMsgStr+': '+rawUsr.fName+' '+rawUsr.lName;
                srvResp.responseCode = '1000';
                srvResp.otherImpObjId= rawUsr.dialerUserId;
                responseList.add(srvResp);
            }
        }
        if(userUpsertList.size() > 0){
            List<Database.UpsertResult> results = Database.upsert(userUpsertList,User.Username,false);
            Set<String> successRecordIds=new Set<String>();
            Integer i=0;
            for(Database.UpsertResult sr: results){
                if(sr.isSuccess()){
                    System.debug('Success' +sr.getId());
                    srvResp = new ACE_ServiceUtil.ServiceResponse();
                    srvResp.responseMsg = 'User Record Saved Successfully: '+sr.getId();
                    srvResp.sfRecordId = sr.getId();
                    srvResp.responseCode = '9999';
                    responseList.add(srvResp);
                    successRecordIds.add(sr.getId());
                }
                else{
                    System.debug('Failure!!');
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred-->'+err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('Fields that affected this error: ' + err.getFields());
                        srvResp = new ACE_ServiceUtil.ServiceResponse();
                        srvResp.responseMsg = err.getMessage();
                        srvResp.sfRecordId = sr.getId();
                        srvResp.responseCode = '1001';
                        responseList.add(srvResp);
                    }
                }
                i++;
            }
            //Queue Assignment
            assignUsersToQueue(successRecordIds, d_UsrId_qIdMap);
            
            jsonResponse = JSON.serialize(responseList); 
        }
        else{
            jsonResponse='Invalid user details provided, Unable to Save Record(s)!!';
        }
        return jsonResponse;
    }
    
    /*--------------------Supporting Methods--------------------*/
    
    public static Map<String,User> fetchExistingUserDetails(Set<String> sfUsrIdSet){
        Map<String,User> oldUsrDtlMap = new Map<String,User>();
        if(sfUsrIdSet!=null && !sfUsrIdSet.isEmpty()){
            for(User u:[SELECT Id,Name,FirstName,LastName,Username,Email,ProfileId,UserRoleId,CommunityNickname,Alias,
                        EmailEncodingKey,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,IsActive,Dialer_User_ID__c 
                        FROM User WHERE Id IN:sfUsrIdSet])
            {
                oldUsrDtlMap.put(u.Id,u);
            }
        }
        return oldUsrDtlMap;
    }
    
    public static Map<String,String> fetchQueuesByNames(Set<String> qNameSet){
        Map<String,String> qNameIdMap=new Map<String,String>();
        if(qNameSet!=null && !qNameSet.isEmpty()){
            for(Group gq:[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name IN: qNameSet]){
                qNameIdMap.put(gq.Name,gq.Id);
            }
        }
        return qNameIdMap;
    }
    
    public static void assignUsersToQueue(Set<String> successRecordIds, Map<String,String> d_UsrId_qIdMap){
        List<GroupMember> gmAsgnList=new List<GroupMember>();
        if(!successRecordIds.isEmpty() && !d_UsrId_qIdMap.isEmpty()){
            for(User u:[SELECT Id,Dialer_User_ID__c FROM User WHERE Id IN:successRecordIds]){
                if(u.Dialer_User_ID__c!=null && d_UsrId_qIdMap.containsKey(u.Dialer_User_ID__c)){
                    GroupMember gm = new GroupMember();
                    gm.UserOrGroupId = u.Id;
                    gm.GroupId = d_UsrId_qIdMap.get(u.Dialer_User_ID__c);
                    gmAsgnList.add(gm);
                }
            }
        }
        if(!gmAsgnList.isEmpty()){
            Database.insert(gmAsgnList, false);
        }
    }
    
    //GroupMember[] gms = [SELECT Id, Name FROM GroupMember WHERE UserOrGroupId =: usrId AND GroupId =: q.id];
    
    public static boolean isValidUserWithRequiredVals(User chkUsr){
        invalidInputErrMsgStr='';
        if(String.isBlank(chkUsr.LastName)||String.isBlank(chkUsr.Username)||
           String.isBlank(chkUsr.Email)||String.isBlank(chkUsr.CommunityNickname)||
           String.isBlank(chkUsr.Alias)||String.isBlank(chkUsr.ProfileId)||
           String.isBlank(chkUsr.Dialer_User_ID__c))
        {
            invalidInputErrMsgStr='Missing value in required field(s) LastName/Email/Profile/Dialer-UserId, for the user record';
            return false;
        }
        else if(!isValidEmailFormat(chkUsr.Email)){
            invalidInputErrMsgStr='Invalid format in field: Email for the user record';
            return false;
        }
        return true;
    }
    public static Boolean isValidEmailFormat(String emailStr) {
        // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        //String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(emailStr);
        return (MyMatcher.matches());	
    }
    public static String generateAliasName(String fName,String lName){
        String aliasStr='';
        if(String.isNotBlank(fName) && String.isNotBlank(lName)){
            aliasStr+= fName.substring(0,1);
            if(lName.length()>=4){
                aliasStr+= lName.substring(0, 4);
            }else{
                aliasStr+= lName;
            }
            aliasStr=aliasStr.toLowerCase();
        }
        return aliasStr;
    }
    /*public class SandBoxInfo implements SandboxPostCopy{
        public String sandboxName{get;set;}
        public void runApexClass(System.SandboxContext context){
            this.sandboxName=context.sandboxName();
        }
    }*/
}