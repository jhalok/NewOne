/* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Util class for Test Classes.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @modifiedBy     Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @modifiedy      Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2020-01-07
* @modified       2020-01-09
* @systemLayer    Apex Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_Test_Util {
    
    // To insert Account.
    public static Account insertAcc(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingStreet='Test';
        acc.BillingState='Test';
        acc.BillingCountry='Test';
        acc.BillingPostalCode='Test';
        acc.ShippingStreet='abc';
        acc.ShippingCountry='usa';
        acc.ShippingState='Test';
        acc.ShippingPostalCode='Test';
        return acc;
    }
    
    // To insert Contact.
    public static Contact insertCon(){
        Contact con = new Contact();
        con.LastName = 'Test_Con';
        con.Email='test@mail.com';
        con.Phone='1234998912';
        return con;
    }
    
    //To insert Enquiry.
    public static Opportunity insertEnquiry(){
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('=====standard price book'+pricebookId);
        Opportunity opp = new Opportunity();
        opp.Name ='TestOpportunity';
        opp.Enquiry_Date__c = Date.valueOf('2018-01-01 00:00:00');
        opp.CloseDate = Date.valueOf('2020-01-01 00:00:00');
        opp.StageName = ACE_Constants.OPP_Stage_Name_Booking;
        opp.Refer_By_Name__c = 'test Refer';
        opp.NextStep = 'test Step';
        opp.Enquiry_Type__c=ACE_Constants.OPP_Enquiry_Type_FLD;
        opp.Enquiry_Source__c=ACE_Constants.OPP_Enquiry_Source_NWP;
        opp.Next_Action__c='T';
        opp.Usage_Area__c='City outskirt';
        opp.Likely_Purchase__c='GT15';
        opp.Pricebook2Id=pricebookId;        
        return opp;
    }
    
    // To insert Product
    public static Product2 insertProduct(){
        Product2 prod = new Product2();
        prod.Name = 'Test Product Parent';
        prod.Status__c ='Active';
        prod.Type__c='Accessories';
        prod.isActive = true;
        prod.Vehicle_Model__c = 'Jeeto';
        prod.Model__c = 'S5 2WD';
        prod.Is_Prelaunch__c = true;
        return prod;
    }
    
    // To insert OppLineItems
    public static OpportunityLineItem insertOppLine(){
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Description='test description';
        oli.Quantity = 2;
        oli.TotalPrice=500; 
        return oli;
    }
    
    //To insert Quote
    public static Quote insertQuote(){
        Quote quo = new Quote();
        quo.Name='Test Quote';
        //quo.ContractId=contr.Id;
        quo.Incidental_Charges__c=100;
        quo.Dealer_Discount_Special_Discount__c = 2.00;
        quo.Registration__c=2.00;
        quo.Road_Safety_Tax__c=2.00;
        quo.Insurance__c=2.00;
        quo.Zero_Depreciation_Insurance_Cost__c=2.00;
        /*Road_Safety_Tax__c, Insurance__c, Zero_Depreciation_Insurance_Cost__c,*/
        return quo;
    }
    //To insert QuoteLineItem
    public static QuoteLineItem insertQuoteLineItem(){
        QuoteLineItem qli = new QuoteLineItem();
        //qli.Name='Test QuoteLinie Item';
        qli.Quantity=5;
        qli.UnitPrice=10;
        
        return qli;
    }
    //To insert Lead
    public static Lead insertLead(){
        Lead leadData =new Lead();
        leadData.LastName='SFDC';
        leadData.Company='SalesForce';
        leadData.MobilePhone = '9958400000';
        leadData.City__c = 'jaipur';
        leadData.Status = 'Open - Not Contacted';
        leadData.ACE_Action_to_be_Taken__c = 'Exchange';
        User curntUser = [Select Id, Name From User where Id =:UserInfo.getUserId()];
        System.debug('$$$$$$$$$-----curntUser'+curntUser);
        leadData.OwnerId = curntUser.Id;
        
        return leadData;
    }
    //To insert Price Booke
    /* public static Pricebook2 insertPriceBook(){
Pricebook2 pb = new Pricebook2();
pb.Name = 'Test Price Book';
pb.IsActive=true;
//pb.IsStandard=true;
return pb;
} */
    //To insert Priece Book Entry
    public static PricebookEntry insertPricebookEntry(){
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.UnitPrice = 10000;
        pbEntry.IsActive = true;
        //pbEntry.UseStandardPrice = false;
        return pbEntry;
    }
    //To insert Product Interest
    public static ACE_Product_Interest__c insertACE_Product_Interest(){
        ACE_Product_Interest__c prodInt = new ACE_Product_Interest__c();
        prodInt.Name = 'Test Prod Interest';
        prodInt.Quantity__c	 = 2;
        return prodInt;
    }
    
    public static User userData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'Partner_Community_Mahindra_Rise'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            //IsPortalEnabled = true,
            IsActive = true
        );
        return portalAccountOwner1;
    }
    
    public static User portalUser(){
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
        System.debug('---contact1---'+contact1);
        
        //Create user
        Profile portalProfile = [select Id from Profile where name ='Partner_Community_Mahindra_Rise' Limit 1];
        User user1 = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = contact1.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = System.now().millisecond() + 'test12345@test.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            //IsPortalEnabled = true,
            IsActive = true
        ); 
        return user1;
    } 
    
    public static ACE_Booking__c bookingData(){
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
            return obj1;
        }
    }
}