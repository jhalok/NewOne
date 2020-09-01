public class bulkCreationUserController {
	
    @AuraEnabled
    public static List<String> userRequiredFields(){
        List<String> requiredFields = new List<String>();
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
            if(!fieldResult.isNillable() && fieldResult.isCreateable() && fieldResult.getType() != Schema.DisplayType.BOOLEAN) {
                requiredFields.add(fieldResult.getName());
            }
        }
        return requiredFields;
    }
    @AuraEnabled
    public static List<wrapperInfo> insertBulkUsers(List<List<String>> userData){
        List<wrapperInfo> wrapperList = new List<wrapperInfo>();
        try{
            List<user> newUserList = new List<user>();
            system.debug('USERDATA -: '+userData);
            Map<String,Profile> UserRoleProfile = new Map<String,Profile>();
            UserRoleProfile.put('Agent - M2All',[SELECT Id, Name FROM Profile where Name = 'M2all agent']);
            for(Integer i=1; i<userData.size(); i++){
                if(userData[i] != null && userData[i].size() > 0) {
                    String usrName = userData[i][0];
                    String lastName = String.isNotBlank(userData[i][1]) ? (userData[i][1]) : '';
                    user singleUser = new user();
                    singleUser.lastName = lastName;
                    singleUser.username = usrName +'.'+ lastName +'@'+'M2allagent'+'.com';
                    system.debug('singleUser.username : '+singleUser.username);
                    singleUser.email = singleUser.username;
                    singleUser.Alias = userData[i][0]+i;
                    singleUser.CommunityNickname = userData[i][1];
                    singleUser.LanguageLocaleKey = 'en_US';
                    singleUser.LocaleSidKey = 'en_IN';
                    singleUser.EmailEncodingKey ='ISO-8859-1';
                    singleUser.TimeZoneSidKey = 'Asia/Kolkata';
                    singleUser.ProfileId  = UserRoleProfile.get('Agent - M2All').Id;
                    newUserList.add(singleUser);
                }
            }
            Database.SaveResult[] srList = Database.insert(newUserList, false);

            // Iterate through each returned result
            
            for (Database.SaveResult sr : srList) {
                Integer i = 0;
                if (sr.isSuccess()) {
                    i++;
                    System.debug('Successfully inserted ID: ' + sr.getId() + ' / i : '+ i);
                    wrapperList.add(new wrapperInfo(true,'Successfully inserted ID: ' + sr.getId() + ' / i : '+ i));
                } else {  
                    wrapperInfo errorInfo = new wrapperInfo(false);
                    for(Database.Error err : sr.getErrors()) {                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        errorInfo.message = (String.isNotBlank(errorInfo.message) ? errorInfo.message : '' )+ err.getMessage();
                    }
                    wrapperList.add(errorInfo);
                }
            }
            
            
            return wrapperList;
        }
        catch(Exception e){
            system.debug(e.getMessage() + '-' + e.getstacktracestring());
            return null;
        }
    }
    public class wrapperInfo {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        public wrapperInfo(Boolean isSuccess, String message){
            this.isSuccess=isSuccess;
            this.message=message;
        }
        
        public wrapperInfo(Boolean isSuccess){
            this.isSuccess=isSuccess;
        }
    }
}