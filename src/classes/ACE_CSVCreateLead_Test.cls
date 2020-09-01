@isTest
public class ACE_CSVCreateLead_Test {
    
    static testmethod void  ACE_CSVCreateLead_Test() {
        
        Product2 p = new Product2();
        p.Name='Mahindra Thar';
        p.Status__c = 'Active';
        p.Type__c='Vehicle';
        insert p;
        
        Lead l =new Lead();
        l.LastName='SFDC';
        l.Company='SFDC';
        l.MobilePhone = '9874566234';
        l.Vehicle__c = p.Id;
        insert l;
        
        //String jsonInput = 	'[{"fWrapper": [{"FirstName": "SAP","LastName" : "SAP","Mobile" : "9898988989","City" : "Banglore","Vehicle" : "SAP","CallCenter" : "SAP"},{"FirstName": "SAP","LastName" : "Salesforce","Mobile" : "9898988089","City" : "Banglore","Vehicle" : "SAP","CallCenter" : "SAP"}]}]';
        String jsonInput = 	'[{"FirstName": "SAP","LastName" : "SAP","Mobile" : "9898988989","City" : "Banglore","Vehicle" : "Mahindra Thar","CallCenter" : "SAP"},{"FirstName": "SAP","LastName" : "Salesforce","Mobile" : "9898988089","City" : "Banglore","Vehicle" : "SAP","CallCenter" : "SAP"}]';

        ACE_CSVCreateLead.insertData(jsonInput);
}
}