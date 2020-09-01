public class ACE_CSVCreateLead {
    @AuraEnabled
    public static List<fieldWrapper> insertData(String strfromlex)
    {
        System.debug('=strfromlex='+strfromlex);
        Map<String,String> productMap = new Map<String,String>();
        Map<String,String> recTypeMap = new Map<String,String>();
        List<Product2> prodList = [select Id,Name from Product2];
        Set<String> phoneVehicleConcat = new Set<String>();
        List<RecordType> lstLeadRecordTypes = [SELECT Id, Name FROM RecordType WHERE sObjectType='Lead'];
        List<Lead> leadList = [select Id,MobilePhone,Vehicle__r.Name from Lead];
        for(Lead l:leadList){
            phoneVehicleConcat.add(l.MobilePhone+l.Vehicle__r.Name);
        }

        for(Product2 p:prodList){
            productMap.put(p.Name,p.Id);
        }
        for(RecordType rt:lstLeadRecordTypes){
            recTypeMap.put(rt.Name,rt.Id);
        }
        
        String returnresponse ='';
        List<Lead> leadListtoInsert = new List<Lead>();
        List<fieldWrapper> duplicateRecs = new List<fieldWrapper>();
        system.debug('@@@ strfromlex = ' + strfromlex);
        
        List<fieldWrapper> datalist = (List<fieldWrapper>) JSON.deserialize(strfromlex, List<fieldWrapper>.class);
        //List<fieldWrapper> datalist = (List<fieldWrapper>) JSON.deserialize(strfromlex, fieldWrapper.class);
        system.debug('@@@ datalist = ' + datalist);
        system.debug('@@@ datalistSize = ' + datalist.size());
        String prelaunch = Label.Pre_launch_Vehicle;
        for(fieldWrapper wrapper: datalist)
        {
            Lead l =new  Lead();
            l.FirstName = wrapper.FirstName;
            l.LastName = wrapper.LastName;
            l.MobilePhone = wrapper.Mobile;
            //l.Vehicle__c = productMap.get('\'%' + String.escapeSingleQuotes(wrapper.Vehicle) + '%\'');
            l.city = wrapper.City;
            l.Company = wrapper.CallCenter;
            //if(wrapper.Vehicle == prelaunch && !phoneVehicleConcat.contains(wrapper.Mobile+wrapper.Vehicle)){
            if(prelaunch.contains(wrapper.Vehicle) && !phoneVehicleConcat.contains(wrapper.Mobile+wrapper.Vehicle)){
			l.Vehicle__c = productMap.get(prelaunch);
            l.RecordTypeId = recTypeMap.get('Pre-launch Lead');    
            	leadListtoInsert.add(l);
            }
            if(phoneVehicleConcat.contains(wrapper.Mobile+wrapper.Vehicle)){
                duplicateRecs.add(wrapper);
            }
            system.debug('SIZE +++++++ '+leadListtoInsert);
            system.debug('SIZE +++++++ '+leadListtoInsert.size());
            System.debug('=duplicateRecs='+duplicateRecs);
        }
        
        if(leadListtoInsert.size() > 0)
        {
            try {
                database.insert(leadListtoInsert);
                //  insert AccoutnListtoInsert;
                //returnresponse = 'SUCCESS';
            }
            catch(Exception ex)
            {
                //returnresponse = 'ERROR';
            }
        }
        return duplicateRecs;
    }
    
    public class fieldWrapper {
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String Mobile;
        @AuraEnabled
        public String City;
        @AuraEnabled
        Public String Vehicle;
        @AuraEnabled
        Public String CallCenter;
        
    } 
    @AuraEnabled
    public static String createLeads(String leadJson){
        LIST<ACE_ServiceUtil.leadsPush> newLeads = (List<ACE_ServiceUtil.leadsPush>)JSON.deserialize(leadJson,List<ACE_ServiceUtil.leadsPush>.class);
    	String leadResult = ACE_InsertIntLeadNProductController.insertLeads(newLeads);
        return leadResult;
    }
}