/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Controller for QuotePDFController to save quote into Quote pdfs section and Files section.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @modifiedBy     Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2019-10-30 
* @modified       2019-11-06
* @systemLayer    Apex Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            krishnan.mishra@in.pwc.com
* YYYY-MM-DD      Attaching newly quote's pdf in Quote pdfs section and Files section.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class ACE_QuotePDFController {
    
    public List<Product2> products{get;set;}
    public List<QuoteLineItem>qLiList{get;set;}
    public String Disclaimer{get;set;}
    public Decimal exshowroomPrice{get;set;}
    public string quoteName;
    public string quoteId;
    public String[] Terms{get;set;}
    public ACE_QuotePDFController(ApexPages.StandardController stdController){
        System.debug('quote id is '+ApexPages.currentPage().getParameters().get('id'));
        LIST<Quote> quoteList   = [SELECT ID,isMahindraAccount__c,name,account.name,Account.Phone,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
                                 Account.BillingCountry,Opportunity.Owner.name,QuoteNumber,Opportunity.Owner.phone,
                                 Opportunity.Dealer__r.name,Opportunity.Dealer__r.BillingStreet,Opportunity.Dealer__r.BillingCity,
                                 Opportunity.Dealer__r.BillingState,Opportunity.Dealer__r.BillingCountry,
                                 (SELECT ID,Product2.name,unitPrice,
                                 Product2.Variant__c,Product2.Color__c,Product2.ProductCode,Product2.Type__c,Product2.vehicle_model__c
                                 FROM QuoteLineItems)
                                 FROM QUOTE 
                                 WHERE ID = :ApexPages.currentPage().getParameters().get('id')];
        products                = new List<Product2>();
        qLiList                 = new LIST<QuoteLineItem>();
        for(QUOTE quo : quoteList){
            quoteName=quo.Name;
            quoteId=quo.id;
            for(QuoteLineItem quoteLine : quo.QuoteLineItems){
                products.add(quoteLine.Product2);
                qLiList.add(quoteLine);
                if(quoteLine.Product2.Type__c == 'Vehicle'){
                    exshowroomPrice = quoteLine.unitPrice;
                }
            }
        }
        String accName          = quoteList[0].Opportunity.Dealer__r.name;
        Disclaimer              = System.Label.Disclaimer;
        
        Disclaimer              = quoteList[0].isMahindraAccount__c ? Disclaimer.replace('$',accName): Disclaimer.replace('$',accName+' and not Mahindra & Mahindra');
        Terms                   = System.Label.Quote_Terms.split('/');
        System.debug('products '+products);
    }
    public PageReference attachPDF() {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        System.debug('quoteId '+quoteId);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        PageReference pdfPage = new PageReference(baseUrl+'/apex/QuotePDF?id='+quoteId);
        System.debug('pdfPage  is '+pdfPage);
        QuoteDocument qd = new QuoteDocument(); 
        //Added By Krishnan
        //Blob b = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pdfPage.getContent();
        Blob b = pdfPage.getContent();
        System.debug('b is '+b);
        qd.Document = b;
        qd.QuoteId = quoteId;
        insert qd;
        return pdfPage;
    }
}