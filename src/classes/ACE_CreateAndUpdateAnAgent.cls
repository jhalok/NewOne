/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Apex Controller for Create or Update an Agent functionality .
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shyam Lal Swami   <shyam.l.tpr@in.pwc.com>
* @modifiedBy     Shyam Lal Swami   <shyam.l.tpr@in.pwc.com>
* @maintainedBy   Shyam Lal Swami   <shyam.l.tpr@in.pwc.com>
* @version        1.0
* @created        2019-11-25
* @modified       2019-11-26
* @systemLayer    Class
*
*
*─────────────────────────────────────────────────────────────────────────────────────────────────
*/

global class ACE_CreateAndUpdateAnAgent {
    // Function for search functionality
    @AuraEnabled
    public static List<allUserDataWrapper> getSearchData(String searchBy, String searchOn, String status){
        
         User u = [select id,Name,CallCenterId,UserRoleId from User where id =: userInfo.getUserId()];
        
        List<allUserDataWrapper> userWrapperData = new List<allUserDataWrapper>();
        Map<String,Agent_Mapping__c> allAgent_Mapping =  new Map<String,Agent_Mapping__c>();
        List<String> allUserId = new List<String>();
        
        String searchLike = '\'%' + searchBy  + '%\'';
        String query = '' ;
        if(searchBy != '' && searchOn != ''){
            if(searchOn == 'Service__c'){ 
               
                String serviceQu = 'SELECT Id, Lookup_To_Service__r.Name, Lookup_To_Service__r.Service_Code__c, Lookup_To_User__c, Name FROM Agent_Mapping__c where  Lookup_To_Service__r.Name LIKE '+searchLike;
                
                 System.debug(serviceQu);
                List<Agent_Mapping__c> allservice =  Database.query(serviceQu ); 
              if(allservice.size() == 0){
                
                    allservice = [SELECT Id, Lookup_To_Service__r.Name, Lookup_To_Service__r.Service_Code__c, Lookup_To_User__c, Name FROM Agent_Mapping__c where   Lookup_To_Service__r.Service_Code__c =:searchBy]; 
               }
                List<Id> userIds = new List<Id>();
                
                for(Agent_Mapping__c maping :allservice){
                  
                    userIds.add(maping.Lookup_To_User__c);
                }
                System.debug(userIds);
                 if(status == '' || status == 'ALL'){
                    query = 'SELECT Id, Username,IsActive, Name FROM User where Id IN: userIds  and CallCenterId = \''+ u.CallCenterId +'\'';
                    }
                    else{
                         query = 'SELECT Id, Username,IsActive, Name FROM User where Id IN: userIds and CallCenterId = \''+ u.CallCenterId +'\' and IsActive = '+ status; 
                    }
                
                  System.debug(query);
                   System.debug('entered in service search');
            }
            else if(status == '' || status == 'ALL'){
                query = 'SELECT Id, Username,IsActive,Name FROM User where CallCenterId = \''+ u.CallCenterId +'\' and '+searchOn+' like '+searchLike ;
            }
            else{
                System.debug(status);
                query = 'SELECT Id, Username,IsActive, Name FROM User where CallCenterId = \''+ u.CallCenterId +'\' and IsActive = '+ status+' AND '+searchOn+' like '+searchLike ;
            }
        }
        else{
            query = 'SELECT Id, Username,IsActive, Name FROM User where CallCenterId = \''+ u.CallCenterId +'\'';
            
        }
        system.debug(status);
        system.debug(query);
        List<User> allUserList =    Database.query(query);
        
        
        for(User us:allUserList){
            allUserId.add(us.id);
        }
        List<Agent_Mapping__c> allUserRelation = [SELECT Id, Lookup_To_Service__r.Name, Lookup_To_Service__r.Service_Code__c, Lookup_To_User__c, Name 
                                                  FROM Agent_Mapping__c where Lookup_To_User__c  IN: allUserId];
        
        for(Agent_Mapping__c userMapping:allUserRelation){
            allAgent_Mapping.put(userMapping.Lookup_To_User__c, userMapping);
        }
        
        
        
        for(User us:allUserList){
            allUserDataWrapper userWrapper = new allUserDataWrapper();
            userWrapper.userData = us;
            userWrapper.AgentMaping  = allAgent_Mapping;
            userWrapper.userService = allAgent_Mapping.get(us.Id); 
            userWrapperData.add(userWrapper);
        }
        
        return userWrapperData;
    }
    // Function for update user functionality
    @AuraEnabled
    public static string updateUserRecord(list<User> selectedUser,String AllData, List<Agent_Mapping__c>  serviceMAp12){
        
        Map<String,Agent_Mapping__c> selectedMapping = new  Map<String,Agent_Mapping__c>();
        for(Agent_Mapping__c agentMap : serviceMAp12){
            selectedMapping.put(agentMap.Lookup_To_Service__c,agentMap );
        }
        List<allUserDataWrapper> allUserData =  (List<allUserDataWrapper>)System.JSON.deserialize(AllData, List<allUserDataWrapper>.class);
        User u = [select id,Name,CallCenterId,UserRoleId from User where id =: userInfo.getUserId()];
        CallCenter callCenter = [select id,Name  from CallCenter where id =: u.CallCenterId];
        // List<ACE_Service__c> allService =  [select id,Name,Service_Code__c,Call_Center__c from ACE_Service__c where Call_Center__c =:callCenter.Name  ];
        List<ACE_Service__c> allService =  [select id,Name,Service_Code__c,Call_Center__c from ACE_Service__c   ];
        List<String> callCenterLeadLIst = new List<String>();
        for(ACE_Service__c  Servicedata:allService){
            if(selectedMapping.containsKey(Servicedata.id)){
                callCenterLeadLIst.add('Team Lead - '+Servicedata.Call_Center__c);
            }
        }
        
        List<UserRole> allTeamLeads = [SELECT Id,Name FROM UserRole where Name IN : callCenterLeadLIst];
        
        Map<String,UserRole> allUserRoles = new  Map<String,UserRole>();
        for(UserRole  role : allTeamLeads){
            allUserRoles.put(role.Name,role);
        }
        
        List<User> allTeamLeas = [SELECT Id, Name,UserRoleId FROM User where UserRoleId IN : allUserRoles.keySet() AND CallCenterId =:callCenter.id   ];
        List<String> allLeadId = new  List<String>();
        for(User us:allTeamLeas){
            allLeadId.add(us.id);
        }
        Map<String,String> teamLeadsIds = new Map<String,String>();
        
        List<Agent_Mapping__c> allTeamLeadsMApping = [SELECT Id, Lookup_To_User__c, Lookup_To_Service__c FROM Agent_Mapping__c where id IN :allLeadId ];
        system.debug('allTeamLeadsMApping'+allTeamLeadsMApping);
        for(Agent_Mapping__c teamLedaMap : allTeamLeadsMApping){
            teamLeadsIds.put(teamLedaMap.Lookup_To_Service__c,teamLedaMap.Lookup_To_User__c );
        }
        
        for(User us : selectedUser){
            String managerId = '';
            for(Agent_Mapping__c getServiceID : serviceMAp12){
                if(getServiceID.Lookup_To_User__c == us.id){
                    managerId = teamLeadsIds.get(getServiceID.Lookup_To_Service__c);
                    system.debug('managerId  >'+teamLeadsIds);
                }
            }
            if(managerId != ''){
				us.ManagerId =  managerId;               
            }
          
            us.IsActive = selectedUser[0].IsActive;
        }
        try{
            if(selectedUser.size() > 0){
                updateMapping(JSON.serialize(serviceMAp12));
                update selectedUser;
            }
            return null;
        }catch(Dmlexception d)
        {
            system.debug(d.getMessage());
            return  d.getMessage();
        }
    }
    @future
    public static void updateMapping(String ageMapping){   
        system.debug(ageMapping);
        try{
            List<Agent_Mapping__c>  serviceMAp12 = (List<Agent_Mapping__c>)System.JSON.deserialize(ageMapping, List<Agent_Mapping__c>.class);
            system.debug(serviceMAp12);
            upsert  serviceMAp12;
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    // Function for for get all data 
    @AuraEnabled
    Public static UserWrapper getAllData(){
        UserWrapper userAllData = new UserWrapper();
        User u = [select id,Name,CallCenterId,UserRoleId from User where id =: userInfo.getUserId()];
        CallCenter callCenter = [select id,Name  from CallCenter where id =: u.CallCenterId];
        userAllData.callCenter = callCenter;
        String callCenterRole = 'Call Center Supervisor - '+callCenter.Name;
        UserRole UserRoleId =  [SELECT Id, Name FROM UserRole where Name =:callCenterRole limit 1   ];
          List<UserRole> allRoles = new   List<UserRole>();
        for(userRole role:[SELECT Id, Name FROM UserRole   ]){
            String roleName = role.Name;
            if(roleName.contains(callCenter.Name)){
                allRoles.add(role);
            }
        }
      
        userAllData.allRole = allRoles;
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = User.Team__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }  

        userAllData.allTeams = pickListValuesList;
        userAllData.allServiceList = [select id,Name,Service_Code__c from ACE_Service__c Where Call_Center__c = :callCenter.Name   ];
        return userAllData;
    }
    // Function for insert new user functionality
    @AuraEnabled
    public static String  insertNewUser(User userData, String serviceId){
        ACE_Service__c service = [SELECT Id, Call_Center__c FROM ACE_Service__c where id =: serviceId ];
        system.debug('Call_Center__c  >> '+service.Call_Center__c);
        CallCenter callCenter = [select id,Name  from CallCenter where Name =: service.Call_Center__c limit 1];
      
        Map<String,Profile> UserRoleProfile = new Map<String,Profile>();
        UserRoleProfile.put('Agent - M2All',[SELECT Id, Name FROM Profile where Name = 'M2all agent']);
        List<String> callCList = new List<String>();
        //callCList = [Select Name from CallCenter ];
        Map<Id, String> callCenterMap = new Map<Id, String>();
        //callCenterMap.put();
        User u = [SELECT Id, Name, Email FROM User where id=:userinfo.getuserid()];
        
        userData.Alias = userData.FirstName.substring(0,0) +  userData.LastName.substring(0,3);
        userData.CommunityNickname = userData.FirstName.substring(0,3) + userData.LastName.substring(0,3)+  System.currentTimeMillis();
        userData.LanguageLocaleKey = 'en_US';
        userData.LocaleSidKey = 'en_IN';
        userData.EmailEncodingKey ='ISO-8859-1';
        userData.TimeZoneSidKey = 'Asia/Kolkata';
        userData.ProfileId  = UserRoleProfile.get('Agent - M2All').Id;
        userData.Email = u.Email;
      
        
        String role = 'Team Lead - '+callCenter.Name;
        UserRole teamLeadRole = [select id,Name from UserRole Where Name =:role limit 1 ];
        
        List<User> allTeamLeads = [select id,Name from User Where UserRoleId =: teamLeadRole.id];
        Map<String,User> allTeamLeadsMap = new Map<String,User>();
        for(user us:allTeamLeads ){
           allTeamLeadsMap.put(us.id, us);
            
        }    
        List<Agent_Mapping__C> allTeadMApping = [select id,Name,Lookup_To_Service__c, Lookup_To_User__c from Agent_Mapping__c where Lookup_To_User__c in : allTeamLeadsMap.keySet()];
        String ManagerId = '';
        for(Agent_Mapping__C maping: allTeadMApping ){
            if(maping.Lookup_To_Service__c == serviceId)
            {
                userData.ManagerId = maping.Lookup_To_User__c; 
             }
            
        }
         try{
            insert userData; 
            
            insertMapping(serviceId, userData.id  );
            return null;
        }catch(Exception e){
            system.debug(e);
            return e.getMessage();
        }
 	
    }
    
    @future
    public static void insertMapping(String serviceId, String userId){   
        try{
            insert new Agent_Mapping__c(Lookup_To_Service__c = serviceId, Lookup_To_User__c =userId);
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    // Wrapper Class 
    global  class UserWrapper{
        @AuraEnabled
        global  List<UserRole> allRole;
        @AuraEnabled
        global CallCenter callCenter;
        @AuraEnabled
        global List<String> allTeams;
        @AuraEnabled
        global List<ACE_Service__c> allServiceList;
        
    }
    
    
    // Wrapper Class allUserDataWrapper
    global  class allUserDataWrapper{
        @AuraEnabled
        global  User userData;
        @AuraEnabled
        global Agent_Mapping__c userService;
        @AuraEnabled
        global Map<string,Agent_Mapping__c> AgentMaping;
    }
    @AuraEnabled
    public static string resetPassword(list<User> selectedUser){
        system.debug(selectedUser);
        try{
            for(User u : selectedUser){
                System.resetPassword(u.Id, true);
            }
            return null;
        }catch(Dmlexception d)
        {
            return  d.getMessage();
        }
        
        
    }
}