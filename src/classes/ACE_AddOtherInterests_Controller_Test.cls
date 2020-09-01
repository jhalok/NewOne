/** 
*    Description     :      ACE_AddOtherInterests_Controller is used to add Other Interests in leads
*
*    Arguments       :      No Arguments
*     
*    Return Types    :      void
*
*    Revision Logs   :      V_1.0 - Created
*                        
**/

@isTest(seeAllData = false)
public class ACE_AddOtherInterests_Controller_Test {
    
     @testsetup 
    public static void insertCommonData() {
        Lead newLead = new Lead();
        newLead.LastName = 'TestLead12';
        newLead.MobilePhone = '1234567891';
        newLead.Phone = '1234567890';
        newLead.Status = '	Open - Not Contacted';
        newLead.LeadSource = '	Advertisement';
        newLead.Primary_Model__c = 'Thar';
        newLead.ACE_Vehicle_Model__c = 'Thar';
        newLead.Likely_Conversion_Date__c = '15-45 days';
        newLead.Company = 'TestLead11';
		insert newLead;
        
        Contact newContact = new Contact();
        newContact.LastName = 'TestLead12';
        newContact.MobilePhone = '12345678912';
        newContact.Phone = '123456789';
        insert newContact;
        
        Product2 newProduct = new Product2(Name='XUV500');
        insert newProduct;
        
    }

        /** 
        *    Description     :      positiveTest method  is used to test the positive cases of ACE_AddOtherInterests_Controller class
        *
        *    Arguments       :      No Arguments
        *     
        *    Return Types    :      void
        *
        *    Revision Logs   :      V_1.0 - Created
        *                        
        **/
    public static testMethod void positiveTest(){
        String make = 'Land Rover';
        ACE_AddOtherInterests_Controller.getAllModel(make);    
        List<Competitors_Considered__c> competitors = new List<Competitors_Considered__c>();
        competitors.add(new Competitors_Considered__c(Make__c = 'Land Rover', Model__c = 'Rang Rover'));
		ACE_AddOtherInterests_Controller.SaveCompetitors(competitors);  
        
        ACE_AddOtherInterests_Controller.dataUpdateForComp(competitors[0]);
        
        Lead NewLead = [select id,Name from Lead Where MobilePhone ='1234567891' limit 1];
        ACE_AddOtherInterests_Controller.getAllCompetitorsList(NewLead.id);
        
        contact newContact = [select id,name from contact where MobilePhone = '12345678912'];
       List<ACE_AddOtherInterests_Controller.prodWrapper> wrapList = new List<ACE_AddOtherInterests_Controller.prodWrapper>();
        ACE_AddOtherInterests_Controller.prodWrapper wrap = new ACE_AddOtherInterests_Controller.prodWrapper();
        wrap.label = 'XUV500';
        wrap.value = [select id,Name from Product2 where Name='XUV500' limit 1].Id;
        wrapList.add(wrap);
        ACE_AddOtherInterests_Controller.SaveLead(newContact.id, JSON.serialize(wrapList));
         
    }
    
}