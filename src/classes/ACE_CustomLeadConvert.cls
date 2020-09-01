public class ACE_CustomLeadConvert {
    @AuraEnabled
    public static void leadConvert(String leadId){
        Database.LeadConvert Leadconvert;
        system.debug('lead Convert called  '+leadId);
        //Get lead data
        Lead Leadobj = [SELECT Email,(select id,Name,Product__c,Quantity__c  from Product_Interests__r),LeadSource,Status,MobilePhone,Name,Phone,ACE_Dealer__c,ACE_Dealer__r.ParentId,
                        Call_Center__c,ACE_Existing_Contact__c from Lead where ID = :leadId ];
        //Get all the siblings Dealers  
        List<Account> allChildDealer = [select id,Name from Account where ParentId =: Leadobj.ACE_Dealer__r.ParentId ];
        // Add the id In list 
        List<String> allChildDealerId = new List<string>();
        for(Account acc: allChildDealer){
            allChildDealerId.add(acc.id);
        }
        //Get all existing contact with same mobile No as Lead Mobile No
        List<Contact> ExistingContactList = [Select id,name, AccountId from Contact where MobilePhone = :Leadobj.MobilePhone];
        
        if(ExistingContactList.size() > 0){
            //Get all existing opportunity of existing mobile number
            List<Opportunity> ExistingOPPList = [Select id,name,(select id,Name from OpportunityLineItems )
                                                 from Opportunity where Contact__c = :ExistingContactList[0].Id and Dealer__c NOT IN : allChildDealerId  and IsClosed = false];
            if(ExistingOPPList.size() > 0){
                // Add all the modal name existing in Opportunity 
                List<String> allOpportunityProduct = new List<String>();
                for(OpportunityLineItem lineItem: ExistingOPPList[0].OpportunityLineItems){
                    allOpportunityProduct.add(lineItem.Name);
                }
                // if update the product interst in opportunity 
                List<OpportunityLineItem> listNewProduct = new List<OpportunityLineItem>();
                for(ACE_Product_Interest__c product: Leadobj.Product_Interests__r){
                    if(!allOpportunityProduct.contains(product.Name)){
                        OpportunityLineItem newInter = new  OpportunityLineItem();
                        newInter.Product2Id  = product.Product__c;
                        newInter.OpportunityId = ExistingOPPList[0].id;
                        newInter.Quantity = product.Quantity__c;
                        newInter.UnitPrice = 1000.000; 
                        listNewProduct.add(newInter);
                    }
                }
                if(listNewProduct.size() > 0){
                    try{
                        insert listNewProduct;
                    }
                    catch(Exception e){
                        system.debug(e);
                    }
                }
                else{
                    
                }
            }
            else{
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setaccountId(ExistingContactList[0].AccountId);
                lc.setLeadId(Leadobj.Id);
                lc.setContactId(ExistingContactList[0].Id);
                //get the lead status from the LeadStatus obejct
                LeadStatus convertStatus = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted=true limit 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                try{
                    //convert the lead. Try Catch is used to display the error message
                    Database.LeadConvertResult lcResults = Database.convertLead(lc);
                    system.debug(lcResults);
                }Catch(Exception exp){
                    system.debug(' >>> exp '+exp);
                }
            }
        }
        else{
            Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(Leadobj.Id);
            LeadStatus Leads= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Leadconvert.setConvertedStatus(Leads.MasterLabel);
            //Leadconvert.setDoNotCreateOpportunity(TRUE); //Remove this line if you want to   create an opportunity from Lead Conversion 
            Database.LeadConvertResult Leadconverts = Database.convertLead(Leadconvert);
        }
        
    }
    
    
    
    
    
}