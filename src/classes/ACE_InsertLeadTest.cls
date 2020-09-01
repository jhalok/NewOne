@isTest
public class ACE_InsertLeadTest {

    static List < Lead > llist = new List < Lead > ();

    public static Lead createLeads(String fn, String ln, String com, String ctype, String mobile, String ls, String conversion) {
        Lead l = new Lead();
        l.FirstName = fn;
        l.LastName = ln;
        l.Company = com;
        //l.Customer_Type__c = ctype;
        l.MobilePhone = mobile;
        l.LeadSource = ls;
        l.Likely_Conversion_Date__c = conversion;
        l.Enquiry_Source__c = 'NWP';
        l.Enquiry_Type__c = 'FLD';
        return l;
    }
    public static Contact createContacts(String ln, String comm, String ctype, String mobile, String acId) {
        Contact c = new Contact();
        c.LastName = ln;
        //c.Communicate_To__c = comm;
        //c.Customer_Type__c = ctype;
        c.MobilePhone = mobile;
        c.AccountId = acId;

        return c;
    }
    public static Account createAccounts(String name, String type) {
        Account ac = new Account();
        ac.Name = name;
        ac.Type = type;

        return ac;
    }
    public static Opportunity createOpps(String name, Date close, String stage, String relatedContact) {
        Opportunity op = new Opportunity();
        op.Name = name;
        op.CloseDate = close;
        op.StageName = stage;
        //op.Sales_consultant_Contact_ACE__c = relatedContact;
        op.Contact__c = relatedContact;
        op.Enquiry_Type__c = 'FLD';
        op.Enquiry_Source__c = 'NWP';
        return op;
    }
    public static OpportunityContactRole createOppContactRoles(String cId, String opId) {
        OpportunityContactRole oc = new OpportunityContactRole();
        oc.ContactId = cId;
        oc.OpportunityId = opId;

        return oc;
    }

    /* @isTest static void checkWithMobilePhone()
	{
        ACE_InsertLeadController.getFieldsOnLayout();
        Lead le = createLeads('New','Lead','MRC','Individual','8767645342','Advertisement','<15 days');
        llist.add(le);
        ACE_InsertLeadController.insertLeads(llist);
	} */
    @isTest static void duplicateContactWithStageClosed() {
        //Product Dummy Record
        Product2 prod = ACE_Test_Util.insertProduct();
        prod.Type__c = 'Vehicle';
        prod.color__c = 'WHITE';
        prod.vehicle_Model__c = 'Alturas';
        prod.Variant__c = 'MM152';
        prod.Fuel_Type__c = 'Petrol';
        insert prod;

        List < Lead > llist = new List < Lead > ();
        Id p = [select id from profile where name = 'Partner Community User'].id;

        Account ac = ACE_Test_Util.insertAcc();
        ac.Type = 'Partner';
        ac.Name='Trial';
        Test.startTest();
        insert ac;

        Contact c = ACE_Test_Util.insertCon();
        c.lastName = 'Partner Contact';
        c.MobilePhone = '5876543212'; 
        c.AccountId = ac.id;
        insert c;

        PriceBook2 stdPrice = new PriceBook2(Id = Test.getStandardPricebookId(), isActive = true);
        update stdPrice;


        User user = new User(alias = 'trial1', email = 'trial1@noemail.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing1', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true,
            ContactId = c.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'mymail@mail.com');

        insert user;
        system.runAs(user) {

            Opportunity op = ACE_Test_Util.insertEnquiry();
            op.Name='MRC-Trial';
            op.CloseDate=Date.valueOf('2019-12-20');
            op.AccountId = ac.id;
            op.Contact__c = c.id;
            op.Pricebook2Id = stdPrice.id;
            op.StageName = ACE_Constants.OPTY_STAGE_CLOSED_WON;
            op.Dealer__c = c.AccountId;
            insert op;

            OpportunityContactRole oc = createOppContactRoles(c.Id, op.Id);
            insert oc;

            Test.stopTest();

            Lead le = ACE_Test_Util.insertLead();
            /* le.FirstName='Duplicate';
            le.LastName = 'Contact'; 
            le.Company = 'MRC';
            le.MobilePhone = '9876543210';
            //le.LeadSource='Advertisement';
            le.Likely_Conversion_Date__c = '<15 days';
            le.Vehicle__c = prod.id;
            le.Related_Contact__c = c.ID;
            le.Account__c = ac.Id;
            le.Enquiry_Type__c=ACE_Constants.OPP_Enquiry_Type_FLD;
            le.Enquiry_Source__c=ACE_Constants.OPP_Enquiry_Source_NWP;
            llist.add(le); */
            le.Enquiry_Type__c=ACE_Constants.OPP_Enquiry_Type_FLD;
            le.Enquiry_Source__c=ACE_Constants.OPP_Enquiry_Source_NWP;
            le.FirstName='Duplicate';
            le.LastName = 'Contact'; 
            //le.Company = 'MRC';
            le.MobilePhone = '5876543212';
            //le.Phone= '6876543212';
            le.Vehicle__c = prod.id;
            le.Related_Contact__c = c.ID;
            le.Account__c = ac.Id;
            llist.add(le); 
            try{
                ACE_InsertLeadController.insertLeads(llist);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
            
        }
    }
}