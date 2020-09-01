/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Data is fetched using Salesforce Standard Method.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shekhar palwankar <shekhar.palwankar@pwc.com>
* @modifiedBy     Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2019-10-23
* @modified       2020-01-16
* @systemLayer    Class
* @see            ????
* @see            ????* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class LightningLoginFormController {

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    } 
 
}