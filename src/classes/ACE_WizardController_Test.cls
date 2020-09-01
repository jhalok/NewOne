@isTest(seeAllData = false)
public class ACE_WizardController_Test {
    @testsetup
    public static void insertCommonData() {
       
        try{ 
        //Account Dummy Record
        Account account = ACE_Test_Util.insertAcc();
        insert account;
        System.assert(account.id != null, 'Account not created');
        //Contact Dummy Record
        Contact contact = ACE_Test_Util.insertCon();
        contact.AccountId = account.id;
        insert contact;
        System.assert(contact.id != null, 'Contact not created');
        //Product Dummy Record
        Product2 prod = ACE_Test_Util.insertProduct();
        prod.Type__c = 'Vehicle';
        prod.color__c = 'WHITE';
        prod.vehicle_Model__c = 'Alturas';
        prod.Variant__c = 'MM152';
        prod.Fuel_Type__c = 'Petrol';
        insert prod;
        System.assert(prod.id != null, 'Product not created');
         //Get Standard Price Book id
        Id pricebookId = Test.getStandardPricebookId();
        System.assert(pricebookId != null, 'PriceBook id is Blank');
        /* Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB; */
        //Price Book Entry Dummy Record
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        PricebookEntry customPrice1 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice1;
        
        //Opportunity Dummy Record
            Opportunity opportunity = ACE_Test_Util.insertEnquiry();
        opportunity.AccountId = account.id;
        opportunity.Contact__c = contact.id;
        opportunity.Pricebook2Id = pricebookId;
        System.debug('opportunity in if is--- ' + opportunity);
        insert opportunity;
        System.assert(opportunity.Id != null, 'opportunity not created');
       /*  //OpportunityLineItem Dummy Record
        OpportunityLineItem oli = ACE_Test_Util.insertOppLine();
        oli.OpportunityId = opportunity.id;
        oli.Product2Id = prod.id;
        oli.PriceBookEntryID=customPrice.id;
        
        insert oli;  */
        //Lead Dummy Record
                
            Lead lead = ACE_Test_Util.insertLead();
            Lead.LastName = 'Testlast';
            lead.Vehicle__c = prod.id;
            /*  lead.Company = 'Test Company';
            Id recordId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Dealer Leads').getRecordTypeId();
            lead.recordTypeId = recordId; */
            insert lead;
            System.assert(lead.Id != null, 'lead not created');
            ACE_Product_Interest__c prodInt = ACE_Test_Util.insertACE_Product_Interest();
            prodInt.Prefered__c = true;
            prodInt.Product__c = prod.id;
            prodInt.Lead__c = lead.id;
            prodInt.Enquiry__c = opportunity.id;
            insert prodInt;
            System.assert(prodInt.Id != null, 'Product Interest not created');
        } catch(DmlException e){
            System.debug(e.getCause());
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            System.debug(e.getDmlMessage(0));
        }
    }
    public static testMethod void allOppModels_Test() {
        try{ 
        Account ac = [select id, name from account limit 1];
        Contact con = [select id, name from Contact limit 1];
        Opportunity opp = [select id, name from Opportunity limit 1];
        Lead lead = [select id, name from Lead limit 1];
        Product2 prod = [select id, name from Product2 limit 1];
        List < ACE_Product_Interest__c > lstProdInt = [select id, name, Product__c,Prefered__c,Enquiry__c,Lead__c from ACE_Product_Interest__c];
        List<ACE_Product_Interest__c> lstProdIntUpdated = new List<ACE_Product_Interest__c>();
        for(Integer i=0;i<1;i++){
            ACE_Product_Interest__c prodInt = new ACE_Product_Interest__c();
            prodInt.Name = 'ProdInt'+i;
            prodInt.Quantity__c	 = 2;
            prodInt.Prefered__c = true;
            prodInt.Product__c = prod.id;
            prodInt.Lead__c = lead.id;
            lstProdIntUpdated.add(prodInt);
            prodInt.Enquiry__c = opp.id;
        }
            insert lstProdIntUpdated;
        
        //prodInt.Enquiry__c = opportunity.id;
        //prodInt.Contact__c=contact.id;
        //prodInt.Dealer_Name__c=account.id;
        
        List < ACE_Product_Interest__c > lstProdIntForUpdated = [select id, name, Product__c,Prefered__c from ACE_Product_Interest__c where Id != :  lstProdInt[0].Id];
        MAP < String, LIST < ACE_WizardController.FieldProperties >> colFldMap;
        colFldMap=ACE_WizardController.getFieldsOnLayout('Lead-Community QE layout');
        System.assert(colFldMap != null, 'Error in getFieldsOnLayout method');
            Product2 prodForLead = ACE_Test_Util.insertProduct();
            prodForLead.Type__c = 'Vehicle';
            prodForLead.color__c = 'LAVA RED';
            prodForLead.vehicle_Model__c = 'Alturas';
            prodForLead.Variant__c = 'S9 140 2WD';
            prodForLead.Fuel_Type__c = 'Petrol';
            insert prodForLead;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodForLead.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        PricebookEntry customPrice1 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prodForLead.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice1;

        Lead leadToInsert = ACE_Test_Util.insertLead();
        leadToInsert.LastName = 'Testlast';
        leadToInsert.Vehicle__c = prodForLead.id;
        leadToInsert.Account__c = ac.id;
        leadToInsert.ACE_Existing_Contact__c = con.id;
        leadToInsert.Enquiry_Source__c = 'NWP';
        leadToInsert.Enquiry_Type__c = 'FLD';
        String str = JSON.serialize(leadToInsert);
        Map < Id, List < Product2 >> mapOfProd = new Map < Id, List < Product2 >> ();
        List < Product2 > lstProd = [select id, name from product2];
        mapOfProd.put(Lead.id, lstProd);
        Lead forGetLeadRecord;
        forGetLeadRecord=ACE_WizardController.getLeadRecord(lead.id);
        System.assert(forGetLeadRecord !=null,'Error in getLeadRecord method');
        List < ACE_Product_Interest__c > forGetExistingProducts;
        forGetExistingProducts = ACE_WizardController.getExistingProducts(lead.id);
        System.assert(forGetExistingProducts !=null,'Error in getExistingProducts method');
        Boolean updateProductInterest;
        updateProductInterest=ACE_WizardController.updateProductInterest(lstProdInt, lstProdIntForUpdated);
        System.assert(forGetExistingProducts != null,'Error in updateProductInterest method');

        ACE_WizardController.insertProductInterest(mapOfProd);
        List < ACE_Product_Interest__c > forInsertProductInterest = [select Id,name from ACE_Product_Interest__c];
        System.debug('at 150 -- '+forInsertProductInterest);
        System.assert(forInsertProductInterest.size() >2,'Error in insertProductInterest method');
        List < ACE_WizardController.RecordsData > forGetProds;
        forGetProds=ACE_WizardController.getProds('Test') ;
        System.assert(forGetProds.size() > 0,'Error in getProds method');    
            
        ACE_WizardController.insertLead(str, true, lstProdInt);
        List<Lead> forInsertLead=[select id,name from Lead];
        System.assert(forInsertLead.size() >1,'Error in insertLead method');
       
       
        } catch(DmlException e){
            System.debug(e.getCause());
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            System.debug(e.getDmlMessage(0));
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}