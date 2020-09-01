public class ACE_CaseTypeChangeUiController {
    
    @AuraEnabled
    public static String recordTypesOnCase(String objectName, Id recId){
        List<Case> caseList =[select id,recordtypeId from case where id =:recId];
        String selectedRecordTypeId = '';
        if(!caseList.isEmpty())
            selectedRecordTypeId = caseList[0].recordtypeId;
        
        List<RecordType> recordTypeList = [select Id,Name from RecordType where sObjectType=:objectName];
        List<OptionType>  optionList = new List<OptionType>();
        for(RecordType recObj : recordTypeList){
            optionList.add(new OptionType(recObj.Name,recObj.Id));
        }
        RecrodTypeWrapper recordTypeWrapObj = new RecrodTypeWrapper(selectedRecordTypeId,optionList);
        return JSON.serialize(recordTypeWrapObj);
    }
    
    public class RecrodTypeWrapper{
        public String selectedRecordId;
        public List<OptionType> recordTypeList;
        public RecrodTypeWrapper(String selectedRecordId,List<OptionType> recordTypeList){
            this.selectedRecordId = selectedRecordId;
            this.recordTypeList = recordTypeList;
        }
        
    }
    
    public Class OptionType{
        public String label;
        public String value;
        public OptionType(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
    public static void updateRecord(String rcdId, String recordTypeId){
        System.debug('Apex Called-----');
        try {
            case obj = new case(Id = rcdId, RecordTypeId = recordTypeId);
            update obj;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}