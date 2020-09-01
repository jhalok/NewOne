/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange Booking data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @modifiedBy     Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2019-12-16
* @modified       
* @systemLayer    RestResource
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* v1.0            mrinal.v.tpr@in.pwc.com
* 2020-01-10      Updated the processBooking Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@RestResource ( urlMapping='/booking/*' )
global with sharing class ACE_CreateBookingAPICallout {
   @HttpPost
    global static String processBooking() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','applicatin/json');

        Map< String, String > params = request.params;
        Blob body = request.requestBody;
        String bodyStr = body.toString();
        System.debug( '@@@@@ bodyStr : ' + bodyStr );
        List<ACE_Utility.Booking> bookings = ( List<ACE_Utility.Booking> ) JSON.deserialize( bodyStr, List<ACE_Utility.Booking>.class );
        System.debug( '@@@@@ bookings : ' + bookings );

        List< ACE_Utility.APIResponse > bookingResponseList = processBooking( bookings );
        String bookingResponseStr = JSON.serialize( bookingResponseList );
        return bookingResponseStr;
    }
    public static List< ACE_Utility.APIResponse > processBooking( List<ACE_Utility.Booking> bList ){
        
        //Contains response for all the records
        List< ACE_Utility.APIResponse > bookingResponseList = new List< ACE_Utility.APIResponse >();
        List< ACE_Utility.Booking > bListValid              = new List< ACE_Utility.Booking >();

        Set< Id > oppExternalIdSet     = new Set< Id >();
        Set< Id > userExternalIdSet    = new Set< Id >();
        Set< Id > contactExternalIdSet = new Set< Id >();
        Set< Id > bookingExternalIdSet = new Set< Id >();

        for(ACE_Utility.Booking booking : bList){

            ACE_Utility.APIResponse bResponse = new ACE_Utility.APIResponse();
            bResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;

            if( String.isNotBlank( booking.CustomerId ) ){
                try {
                    contactExternalIdSet.add(booking.CustomerId);
                } catch (Exception e) {
                    bResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( booking.id ) ) {
                try {
                    bookingExternalIdSet.add( booking.id );
                } catch (Exception e) {
                    bResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( booking.enquiryId ) ){
                try {
                    oppExternalIdSet.add(booking.enquiryId);
                } catch (Exception e) {
                    bResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank(booking.ownerId) ){
                try {
                    userExternalIdSet.add(booking.ownerId);
                } catch (Exception e) {
                    bResponse.errors.add( e.getMessage() );
                }
            }

            if( !bResponse.errors.isEmpty() ) {
                bResponse.record = booking;
                bookingResponseList.add( bResponse );
            } else {
                bListValid.add( booking );
            }
        }

        Set< String > contactIdSet = new Set< String >();
        for( Contact con : [ SELECT Id FROM Contact WHERE Id IN :contactExternalIdSet ] ) {
            contactIdSet.add( con.Id );
        }

        Set< String > oppIdSet = new Set< String >();
        for( Opportunity opp : [ SELECT Id FROM Opportunity WHERE Id IN :oppExternalIdSet ] ) {
            oppIdSet.add( opp.Id );
        }

        Set< String > userIdSet = new Set< String >();
        for( User u : [ SELECT Id FROM User WHERE Id IN :userExternalIdSet ] ) {
            userIdSet.add( u.Id );
        }

        Map< String, ACE_Booking__c > aceBookingExternalIdMap = new Map< String, ACE_Booking__c >();
        for( ACE_Booking__c acebook : [ SELECT Id, 
                                            Amount__c,
                                            Amount_Received__c,
                                            Amount_Received_Date__c,
                                            Booking_Amount__c,
                                            Booking_Date__c,
                                            Name,
                                            Cheque_DD_PO_Details__c,
                                            Consumer_Scheme__c,
                                            Corporate_Bonus__c,
                                            Customer_Expected_Delivery_Date__c,
                                            Customer_Id__c,
                                            Dealer_Discount_Special_Discount__c,
                                            Delivery_Location__c,
                                            Down_Payment__c,
                                            Drawn_Date__c,
                                            Drawn_On__c,
                                            Exchange_Bonus__c,
                                            Expected_EMI__c,
                                            Finance_Arranged_By__c,
                                            Finance_Company__c,
                                            Insurance__c,
                                            Insurance_By__c,
                                            Insurance_Company__c,
                                            Insurance_Types__c,
                                            Interest_Rates__c,
                                            Loan_Amount__c,
                                            Loyalty_Bonus__c,
                                            Mode_OF_Payment__c,
                                            Opportunity__c,
                                            Order_Date__c,
                                            Order_ID__c,
                                            OTF_No__c,
                                            OwnerId,
                                            Price_Type__c,
                                            Committed_Delivery_Date__c,
                                            Reasons_For_Cancellation__c,
                                            Registration__c,
                                            Registration_By__c,
                                            Registration_Place__c,
                                            Registration_Types__c,
                                            Remarks__c,
                                            Road_Safety_Tax__c,
                                            RSA__c,
                                            Sales_Type__c,
                                            Scheme_Name__c,
                                            Shield__c,
                                            Shield_Warranty__c,
                                            Stage__c,
                                            Status__c,
                                            Tenure__c,
                                            Usage__c,
                                            Zero_Depreciation_Insurance_Cost__c
                                        FROM ACE_Booking__c 
                                        WHERE Id IN :bookingExternalIdSet ] ) {

            aceBookingExternalIdMap.put( acebook.Id, acebook );
        }
        
        List< ACE_Booking__c > newBooking_List               = new List< ACE_Booking__c >();
        List< ACE_Utility.Booking > bookingWrapperUpsertList = new List< ACE_Utility.Booking >();
        
        for( ACE_Utility.Booking b : bListValid ) {
            if( String.isBlank( b.enquiryId ) ||
                String.isBlank( b.stage ) ||
                b.committedDeliveryDate == NULL ||
                b.orderDate == NULL ||
                b.customerExpectedDeliveryDate == NULL ||
                b.bookingAmount == NULL ||
           //     b.drawnDate == NULL ||
                b.amountReceived == NULL ||
                b.amountReceivedDate == NULL ||
                b.interestRates == NULL ||
           //     b.expectedEMI == NULL ||
                b.loanAmount == NULL ||
                b.tenure == NULL ||
                b.downPayment == NULL ||
                b.customerId == NULL ) {
                
                ACE_Utility.APIResponse bResponse = new ACE_Utility.APIResponse();
                bResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                bResponse.errors.add( 'Missing required field(s).' );
                bResponse.record = b;

                bookingResponseList.add( bResponse );
            } 
            else if( !oppIdSet.contains( b.enquiryId ) ) {
                ACE_Utility.APIResponse bResponse = new ACE_Utility.APIResponse();
                bResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                bResponse.errors.add( 'No record found for given enquiryId.' );
                bResponse.record = b;
                bookingResponseList.add( bResponse );
            }
            else if( String.isNotBlank( b.ownerId ) && !userIdSet.contains( b.ownerId ) ) {
                ACE_Utility.APIResponse bResponse = new ACE_Utility.APIResponse();
                bResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                bResponse.errors.add( 'No record found for given ownerId.' );
                bResponse.record = b;
                bookingResponseList.add( bResponse );
            }
            else if(( String.isNotBlank( b.CustomerId ) && !contactIdSet.contains(b.CustomerId) )) {
                ACE_Utility.APIResponse bResponse = new ACE_Utility.APIResponse();
                bResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                bResponse.errors.add( 'No record found for given CustomerId.' );
                bResponse.record = b;
                bookingResponseList.add( bResponse );
            }
            else{
                ACE_booking__c booking;
                // checking if the Test Drive record already exists or not
                if( aceBookingExternalIdMap.get( b.id ) != NULL ) {
                    booking = aceBookingExternalIdMap.get( b.id );
                } else {
                    booking = new ACE_booking__c();
                }

                if( String.isNotBlank( b.OwnerId ) ) {
                    booking.OwnerId = b.OwnerId;
                }
                booking.Amount__c                           = b.amount;
                booking.Amount_Received__c                  = b.amountReceived;
                booking.Amount_Received_Date__c             = b.amountReceivedDate;
                booking.Booking_Amount__c                   = b.bookingAmount;
                booking.Booking_Date__c                     = b.bookingDate;
                booking.Cheque_DD_PO_Details__c             = b.chequeDD_PO_Details;
                booking.Consumer_Scheme__c                  = b.consumerScheme;
                booking.Corporate_Bonus__c                  = b.corporateBonus;
                booking.Customer_Expected_Delivery_Date__c  = b.customerExpectedDeliveryDate;
                booking.Customer_Id__c                      = b.customerId;
                booking.Dealer_Discount_Special_Discount__c = b.dealerDiscountSpecialDiscount;
                booking.Delivery_Location__c                = b.deliveryLocation;
                booking.Down_Payment__c                     = b.downPayment;
                booking.Drawn_Date__c                       = b.drawnDate;
                booking.Drawn_On__c                         = b.drawnOn;
                booking.Exchange_Bonus__c                   = b.exchangeBonus;
                booking.Expected_EMI__c                     = b.expectedEMI;
                booking.Finance_Arranged_By__c              = b.financeArrangedBy;
                booking.Finance_Company__c                  = b.financeCompany;
                booking.Insurance__c                        = b.insurance;
                booking.Insurance_By__c                     = b.insuranceBy;
                booking.Insurance_Company__c                = b.insuranceCompany;
                booking.Insurance_Types__c                  = b.insuranceTypes;
                booking.Interest_Rates__c                   = b.interestRates;
                booking.Loan_Amount__c                      = b.loanAmount;
                booking.Loyalty_Bonus__c                    = b.loyaltyBonus;
                booking.Mode_OF_Payment__c                  = b.modeOfPayment;
                booking.Opportunity__c                      = b.enquiryId;
                booking.Order_Date__c                       = b.orderDate;
                booking.Order_ID__c                         = b.orderID;
                booking.OTF_No__c                           = b.otfNo;
                booking.Price_Type__c                       = b.priceType;
                booking.Committed_Delivery_Date__c          = b.committedDeliveryDate;
                booking.Reasons_For_Cancellation__c         = b.reasonsForCancellation;
                booking.Registration__c                     = b.registration;
                booking.Registration_By__c                  = b.registrationBy;
                booking.Registration_Place__c               = b.registrationPlace;
                booking.Registration_Types__c               = b.registrationTypes;
                booking.Remarks__c                          = b.remarks;
                booking.Road_Safety_Tax__c                  = b.roadSafetyTax;
                booking.RSA__c                              = b.RSA;
                booking.Sales_Type__c                       = b.salesType;
                booking.Scheme_Name__c                      = b.schemeName;
                booking.Shield__c                           = b.shield;
                booking.Shield_Warranty__c                  = b.shieldWarranty;
                booking.Stage__c                            = b.stage;
                booking.Status__c                           = b.status;
                booking.Tenure__c                           = b.tenure;
                booking.Usage__c                            = b.usage;
                booking.Zero_Depreciation_Insurance_Cost__c = b.zeroDepreciationInsuranceCost;
                
                newBooking_List.add(booking);
                bookingWrapperUpsertList.add( b );
            }
        }
        // upserting the Booking records
        if( newBooking_List.size() > 0 ) {
            try {
                List< Database.UpsertResult > upsertResultList = Database.upsert( newBooking_List, FALSE );
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    Database.UpsertResult ur = upsertResultList.get( i );
                    ACE_Utility.Booking b    = bookingWrapperUpsertList.get( i );
                    b.id                     = ur.getId();

                    ACE_Utility.APIResponse bookinResponse = new ACE_Utility.APIResponse();
                    bookinResponse.status = ACE_Constants.API_RESPONSE_STATUS_SUCCESS;
                    bookinResponse.record = b;

                    List< String > errorList = new List< String >();
                    for( Database.Error error : ur.getErrors() ) {
                        errorList.add( error.getMessage() );
                    }
                    if( !ur.isSuccess() ) {
                        bookinResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                        bookinResponse.errors.addAll( errorList );
                    }

                    bookingResponseList.add( bookinResponse );
                }
            }
            catch ( Exception e ) {
                System.debug( '@@@@@ Exception occured in Booking API. ' + e.getMessage() );
                ACE_Utility.APIResponse bookingResponse = new ACE_Utility.APIResponse();
                bookingResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
                bookingResponse.errors.add( e.getMessage() );

                bookingResponseList.add( bookingResponse );
            }
        }
        return bookingResponseList;
    }
}