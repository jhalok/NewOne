public class ACE_TestData {
	
   public static Opportunity opportunityData(){
        Opportunity opp = new Opportunity();
            //opp.Assigned_Agent__c = curntUser.Id;
            //opp.Name =curntUser.Name;
            opp.Enquiry_Date__c = Date.valueOf('2018-01-01 00:00:00');
            opp.CloseDate = Date.valueOf('2020-01-01 00:00:00');
            opp.StageName = ACE_Constants.OPP_Stage_Name_Booking;
            opp.Refer_By_Name__c = 'test Refer';
            opp.NextStep = 'test Step';
            opp.Enquiry_Type__c= 'FLD';
            opp.Enquiry_Source__c= 'TEV';
            opp.Next_Action__c='T';
            opp.Usage_Area__c='City outskirt';
            opp.Likely_Purchase__c='GT15';
        return opp;        
    }
    
    public static User userData(){
        User portalUsr = new User(
            //UserRoleId = portalRole.Id,
            //ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'   
        );
         return portalUsr;
    }
}