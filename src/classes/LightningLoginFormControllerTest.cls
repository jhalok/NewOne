/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Test class for LightningLoginFormController.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @modifiedBy     Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2020-01-03
* @modified       2020-01-16
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {
    
    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
    }
    
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
}