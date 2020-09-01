/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * Summary : Handler for LeadTrigger to perform Lead conversion operations.
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Prerna Purwar   <prerna.purwar@pwc.com>
 * @modifiedBy     Prerna Purwar   <prerna.purwar@pwc.com>
 * @modifiedy      Krishnan Mishra <krishnan.mishra@in.pwc.com>
 * @maintainedBy   Prerna Purwar   <prerna.purwar@pwc.com>
 * @version        1.0
 * @created        2019-10-25
 * @modified       2019-11-07
 * @systemLayer    Trigger
 * @see            ????
 * @see            ????
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @changes
 * vX.X            firstname.lastname@pwc.com
 * YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
 *                 each line should be indented till left aligned with the previous description text.

 * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
 */
public class ACE_LeadTriggerHandler {
    public static Boolean runOnce = true;

    public static void updateProductInterests(Map < Id, Id > contactLeadMap) {

        Map < Id, Id > productIntMap = new Map < Id, Id > ();

        for (ACE_Product_Interest__c pi: [Select Id, Lead__c from ACE_Product_Interest__c where Lead__c IN: contactLeadMap.keySet()]) {

        }

    }

    // On lead conversion
    public static void onLeadConversion(LIST < Lead > convertedLeads) {
        runOnce = false;

        SET < ID > leadId = new SET < ID > ();
        SET < ID > accId = new SET < ID > ();
        SET < ID > oppId = new SET < ID > ();
        SET < ID > conId = new SET < ID > ();

        //<lead id,Opportunity id>
        MAP < String, String > leadIdOpp = new MAP < String, String > ();
        MAP < String, String > leadIdAcc = new MAP < String, String > ();
        MAP < String, String > leadIdCon = new MAP < String, String > ();
        // map to get trigger trigger.new index with lead id. This is used to throw error on that trigger.new
        MAP < String, Integer > leadIdCountMap = new MAP < String, Integer > ();
        Integer count = 0;
        SET < ID > productIdSet = new SET < ID > ();

        for (Lead lead: convertedLeads) {
            System.debug('lead ' + lead);
            leadIdOpp.put(lead.id, lead.convertedOpportunityId);
            leadIdAcc.put(lead.id, lead.convertedAccountId);
            leadIdCon.put(lead.id, lead.ConvertedContactId);
            leadId.add(lead.id);

            accId.add(lead.convertedAccountId);
            oppId.add(lead.convertedOpportunityId);
            conId.add(lead.ConvertedContactId);

            leadIdCountMap.put(lead.id, count);
            count++;
            System.debug('oppId is ' + lead.convertedOpportunityId);
        }
        MAP < ID, Account > accIdMap = new MAP < ID, Account > ([SELECT ID, Type, Name FROM ACCOUNT WHERE ID IN: accId]);
        MAP < ID, Opportunity > oppIdMap = new MAP < ID, Opportunity > ([SELECT ID FROM Opportunity WHERE ID IN: oppId]);
        MAP < ID, Contact > conIdMap = new MAP < ID, Contact > ([SELECT ID FROM Contact WHERE ID IN: conId]);


        LIST < Opportunity > oppsToUpdate = new LIST < Opportunity > ();
        System.debug('oppIdMap is ' + oppIdMap);
        LIST < Lead > leads = [SELECT ID, lastName, createdDate, ACE_Dealer__c, Enquiry_Source__c, Referred_By__r.name,
                                (SELECT ID, Interest_Category__c, Lead__c, Product__c FROM Product_Interests__r ORDER BY Prefered__c DESC)
                                FROM LEAD WHERE ID IN: leadId
                              ];
        LIST < OpportunityLineItem > insertOppLine = new LIST < OpportunityLineItem > ();
        LIST < ACCOUNT > accUpdate = new LIST < ACCOUNT > ();

        LIST < OPPORTUNITY > oppToUpdate = new LIST < OPPORTUNITY > ();
        //OppId,ACE_Product_Interest__c.
        MAP < String, LIST < ACE_Product_Interest__c >> oppIdPrdInterest = new MAP < String, LIST < ACE_Product_Interest__c >> ();

        Id dealerAccRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer_Account').getRecordTypeId();
        LIST < ACE_Product_Interest__c > leadProds;
        for (Lead ld: leads) {
            Opportunity opp = oppIdMap.get(leadIdOpp.get(ld.id));
            // Added by ppurwar
            opp.Contact__c = conIdMap.get(leadIdCon.get(ld.id)).Id;
            opp.Enquiry_Date__c = ld.createdDate;
            opp.Refer_By_Name__c = String.valueOf(ld.Referred_By__r.name);
            oppToUpdate.add(opp);


            if (!(ld.Product_Interests__r.size() > 0)) {
                convertedLeads[(leadIdCountMap.get(ld.id))].addError('Please add Products to the lead first !');
                continue;
            }
            //productIdSet.add(ld.Product_Interests__r [0].Product__c);
            leadProds = ld.Product_Interests__r;
            for (ACE_Product_Interest__c prd: leadProds) {
                productIdSet.add(prd.Product__c);
            }
            oppIdPrdInterest.put(opp.id, leadProds);


            Account acc = accIdMap.get(leadIdAcc.get(ld.id));
            acc.name = ld.lastName;
            acc.RecordTypeId = dealerAccRT_Id;
            accUpdate.add(acc);
            /* 
            # Requirement was changed, now all products will be added to OLI.
            OpportunityLineItem oppLi = new OpportunityLineItem();
            oppLi.Product2Id = ld.Product_Interests__r [0].Product__c;
            oppLi.OpportunityId = opp.id;
            //For testing only.
            oppLi.TotalPrice    = 1500000;
            // This will be included later once fields are created.
            oppLi.Quantity = 1;
            
            //oppLi.TotalPrice = ld.Product_Interests__r [0].Total_Price__c;
            insertOppLine.add(oppLi);

            

            Contact con = conIdMap.get(leadIdCon.get(ld.id));

            if(ld.Product_Interests__r.size() > 1){
                List<ACE_Product_Interest__c> prdList = new LIST<ACE_Product_Interest__c>();
                prdList = ld.Product_Interests__r;
                prdList.remove(0);
                ld.Product_Interests__r.remove(0);
                insertOppProductIntrst(JSON.serialize(prdList), opp.Id, con.id);
            } */
        }

        /* if(insertOppLine.size() > 0) {
            System.debug('insertOppLine is '+insertOppLine);
            Insert insertOppLine;
        } */
        if (oppIdPrdInterest.size() > 0) {
            insertOppProductIntrst(JSON.serialize(oppIdPrdInterest), productIdSet);
        }
        if (accUpdate.size() > 0) {
            Update accUpdate;
            System.debug('updated acc id is ' + accUpdate);
        }
        if (oppToUpdate.size() > 0) {
            Update oppToUpdate;
        }


    }

