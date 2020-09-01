/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange FollowUp ( Task ) data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
* @modifiedBy     Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2019-01-21
* @modified       
* @systemLayer    RestResource
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* v1.0            shailendra.tiwari.tpr@pwc.com
* 2020-01-08      Updated the getAllEnquiryRequest Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/getAllEnquiry/*' )
global class ACE_GetAllEnquiryAPICallRequest {
    
    @HttpPost
    global static String getAllEnquiryRequest(List<String> salesConsultantIds) {
        
        try{
            if(salesConsultantIds.size() > 0 && salesConsultantIds != null) {
                List<User> user = [SELECT Id, ContactId FROM User WHERE Id IN: salesConsultantIds];
                List<ACE_Utility.Enquiry> enquiryList = new List<ACE_Utility.enquiry>();
                List< ACE_Utility.Booking > bookingList = new List< ACE_Utility.Booking >();
                List<ACE_Utility.TestDrive> testDriveList = new List<ACE_Utility.TestDrive>();
                List< ACE_Utility.FollowUp > followUpWrapperList = new List< ACE_Utility.FollowUp >();
                if(user.size() > 0) {
                    Set<Id> contactIds = new Set<Id>();
                    for(User usr : user) {
                    	contactIds.add(usr.ContactId);    
                    }
                    ACE_Utility.Enquiry enquiry = new ACE_Utility.enquiry();
                    if(contactIds.size() > 0){
                        for(Opportunity oppt : [SELECT Id, Name, 
                                                (SELECT Id, Amount__c, Amount_Received__c, Amount_Received_Date__c, Booking_Amount__c, Booking_Date__c, Name, Cheque_DD_PO_Details__c, Consumer_Scheme__c, Corporate_Bonus__c, Customer_Expected_Delivery_Date__c, Customer_Id__c, Dealer_Discount_Special_Discount__c, Delivery_Location__c, Down_Payment__c, Drawn_Date__c, Drawn_On__c, Exchange_Bonus__c, Expected_EMI__c, Finance_Arranged_By__c, Finance_Company__c, Insurance__c, Insurance_By__c, Insurance_Company__c, Insurance_Types__c, Interest_Rates__c, Loan_Amount__c, Loyalty_Bonus__c, Mode_OF_Payment__c, Opportunity__c, Order_Date__c, Order_ID__c, OTF_No__c, OwnerId, Price_Type__c, Committed_Delivery_Date__c, Reasons_For_Cancellation__c, Registration__c, Registration_By__c, Registration_Place__c, Registration_Types__c, Remarks__c, Road_Safety_Tax__c, RSA__c, Sales_Type__c, Scheme_Name__c, Shield__c, Shield_Warranty__c, Stage__c, Status__c, Tenure__c, Usage__c, Zero_Depreciation_Insurance_Cost__c FROM Bookings__r)
                                                ,(SELECT Id, OwnerId, Description, IsRecurrence, ActivityDate, WhoId, WhatId, Type, Subject, Status, Disposition__c, SubDisposition__c, Service__c, Next_Followup_Time__c FROM Tasks)
                                                ,(SELECT Id, Enquiry_Id__c, Model__c, OwnerId, Place__c, Rating__c, Release_No__c, Stage__c, Start_Date_Time__c, End_Date_Time__c, Test_Drive_by__c FROM Test_Drives__r)
                                                ,AccountId, Enquiry_Date__c, CloseDate, Contact__c, StageName, Refer_By_Name__c, NextStep, Enquiry_Type__c, Enquiry_Source__c, Next_Action__c, Usage_Area__c, Likely_Purchase__c, Amount, OwnerId, DMS_Enquiry_Number__c, Completed_Stages__c, Sales_consultant_Contact_ACE__c, Sales_Manager_Contact_ACE__c, Dealer_Manager_Contact_ACE__c, Branch_Manager_Contact_ACE__c, Quotation_Type__c, Cust_Interested_in_Leasing_Vehicle__c, Quotation_Required__c, Leasing_policy_Expln__c, Referral_Mobile__c FROM Opportunity WHERE Contact__c IN: contactIds]) {
                        	enquiry.name = oppt.Name; 
                            enquiry.accountId = oppt.AccountId;
                            enquiry.enquiryDate = oppt.Enquiry_Date__c;
                            enquiry.closeDate = oppt.CloseDate ;
                            enquiry.stageName = oppt.StageName ;
                            enquiry.referByName = oppt.Refer_By_Name__c ;
                            enquiry.nextStep = oppt.NextStep;
                            enquiry.enquiryType = oppt.Enquiry_Type__c ;
                            enquiry.enquirySource = oppt.Enquiry_Source__c;
                            enquiry.nextAction = oppt.Next_Action__c;
                            enquiry.usageArea = oppt.Usage_Area__c;
                            enquiry.likelyPurchase = oppt.Likely_Purchase__c ;
                            enquiry.amount = oppt.Amount;
                            enquiry.ownerId = oppt.OwnerId;
                            enquiry.dMSEnquiryNumber = oppt.DMS_Enquiry_Number__c;
                            enquiry.quotationType = oppt.Quotation_Type__c;
                            enquiry.custInterestedInLeasingVehicle = oppt.Cust_Interested_in_Leasing_Vehicle__c ;
                            enquiry.quotationRequired = oppt.Quotation_Required__c ;
                            enquiry.leasingPolicyExpln = oppt.Leasing_policy_Expln__c ;
                            enquiry.referralMobile = oppt.Referral_Mobile__c;
                                                    
                                                    /* Booking start */
                                                    for(ACE_Booking__c booking :  oppt.Bookings__r) {
                                                        ACE_Utility.Booking b = new ACE_Utility.Booking();
                                                        b.amount = Integer.valueOf(booking.Amount__c) ;
                                                        b.amountReceived = booking.Amount_Received__c ;
                                                        b.amountReceivedDate = booking.Amount_Received_Date__c ;
                                                        b.bookingAmount = booking.Booking_Amount__c ;
                                                        b.bookingDate = booking.Booking_Date__c ;
                                                        b.chequeDD_PO_Details = booking.Cheque_DD_PO_Details__c ; 
                                                        b.consumerScheme = Integer.valueOf(booking.Consumer_Scheme__c) ;
                                                        b.corporateBonus = Integer.valueOf(booking.Corporate_Bonus__c) ;
                                                        b.customerExpectedDeliveryDate = booking.Customer_Expected_Delivery_Date__c ;
                                                        b.customerId = booking.Customer_Id__c ;
                                                        b.dealerDiscountSpecialDiscount = Integer.valueOf(booking.Dealer_Discount_Special_Discount__c) ;
                                                        b.deliveryLocation = booking.Delivery_Location__c ;
                                                        b.downPayment = booking.Down_Payment__c ;
                                                        b.drawnDate = booking.Drawn_Date__c ;
                                                        b.drawnOn = booking.Drawn_On__c ;
                                                        b.exchangeBonus = Integer.valueOf(booking.Exchange_Bonus__c) ;
                                                        b.expectedEMI = booking.Expected_EMI__c ;
                                                        b.financeArrangedBy = booking.Finance_Arranged_By__c;
                                                        b.financeCompany = booking.Finance_Company__c ;
                                                        b.insurance = Integer.valueOf(booking.Insurance__c) ;
                                                        b.insuranceBy = booking.Insurance_By__c ;
                                                        b.insuranceCompany = booking.Insurance_Company__c ;
                                                        b.insuranceTypes = booking.Insurance_Types__c ;
                                                        b.interestRates = booking.Interest_Rates__c ;
                                                        b.loanAmount = booking.Loan_Amount__c ;
                                                        b.loyaltyBonus = Integer.valueOf(booking.Loyalty_Bonus__c) ;
                                                        b.modeOfPayment = booking.Mode_OF_Payment__c ;
                                                        b.enquiryId = booking.Opportunity__c ;
                                                        b.orderDate = booking.Order_Date__c ;
                                                        b.orderID = booking.Order_ID__c ;
                                                        b.otfNo = booking.OTF_No__c ;
                                                        b.priceType = booking.Price_Type__c ;
                                                        b.committedDeliveryDate = booking.Committed_Delivery_Date__c ;
                                                        b.reasonsForCancellation = booking.Reasons_For_Cancellation__c ;
                                                        b.registration = Integer.valueOf(booking.Registration__c) ;
                                                        b.registrationBy = booking.Registration_By__c ;
                                                        b.registrationPlace = booking.Registration_Place__c ;
                                                        b.registrationTypes = booking.Registration_Types__c ;
                                                        b.remarks = booking.Remarks__c ;
                                                        b.roadSafetyTax = Integer.valueOf(booking.Road_Safety_Tax__c);
                                                        b.RSA = Integer.valueOf(booking.RSA__c) ;
                                                        b.salesType = booking.Sales_Type__c ;
                                                        b.schemeName = booking.Scheme_Name__c ;
                                                        b.shield = Integer.valueOf(booking.Shield__c) ;
                                                        b.shieldWarranty = booking.Shield_Warranty__c ;
                                                        b.stage = booking.Stage__c ;
                                                        b.status = booking.Status__c ;
                                                        b.tenure = Integer.valueOf(booking.Tenure__c) ;
                                                        b.usage = booking.Usage__c ;
                                                        b.zeroDepreciationInsuranceCost = Integer.valueOf(booking.Zero_Depreciation_Insurance_Cost__c) ;
                                                        bookingList.add(b);
                                                    }
                                                    
                                                    for( ACE_Test_Drive__c testDrive : oppt.Test_Drives__r){
                                                        ACE_Utility.TestDrive td = new ACE_Utility.TestDrive();
                                                    	td.ownerId = testDrive.OwnerId ;
                                                        td.place = testDrive.Place__c ;
                                                        td.rating = testDrive.Rating__c ;
                                                        td.releaseNo = testDrive.Release_No__c ;
                                                        td.stage = testDrive.Stage__c ;
                                                        td.startDateTime = testDrive.Start_Date_Time__c ;
                                                        td.endDateTime = DateTime.valueOf(testDrive.End_Date_Time__c.format('hh:mm:ss a')) ;
                                                    	testDriveList.add(td);
                                                    }
                                                    
                                                    for(Task followUp : oppt.Tasks) {
                                                        ACE_Utility.FollowUp followUpWrapper = new ACE_Utility.FollowUp();
                                                        followUpWrapper.description = followUp.Description ;
                                                        followUpWrapper.activityDate = followUp.ActivityDate ;
                                                        followUpWrapper.whoId = followUp.WhoId;
                                                        followUpWrapper.whatId = followUp.WhatId;
                                                        followUpWrapper.type = followUp.Type ;
                                                        followUpWrapper.subject = followUp.Subject ;
                                                        //followUpWrapper.status = String.isNotBlank( followUp.Status != null ? followUpWrapper.status : ACE_Constants.TASK_Status_Open) ;
                                                        followUpWrapper.disposition = followUp.Disposition__c ;
                                                        followUpWrapper.subDisposition = followUp.SubDisposition__c ;
                                                        followUpWrapper.service = followUp.Service__c ;
                                                        followUpWrapper.nextFollowupTime = followUp.Next_Followup_Time__c ;
                                                        followUpWrapper.callDurationInSeconds = followUp.CallDurationInSeconds ;
                                                        followUpWrapper.callObject = followUp.CallObject ;
                                                        followUpWrapper.callDisposition = followUp.CallDisposition ;
                                                        followUpWrapper.callType = followUp.CallType ;
                                                        
                                                        followUpWrapperList.add(followUpWrapper);
													}
                            enquiryList.add(enquiry);    
                        }  
                        
                        /* Enquiry end */
                        
                    }
                } else {
                    return 'Invalid Sales Consultant Id ';
                }
            } else {
                return 'Please pass the sales consultant id';
            }
        } catch(Exception e) {
            
        }
        return null;
    }
    
    

}