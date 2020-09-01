/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : This class is used to exchange TestDrive data with 3rd party system.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Prerna Purwar   <prerna.purwar@pwc.com>
* @modifiedBy     Prerna Purwar   <prerna.purwar@pwc.com>
* @maintainedBy   Prerna Purwar   <prerna.purwar@pwc.com>
* @version        1.0
* @created        2019-01-08
* @modified       
* @systemLayer    RestResource
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource ( urlMapping='/enquiries/*' )
global with sharing class ACE_EnquiryController {
    
    @HttpPost
    global static String processEnquiry() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','applicatin/json');
        
        Map< String, String > params = request.params;
        System.debug( '@@@@@ params : ' + params );
        Blob body = request.requestBody;
        System.debug( '@@@@@ body : ' + body );
        String bodyStr = body.toString();
        System.debug( '@@@@@ bodyStr : ' + bodyStr );
        List<ACE_Utility.Enquiry> enquiry = ( List<ACE_Utility.Enquiry> ) JSON.deserialize( bodyStr, List<ACE_Utility.Enquiry>.class );
        System.debug( '@@@@@ enquiry : ' + enquiry );
        
        List< ACE_Utility.APIResponse > enquiryResponseList = createEnquiries( enquiry );
        String enquiryesponseStr = JSON.serialize( enquiryResponseList );
        return enquiryesponseStr;
    }
    
    private static List< ACE_Utility.APIResponse > createEnquiries( List<ACE_Utility.Enquiry> enquiryList ) {
        Set< String > enquiryExternalIdSet = new Set< String >();
        Set< String > accountExternalIdSet = new Set< String >();
        Set< String > contactExternalIdSet = new Set< String >();
        Set< String > userExternalIdSet = new Set< String >();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Account> accounts = new List<Account>();
        Contact newContact;
        Opportunity newOpportunity;
        Account newAccoount;
        for( ACE_Utility.Enquiry enq : enquiryList ) { 
            // search contact
            List<String> contactDetails = new List<String>();
            if(enq.mobileNo!='')
                contactDetails.add(enq.mobileNo);
            if(enq.phoneNum!='')
                contactDetails.add(enq.phoneNum);
            if(enq.Email!='')
                contactDetails.add(enq.Email);
            newContact = new Contact();
            newContact=ACE_Utility.searchExistingContact(contactDetails);
            
            newOpportunity = new Opportunity();
            //Create Contact if not exiisting
            if(newContact==null){
                newContact.Title = enq.title;
                newContact.FirstName= enq.firstName;
                newContact.lastName= enq.lastName;
                newContact.MobilePhone= enq.mobileNo;
                newContact.OtherPhone= enq.phoneNum;
                newContact.Email = enq.Email;
                newContact.Age__c = enq.age;
                newContact.Gender__c = enq.gender;
                contacts.add(newContact);
            }
            else{
                newOpportunity.Contact__c=newContact.Id;            
            }
            newOpportunity.Enquiry_Source__c = enq.enquirySource;
            newOpportunity.Enquiry_Type__c = enq.enquiryType;
            newOpportunity.LeadSource = enq.LeadSource;
            newOpportunity.Refer_By_Name__c =enq.referByName;
            newOpportunity.StageName ='Enquiry';
            opportunities.add(newOpportunity);
        }
        return null;
    }
}