    // To insert  Opportunity's.
    @future
    public static void insertOppProductIntrst(String oppPrdInterest, SET < ID > prod2Id) {
        MAP < String, LIST < ACE_Product_Interest__c >> oppIdPrdInterest = (Map < String, LIST < ACE_Product_Interest__c >> ) JSON.deserialize(oppPrdInterest, Map < String, LIST < ACE_Product_Interest__c >> .class);

        LIST < PriceBookEntry > productPrices = [SELECT ID, Name, UnitPrice, Product2Id,
                                                    Product2.Type__c, Product2.Name
                                                    FROM PriceBookEntry
                                                    WHERE Product2Id IN: prod2Id
                                                ];
        LIST < OpportunityLineItem > oppLineToInsert = new LIST < OpportunityLineItem > ();
        MAP < String, PriceBookEntry > prodIdPbe = new MAP < String, PriceBookEntry > ();
        for (PriceBookEntry pbe: productPrices) {
            prodIdPbe.put(pbe.Product2Id, pbe);
        }
        Set < Id > testProdIds = new Set < Id > (); //For Testing Purpose

        for (String oppId: oppIdPrdInterest.keySet()) {
            LIST < ACE_Product_Interest__c > prodIntrstLi = (LIST < ACE_Product_Interest__c > ) oppIdPrdInterest.get(oppId);
            try {
                for (ACE_Product_Interest__c prd: prodIntrstLi) {
                    OpportunityLineItem oLi = new OpportunityLineItem();
                    oLi.Product2Id = prd.Product__c;
                    oLi.TotalPrice = prodIdPbe.get(prd.Product__c).UnitPrice;
                    oLi.OpportunityId = oppId;
                    oLi.Quantity = 1;
                    if (Test.isRunningTest()) {
                        oli.PriceBookEntryId = prodIdPbe.GET(prd.Product__c).Id;
                        testProdIds.add(prd.Product__c);
                    }
                    oppLineToInsert.add(oLi);
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        /* LIST<ACE_Product_Interest__c> productIntrstList = (List<ACE_Product_Interest__c>)Json.deserialize(products,List<ACE_Product_Interest__c>.class);
        LIST<ACE_Product_Interest__c> updateProdcutsList = new LIST<ACE_Product_Interest__c>();
        for(ACE_Product_Interest__c prods : productIntrstList){
            prods.Enquiry__c = oppId;
            prods.Contact__c = conId;
            updateProdcutsList.add(prods);
        }
        Update updateProdcutsList; */
        if (oppLineToInsert.size() > 0) {
            Insert oppLineToInsert;
        }
    }


    public static void callpushleadsBatch(List < Lead > leadList) {
       // ACE_pushLeadsIntoDialerBatch leadpush = new ACE_pushLeadsIntoDialerBatch(leadList);
       // Database.executeBatch(leadpush, 50);
    }
}