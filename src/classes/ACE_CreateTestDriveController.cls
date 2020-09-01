/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange TestDrive data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
* @modifiedBy     Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
* @maintainedBy   Mrinal Vishal   <mrinal.v.tpr@in.pwc.com>
* @version        1.0
* @created        2019-12-10
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
* 2020-01-08      Updated the processTestDrive Method for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/testdrive/*' )
global with sharing class ACE_CreateTestDriveController {
    
    @HttpPost
    global static String processTestDrive() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','applicatin/json');

        Map< String, String > params = request.params;
        System.debug( '@@@@@ params : ' + params );
        Blob body = request.requestBody;
        System.debug( '@@@@@ body : ' + body );
        String bodyStr = body.toString();
        System.debug( '@@@@@ bodyStr : ' + bodyStr );
        List<ACE_Utility.TestDrive> tds = ( List<ACE_Utility.TestDrive> ) JSON.deserialize( bodyStr, List<ACE_Utility.TestDrive>.class );
        System.debug( '@@@@@ tds : ' + tds );

        List< ACE_Utility.APIResponse > tdResponseList = new List< ACE_Utility.APIResponse >();
        try {
            tdResponseList = processTestDrive( tds );
        } catch( Exception e ) {
            System.debug( '@@@@@ Exception occured in Test Drive API. ' + e.getMessage() );
            ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
            tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
            tdResponse.errors.add( e.getMessage() );

            tdResponseList.add( tdResponse );
        }
        
        String tdResponseStr = JSON.serialize( tdResponseList );
        return tdResponseStr;
    }

    private static List< ACE_Utility.APIResponse > processTestDrive( List<ACE_Utility.TestDrive> tdList ) {
        System.debug( '@@@@ tdList : ' + tdList );
        Set< Id > enquiryExternalIdSet   = new Set< Id >();
        Set< Id > leadExternalIdSet      = new Set< Id >();
        Set< Id > ownerExternalIdSet     = new Set< Id >();
        Set< Id > testDriveExternalIdSet = new Set< Id >();

        //Contains response for all the records
        List< ACE_Utility.APIResponse > tdResponseList = new List< ACE_Utility.APIResponse >();
        List< ACE_Utility.TestDrive > tdListValid      = new List< ACE_Utility.TestDrive >();

        for( ACE_Utility.TestDrive td : tdList ) {
            ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
            tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
            if( String.isNotBlank( td.enquiryId ) ) {
                try {
                    enquiryExternalIdSet.add( td.enquiryId );
                } catch (Exception e) {
                    tdResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( td.testDriveBy ) ) {
                try {
                    leadExternalIdSet.add( td.testDriveBy );
                } catch (Exception e) {
                    tdResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( td.ownerId ) ) {
                try {
                    ownerExternalIdSet.add( td.ownerId );
                } catch (Exception e) {
                    tdResponse.errors.add( e.getMessage() );
                }
            }
            if( String.isNotBlank( td.id ) ) {
                try {
                    testDriveExternalIdSet.add( td.id );
                } catch (Exception e) {
                    tdResponse.errors.add( e.getMessage() );
                }
            }

            if( !tdResponse.errors.isEmpty() ) {
                tdResponse.record = td;
                tdResponseList.add( tdResponse );
            } else {
                tdListValid.add( td );
            }
        }

        Set< String > enquiryIdSet = new Set< String >();
        for( Opportunity opp : [ SELECT Id FROM Opportunity WHERE Id IN :enquiryExternalIdSet ] ) {
            enquiryIdSet.add( opp.Id );
        }

        Set< String > leadIdSet = new Set< String >();
        for( Lead l : [ SELECT Id FROM Lead WHERE Id IN :leadExternalIdSet ] ) {
            leadIdSet.add( l.Id );
        } 

        Set< String > ownerIdSet = new Set< String >();
        for( User u : [ SELECT Id FROM User WHERE Id IN :ownerExternalIdSet ] ) {
            ownerIdSet.add( u.Id );
        }

        Map< String, ACE_Test_Drive__c > aceTestDriveExternalIdMap = new Map< String, ACE_Test_Drive__c >();
        for( ACE_Test_Drive__c aceTD : [ SELECT Id,
                                            Enquiry_Id__c,
                                            Model__c,
                                            OwnerId,
                                            Place__c,
                                            Rating__c,
                                            Release_No__c,
                                            Stage__c,
                                            Start_Date_Time__c,
                                            End_Date_Time__c,
                                            Test_Drive_by__c
                                        FROM ACE_Test_Drive__c 
                                        WHERE Id IN :testDriveExternalIdSet ] ) {

            aceTestDriveExternalIdMap.put( aceTD.Id, aceTD );
        }

        List< ACE_Test_Drive__c > newTD_List                = new List< ACE_Test_Drive__c >();
        List< ACE_Utility.TestDrive > testWrapperUpsertList = new List< ACE_Utility.TestDrive >();
        
        for( ACE_Utility.TestDrive td : tdListValid ) {
            if( ( String.isBlank( td.enquiryId ) && String.isBlank( td.testDriveBy ) ) ||
                String.isBlank( td.place ) ||
                String.isBlank( td.rating ) ||
                String.isBlank( td.releaseNo ) ||
                String.isBlank( td.stage ) ||
                td.startDateTime == NULL ) {
                
                System.debug( '@@@@ IN IF............' );
                ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
                tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                tdResponse.errors.add( 'Missing required field(s).' );
                tdResponse.record = td;

                tdResponseList.add( tdResponse );
            } else if( String.isNotBlank( td.id ) && aceTestDriveExternalIdMap.get( td.id ) == NULL ) {

                ACE_Utility.APIResponse followupResponse = new ACE_Utility.APIResponse();
                followupResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                followupResponse.errors.add( 'No record found for given id.' );
                followupResponse.record = td;

                tdResponseList.add( followupResponse );

            } else if( (!enquiryIdSet.contains( td.enquiryId ) && !leadIdSet.contains( td.testDriveBy ) )  ) {
                System.debug( '@@@@ IN else 1............' );
                ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
                tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                tdResponse.errors.add( 'No record found for given enquiryId or testDriveBy.' );
                tdResponse.record = td;
                tdResponseList.add( tdResponse );
            } else if( String.isNotBlank( td.ownerId ) && !ownerIdSet.contains( td.ownerId ) ) {
                System.debug( '@@@@ IN else 3............' );
                ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
                tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                tdResponse.errors.add( 'No record found for given ownerId.' );
                tdResponse.record = td;
                tdResponseList.add( tdResponse );
            } else {
                System.debug( '@@@@ IN else 4............' );

                ACE_Test_Drive__c testDrive;
                if( aceTestDriveExternalIdMap.get( td.id ) != NULL ) {
                    testDrive = aceTestDriveExternalIdMap.get( td.id );
                } else {
                    testDrive = new ACE_Test_Drive__c();
                }

                if( String.isNotBlank( td.enquiryId ) ) {
                    testDrive.Enquiry_Id__c = td.enquiryId;                    
                }
                if( String.isNotBlank( td.testDriveBy ) ) {
                    testDrive.Test_Drive_by__c = td.testDriveBy;
                }
                testDrive.OwnerId            = td.ownerId;
                testDrive.Place__c           = td.place;
                testDrive.Rating__c          = td.rating;
                testDrive.Release_No__c      = td.releaseNo;
                testDrive.Stage__c           = td.stage;
                testDrive.Start_Date_Time__c = td.startDateTime;
                testDrive.End_Date_Time__c   = td.endDateTime != NULL ? td.endDateTime : testDrive.Start_Date_Time__c.addMinutes( 30 );

                newTD_List.add( testDrive );
                testWrapperUpsertList.add( td );
            }
        }

        // upserting the Test Drive records
        if( newTD_List.size() > 0 ) {
            try {
                System.debug( '@@@@ Before Upsert..........' );
                List< Database.UpsertResult > upsertResultList = Database.upsert( newTD_List, FALSE );
                System.debug( '@@@@ After Upsert..........' );
                for( Integer i = 0; i < upsertResultList.size() ; i++ ) {
                    Database.UpsertResult ur = upsertResultList.get( i );
                    ACE_Utility.TestDrive td = testWrapperUpsertList.get( i );
                    td.id = ur.getId();

                    ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
                    tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_SUCCESS;
                    tdResponse.record = td;

                    List< String > errorList = new List< String >();
                    for( Database.Error error : ur.getErrors() ) {
                        errorList.add( error.getMessage() );
                    }
                    if( !ur.isSuccess() ) {
                        tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_ERROR;
                        tdResponse.errors.addAll( errorList );
                    }

                    tdResponseList.add( tdResponse );
                }
            } catch ( Exception e ) {
                System.debug( '@@@@@ Exception occured in Test Drive API. ' + e.getMessage() );
                ACE_Utility.APIResponse tdResponse = new ACE_Utility.APIResponse();
                tdResponse.status = ACE_Constants.API_RESPONSE_STATUS_EXCEPTION;
                tdResponse.errors.add( e.getMessage() );

                tdResponseList.add( tdResponse );
            }
        }
        System.debug( '@@@@ tdResponseList : ' + tdResponseList );
        return tdResponseList;
    }
}