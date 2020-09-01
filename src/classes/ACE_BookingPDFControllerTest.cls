@IsTest
public class ACE_BookingPDFControllerTest {
    
    @IsTest
    static void testBookingPDFController(){
        Account portalAccount1 = new Account(
            Name = 'TestAccount'
        );
        Database.insert(portalAccount1);
        
        Contact contact1 = new Contact(
            FirstName = 'Test',
            Lastname = 'McTesty',
            User_Role_ACE__c = 'Sales Consultant',
            AccountId = portalAccount1.Id,
            Email = System.now().millisecond() + 'test@test.com'
        );
        Database.insert(contact1);
        
        ACE_Booking__c obj1 = new ACE_Booking__c();{
            obj1.Booking_Amount__c = 20000;
            obj1.Amount_Received_Date__c = system.today();
            obj1.Booking_Date__c = system.today();
            obj1.Customer_Id__c = contact1.Id;
            obj1.Order_Date__c =  system.today();
            obj1.Stage__c = 'e-booked';
        }       
        insert obj1;
        
        PageReference pageRef = Page.BookingPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(obj1.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(obj1);
        BookingPDFController testAccPlan = new BookingPDFController(sc);  
    }
}