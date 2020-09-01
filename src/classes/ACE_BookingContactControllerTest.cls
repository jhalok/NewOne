/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Test class for ACE_BookingContactController.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vidhya Bharathi <vidhya.b.tpr@in.pwc.com>
* @modifiedBy     Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2019-11-20
* @modified       2020-01-21
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ACE_BookingContactControllerTest {
    
    @IsTest
    static void testStorePdf(){
        ACE_Booking__c bkData = ACE_Test_Util.bookingData();
        insert bkData;
        PageReference pref = Page.BookingPDF;       
        pref.getParameters().put('id',bkData.id);
        blob pdfBody;
        pdfBody = blob.valueOf('Unit Test');    
        test.startTest(); 
        ACE_BookingContactController.storePDF(bkData.id);
        test.stopTest();
    }
    
    @IsTest
    static void testCustID(){
        Contact conData = ACE_Test_Util.insertCon();
        conData.ACE_Customer_Id__c = '';
        insert conData;
        Opportunity oppData = ACE_Test_Util.insertEnquiry();
        insert oppData;
        test.startTest();
        ACE_BookingContactController.getCustID(oppData.Id);
        test.stopTest();
    }
    
    @IsTest
    static void testGetProductData(){
        List<Id> prdList = new List<Id>();
        Product2 prdData = ACE_Test_Util.insertProduct();
        insert prdData;
        prdList.add(prdData.Id);
        test.startTest();
        ACE_BookingContactController.getProductData(prdList);
        test.stopTest();
    }
    
    @IsTest
    static void testBookingData(){
        ACE_Booking__c bkData = ACE_Test_Util.bookingData();
        insert bkData;
        Opportunity opp = ACE_Test_Util.insertEnquiry();
        insert opp;
        String serializeData = '{"stage":"e-booked","orderDate":"2019-12-04","bookingAmount":"3000","amountReceived":"20000","amountReceivedDate":"2019-12-04","downPayment":"2000.1","loanAmount":"123456","tenure":"12","interestRates":"12","enquiryId":"'+opp.Id+'"}';
        test.startTest();
        ACE_BookingContactController.insertBooking(serializeData);
        test.stopTest();
    }
}