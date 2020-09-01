/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange TestDrive data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Meghana Sonare   <meghana.sonare@pwc.com>
* @modifiedBy     Meghana Sonare   <meghana.sonare@pwc.com>
* @maintainedBy   Meghana Sonare   <meghana.sonare@pwc.com>
* @version        1.0
* @created        2019-12-11
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
* 2020-01-10      Updated the processFeedback Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/feedback/*' )
global with sharing class ACE_CreateFeedbackController {
	
    @HttpPost
    global static String processFeedback() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','application/json');

        String result = request.requestBody.toString();
        System.debug('@@@ result : '+result);
        List<ACE_Utility.Feedback> feedbacks = ( List<ACE_Utility.Feedback> ) JSON.deserialize( result, List<ACE_Utility.Feedback>.class );
        System.debug( '@@@@@ feedback : ' + feedbacks );
        
        List< ACE_Utility.APIResponse > apiResponseList = processFeedback( feedbacks );
        String feedResponseStr = JSON.serialize( apiResponseList );
        return feedResponseStr;
       
      /*  for(ACE_Utility.APIResponse ap : apiResponseList)
        {
            //System.debug('@@@@@error msg: '+ ap.errorMessage);
            System.debug('status: '+ap.status);
            System.debug('record '+ ap.record);
        }*/
      
    }
    
    private static List<ACE_Utility.APIResponse> processFeedback( List<ACE_Utility.Feedback> feedbackList ) {
		
		System.debug('inside the processFeedack method');        
        Set< Id > feedbackExternalIdSet    = new Set< Id >();
        Set< Id > contactExternalIdSet     = new Set< Id >();
        Set< Id > repairOrderExternalIdSet = new Set< Id >();
        Set< Id > testDriveExternalIdSet   = new Set< Id >();

        //Contains response for all the records
        List< ACE_Utility.APIResponse > apiResponseList = new List< ACE_Utility.APIResponse >();
        List< ACE_Utility.Feedback > feedbackListValid  = new List< ACE_Utility.Feedback >();

        for( ACE_Utility.Feedback feed : feedbackList ) {
            System.debug('inserting into set');
            
            ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
            apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;

            if( String.isNotBlank( feed.id ) ) {
                try {
                    feedbackExternalIdSet.add( feed.id );
                } catch (Exception e) {
                    apiResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( feed.aceFeedbackby ) ) {
                try {
                    contactExternalIdSet.add( feed.aceFeedbackby );
                } catch (Exception e) {
                    apiResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( feed.repairOrder ) ) {
                try {
                    repairOrderExternalIdSet.add( feed.repairOrder );
                } catch (Exception e) {
                    apiResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( feed.testDrive ) ) {
                try {
                    testDriveExternalIdSet.add( feed.testDrive );
                } catch (Exception e) {
                    apiResponse.errors.add( e.getMessage() );
                }
            }

            if( !apiResponse.errors.isEmpty() ) {
                apiResponse.record = feed;
                apiResponseList.add( apiResponse );
            } else {
                feedbackListValid.add( feed );
            }
        }
        
        Map< String, ACE_Feedback__c > aceFeedbackExternalIdMap = new Map< String, ACE_Feedback__c >();
        for( ACE_Feedback__c aceFeed : [ SELECT Id, Comments__c, ACE_Feedback_by__c, Overall_Rating__c, Repair_Order__c, Test_Drive__c 
                                        FROM ACE_Feedback__c 
                                        WHERE Id IN :feedbackExternalIdSet ] ) {

            aceFeedbackExternalIdMap.put( aceFeed.Id, aceFeed );
        }

        Set< String > testDriveIdSet = new Set< String >();
        for( ACE_Test_Drive__c td : [ SELECT Id FROM ACE_Test_Drive__c WHERE Id IN :testDriveExternalIdSet ] ) {
            testDriveIdSet.add( td.Id );
        }

        Set< String > repairOrderIdSet = new Set< String >();
        for( ACE_Repair_Order__c ro : [ SELECT Id FROM ACE_Repair_Order__c WHERE Id IN :repairOrderExternalIdSet ] ) {
            repairOrderIdSet.add( ro.Id );
        }

        Set< String > contactIdSet = new Set< String >();
		for( Contact ct : [ SELECT Id FROM Contact where Id IN :contactExternalIdSet]) {
            contactIdSet.add( ct.Id );
        }
        
        List< ACE_Feedback__c > newFeedback_List = new List< ACE_Feedback__c >();
        List< ACE_Utility.Feedback > feedbackWraperUpsertList = new List< ACE_Utility.Feedback >();
        
        for( ACE_Utility.Feedback feed : feedbackListValid ) {
            if( feed.overallRating == NULL ) {
                System.debug('found null overall rating');

                List<String> error = new List<String>();
                ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
                apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                error.add('Missing Required Fields');
				apiResponse.errors = error;
                apiResponse.record = feed;
                
                apiResponseList.add(apiResponse);   
            } else if( String.isNotBlank( feed.id ) && aceFeedbackExternalIdMap.get( feed.id ) == NULL ) {
                System.debug('invalid record id');

                List<String> error = new List<String>();
                ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
                apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                error.add( 'No record found for given id.' );
                apiResponse.errors = error;
                apiResponse.record = feed;

                apiResponseList.add( apiResponse );

            } else if(String.isBlank( feed.testDrive ) && String.isBlank( feed.repairOrder )) {
                System.debug('found null test drive and ro details');

               	List<String> error = new List<String>();
                ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
                apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                error.add('Test Drive or Repair Order Record Not Available.');
				apiResponse.errors = error;
                apiResponse.record = feed;
                
                apiResponseList.add(apiResponse);
            } else if(String.isNotBlank( feed.aceFeedbackby ) && !contactIdSet.contains( feed.aceFeedbackby )) {
                System.debug('found no contact for give id.');

               	List<String> error = new List<String>();
                ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
                apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                error.add('Contact Record Not Available.');
				apiResponse.errors = error;
                apiResponse.record = feed;
                
                apiResponseList.add(apiResponse);
            } else {
                ACE_Feedback__c feedToAdd;

                if( aceFeedbackExternalIdMap.get( feed.id ) != NULL ) {
                    feedToAdd = aceFeedbackExternalIdMap.get( feed.id );
                } else {
                    feedToAdd = new ACE_Feedback__c();
                }
                System.debug('record creation..');

                if( String.isNotBlank( feed.testDrive) ) {
                    feedToAdd.Test_Drive__c = feed.testDrive;
                }
                if( String.isNotBlank( feed.repairOrder) ) {
                    feedToAdd.Repair_Order__c = feed.repairOrder;
                }
                if( String.isNotBlank( feed.aceFeedbackby) ) {
                    feedToAdd.ACE_Feedback_by__c = feed.aceFeedbackby;
                }
                feedToAdd.Comments__c       = feed.comments;
                feedToAdd.Overall_Rating__c = feed.overallRating;
                
                newFeedback_List.add(feedToAdd);
                feedbackWraperUpsertList.add(feed);
            }
        }

        if(newFeedback_List.size() > 0) {
            try {
                List< Database.UpsertResult > upsertResultList = Database.upsert( newFeedback_List, FALSE );
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    Database.UpsertResult ur = upsertResultList.get( i );
                    ACE_Utility.Feedback feed = feedbackWraperUpsertList.get( i );
                    feed.id = ur.getId();
                    
                    ACE_Utility.APIResponse apiResponse = new ACE_Utility.APIResponse();
                    apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_SUCCESS;
                    apiResponse.record = feed;
                    
                    List< String > errorList = new List< String >();
                    for( Database.Error error : ur.getErrors() ) {
                        errorList.add( error.getMessage() );
                    }
                    
                    if( !ur.isSuccess() ) {
                        apiResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                        apiResponse.errors = errorList;
                    }

                    apiResponseList.add(apiResponse);
                }
            } catch ( Exception e ) {

            }
        }
        
        return apiResponseList;
    }
}