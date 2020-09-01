public class ACE_UploadLeadsCSV {
    
    public String campingnName{get;set;}
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public List<String> csvRowLines{get;set;}
    public List<Lead> leadsToUpload{get;set;}
    public String errCsvLines{get;set;}
    
    private Map<String,String> fieldLbl_ApiMap;//only required if csv-header is same as field-label
    private Map<String,Schema.DisplayType> fieldApi_DatatypeMap;
    private Map<String,Boolean> fieldApi_IsEditableMap;
    private Map<String,String> csvHdrLbl_FieldApiMap;
    private List<String> csvHdrOrderedList;
    
    private static final Schema.DisplayType DATATYPE_DATE=Schema.DisplayType.DATE;
    private static final Schema.DisplayType DATATYPE_DATETIME=Schema.DisplayType.DATETIME;
    private static final Schema.DisplayType DATATYPE_BOOLEAN=Schema.DisplayType.BOOLEAN;
    private static final Schema.DisplayType DATATYPE_EMAIL=Schema.DisplayType.EMAIL;
    private static final Schema.DisplayType DATATYPE_PHONE=Schema.DisplayType.PHONE;
    private static final Schema.DisplayType DATATYPE_URL=Schema.DisplayType.URL;
    
    public ACE_UploadLeadsCSV(){
        csvRowLines = new List<String>();
        leadsToUpload = New List<Lead>(); 
        createObjFieldLblVsApiMap('Lead');
        createCsvReadHdrVsFieldApiMap();
    }
    
    public String importCSVFile(){
        try{
            csvAsString = csvFileBody.toString();
            csvRowLines = csvAsString.split('\n');
            errCsvLines='';
            Integer errLineCnt=0;
            
            Lead leadRecord;
            List<String> csvRecordData;

            for(Integer rowIdx=0;rowIdx<csvRowLines.size();rowIdx++){
                if(rowIdx==0){
                    errCsvLines+= csvRowLines.get(rowIdx)+'\n';
                }
                else{
                    leadRecord = new Lead() ;
                    csvRecordData = csvRowLines.get(rowIdx).split(',');
                    if(csvHdrOrderedList!=null && !csvHdrOrderedList.isEmpty()){
                        for(Integer colIdx=0;colIdx<csvHdrOrderedList.size();colIdx++){
                            String hdrLblStr=csvHdrOrderedList.get(colIdx);
                            String dataStr=csvRecordData.get(colIdx);
                            leadRecord=populateLeadFieldsValue(leadRecord,hdrLblStr,dataStr);
                        }
                    }
                    //checkValidations
                    if(isValidLeadData(leadRecord)){
                        leadsToUpload.add(leadRecord);
                    }
                    else{
                        //add to invalidDataFailedToUploadList
                        if(errLineCnt==0){
                            errCsvLines+= csvRowLines.get(rowIdx);
                        }else{
                            errCsvLines+= '\n'+ csvRowLines.get(rowIdx);
                        }
                        errLineCnt++;
                    }
                }
            }
            if(leadsToUpload.size()>0){
                //List<Database.UpsertResult> results= Database.upsert(leadsToUpload,Lead.Phone,false);
            }
            if(errLineCnt>0){
                return errCsvLines;
            }
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }
        return null;
    }
    
    /*--------------------------------------------------------*/
    //Support Methods.....Move these in Utility Class...
    
    private void createCsvReadHdrVsFieldApiMap(){
        csvHdrLbl_FieldApiMap=new Map<String,String>();
        //Search mapping config table based on campingnName
        //populate csvHdrLbl_FieldApiMap with Key=CsvHeader,Value=FieldApi
        //Also populate ordered list of csv header in csvHdrOrderedList
    }

    //common for all objects
    private void createObjFieldLblVsApiMap(String objectType){
        fieldLbl_ApiMap= new Map<String,String>();
        fieldApi_DatatypeMap= new Map<String,Schema.DisplayType>();
        fieldApi_IsEditableMap= new Map<String,Boolean>();
        
        Map<String,Schema.SObjectType> schemaMap= Schema.getGlobalDescribe();
        Schema.SObjectType objSchema= schemaMap.get(objectType);
        Map<String,Schema.SObjectField> allFieldsMap= objSchema.getDescribe().fields.getMap();
        
        Map<String,String>fieldApi_LabelMap= new Map<String,String>();
        
        for(String fName:allFieldsMap.keySet()){
            fieldApi_LabelMap.put(fName/*API*/,allFieldsMap.get(fName).getDescribe().getLabel()/*Label*/);
            fieldApi_DatatypeMap.put(fName.toUpperCase(), allFieldsMap.get(fName).getDescribe().getType()/*DataType*/);
            fieldApi_IsEditableMap.put(fName.toUpperCase(), allFieldsMap.get(fName).getDescribe().isUpdateable()/*IsEditable*/);
        }
        
        for(Schema.SObjectField f:allFieldsMap.values()){
            fieldLbl_ApiMap.put(f.getDescribe().getLabel().toUpperCase(), f.getDescribe().getName());
        }
    }
    
    private Lead populateLeadFieldsValue(Lead leadRecord, String hdrLblStr, String dataStr){
        if(leadRecord!=null && String.isNotBlank(hdrLblStr) && String.isNotBlank(dataStr)){
            if(csvHdrLbl_FieldApiMap.containsKey(hdrLblStr)){
                String fApiName=csvHdrLbl_FieldApiMap.get(hdrLblStr);
                if(fieldApi_IsEditableMap.containsKey(fApiName) && fieldApi_DatatypeMap.containsKey(fApiName)){
                    Boolean isEditable=fieldApi_IsEditableMap.get(fApiName);
                    Schema.DisplayType fDataTyp=fieldApi_DatatypeMap.get(fApiName);
                    if(isEditable==true){
                        if(fDataTyp==DATATYPE_DATE){
                            //pasre string to date
                            //leadRecord.put(fApiName,Date.newInstance(year, month, day));
                        }
                        else if(fDataTyp==DATATYPE_DATETIME){
                            //parse string to datetime
                            //leadRecord.put(fApiName,Datetime.valueOf(strDatetime));
                        }
                        else if(fDataTyp==DATATYPE_BOOLEAN){
                            //parse string to boolean and put
                        }
                        else if(fDataTyp==DATATYPE_EMAIL){
                            //parse string to email and put
                        }
                        else if(fDataTyp==DATATYPE_PHONE){
                            //parse string to phone and put
                        }
                        else if(fDataTyp==DATATYPE_URL){
                            //parse string to else and put
                        }
                        else{
                            //directly put the string for text types
                        }
                    }
                }
            }
        }
        return leadRecord;
    }
    
    private Boolean isValidLeadData(Lead leadRecord){
        //check all field validations here
        //return false if invalid anywhere
        return true;
    }
}