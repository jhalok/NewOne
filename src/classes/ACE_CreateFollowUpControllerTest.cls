@IsTest
public class ACE_CreateFollowUpControllerTest {
    
    /*@IsTest
    static void testAPIResponse(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        //usrData.Username = '';
        insert usrData;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '';
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }*/
    
     @IsTest
    static void testProcessFollowUp6(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        //usrData.Username = '';
        insert usrData;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{"Id":"abc","whoId":"abc","whatId":"abc","ownerId":"abc","callDisposition":"check","subDisposition":"abc","taskSubtype":"check","description":"abc","status":"open","activityDate":"2019-12-04","phone":"1234567890","type":"12","subject":"Send Letter","disposition":"123","service":"abc","nextFollowupTime":"2019-12-04","callType":"urgent","stage":"e-booked","orderDate":"2019-12-04","bookingAmount":"3000","amountReceived":"20000","callObject":"account","callDurationInSeconds":"20","amountReceivedDate":"2019-12-04","downPayment":"2000.1"}]';    
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Account acc = new Account(Name='Test Ignore'); // any sobject for DML
           insert acc;
           /* Replace me with execute batch statement here in between DML */
           delete acc;
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessFollowUp7(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        insert usrData;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{}]';
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessFollowUp8(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        User usrData = ACE_Test_Util.portalUser();
        insert usrData;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{"subDisposition":"abc","type":"Meeting","id":"'+t.id+'","ownerId":"'+usrData.Id+'","whoId":"'+usrData.Id+'","whatId":"'+usrData.Id+'","description":"abc"}]';
        
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    } 
    
    @IsTest
    static void testProcessFollowUp(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        insert usrData;
        Opportunity oppData = ACE_Test_Util.insertEnquiry();
        insert oppData; 
        ACE_Disposition__c dspData = new ACE_Disposition__c();
        dspData.DispositionType__c = 'Agent';
        dspData.Disposition_Code__c = '1234';
        insert dspData;
        ACE_Service__c acData = new ACE_Service__c();
        acData.Call_Center__c = 'MRC';
        acData.Service_Code__c = '12345';
        insert acData;
        ACE_SubDisposition__c subDsp = new ACE_SubDisposition__c();
        subDsp.Name = 'subdsp';
        subDsp.SubDisposition_Code__c = '123456';
        subDsp.Disposition__c = dspData.Id; //check refrence
        insert subDsp;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{"type": "Call","whoId":"'+oppData.Id+'","whatId":"'+oppData.Id+'","id":"'+t.id+'","callDisposition":"check","subDisposition":"'+subDsp.Id+'","taskSubtype":"check","ownerId":"'+usrData.Id+'","description":"abc","status":"open","activityDate":"2019-12-04","phone":"1234567890","subject":"Send Letter","disposition":"'+dspData.Id+'","service":"'+acData.Id+'","nextFollowupTime":"2019-06-06T10:03:03.000+0000","callType":"urgent","stage":"e-booked","orderDate":"2019-12-04","bookingAmount":"3000","amountReceived":"20000","callObject":"account","callDurationInSeconds":"20","amountReceivedDate":"2019-12-04"}]';
        
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessFollowUp1(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        insert usrData;
        Opportunity oppData = ACE_Test_Util.insertEnquiry();
        insert oppData; 
        ACE_Disposition__c dspData = new ACE_Disposition__c();
        dspData.DispositionType__c = 'Agent';
        dspData.Disposition_Code__c = '1234';
        insert dspData;
        ACE_Service__c acData = new ACE_Service__c();
        acData.Call_Center__c = 'MRC';
        acData.Service_Code__c = '12345';
        insert acData;
        ACE_SubDisposition__c subDsp = new ACE_SubDisposition__c();
        subDsp.Name = 'subdsp';
        subDsp.SubDisposition_Code__c = '123456';
        subDsp.Disposition__c = dspData.Id; //check refrence
        insert subDsp;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{"type": "Call","whoId":"","whatId":"'+oppData.Id+'","id":"'+t.id+'","callDisposition":"check","subDisposition":"'+subDsp.Id+'","taskSubtype":"check","ownerId":"'+usrData.Id+'","description":"abc","status":"open","activityDate":"2019-12-04","phone":"1234567890","subject":"Send Letter","disposition":"'+dspData.Id+'","service":"'+acData.Id+'","nextFollowupTime":"2019-06-06T10:03:03.000+0000","callType":"urgent","stage":"e-booked","orderDate":"2019-12-04","bookingAmount":"3000","amountReceived":"20000","callObject":"account","callDurationInSeconds":"20","amountReceivedDate":"2019-12-04"}]';
        
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessFollowUp2(){
        Task t = new Task();
        t.Status = 'open';
        t.Subject = 'Send Letter';
        t.Priority = 'High';
        insert t;
        //Contact con = [Select ownerId From Contact limit 1];
        User usrData = ACE_Test_Util.portalUser();
        insert usrData;
        Opportunity oppData = ACE_Test_Util.insertEnquiry();
        insert oppData; 
        ACE_Disposition__c dspData = new ACE_Disposition__c();
        dspData.DispositionType__c = 'Agent';
        dspData.Disposition_Code__c = '1234';
        insert dspData;
        ACE_Service__c acData = new ACE_Service__c();
        acData.Call_Center__c = 'MRC';
        acData.Service_Code__c = '12345';
        insert acData;
        ACE_SubDisposition__c subDsp = new ACE_SubDisposition__c();
        subDsp.Name = 'subdsp';
        subDsp.SubDisposition_Code__c = '123456';
        subDsp.Disposition__c = dspData.Id; //check refrence
        insert subDsp;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/FollowUp';
        String JsonMsg = '[{"whoId":"abc","type": "Call","whatId":"'+oppData.Id+'","callDisposition":"check","subDisposition":"abc","taskSubtype":"check","ownerId":"'+usrData.Id+'","description":"abc","status":"open","activityDate":"2019-12-04","phone":"1234567890","subject":"Send Letter","disposition":"abc","service":"'+acData.Id+'","nextFollowupTime":"2019-06-06T10:03:03.000+0000","callType":"urgent","stage":"e-booked","orderDate":"2019-12-04","bookingAmount":"3000","amountReceived":"20000","callObject":"account","callDurationInSeconds":"20","amountReceivedDate":"2019-12-04"}]';
        
        req.httpMethod = 'POST';
        req.addParameter('page', '0');
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ACE_CreateFollowUpController.processFollowUp();
        Test.stopTest();
    }
    
    
}