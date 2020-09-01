/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Data is fetched using Junction Object.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @modifiedBy     Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2019-12-05
* @modified       2019-12-05
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class BookingPDFController {
    
    public List<Product2> products{get;set;}
    public String Disclaimer{get;set;}
    public string quoteName;
    public string quoteId;
    public String[] Terms{get;set;}
    public List<Opportunity> listOfOpportunities{get;set;}
    
    public BookingPDFController(ApexPages.StandardController stdController){
        LIST<ACE_Booking__c> Booking   = [SELECT Customer_Id__r.ACE_Customer_Id__c,Opportunity__c, Order_Date__c, Sales_Type__c, Price_Type__c, Name, Id FROM ACE_Booking__c 
                                  WHERE ID = :ApexPages.currentPage().getParameters().get('id')];
        Disclaimer = System.Label.Disclaimer;
        
        Terms = System.Label.Quote_Terms.split('/');
        listOfOpportunities = [SELECT Id, Name, Account.Name, (SELECT Quantity, UnitPrice, TotalPrice, PricebookEntry.Name, PricebookEntry.Product2.Family, 
                                                                                 Product2.Name, Product2.ProductCode, Product2.Colour__c, Product2.Vehicle_Model__c, Product2.Variant__c 
                                                                                 FROM OpportunityLineItems limit 1) FROM Opportunity WHERE Id = : Booking[0].Opportunity__c];
    } 
}