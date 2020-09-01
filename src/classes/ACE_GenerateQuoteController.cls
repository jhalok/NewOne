/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Handler for GenerateQuoteHelper to Genrate Quote.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @modifiedBy     Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2019-11-01
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
public class ACE_GenerateQuoteController {
    
    @AuraEnabled
    public static LIST < FieldWrapper > getProducts(String oppId) {
        System.debug('Enter in getProducts method in GenrateQuoteController'+oppId);
        // For testing purpose only. Delete after use.
        oppId = oppId == null ? '0065D000004rXAxQAM' : oppId;
        MAP < String, Product2[] > prodMap = new MAP < String, Product2[] > ();
        Opportunity curOpp = [SELECT ID, (SELECT ID, Name, Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE ID =: oppId LIMIT 1];
        //LIST < Product2 > prodList;
        LIST < FieldWrapper > prodWrapper = new LIST < FieldWrapper > ();
        if(curOpp.OpportunityLineItems.size() > 0){
            System.debug('curOpp is ' + curOpp.OpportunityLineItems[0].id);
            
            LIST < PriceBookEntry > productPrices = [SELECT ID, Name, UnitPrice, Product2Id,Product2.Type__c, Product2.Name, Product2.Parent_Product__c
                                                     
                                                     FROM PriceBookEntry
                                                     WHERE((Product2.Parent_Product__c =: curOpp.OpportunityLineItems[0].Product2Id OR Product2Id =: curOpp.OpportunityLineItems[0].Product2Id) AND Product2.Type__c != 'Vehicle')
                                                     ORDER BY Product2.Type__c Desc
                                                    ];
            System.debug('prods are ' + productPrices);
            for (PriceBookEntry pbe: productPrices) {
                prodWrapper.add(new FieldWrapper(pbe.Product2.Name, pbe.Product2.Type__c, pbe.UnitPrice, pbe.Product2.Id));
            }
        }
        System.debug('prodWrapper is ' + prodWrapper);
        return prodWrapper;
    }
    // Get opp Details 
    @AuraEnabled
    public static Opportunity getOppDetails(String oppId){
        Opportunity curOpp = [SELECT ID,contact__r.name, (SELECT ID, Name, Product2.name, UnitPrice FROM OpportunityLineItems WHERE Product2.Type__c ='Vehicle') FROM Opportunity WHERE ID =: oppId LIMIT 1];
        return curOpp;
    }
    // To get Opportunity Id of the quote.
    @AuraEnabled
    public static Quote getOppID(String quoteId) {
        System.debug('Enter in getOppID method in GenrateQuoteController '+quoteId);
        String oppId;
        quoteId = quoteId == null ? '0Q05D000000PKvuSAG' : quoteId;
        Quote quote = [SELECT ID, OpportunityId, Incidental_Charges__c, Registration__c, Dealer_Discount_Special_Discount__c,
                       Road_Safety_Tax__c, Insurance__c, Zero_Depreciation_Insurance_Cost__c,
                       (SELECT Product2.name, unitPrice, product2.Type__c FROM QuoteLineItems)
                       FROM Quote WHERE ID =: quoteId LIMIT 1
                      ];
        return quote;
    }
    // To update Quote and QLI
    @AuraEnabled
    public static String updateQuote(String quoteId, Quote quoteCharges, Boolean updateQuote, String[] qLi) {
        System.debug('Enter in updateQuote method in GenrateQuoteController '+quoteId + quoteCharges +updateQuote + qLi);
        Quote quote = [SELECT ID, Dealer_Discount_Special_Discount__c, Incidental_Charges__c,
                       Registration__c, Road_Safety_Tax__c, Insurance__c, Zero_Depreciation_Insurance_Cost__c,
                       (SELECT Product2Id, ID FROM QuoteLineItems WHERE Product2.Type__c != 'Vehicle')
                       FROM Quote WHERE ID =: quoteId
                      ];
        LIST < QuoteLineItem > oldQLi = quote.quoteLineItems;
        LIST < QuoteLineItem > delQuoteLinesID = new LIST < QuoteLineItem > ();
        System.debug('oldQLi is ' + oldQLi);
        Integer count = qLi.size() > oldQLi.size() ? qLi.size() : oldQLi.size();
        for (Integer i = 0; i < oldQLi.size(); i++) {
            // Del qLi if it was in oldQLi but not in qLi.
            if (!qLi.contains(oldQLi[i].Product2Id)) {
                delQuoteLinesID.add(oldQLi[i]);
            }
            // If qLi is present in both oldQLi and qLi, remove it from qLi. Insert qLi then.
            else {
                System.debug('in else oldQLi[i].id ' + oldQLi[i].id);
                Integer indexToRemove = qLi.indexOf(String.valueOf(oldQLi[i].Product2Id));
                qLi.remove(indexToRemove);
            }
        }
        System.debug('delQuoteLinesID is ' + delQuoteLinesID);
        System.debug('qLi final is ' + qLi);
        insertQuoteLines(JSON.serialize(qLi), quote.id);
        
        if (updateQuote) {
            System.debug('Update quotes are ' + quoteCharges);
            quote.Dealer_Discount_Special_Discount__c = quoteCharges.Dealer_Discount_Special_Discount__c;
            quote.Incidental_Charges__c = quoteCharges.Incidental_Charges__c;
            quote.Registration__c = quoteCharges.Registration__c;
            quote.Road_Safety_Tax__c = quoteCharges.Road_Safety_Tax__c;
            quote.Insurance__c = quoteCharges.Insurance__c;
            quote.Zero_Depreciation_Insurance_Cost__c = quoteCharges.Zero_Depreciation_Insurance_Cost__c;
            Update quote;
        }
        if (delQuoteLinesID.size() > 0) {
            Delete delQuoteLinesID;
        }
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseURL is ' + baseUrl);
        return baseUrl;
    }
    
    // To insert Quote line items from opportunity line items.
    /*@AuraEnabled
public static void insertQuoteLineItems(String oppId, String quoteId) {

LIST<QuoteLineItem> insertQuoteLineItems = new LIST<QuoteLineItem>();
Opportunity opp = [SELECT ID, pricebook2Id, (Select Id, name, UnitPrice, Product2Id, Quantity, Description, PricebookEntryID From OpportunityLineItems) FROM OPPORTUNITY WHERE ID = :oppId];
Quote quo = [SELECT ID, pricebook2Id FROM QUOTE WHERE id = :quoteId];
quo.pricebook2Id = opp.pricebook2Id;
update quo;
for(OpportunityLineItem oppline :opp.OpportunityLineItems) {
QuoteLineItem qli = new QuoteLineItem();
qli.UnitPrice = oppline.UnitPrice;
qli.Product2Id = oppline.Product2Id;
qli.Quantity = oppline.Quantity;
qli.Description = oppline.Description;
qLi.QuoteId = quoteId;
qLi.PricebookEntryID = oppline.PricebookEntryID;
insertQuoteLineItems.add(qLi);
}
insert insertQuoteLineItems;
System.debug('insertQuoteLineItems are ' + insertQuoteLineItems);

}*/
    // To insert Quote and update newly inserted QuoteLineItems.
    @AuraEnabled
    public static String[] insertQuote(String oppId, Quote quoteCharges, String[] quoteLineItems) {
        System.debug('Enter in insertQuote method in GenrateQuoteController '+'id is ' + oppId +' charges are '+quoteCharges +'ln'+ quoteLineItems);
        // For testing purpose only. Delete after use.
        oppId = oppId == null ? '0065D000004rXAxQAM' : oppId;
        System.debug('quoteCharges are ' + quoteCharges);
        System.debug('quoteLineItems are ' + quoteLineItems.size());
        // We might use contact opportunity role here.
        Opportunity opp = [SELECT ID, Name, pricebook2Id, Account.name,
                           accountId, Account.BillingStreet, Account.BillingState, Account.BillingCountry, Account.BillingPostalcode,
                           Account.ShippingStreet, Account.ShippingCountry, Account.ShippingState, Account.ShippingPostalCode,
                           Contact__r.Phone, Contact__r.Email, (Select Id, name, UnitPrice, Product2Id, Quantity,
                                                                Description, PricebookEntryID From OpportunityLineItems WHERE Product2.Type__c = 'Vehicle'
                                                                LIMIT 1) FROM Opportunity
                           WHERE ID =: OppId LIMIT 1];
        Quote quote = new Quote();
        quote.Name = opp.name;
        quote.OpportunityId = opp.id;
        quote.ContactId = opp.Contact__c;
        quote.pricebook2Id = opp.pricebook2Id;
        quote.BillingStreet = opp.Account.BillingStreet;
        quote.BillingState = opp.Account.BillingState;
        quote.BillingCountry = opp.Account.BillingCountry;
        quote.BillingPostalcode = opp.Account.BillingPostalcode;
        
        quote.ShippingStreet = opp.Account.ShippingStreet;
        quote.ShippingCountry = opp.Account.ShippingCountry;
        quote.ShippingState = opp.Account.ShippingState;
        quote.ShippingPostalCode = opp.Account.ShippingPostalCode;
        quote.BillingName = opp.Account.name;
        quote.shippingName = opp.Account.name;
        quote.Dealer_Discount_Special_Discount__c = quoteCharges.Dealer_Discount_Special_Discount__c;
        quote.Incidental_Charges__c = quoteCharges.Incidental_Charges__c;
        quote.Registration__c = quoteCharges.Registration__c;
        quote.Road_Safety_Tax__c = quoteCharges.Road_Safety_Tax__c;
        quote.Insurance__c = quoteCharges.Insurance__c;
        quote.Zero_Depreciation_Insurance_Cost__c = quoteCharges.Zero_Depreciation_Insurance_Cost__c;
        quote.ContactId = opp.Contact__c;
        insert quote;
        System.debug('quotes inserted ' + quote.id);
        OpportunityLineItem oppline = opp.OpportunityLineItems;
        System.debug('oppLine is ' + oppline);
        quoteLineItems.add(oppline.Product2Id);
        if(quoteLineItems.size()>0){
            insertQuoteLines(JSON.serialize(quoteLineItems), quote.id);
        }
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseURL is ' + baseUrl);
        LIST < String > quoURL = new LIST < String > ();
        quoURL.add(quote.id);
        quoURL.add(baseUrl);
        return quoURL;
    }
    // To insert Quote Line Items.
    @future
    public static void insertQuoteLines(String prodcutIds, String quoteId) {
        System.debug('Enter in insertQuoteLines future method in GenrateQuoteController '+' productIds are-- '+prodcutIds+' quoteId is -- '+quoteId);
        List<String> splitted = prodcutIds.split(',');
        System.debug('splitted --- '+ splitted+' value is '+splitted[0]);
        
        SET < ID > prodId = (SET < ID > ) JSON.deserialize(prodcutIds, SET < ID > .Class);
        System.debug('prodId deserialized is ' + prodId);
        LIST < PriceBookEntry > productPrices = [SELECT ID, Name, UnitPrice, Product2Id,
                                                 Product2.Type__c, Product2.Name, Product2.Parent_Product__c
                                                 FROM PriceBookEntry
                                                 WHERE Product2Id IN: prodId	];
        LIST < QuoteLineItem > insertQuoteLineItems = new LIST < QuoteLineItem > ();
        for (PriceBookEntry pe: productPrices) {
            QuoteLineItem qli = new QuoteLineItem();
            qLi.UnitPrice = pe.UnitPrice;
            qli.Product2Id = pe.Product2Id;
            qLi.QuoteId = quoteId;
            qLi.PricebookEntryID = pe.Id;
            qli.Quantity = 1;
            insertQuoteLineItems.add(qLi);
        }
        
        if (insertQuoteLineItems.size() > 0) {
            Insert insertQuoteLineItems;
        }
    }
    //This method is no longer in use.
    /*@future(callout = true)
    public static void insertQuotePdf(String quoteId) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('Entered in generateQuoteCOntroller ' + baseUrl);
        System.debug('quoteId ' + quoteId);
        PageReference pr = new PageReference(baseUrl + '/apex/QuotePDF?id=' + quoteId);
        QuoteDocument qd = new QuoteDocument();
        //Blob b = pr.getContentAsPDF();
        
        Blob b = pr.getContentAsPDF();
        System.debug('b is ' + pr.getContentAsPDF());
        qd.Document = b;
        qd.QuoteId = quoteId;
        insert qd;
        
    }*/
    public class FieldWrapper {        
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String prodType;
        @AuraEnabled
        public Decimal unitPrice;
        @AuraEnabled
        public String value;
        public fieldWrapper(String prdName, String prdType, Decimal cur, String prodId) {
            if (prdType != '') {
                if (prdType != 'Accessories') {
                    label = prdName;
                } else {
                    label = prdName + ', (' + String.valueOf(cur) + ')';
                }
                
            } else {
                
            }
            prodType = prdType;
            unitPrice = cur;
            value = prodId;
        }
    }
    
}