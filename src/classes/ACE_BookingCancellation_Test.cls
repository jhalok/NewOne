@isTest
public class ACE_BookingCancellation_Test {
    @testSetup static void ACE_BookingCancellation() {
        Account accObj = new Account();
        accObj.Name = 'Test';
        insert accObj;
        
        Contact conObj = new Contact();
        conObj.FirstName = 'Test';
        conObj.LastName = 'test';
        conObj.Age__c = '30-45 Yrs';
        conObj.AccountId = accObj.Id;
        conObj.Email = 'test@gmail.com';
        conObj.Wedding_Anniversary_Date__c = System.today();
        conObj.MobilePhone = '9876543210';
        conObj.Customer_Type__c = 'CRP';
        conObj.Communicate_To__c = 'OFC';
        
        insert conObj;
        
        ACE_Booking__c aceObj = new ACE_Booking__c();
        //aceObj.Name='Test A' ;
        aceObj.Customer_Id__c = conObj.Id;
        aceObj.Order_Date__c = System.today();
        aceObj.Booking_Amount__c = 123456;
        aceObj.Stage__c = 'e-booked';
        
        insert aceObj;
    }
    @isTest Static void Test1(){
        Account Acc = [SELECT Id, Name FROM Account];
        Contact con = [Select Id, Name FROM Contact];
        ACE_Booking__c Ace = [SELECT Id, Name FROM ACE_Booking__c];
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/BookingCancellation/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        List<ACE_ServiceUtil.bookingCancellation> bookingList = new List<ACE_ServiceUtil.bookingCancellation>();
        ACE_ServiceUtil.bookingCancellation bookObj = new ACE_ServiceUtil.bookingCancellation();
        bookObj.Id = Ace.Id;
        bookingList.add(bookObj);
        req.requestBody = Blob.valueof(JSON.serialize(bookingList));
        RestContext.request = req;
        RestContext.response= res;
        ACE_BookingCancellation.BookingCancellation();
        Test.stopTest();
    }
}