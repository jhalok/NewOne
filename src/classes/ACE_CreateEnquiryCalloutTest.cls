/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Test class for ACE_CreateEnquiryCalloutController.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @modifiedBy     Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @maintainedBy   Shailendra Tiwari <Shailendra.tiwari.tpr@pwc.com>
* @version        1.0
* @created        2020-01-03
* @modified       2020-01-16
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname.tpr@in.pwc.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class ACE_CreateEnquiryCalloutTest {
    public static testMethod void validateEnquiryCallout(){
		Account acc = new Account(Name='TestAccount',External_Id__c='01Acckwjhetft24563', Customer_Id__c='01Acckwjhetft24563');
        insert acc;
        Contact con = new Contact(LastName='TestAccount',ACE_Customer_Id__c='01Acckwjhetft24563',AccountId=acc.id);
        insert con;
       
        List<Opportunity> listOfOpp = new List<Opportunity>();
        for(Integer i = 1; i <= 10; i++){
            Opportunity Opp = new Opportunity();
				Opp.AccountId = acc.id;
                Opp.CloseDate = Date.today() + 5;
                Opp.Name = 'Enq'+i;
                Opp.StageName = 'Open';
            	opp.Contact__c = con.id;
            	opp.OwnerId = con.Id;
            listOfOpp.add(Opp);
        }
        String resp = String.valueOf(listOfOpp);
         String response = ACE_CreateEnquiryCalloutController.processEnquiry();
        RestRequest request = RestContext.request;
		request.params.put('requestBody',Resp); 
       
    }
}