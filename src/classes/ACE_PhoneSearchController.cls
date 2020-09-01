/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Summary : Controller to search for phone/mob numbers.
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @modifiedBy     Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @modifiedy      Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @maintainedBy   Prerna Purwar   <prerna.purwar@pwc.com>
 * @version        1.0
 * @created        2020-01-01
 * @modified       2020-01-13
 * @systemLayer    Aura Definition bundle
 * @see            ????
 * @see            ????
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @changes
 * vX.X            firstname.lastname@pwc.com
 * YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
 *                 each line should be indented till left aligned with the previous description text.

 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public with sharing class ACE_PhoneSearchController {
    @AuraEnabled
    public static String phoneRecord(String Numb){
        USER curUser  = [SELECT ID, contact.AccountId,contact.Account.ParentId FROM USER WHERE ID =:UserInfo.getUserId()];
        String leadPartnerAccountId = curUser.contact.AccountId;
        SET<ID> leadPartnerAccountIdSet = new SET<ID>();
        if(curUser.contact.Account.ParentId != null){
            String parentAcc = curUser.contact.Account.ParentId;
            MAP<ID, ACCOUNT> accChild = new MAP<ID, ACCOUNT>([SELECT ID, Name FROM Account WHERE ParentId =: parentAcc]);
            leadPartnerAccountIdSet = accChild.keySet();
        }
        else{
            leadPartnerAccountIdSet.add(leadPartnerAccountId);
        }
        // Record Id to navigate to.
        String recId = '';
        // Using SOSL was giving unexpected results while testing 
        /* String searchQuery = 'FIND \'' + Numb + '\' IN ALL FIELDS RETURNING Opportunity(Contact__r.Phone,StageName,Dealer__c), Lead (Id,Name,MobilePhone,Phone)'; 
        List<List <sObject>> searchList = search.query(searchQuery);
        List<searchVals> recList = new LIST<searchVals>();
        //If Enquiry is found.
        if(searchList[0].size() > 0){
            //searchVals vals = new searchVals(searchList[0][0].id,String.valueOf(searchList[0][0].get('Name')),String.valueOf(searchList[0][0].get('Phone')),'Contact');
            LIST<Opportunity> oppMatch = (LIST<Opportunity>)searchList[0];
            for(Opportunity opp : oppMatch){
                // Check for stage of enquiry
                if(opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_WON && opp.StageName != ACE_Constants.OPTY_STAGE_CLOSED_Lost){
                    //Check for dealer
                    if(opp.Dealer__c == leadPartnerAccountId){
                        // Check for OLI

                    }
                }
            }
        }
        // If Lead is found
        else if(searchList[1].size() > 0){ 
            LIST<Lead> oppMatch = (LIST<Lead>)searchList[1];
        }
        
        return recList; */
                    String oppClosedWon         =   ACE_Constants.OPTY_STAGE_CLOSED_WON;
                    String oppClosedLost        =   ACE_Constants.OPTY_STAGE_CLOSED_Lost;
                    LIST<Contact> conMatch      =   [SELECT ID,Name,Phone,MobilePhone,
                                                        (SELECT Id, Dealer__c, StageName 
                                                        FROM Enquiries__r
                                                        WHERE (StageName !=: oppClosedWon OR StageName !=: oppClosedLost) AND Dealer__c IN : leadPartnerAccountIdSet)
                                                        FROM Contact
                                                        WHERE Phone =: numb OR MobilePhone =: numb];
        
        LIST<Opportunity> oppToInsert           =   new LIST<Opportunity>();     
        LIST<Lead> leadToInsert                 =   new LIST<Lead>();
        // If contact is matched.  
        System.debug('conMathc is '+conMatch);                         
        if(conMatch.size() > 0){
            // If Opportunity is in open stage and dealer matches. If any of these doesn't match then insert a new enquiry for the contact
            if(conMatch[0].Enquiries__r.size() > 0){
                System.debug('Enquiry found');
                LIST<Opportunity> oppMatch      =   [SELECT Id, Dealer__c, StageName,
                                                        (SELECT ID, Product2Id FROM OpportunityLineItems)
                                                        FROM Opportunity
                                                        WHERE ID IN :conMatch[0].Enquiries__r];
                recId = oppMatch[0].Id;                                            
                // Check for the OLI
                /* LIST<OpportunityLineItem> oLi   =   oppMatch[0].OpportunityLineItems;
                if(oLi.size() > 0){

                } */

            }
            else{
                // Navigate to the contact's detail page.
                System.debug('Contact found without Enquiry');
                recId = conMatch[0].Id;
            }
            //Insert a new enquiry
            /* else{
                Opportunity oppIns              = new Opportunity();
                oppIns.Contact__c               = conMatch[0].Id;
                oppToInsert.add(oppIns);
             }*/

        }
        else{
            System.debug('checking for leads ');
            String recType = ACE_Constants.leadDealerRecType;
            Id dealerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recType).getRecordTypeId();
            LIST<Lead> leadMatch    =   [SELECT ID,Phone,MobilePhone,ACE_Dealer__c,
                                            (SELECT ID,Product__c FROM Product_Interests__r)
                                            FROM Lead
                                            WHERE (Phone=: numb OR MobilePhone=: numb) 
                                            AND ACE_Dealer__c IN:leadPartnerAccountIdSet
                                            AND recordTypeId =: dealerRecTypeId];
            if(leadMatch.size() > 0){
                recId = leadMatch[0].Id;
                System.debug('Lead id is '+recId);
                // Check for Product Interest.
            }
            // Insert new Lead
            /* else{
                Lead ld             =   new Lead();
                
            } */
        }
        return recId;
    }    
    public Class searchVals{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String Phone;     
       
        @AuraEnabled
        public String Type; 
        public searchVals(String id, String Name, String Phone, String Type){
            this.id = id;
            this.name = name;
            this.Phone = Phone;
            //this.AditionalPhone = AditionalPhone;
            this.Type = Type;
        }
    }
}