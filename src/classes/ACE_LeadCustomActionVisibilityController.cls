public class ACE_LeadCustomActionVisibilityController {
    @AuraEnabled
    public static User fetchUserProfileInfo() {
        User curUser  = [SELECT ID, ProfileId, Profile.Name
                        FROM USER
                        WHERE ID =:UserInfo.getUserId()];
        return curUser;
    }
}