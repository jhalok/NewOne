@isTest(SeeAllData=false)
public class QuotePDFController_Test {
    public static testMethod void testOpp() {
        
        //PageReference pageRef = Page.yourPageName;
        Account acc = ACE_Test_Util.insertAcc();
        insert acc;
        System.assert(acc.id != null, 'Account not created');
        Contact con = ACE_Test_Util.insertCon();
        con.AccountId = acc.id;
        insert con;
        System.assert(con.id != null, 'Contact not created');
        Opportunity opportunity = ACE_Test_Util.insertEnquiry();
        opportunity.AccountId = acc.id;
        opportunity.Contact__c = con.id;
        insert opportunity;
        System.assert(opportunity.id != null, 'opportunity not created');
       
        Product2 prod = ACE_Test_Util.insertProduct();
        prod.Type__c = 'Vehicle';
        insert prod;
        System.assert(prod.id != null, 'Product not created');
        Id pricebookId = Test.getStandardPricebookId();
        System.assert(pricebookId != null, 'Standarnd Price Book Id is Blank');
        System.debug('price book id is -- '+pricebookId);
        PricebookEntry pbEntry = ACE_Test_Util.insertPricebookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.Product2Id = prod.id;
        insert pbEntry;

        Quote quote = ACE_Test_Util.insertQuote();
        quote.Name='Test_Quote';
        quote.OpportunityId = opportunity.Id;
        quote.ContactId = con.Id;
        quote.PriceBook2Id = pricebookId;
        insert quote;
        System.assert(quote.Id != null, 'Quote is not created');
        QuoteLineItem qli = ACE_Test_Util.insertQuoteLineItem();
        qli.Product2Id = prod.id;
        qli.QuoteId = quote.id;
        qli.PriceBookEntryID = pbEntry.id;
       
        insert qli; 
        System.assert(qli.Id != null, 'Quote line item is not created');
        Test.startTest();
        PageReference pageRef = Page.QuotePDF;
        System.debug('pageRef is '+pageRef);
        Test.setCurrentPage(pageRef);
        //pageRef.getParameters().put('id',quote.id);
        pageRef.getParameters().put('id', String.valueOf(quote.Id));
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        ACE_QuotePDFController  quoteObj = new ACE_QuotePDFController(sc);
        System.debug('at 51----');
        Blob content = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pageRef.getContent();
        /* String testLbl = Label.Disclaimer;
        controller.Disclaimer = testLbl; */
        PageReference forAttachPDF;
        forAttachPDF=quoteObj.attachPDF();
        System.assert(forAttachPDF != null, 'attachPDF is not called');
        /*  quote.isMahindraAccount__c =
         Test.setCurrentPage(pageRef);
         pageRef.ApexPages.currentPage().getParameters().put('id', acc.id);
         ApexPages.StandardController sc = new ApexPages.standardController(testOppty);
         Myclass controller = new Myclass(sc); */
        Test.stopTest();
    }
}