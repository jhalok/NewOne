/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Data is fetched using Junction Object.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vidhya Bharathi   <vidhya.b.tpr@in.pwc.com>
* @modifiedBy     Vidhya Bharathi   <vidhya.b.tpr@in.pwc.com>
* @maintainedBy   Vidhya Bharathi   <vidhya.b.tpr@in.pwc.com>
* @version        1.0
* @created        2019-11-15
* @modified       2019-11-19
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com

* @modifiedBy     Shailendra Tiwari   <shailendra.tiwari.tpr@in.pwc.com>
* @modified       2019-12-05
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class ACE_BookingContactController {
    public static Blob Pdf1;
    @AuraEnabled
    public static List<OpportunityLineItem> getProductData( List<Id> prodIds ) {
        
        List<OpportunityLineItem> oppitems = new list<OpportunityLineItem>();
        
        // Fetch the related data from the Product using the Junction Object.
        if(prodIds.size() > 0 && prodIds != null && !prodIds.isEmpty()){
            List<OpportunityLineItem> oppWithItems = [Select id, Product2.Vehicle_Model__c,Product2.Variant__c,Product2.Colour__c  FROM OpportunityLineItem where OpportunityId IN :prodIds];
            oppitems.addall(oppWithItems);
            System.debug('opportunities' + oppWithItems);
            
        }
        // Returns the List of Procuct Data. 
        return oppitems;
    }
    
    /* Method Added by : Shailendra Tiwari, This method is using for insert new booking record*/
    @AuraEnabled
    public static ResultMessage insertBooking(String serializedBookingData){
        ResultMessage result = new ResultMessage();
        result.success = false;
        try{
            JSONParser parser = JSON.createParser(serializedBookingData);

            ACE_Utility.Booking booking = ( ACE_Utility.Booking ) JSON.deserialize( serializedBookingData, ACE_Utility.Booking.class );
            User user = [Select id, contactId, UserType from User where id = :UserInfo.getUserId()];
            Opportunity opp = [SELECT Id, Contact__c FROM Opportunity WHERE Id=: booking.enquiryId];
            if(user.UserType == 'PowerPartner') {
                booking.customerId = opp.Contact__c;
            } else {
                booking.customerId = opp.Contact__c; 
            }

            List< ACE_Utility.APIResponse > bookingResponseList = ACE_CreateBookingAPICallout.processBooking( new List< ACE_Utility.Booking >{booking} );
            
            ACE_Utility.Booking returnedRecord = ( ACE_Utility.Booking ) bookingResponseList[0].record;
            
            result.success = bookingResponseList[0].status == 'success' ? true : false ;
            if(bookingResponseList[0].status == 'success') {
            	result.message = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/BookingPDF?id='+returnedRecord.id;
            } else {
                String message = '';
                if( bookingResponseList[0].errors != NULL ) {
                	result.message =  String.join( bookingResponseList[0].errors, ', ' );
                }
            }
            
        } catch(DMLException e){
            result.message = e.getMessage();
        }
        return result;
    }
    
    /* Method Added by : Shailendra Tiwari, Wrapper class is using for JSON deserialize from lightning component. */
    public class BookingWrapper{
        public String Name;
        public String Order_Date;
        public String Registration_By;
        public String Registration_Types;
        public String Insurance_By;
        public String Insurance_Company;
        public String Insurance_Types;
        public String Shield_Warranty;
        public String Customer_Expected_Delivery_Date;
        public String Committed_Delivery_Date;
        //public String Committed_Delivery_Week;
        public String Booking_Amount;
        public String Mode_OF_Payment;
        public String Cheque_DD_PO_Details;
        public String Amount_Received;
        //public String Drawn_On;
        //public String Amount_Received_Date;
        public String Drawn_Date;
        public String Finance_Arranged_By;
        public String Loan_Amount;
        public String Finance_Company;
        public String Tenure;
        public String Interest_Rates;
        public String Down_Payment;
        public String Stage;
        //public String Expected_EMI;
        public String Opportunity;
        public String Customer_Id;
        public String EnquiryId;
        public String Consumer_Scheme;
        public String Dealer_Discount_Special_Discount;
        public String Road_Safety_Tax;
        public String Registration;
        public String Shield;
        public String Zero_Depreciation_Insurance_Cost;
        public String Loyalty_Bonus;
        public String Amount_Received_Date;
        public String Corporate_Bonus;
        
    }
    
    /* Method ADD by: Shailendra Tiwari,  This method is using for pdf store in document  */
    @AuraEnabled
    public static String storePDF(String bookingId){
        try{
            ACE_Booking__c booking = [SELECT Name, Stage__c, Customer_Id__c, Id, CreatedDate FROM ACE_Booking__c WHERE Id =: bookingId];
            if(booking != null) {
                pagereference Pg = Page.BookingPDF;
                Pg.getParameters().put('id',bookingId);
                if(Test.isRunningTest()){
                    Pdf1 = blob.valueOf('Unit.Test');
                }else{
                    Pdf1 = pg.getcontentAsPdf();
                }
                
                
                /*Document d = new Document();
                d.FolderId = UserInfo.getUserId();
                d.Body = Pdf1;
                d.Name = 'B_'+booking.Customer_Id__c+'_'+booking.CreatedDate+'.pdf';
                d.ContentType = 'application/pdf';
                d.Type = 'pdf';
                insert d;*/
                
                //Insert ContentVersion
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                cVersion.PathOnClient = 'B_'+booking.Customer_Id__c+'_'+booking.CreatedDate+'.pdf';//File name with extention
                cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
                cVersion.Title = 'B_'+booking.Customer_Id__c;//Name of the file
                cVersion.VersionData = Pdf1;//File content
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                cDocLink.LinkedEntityId = bookingId;//Add attachment parentId
                cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                Insert cDocLink;
                return 'SUCCESS';
            }
        } catch (Exception e){
            return 'ERROR :'+e.getMessage();    
        }
        return null;
    }
    
    @AuraEnabled
    public static Id getCustID(Id recordId) {
        List<Opportunity> listOfOpp = [Select id,Contact__r.ACE_Customer_Id__c from Opportunity where id =: recordId];
        return listOfOpp[0].Contact__r.ACE_Customer_Id__c;
    }
}