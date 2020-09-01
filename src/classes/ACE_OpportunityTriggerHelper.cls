/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Helper for OpportunityTriggerHandler to update Account Type into Customer and generate Asset
            for Opportunity Product(s).
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Raksha Kala   <raksha.kala@pwc.com>
* @modifiedBy     Raksha Kala   <raksha.kala@pwc.com>
* @maintainedBy   Raksha Kala   <raksha.kala@pwc.com>
* @version        1.0
* @created        2019-10-30
* @modified       2019-11-04
* @systemLayer    Class
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* 2019-11-22      added logic to populate Area_Sales_Manager_Contact_ACE__c field in populateAccessFields(...) method
*
* v1.2            Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* 2019-12-06      created populateCompletedStagesField(...) method to populate Completed_Stages__c field
*
* v1.3            Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* 2019-12-19      changed asset.ContactId from OpportunityContactRole.ContactId to Opportunity.Contact__c
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_OpportunityTriggerHelper {
    public static void updateAccountToCustomer(List<String> closedWonOppAccIds){
         try{
            List<Account> accList = [Select Id, Type 
                                     From Account 
                                     where Id IN: closedWonOppAccIds];
            if(accList.size() > 0){
                for(Account acc : accList){
                    if(acc.Type == ACE_Constants.ACC_TYPE_PROSPECT){
                        acc.Type = ACE_Constants.ACC_TYPE_CUSTOMER;
                    }
                }
               
                
                update accList;
            }
        }catch(Exception e){
            ACE_Exception.LogException(e);
        }
    }
    public static void generateProductAsset(Map<Id, Opportunity> closedWonOppMap){
        List<Asset> assetList = new List<Asset>();
    //    Map<Id, OpportunityContactRole> optyContactMap = new Map<Id, OpportunityContactRole>();
        try{
        
            List<OpportunityLineItem> oliList = [Select Id, Name, OpportunityId, Product2Id, Product2.Name, ProductCode,
                                                 TotalPrice, Quantity 
                                                 From OpportunityLineItem
                                                 Where OpportunityId IN : closedWonOppMap.keySet()];
                                                 
            /* for( OpportunityContactRole ocr : [SELECT OpportunityId,IsPrimary,ContactId 
                                                     FROM OpportunityContactRole
                                                     Where OpportunityId IN : closedWonOppMap.keySet()]){
                 optyContactMap.put(ocr.OpportunityId, ocr);
            } */
                                                     
            if(oliList.size() > 0) {
                for(OpportunityLineItem oli : oliList){
                    Asset asset = new Asset();
                    asset.Name = oli.Product2.Name;
                    asset.AccountId = closedWonOppMap.get(oli.OpportunityId).AccountId;
                    asset.OwnerId =  closedWonOppMap.get(oli.OpportunityId).OwnerId;
                    asset.AssetProvidedById = closedWonOppMap.get(oli.OpportunityId).PartnerAccountId;
                    asset.AssetServicedById = closedWonOppMap.get(oli.OpportunityId).PartnerAccountId;
                //    if(optyContactMap.keySet().size() > 0)
                //    asset.ContactId = optyContactMap.get(oli.OpportunityId).ContactId;
                    asset.ContactId = closedWonOppMap.get(oli.OpportunityId).Contact__c;
                    asset.InstallDate = Date.today();
                    asset.Product2Id = oli.Product2Id;
                    asset.Quantity = oli.Quantity;
                    asset.price = oli.TotalPrice;
                    asset.status = ACE_Constants.ASSET_STATUS_PURCHASED;
                    asset.purchaseDate = Date.today();
                    assetList.add(asset);
                }
                
                if(!assetList.isEmpty()){
                    insert assetList;
                }
            } 
        }catch(Exception e){
            ACE_Exception.LogException(e);
        }
    }
    
    public static void populateAccessFields(List<Opportunity> opportunities) {
        // Added By Krishnan, to insert Price book for the opportunity.

        List<Pricebook2> pb2 = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];
        system.debug(pb2);
        System.debug('opportunities are -- '+opportunities);
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Opportunity opp : opportunities) {
            // Added By Krishnan, to insert Price book for the opportunity.
            if(!pb2.isEmpty()){
                opp.Pricebook2Id  = pb2.get(0).Id;
            }
            if(String.isNotBlank(opp.Area_Sales_Manager_Contact_ACE__c)) {
                contactIds.add(opp.Area_Sales_Manager_Contact_ACE__c);
            }
            if(String.isNotBlank(opp.Dealer_Manager_Contact_ACE__c)) {
                contactIds.add(opp.Dealer_Manager_Contact_ACE__c);
            }
            if(String.isNotBlank(opp.Branch_Manager_Contact_ACE__c)) {
                contactIds.add(opp.Branch_Manager_Contact_ACE__c);
            }
            if(String.isNotBlank(opp.Sales_Manager_Contact_ACE__c)) {
                contactIds.add(opp.Sales_Manager_Contact_ACE__c);
            }
            if(String.isNotBlank(opp.Sales_consultant_Contact_ACE__c)) {
                contactIds.add(opp.Sales_consultant_Contact_ACE__c);
            }
        }
        
        List<Contact> Contacts = [SELECT Id, 
                                    Parent_Contact_ACE__c,
                                    Parent_Contact_ACE__r.Parent_Contact_ACE__c,
                                    Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__c,
                                    Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__c 
                                FROM Contact 
                                WHERE Id IN : contactIds 
                                LIMIT 50000];
        for(Contact cont : Contacts) {
            contactMap.put(cont.Id, cont);
        }
        
        for(Opportunity opp : opportunities) {
            Contact con;
            if( String.isBlank(opp.Area_Sales_Manager_Contact_ACE__c) && 
                String.isBlank(opp.Dealer_Manager_Contact_ACE__c) && 
                String.isBlank(opp.Branch_Manager_Contact_ACE__c) && 
                String.isBlank(opp.Sales_Manager_Contact_ACE__c) && 
                String.isBlank(opp.Sales_consultant_Contact_ACE__c)) {
                
                //opp.addError('At least one related contact required');    
            } else {
                if(String.isBlank(opp.Area_Sales_Manager_Contact_ACE__c) && String.isNotBlank(opp.Dealer_Manager_Contact_ACE__c)){
                    con = contactMap.get(opp.Dealer_Manager_Contact_ACE__c);
                    opp.Area_Sales_Manager_Contact_ACE__c = con.Parent_Contact_ACE__c;
                }
                if((String.isBlank(opp.Area_Sales_Manager_Contact_ACE__c) || String.isBlank(opp.Dealer_Manager_Contact_ACE__c)) && String.isNotBlank(opp.Branch_Manager_Contact_ACE__c)) {
                  con = contactMap.get(opp.Branch_Manager_Contact_ACE__c);
                    opp.Dealer_Manager_Contact_ACE__c = con.Parent_Contact_ACE__c;
                    opp.Area_Sales_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__c;
                }
                if((String.isBlank(opp.Area_Sales_Manager_Contact_ACE__c) || String.isBlank(opp.Dealer_Manager_Contact_ACE__c) || String.isBlank(opp.Branch_Manager_Contact_ACE__c)) && String.isNotBlank(opp.Sales_Manager_Contact_ACE__c)) {
                  con = contactMap.get(opp.Sales_Manager_Contact_ACE__c);
                    opp.Branch_Manager_Contact_ACE__c = con.Parent_Contact_ACE__c;                
                    opp.Dealer_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__c;
                    opp.Area_Sales_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__c;
                }
                if((String.isBlank(opp.Area_Sales_Manager_Contact_ACE__c) || String.isBlank(opp.Dealer_Manager_Contact_ACE__c) || String.isBlank(opp.Branch_Manager_Contact_ACE__c) || String.isBlank(opp.Sales_Manager_Contact_ACE__c)) && String.isNOtBlank(opp.Sales_consultant_Contact_ACE__c)) {
                  con = contactMap.get(opp.Sales_consultant_Contact_ACE__c);
                    opp.Sales_Manager_Contact_ACE__c = con.Parent_Contact_ACE__c;                
                    opp.Branch_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__c;                
                    opp.Dealer_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__c;
                    opp.Area_Sales_Manager_Contact_ACE__c = con.Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__r.Parent_Contact_ACE__c;
                }
            }
        }
    }

    public static void populateCompletedStagesField( List< Opportunity > oppList ) {
        for( Opportunity opp : oppList ) {
            if( String.isBlank( opp.Completed_Stages__c ) ) {
                opp.Completed_Stages__c = opp.StageName;
            } else {
                if( opp.StageName == 'Closed Won' ) {
                    if( opp.Completed_Stages__c.contains( 'Closed Lost' ) ) {
                        opp.Completed_Stages__c = opp.Completed_Stages__c.replace( 'Closed Lost', 'Closed Won' );
                    } 
                } else if( opp.StageName == 'Closed Lost' ) {
                    if( opp.Completed_Stages__c.contains( 'Closed Won' ) ) {
                        opp.Completed_Stages__c = opp.Completed_Stages__c.replace( 'Closed Won', 'Closed Lost' );
                    } 
                } 
                if( !opp.Completed_Stages__c.contains( opp.StageName ) ) {
                    opp.Completed_Stages__c = opp.Completed_Stages__c + ',' + opp.StageName;
                }
            }
        }
    }
}