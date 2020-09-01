/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange TestDrive data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
* @modifiedBy     Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari   <shailendra.tiwari.tpr@pwc.com>
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
* 2020-01-13      Updated the processEnquiry Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/enquiry/*' )
global with sharing class ACE_CreateEnquiryCalloutController {

    @HttpPost
    global static String processEnquiry() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','applicatin/json');

        Map< String, String > params = request.params;
        Blob body = request.requestBody;
        String bodyStr = body.toString();
        List<ACE_Utility.Enquiry> enquiry = ( List<ACE_Utility.Enquiry> ) JSON.deserialize( bodyStr, List<ACE_Utility.Enquiry>.class );
        List< ACE_Utility.APIResponse > enquiryResponseList = processEnquiryCreate( enquiry );
        String enquiryesponseStr = JSON.serialize( enquiryResponseList );
        return enquiryesponseStr;
    }

    private static List< ACE_Utility.APIResponse > processEnquiryCreate( List<ACE_Utility.Enquiry> enquiryList ) {
        Set< Id > userExternalIdSet    = new Set< Id >();
        Set< Id > contactExternalIdSet = new Set< Id >();
        Set< Id > enquiryExternalIdSet = new Set< Id >();
        Set< Id > accountExternalIdSet = new Set< Id >();

        //Contains response for all the records
        List< ACE_Utility.APIResponse > enquiryResponseList = new List< ACE_Utility.APIResponse >();
        List< ACE_Utility.Enquiry > enquiryListValid        = new List< ACE_Utility.Enquiry >();
        
        for( ACE_Utility.Enquiry enquiry : enquiryList ) { 

            ACE_Utility.APIResponse enquiryResponse = new ACE_Utility.APIResponse();
            enquiryResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;

            if( String.isNotBlank( enquiry.id ) ) {
                try {
                    enquiryExternalIdSet.add( enquiry.id );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }   
            }
            if( String.isNotBlank( enquiry.accountId ) ) {
                try {
                    accountExternalIdSet.add( enquiry.accountId );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.contactId ) ) {
                try {
                    contactExternalIdSet.add( enquiry.contactId );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.salesConsultantContactACE ) ) {
                try {
                    contactExternalIdSet.add( enquiry.salesConsultantContactACE );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.salesManagerContactACE ) ) {
                try {
                    contactExternalIdSet.add( enquiry.salesManagerContactACE );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.dealerManagerContactACE ) ) {
                try {
                    contactExternalIdSet.add( enquiry.dealerManagerContactACE );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.branchManagerContactACE ) ) {
                try {
                    contactExternalIdSet.add( enquiry.branchManagerContactACE );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( enquiry.ownerId ) ) {
                try {
                    userExternalIdSet.add( enquiry.ownerId );
                } catch (Exception e) {
                    enquiryResponse.errors.add( e.getMessage() );
                }
            }

            if( !enquiryResponse.errors.isEmpty() ) {
                enquiryResponse.record = enquiry;
                enquiryResponseList.add( enquiryResponse );
            } else {
                enquiryListValid.add( enquiry );
            }
        }    

        Map< String, Opportunity > externalIdWithEnquiry = new Map< String, Opportunity >();
        for( Opportunity opportunity : [SELECT Id,
                                            Name,
                                            AccountId,
                                            Enquiry_Date__c,
                                            CloseDate,
                                            Contact__c,
                                            StageName,
                                            Refer_By_Name__c,
                                            NextStep,
                                            Enquiry_Type__c,
                                            Enquiry_Source__c,
                                            Next_Action__c,
                                            Usage_Area__c,
                                            Likely_Purchase__c,
                                            Amount,
                                            OwnerId,
                                            DMS_Enquiry_Number__c,
                                            Completed_Stages__c,
                                            Sales_consultant_Contact_ACE__c,
                                            Sales_Manager_Contact_ACE__c,
                                            Dealer_Manager_Contact_ACE__c,
                                            Branch_Manager_Contact_ACE__c,
                                            Quotation_Type__c,
                                            Cust_Interested_in_Leasing_Vehicle__c,
                                            Quotation_Required__c,
                                            Leasing_policy_Expln__c,
                                            Referral_Mobile__c
                                        FROM Opportunity 
                                        WHERE Id IN : enquiryExternalIdSet] ) {
            
            externalIdWithEnquiry.put( opportunity.Id, opportunity );
        }

        Set< String > externalIdWithAccount = new Set< String >();
        for(Account account : [SELECT Id FROM Account WHERE Id IN: accountExternalIdSet]) {
                externalIdWithAccount.add(account.Id);
        }
        
        Set< String > externalIdWithContact = new Set< String >();
        for(Contact acct : [SELECT Id FROM Contact WHERE Id IN: contactExternalIdSet]) {
                externalIdWithContact.add(acct.Id);
        }

        Set< String > externalIdWithUser = new Set< String >();
        for(User con : [SELECT Id FROM User WHERE Id IN: userExternalIdSet]) {
                externalIdWithUser.add(con.Id);
        }

        List< Opportunity > newEnqyiryList                   = new List< Opportunity >();
        List< ACE_Utility.Enquiry > enquiryWrapperUpsertList = new List< ACE_Utility.Enquiry >();
        for( ACE_Utility.Enquiry enquiry : enquiryListValid ) {

            if( String.isBlank( enquiry.name ) ||
                String.isBlank( enquiry.stageName ) ||
                String.isBlank( enquiry.accountId ) ||
                enquiry.closeDate == NULL ||
                enquiry.enquiryDate == NULL ||
                enquiry.contactId == NULL ||
                String.isBlank( enquiry.referByName ) ||
                String.isBlank( enquiry.nextStep ) ||
                String.isBlank( enquiry.enquiryType ) ||
                String.isBlank( enquiry.enquirySource ) ||
                String.isBlank( enquiry.nextAction ) ||
                String.isBlank( enquiry.usageArea ) ||
                String.isBlank( enquiry.likelyPurchase ) ) { 

        ACE_Utility.APIResponse enquiryResponse = new ACE_Utility.APIResponse();
                enquiryResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryResponse.record = enquiry;
                enquiryResponse.errors.add( 'Missing required field(s).' );
                enquiryResponseList.add( enquiryResponse );

            }
            else if ( !externalIdWithAccount.contains(enquiry.accountId) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given accountId.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.contactId ) && !externalIdWithContact.contains(enquiry.contactId) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given contactId.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.salesConsultantContactACE ) && !externalIdWithContact.contains(enquiry.salesConsultantContactACE) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given salesConsultantContactACE.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.salesManagerContactACE ) && !externalIdWithContact.contains(enquiry.salesManagerContactACE) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given salesManagerContactACE.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.dealerManagerContactACE ) && !externalIdWithContact.contains(enquiry.dealerManagerContactACE) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given dealerManagerContactACE.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.branchManagerContactACE ) && !externalIdWithContact.contains(enquiry.branchManagerContactACE) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given branchManagerContactACE.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else if ( String.isNotBlank( enquiry.ownerId ) && !externalIdWithUser.contains(enquiry.ownerId) ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                enquiryAPIResponse.record = enquiry;
                enquiryAPIResponse.errors.add( 'No record found for given ownerId.' );
                enquiryResponseList.add( enquiryAPIResponse );
            }
            else {
                
                Opportunity oppt;
                if( externalIdWithEnquiry.containskey( enquiry.id ) ) {
                    oppt = externalIdWithEnquiry.get( enquiry.id );
                } else {
                    oppt = new Opportunity();
                }

                if( String.isNotBlank( enquiry.contactId ) ) {
                    oppt.Contact__c = enquiry.contactId;
                }
                if( String.isNotBlank( enquiry.salesConsultantContactACE ) ) {
                    oppt.Sales_consultant_Contact_ACE__c = enquiry.salesConsultantContactACE;
                }
                if( String.isNotBlank( enquiry.salesManagerContactACE ) ) {
                    oppt.Sales_Manager_Contact_ACE__c = enquiry.salesManagerContactACE;
                }
                if( String.isNotBlank( enquiry.dealerManagerContactACE ) ) {
                    oppt.Dealer_Manager_Contact_ACE__c = enquiry.dealerManagerContactACE;
                }
                if( String.isNotBlank( enquiry.branchManagerContactACE ) ) {
                    oppt.Branch_Manager_Contact_ACE__c = enquiry.branchManagerContactACE;
                }
                oppt.Name                                   = enquiry.name;
                oppt.AccountId                              = enquiry.accountId;
                oppt.Enquiry_Date__c                        = enquiry.enquiryDate;
                oppt.CloseDate                              = enquiry.closeDate;
                oppt.StageName                              = enquiry.stageName;
                oppt.Refer_By_Name__c                       = enquiry.referByName;
                oppt.NextStep                               = enquiry.nextStep;
                oppt.Enquiry_Type__c                        = enquiry.enquiryType;
                oppt.Enquiry_Source__c                      = enquiry.enquirySource;
                oppt.Next_Action__c                         = enquiry.nextAction;
                oppt.Usage_Area__c                          = enquiry.usageArea;
                oppt.Likely_Purchase__c                     = enquiry.likelyPurchase;
                oppt.Amount                                 = enquiry.amount;
                oppt.OwnerId                                = enquiry.ownerId;
                oppt.DMS_Enquiry_Number__c                  = enquiry.dMSEnquiryNumber;
                oppt.Quotation_Type__c                      = enquiry.quotationType;
                oppt.Cust_Interested_in_Leasing_Vehicle__c  = enquiry.custInterestedInLeasingVehicle;
                oppt.Quotation_Required__c                  = enquiry.quotationRequired;
                oppt.Leasing_policy_Expln__c                = enquiry.leasingPolicyExpln;
                oppt.Referral_Mobile__c                     = enquiry.referralMobile;

                newEnqyiryList.add( oppt );
                enquiryWrapperUpsertList.add( enquiry );
            }
        }

        // upserting the Enquiry ( Opportunity ) records
        if( newEnqyiryList.size() > 0 ) {
            try {
                List< Database.UpsertResult > upsertResultList = Database.upsert( newEnqyiryList, FALSE );
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    Database.UpsertResult ur          = upsertResultList.get( i );
                    ACE_Utility.Enquiry enquiryInsert = enquiryWrapperUpsertList.get( i );
                    enquiryInsert.Id                  = ur.getId();

                    ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                    enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_SUCCESS;
                    enquiryAPIResponse.record = enquiryInsert;

                    List< String > errorList = new List< String >();
                    for( Database.Error error : ur.getErrors() ) {
                        errorList.add( error.getMessage() );
                    }
                    if( !ur.isSuccess() ) {
                        enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                        enquiryAPIResponse.errors.addAll( errorList );
                    }

                    enquiryResponseList.add( enquiryAPIResponse );
                }
            } catch ( Exception e ) {
                ACE_Utility.APIResponse enquiryAPIResponse = new ACE_Utility.APIResponse();
                enquiryAPIResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
                enquiryAPIResponse.errors.add( e.getMessage() );

                enquiryResponseList.add( enquiryAPIResponse );
            }
        }
        return enquiryResponseList;
        
    }
}