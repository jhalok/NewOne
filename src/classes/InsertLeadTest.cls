@isTest
public class InsertLeadTest {
    
    static List<Lead> llist = new List<Lead>();
    
    public static Lead createLeads(String fn, String ln,String com,String ctype,String mobile,String ls,String conversion)
    {
		Lead l = new Lead();
        l.FirstName = fn;
        l.LastName = ln;
        l.Company = com;
        l.Customer_Type__c = ctype;
        l.MobilePhone = mobile;
        l.LeadSource = ls;
        l.Likely_Conversion_Date__c = conversion;
        
        return l;
    }
    public static Contact createContacts(String ln,String comm,String ctype,String mobile,String acId)
    {
		Contact c = new Contact();
        c.LastName= ln;
        c.Communicate_To__c = comm;
        c.Customer_Type__c = ctype;
        c.MobilePhone = mobile; 
        c.AccountId = acId;
        
        return c;
    }
    public static Account createAccounts(String name,String type)
    {
		Account ac = new Account();
		ac.Name = name;
        ac.Type = type;
        
        return ac;
    }
    public static Opportunity createOpps(String name,Date close,String stage,String relatedContact)
    {
		Opportunity op = new Opportunity();
        op.Name = name;
        op.CloseDate = close;
        op.StageName = stage;
        op.Sales_consultant_Contact_ACE__c = relatedContact;
        
        return op;
    }
    public static OpportunityContactRole createOppContactRoles(String cId,String opId)
    {
		OpportunityContactRole oc = new OpportunityContactRole();
        oc.ContactId = cId;
        oc.OpportunityId = opId;
        
        return oc;
    }
    
	@isTest static void checkWithMobilePhone()
	{
        InsertLeadController.getFieldsOnLayout();
        Lead le = createLeads('New','Lead','MRC','Individual','8767645342','Advertisement','<15 days');
        llist.add(le);
        InsertLeadController.insertLeads(llist);
	}
    @isTest static void duplicateContactWithStageClosed()
	{   
        List<Lead> llist = new List<Lead>();
        Id p = [select id from profile where name='Partner Community User'].id;
        
        Account ac = createAccounts('Trial','Partner');
        Test.startTest();
        insert ac;

        Contact c = createContacts('Partner Contact','Office','Individual','9876543210',ac.Id);
        insert c;
        
        PriceBook2 stdPrice = new PriceBook2(Id = Test.getStandardPricebookId(), isActive=true);
		update stdPrice;   
       
        
        User user = new User(alias = 'trial1', email='trial1@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='mymail@mail.com');
       
        	insert user;
        	system.runAs(user) {
                
                Opportunity op = createOpps('MRC-Trial',Date.valueOf('2019-12-20'),ACE_Constants.OPTY_STAGE_CLOSED_WON,c.Id);
                op.Dealer__c = c.AccountId;
                insert op;
                
                OpportunityContactRole oc = createOppContactRoles(c.Id,op.Id);
                insert oc;
                
                Test.stopTest();
                
                Lead le = createLeads('Duplicate','Contact','MRC','Individual','9876543210','Advertisement','<15 days');
                le.Related_Contact__c = c.ID;
                le.Account__c = ac.Id;
                llist.add(le);
                InsertLeadController.insertLeads(llist); 
        }           
	}
    @isTest static void duplicateContactOppWithStageEnquiry()
	{   
        List<Lead> llist = new List<Lead>();
        Id p1 = [select id from profile where name='Partner Community User'].id;

        Account ac = createAccounts('Trial2','Partner');
        Test.startTest();
        insert ac;

        Contact c = createContacts('Partner Contact2','Office','Individual','9876543210',ac.Id);
        insert c;
        
        PriceBook2 stdPrice = new PriceBook2(Id = Test.getStandardPricebookId(), isActive=true);
		update stdPrice;   
       
        
        User user1 = new User(alias = 'trial2', email='trial2@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='mymail1@mail.com');
       
        	insert user1;
        	system.runAs(user1) {
                
                Opportunity op = createOpps('MRC-Trial',Date.valueOf('2019-12-20'),ACE_Constants.OPTY_STAGE_Enquiry,c.Id);
                op.Dealer__c = c.AccountId;
                insert op;
                
                OpportunityContactRole oc = createOppContactRoles(c.Id,op.Id);
                insert oc;
                Test.stopTest();
                
                Lead le = createLeads('Duplicate','Contact','MRC','Individual','9876543210','Advertisement','<15 days');
               	le.Related_Contact__c = c.ID;
                le.Account__c = ac.Id;
                llist.add(le);
                InsertLeadController.insertLeads(llist);
	}
    }
	@isTest static void duplicateContactWithoutExistingOpp()
	{   
        List<Lead> llist = new List<Lead>();
        Id p1 = [select id from profile where name='Partner Community User'].id;

        Account ac = createAccounts('Trial2','Partner');
        Test.startTest();
        insert ac;

        Contact c = createContacts('Partner Contact2','Office','Individual','9876543210',ac.Id);
        insert c;
        
        PriceBook2 stdPrice = new PriceBook2(Id = Test.getStandardPricebookId(), isActive=true);
		update stdPrice;   
       
        
        User user1 = new User(alias = 'trial2', email='trial2@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='mymail1@mail.com');
       
        	insert user1;
        	system.runAs(user1) {
                
                Opportunity op = createOpps('MRC-Trial',Date.valueOf('2019-12-20'),ACE_Constants.OPTY_STAGE_CLOSED_WON,c.Id);
                insert op;
                
                OpportunityContactRole oc = createOppContactRoles(c.Id,op.Id);
                insert oc;
                Test.stopTest();
                
                Lead le = createLeads('Duplicate','Contact','MRC','Individual','9876543210','Advertisement','<15 days');
               	le.Related_Contact__c = c.ID;
                llist.add(le);
                InsertLeadController.insertLeads(llist);
	}
    }
    @isTest static void duplicateLead()
	{   
		List<Lead> llist = new List<Lead>();
        Id p1 = [select id from profile where name='Partner Community User'].id;

        Account ac = createAccounts('Trial2','Partner');
        Test.startTest();
        insert ac;

        Contact c = createContacts('Partner Contact2','Office','Individual','9876543210',ac.Id);
        insert c;
        
        PriceBook2 stdPrice = new PriceBook2(Id = Test.getStandardPricebookId(), isActive=true);
		update stdPrice;   
       
        
        User user1 = new User(alias = 'trial3', email='trial3@noemail.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='mymail3@mail.com');
       
        	insert user1;
        Test.stopTest();
        	system.runAs(user1) {
                
            Lead le = createLeads('Duplicate','Lead1','MRC','Individual','987456321','Advertisement','<15 days');
			le.Related_Contact__c = c.ID;
            le.Account__c = ac.Id;
            insert le;

			Lead le1 = createLeads('Duplicate','Lead2','MRC1','Individual','987456321','Advertisement','<15 days');
            le1.Related_Contact__c = c.ID;
            le1.Account__c = ac.Id;
            llist.add(le1);
                
            InsertLeadController.insertLeads(llist);
	}
}
}