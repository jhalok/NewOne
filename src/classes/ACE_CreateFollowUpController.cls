/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange FollowUp ( Task ) data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
* @modifiedBy     Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
* @maintainedBy   Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
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
* 2020-01-08      Updated the processFollowUp Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/followup/*' )
global with sharing class ACE_CreateFollowUpController {
    
    @HttpPost
    global static String processFollowUp() {
        RestRequest request   = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','applicatin/json');

        Map< String, String > params = request.params;
        System.debug( '@@@@@ params : ' + params );
        Blob body = request.requestBody;
        System.debug( '@@@@@ body : ' + body );
        String bodyStr = body.toString();
        System.debug( '@@@@@ bodyStr : ' + bodyStr );
        List<ACE_Utility.FollowUp> followups = ( List<ACE_Utility.FollowUp> ) JSON.deserialize( bodyStr, List<ACE_Utility.FollowUp>.class );
        System.debug( '@@@@@ followups : ' + followups );

        List< ACE_Utility.APIResponse > followupResponseList = new List< ACE_Utility.APIResponse >();
        try {
            followupResponseList = processFollowUp( followups );
        } catch (Exception e) {
            System.debug( '@@@@@ Exception occured in Test Drive API. ' + e.getMessage() );
            ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
            followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
            followupResponse.errors.add( e.getMessage() );

            followupResponseList.add( followupResponse );
        }
        
        String followupResponseStr = JSON.serialize( followupResponseList );
        return followupResponseStr;
    }

    private static List< ACE_Utility.APIResponse > processFollowUp( List<ACE_Utility.FollowUp> followUpWrapperList ) {
        Set< Id > whatIdExternalIdSet   = new Set< Id >();
        Set< Id > whoIdExternalIdSet    = new Set< Id >();
        Set< Id > followUpExternalIdSet = new Set< Id >();
        Set< Id > externalIdSet         = new Set< Id >();

        //Contains response for all the records
        List< ACE_Utility.APIResponse > followupResponseList  = new List< ACE_Utility.APIResponse >();
        List< ACE_Utility.FollowUp > followUpWrapperListValid = new List< ACE_Utility.FollowUp >();

        for( ACE_Utility.FollowUp followUpWrapper : followUpWrapperList ) {

            ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
            followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;

            if( String.isNotBlank( followUpWrapper.whatId ) ) {
                try {
                    whatIdExternalIdSet.add( followUpWrapper.whatId );
                    externalIdSet.add( followUpWrapper.whatId );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.whoId ) ) {
                try {
                    whoIdExternalIdSet.add( followUpWrapper.whoId );
                    externalIdSet.add( followUpWrapper.whoId );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.ownerId ) ) {
                try {
                    externalIdSet.add( followUpWrapper.ownerId );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.service ) ) {
                try {
                    externalIdSet.add( followUpWrapper.service );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.disposition ) ) {
                try {
                    externalIdSet.add( followUpWrapper.disposition );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.subDisposition ) ) {
                try {
                    externalIdSet.add( followUpWrapper.subDisposition );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( followUpWrapper.id ) ) {
                try {
                    followUpExternalIdSet.add( followUpWrapper.id );
                } catch (Exception e) {
                    followupResponse.errors.add( e.getMessage() );
                }
            }

            if( !followupResponse.errors.isEmpty() ) {
                followupResponse.record = followUpWrapper;
                followupResponseList.add( followupResponse );
            } else {
                followUpWrapperListValid.add( followUpWrapper );
            }
        }       

        List<List<SObject>> recordsList = new List<List<SObject>>();

        List<SObject> conList = [SELECT Id FROM Contact WHERE Id In :externalIdSet];
        List<SObject> ledList = [SELECT Id FROM Lead WHERE Id In :externalIdSet];
        List<SObject> oppList = [SELECT Id FROM Opportunity WHERE Id In :externalIdSet];
        List<SObject> usrList = [SELECT Id FROM User WHERE Id In :externalIdSet];
        List<SObject> rprList = [SELECT Id FROM ACE_Repair_Order__c WHERE Id In :externalIdSet];
        List<SObject> sraList = [SELECT Id FROM ACE_Service_Appointment__c WHERE Id In :externalIdSet];
        List<SObject> srvList = [SELECT Id FROM ACE_Service__c WHERE Id In :externalIdSet];
        List<SObject> disList = [SELECT Id FROM ACE_Disposition__c WHERE Id In :externalIdSet];
        List<SObject> sdiList = [SELECT Id FROM ACE_SubDisposition__c WHERE Id In :externalIdSet];

        recordsList.add(conList);
        recordsList.add(ledList);
        recordsList.add(oppList);
        recordsList.add(usrList);
        recordsList.add(rprList);
        recordsList.add(sraList);
        recordsList.add(srvList);
        recordsList.add(disList);
        recordsList.add(sdiList);

        System.debug('@@@@@ recordsList : ' + recordsList);

        Set< String > externalIdRecordIdSet = new Set< String >();
        for( List< SObject > sobjList : recordsList ) {
            for( SObject sobj : sobjList ) {
                String sobjId = ( String ) sobj.get( 'Id' );
                externalIdRecordIdSet.add( sobjId );
            }
        }

        Map< String, Task > externalIdFollowUpMap = new Map< String, Task >();
        for( Task followUpRecord : [ SELECT Id, 
                                    OwnerId,
                                    Description,
                                    IsRecurrence,
                                    ActivityDate,
                                    WhoId,
                                    WhatId,
                                    Type,
                                    Subject,
                                    Status,
                                    Disposition__c,
                                    SubDisposition__c,
                                    Service__c,
                                    Next_Followup_Time__c                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
                                FROM Task 
                                WHERE Id IN :FollowUpExternalIdSet ] ) {

            externalIdFollowUpMap.put( followUpRecord.Id, followUpRecord );
        }

        Map< String, ACE_Utility.FollowUp > externalIdFollowUpWrapperMap = new Map< String, ACE_Utility.FollowUp >(); 

        List< Task > newfollowup_List = new List< Task >();
        List< ACE_Utility.FollowUp > followUpWrapperUpsertList = new List< ACE_Utility.FollowUp >();

        // getting Lead prefix
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String leadPrefix = r.getKeyPrefix();
        System.debug('--leadPrefix--'+leadPrefix);
        
        System.debug('---externalIdRecordIdSet---'+externalIdRecordIdSet);
        system.debug('-------followUpWrapperListValid-------'+followUpWrapperListValid);
        for( ACE_Utility.FollowUp followUpWrapper : followUpWrapperListValid ) {
            if( String.isBlank( followUpWrapper.type ) ||
                String.isBlank( followUpWrapper.subject ) ||
              	String.isBlank( followUpWrapper.whoId )) {
                
                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'Missing required field(s).' );
                followupResponse.record = followUpWrapper;

                followupResponseList.add( followupResponse );
            
            }
            
            else if( String.isNotBlank( followUpWrapper.id ) && externalIdFollowUpMap.get( followUpWrapper.id ) == NULL ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given id.' );
                followupResponse.record = followUpWrapper;

                followupResponseList.add( followupResponse );
                
            } else if( !externalIdRecordIdSet.contains( followUpWrapper.whoId ) ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given whoId.' );
                followupResponse.record = followUpWrapper;

                followupResponseList.add( followupResponse );

            } else if( (followUpWrapper.whoId).substring( 0, 3 ) != leadPrefix && 
                        String.isBlank( followUpWrapper.whatId ) ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'Missing required field(s).' );
                followupResponse.record = followUpWrapper;

                followupResponseList.add( followupResponse );

            } else if( (followUpWrapper.whoId).substring( 0, 3 ) != leadPrefix && 
                        !externalIdRecordIdSet.contains( followUpWrapper.whatId ) ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given whatId.' );
                followupResponse.record = followUpWrapper;

                followupResponseList.add( followupResponse );

            } else if( (followUpWrapper.whoId).substring( 0, 3 ) == leadPrefix &&
                        ( String.isBlank( followUpWrapper.disposition ) || String.isBlank( followUpWrapper.subDisposition ) ) ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'disposition and subDisposition are required when FollowUp is created for Lead.' );
                followupResponse.record = followUpWrapper;
                followupResponseList.add( followupResponse );
            
            } else if( (followUpWrapper.whoId).subString( 0, 3 ) == leadPrefix &&
                        ( !externalIdRecordIdSet.contains( followUpWrapper.disposition ) || 
                           !externalIdRecordIdSet.contains( followUpWrapper.subDisposition ) ) ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given disposition or subDisposition.' );
                followupResponse.record = followUpWrapper;
                followupResponseList.add( followupResponse );
            
            } else if( String.isNotBlank( followUpWrapper.ownerId ) &&
                        !externalIdRecordIdSet.contains( followUpWrapper.ownerId ) ) {
                
                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given ownerId.' );
                followupResponse.record = followUpWrapper;
                followupResponseList.add( followupResponse );

            } else {

                Task followUp;
                // checking if the Follow Up ( Task ) record already exists or not
                if( externalIdFollowUpMap.get( followUpWrapper.id ) != NULL ) {
                    followUp = externalIdFollowUpMap.get( followUpWrapper.id );
                } else {
                    followUp = new Task();
                    followUp.IsRecurrence = FALSE;
                }

                if( String.isNotBlank( followUpWrapper.ownerId ) ) {
                    followUp.OwnerId = followUpWrapper.ownerId; 
                }
                followUp.Description           = followUpWrapper.description;
                followUp.ActivityDate          = followUpWrapper.activityDate;
                followUp.WhoId                 = followUpWrapper.whoId;
                followUp.WhatId                = followUpWrapper.whatId;
                followUp.Type                  = followUpWrapper.type;
                followUp.Subject               = followUpWrapper.subject;
                followUp.Status                = String.isNotBlank( followUpWrapper.status ) ? followUpWrapper.status : ACE_Constants.TASK_Status_Open;
                followUp.Disposition__c        = followUpWrapper.disposition;
                followUp.SubDisposition__c     = followUpWrapper.subDisposition;
                followUp.Service__c            = followUpWrapper.service;
                followUp.Next_Followup_Time__c = followUpWrapper.nextFollowupTime;
                followUp.CallDurationInSeconds = followUpWrapper.callDurationInSeconds;
                followUp.CallObject            = followUpWrapper.callObject;
                followUp.CallDisposition       = followUpWrapper.callDisposition;
                followUp.CallType              = followUpWrapper.callType;
                
                newfollowup_List.add( followUp );
                followUpWrapperUpsertList.add( followUpWrapper );

            }
        }

        // upserting the FollowUp ( Task ) records
        if( newfollowup_List.size() > 0 ) {
            try {
                List< Database.UpsertResult > upsertResultList = Database.upsert( newfollowup_List, FALSE );
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    Database.UpsertResult ur = upsertResultList.get( i );
                    ACE_Utility.FollowUp followUpWrapper = followUpWrapperUpsertList.get( i );
                    followUpWrapper.id = ur.getId();
                    
                    ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                    followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_SUCCESS;
                    followupResponse.record = followUpWrapper;

                    List< String > errorList = new List< String >();
                    for( Database.Error error : ur.getErrors() ) {
                        errorList.add( error.getMessage() );
                    }
                    if( !ur.isSuccess() ) {
                        followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                        followupResponse.errors.addAll( errorList );
                    }

                    followupResponseList.add( followupResponse );
                }
            } catch ( Exception e ) {
                System.debug( '@@@@@ Exception occured in FollowUp API. ' + e.getMessage() );
                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
                followupResponse.errors.add( e.getMessage() );

                followupResponseList.add( followupResponse );
            }
        }
        System.debug('@@@@@ Followup Response List. ' + followupResponseList);
        return followupResponseList;
    }
}