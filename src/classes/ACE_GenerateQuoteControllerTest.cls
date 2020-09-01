@isTest
public class ACE_GenerateQuoteControllerTest {
    public static testMethod void testOpp(){
        Test.startTest();
        //Account Dummy Record
        Account acc = ACE_Test_Util.insertAcc();
        insert acc;
        System.debug('Inserted account id is---'+acc.Id);        
        //Contact Dummy Record
        Contact con = ACE_Test_Util.insertCon();
        con.AccountId =acc.Id;
        insert con;
        //Opportunity Dummy Record
        Id pricebookId = Test.getStandardPricebookId();
        LIST<Opportunity> insertOppList = new LIST<Opportunity>();
        for(Integer i = 0; i < 3; i++){
            Opportunity opp = ACE_Test_Util.insertEnquiry();
            opp.name = 'Test Opp '+i;
            opp.AccountId =acc.Id;
            opp.Contact__c = con.Id; 
            insertOppList.add(opp);
        }         
        insert insertOppList;  
        String strId = String.valueOf(insertOppList[0].Id);     
        String strId1 = String.valueOf(insertOppList[1].Id); 
        //Dummy Product Record
        Product2 prod = ACE_Test_Util.insertProduct();
        prod.Type__c='Accessories';
        insert prod;
        prod.Name = 'Test Product Parent';
        //Dummy Product Record
        Product2 pro = ACE_Test_Util.insertProduct();
        pro.Name = 'Test Product';
        pro.Type__c='Vehicle';
        pro.Parent_Product__c=prod.id;
        insert pro;
        //Dummy Opportunity Line Item        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;  
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice1; 
        LIST<OpportunityLineItem> oliList = new LIST<OpportunityLineItem>();
        for(Integer i = 0; i < 3; i++) {
            OpportunityLineItem oli = ACE_Test_Util.insertOppLine();
            oli.OpportunityId = insertOppList[1].id;
            if(i == 0){                
                oli.PricebookEntryId = customPrice.Id;              
            }
            else{
                oli.PricebookEntryId = customPrice1.Id;
            }
            oliList.add(oli);
        }
        Insert oliList;      
        //Dummy Contract Record
        /* Contract contr = new Contract();
        contr.AccountId = acc.Id;
        contr.Status ='Draft';
        contr.StartDate =Date.valueOf('2018-01-01 00:00:00');
        contr.ContractTerm =4;
        insert contr;
        System.debug('contract id is:'+contr.Id); */
        //Dummy Quote Record
        LIST<Quote> insertQuoteList = new LIST<Quote>();
        for(Integer i = 0; i < 3; i++){
            Quote quote = ACE_Test_Util.insertQuote();
            quote.name = 'Test '+i;
            quote.OpportunityId=insertOppList[0].Id;
            quote.ContactId=con.Id;
            insertQuoteList.add(quote);
        }
        Insert insertQuoteList;
        String strIdQuote = String.valueOf(insertQuoteList[0].Id);
        String proIds = String.valueOf(pro.Id);
        List<String> strList = new List<String>();
        //Method call
        ACE_GenerateQuoteController.getProducts(strId1);
        ACE_GenerateQuoteController.getOppID(strIdQuote);
        ACE_GenerateQuoteController.updateQuote(strIdQuote,insertQuoteList[0],true,strList);   
        ACE_GenerateQuoteController.getOppDetails(strId1);       
        ACE_GenerateQuoteController.insertQuote(strId1, insertQuoteList[0], strList);
        //ACE_GenerateQuoteController.insertQuotePdf(strIdQuote);
        Test.stopTest();        
    }
}