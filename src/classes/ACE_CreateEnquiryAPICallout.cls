/**
 * @File Name          : ACE_CreateEnquiryAPICallout.cls
 * @Description        : 
 * @Author             : Ruchit Gupta<ruchit.r.gupta.pwc.com>
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/15/2020, 12:32:43 PM
 * @Modification Log   : 
 * Ver       Date          Author                                   Modification
 * 1.0    11/18/2019       Ruchit Gupta<ruchit.r.gupta.pwc.com>     Initial Version
**/
global with sharing class ACE_CreateEnquiryAPICallout {
    
    /* This method is calling from quick action lightning button to Push Enquiry Data into DMS system using mulesoft */
    @AuraEnabled
    public static WrapperSuccessFailure getEnquiryDetail(Id opportunityId){
        ACE_Utility.CreateEnquiry  ace_utility =  new ACE_Utility.CreateEnquiry();      
        //ACE_MulesoftIntegrationAPIDetail__c ace_mulesoft = ACE_MulesoftIntegrationAPIDetail__c.getOrgDefaults();  
        String EnquiryEndPointURL;
        String APIMethodType = System.Label.APIMethodType;    
        Opportunity objOppt = new Opportunity();
        WrapperSuccessFailure wrapperToast = new WrapperSuccessFailure();
      
        List<Opportunity> newopplist;
        try{            
               
            newopplist = [SELECT Id, Enquiry_Date__c, Enquiry_Type__c, Likely_Purchase__c, Enquiry_Source__c, Usage_Area__c, Refer_By_Name__c, Next_Action__c, Enquiry_Number__c, Existing_Customer__c, DMS_Enquiry_Number__c,
                            Contact__r.Name, Contact__r.MobilePhone, Contact__r.Email, Contact__r.Salutation, Contact__r.Phone,
                            Contact__r.Customer_Type__c, Contact__r.Age__c, Contact__r.Communicate_To__c, Contact__r.Wedding_Anniversary_Date__c,
                            Contact__r.MailingStreet, Contact__r.MailingPostalCode, Contact__r.Gender__c, Contact__r.Number_Of_Car_Owned__c,
                            Contact__r.Family_Size__c, Contact__r.First_Time_User__c   
                          FROM Opportunity Where Id=: opportunityId Limit 1];

           
            System.debug('newopplist' + newopplist);
            
            if(newopplist!=null && !newopplist.isEmpty()){
                /* To assign Endpoint URL When Enquiry is Created */
                if(newopplist[0].DMS_Enquiry_Number__c == null){
                    EnquiryEndPointURL = System.Label.CreateEnquiryEndPointURL;              

                }
                /* To assign Endpoint URL When Enquiry is Updated */
                else{
                    EnquiryEndPointURL = System.Label.UpdateEnquiryEndPointURL;  
                }
               for(Opportunity Opp: newopplist){
                    /* To assign Lead Id When Enquiry is Updated */
                    if(Opp.DMS_Enquiry_Number__c != null){
                        ace_utility.LeadId = Opp.DMS_Enquiry_Number__c;
                    }
                    if(Opp.Enquiry_Date__c == null) {
                          throw new MyException('Enquiry Date : Please fill the Required Field');
                    } 
                    DateTime dt = DateTime.valueOf(Opp.Enquiry_Date__c);
                    String strenquirydate = dt.format('dd/MM/yyyy'); //Parsing the date into string                   
                    ace_utility.enquiryDate = strenquirydate;
                    if(Opp.Enquiry_Type__c == null) {
                          throw new MyException('Enquiry Type : Please fill the Required Field');
                    }
                    ace_utility.enquiryType = Opp.Enquiry_Type__c;
                    //ace_utility.enquiryType = 'MRC';
                    if(Opp.Enquiry_Source__c == null) {
                          throw new MyException('Enquiry Source : Please fill the Required Field');
                    }
                    ace_utility.enquirySource = Opp.Enquiry_Source__c;
                    //ace_utility.enquirySource = 'CAB';
                    if(Opp.Usage_Area__c == null) {
                          throw new MyException('Usage Area : Please fill the Required Field');
                    }
                    ace_utility.prospusageArea = Opp.Usage_Area__c;
                    if(Opp.Refer_By_Name__c == null){
                      ace_utility.refByName = '';
                    }else{
                      ace_utility.refByName = Opp.Refer_By_Name__c;
                    }
                    if(Opp.Next_Action__c == null) {
                          throw new MyException('Next Followup Action : Please fill the Required Field');
                    }                  
                    ace_utility.nextAction = Opp.Next_Action__c; 
                    //ace_utility.nextAction = 'T';                     												
                    ace_utility.purpose = 'T';
                    ace_utility.sfEnquiryId = Opp.Id;                                   
                    ace_utility.webEnquiryNo = Opp.Enquiry_Number__c; 
 					//Fields not Exist, Values passed as Empty                   
                    ace_utility.weblink = '';
                    ace_utility.pinCodePermanent = '';
                    ace_utility.distCodePermanent= '';
                    
                    ace_utility.enquiryFollowUpdate = strenquirydate;
                   
                    ace_utility.custmrOtherRemrks = '';                  
                    ace_utility.parentCode = 'MV001';
                    ace_utility.exchange = 'N';                   
                    ace_utility.occupation = '';                  
                    ace_utility.distCodeResidence = 'D10260';
                    if(Opp.Likely_Purchase__c == null) {
                          throw new MyException('Likely Purchase : Please fill the Required Field');
                    } 
                    ace_utility.likelyPurchase = Opp.Likely_Purchase__c;
                    //ace_utility.likelyPurchase = 'GT45';
                    ace_utility.location = 'MV01';
                    ace_utility.segment = '';                   
                    ace_utility.usge = '';
                    
                   
                    ace_utility.kmsTravelDaily = '';
                    ace_utility.webSitecd = '';
                    ace_utility.roParntgrop = '';
                    ace_utility.roId = ''; 
                    ace_utility.wapCampcd = '';
                    ace_utility.dgtlCampid = '';
                    ace_utility.numberofPreviousowners = '';
                   
                    ace_utility.vehicleType = '';
                    ace_utility.finance = '';
                    ace_utility.downPayment = '';
                    ace_utility.valueAddedProduct = '';
                    ace_utility.VAPOthers = '';
                    ace_utility.corpType = '';
                    ace_utility.corpCode = '';
                    ace_utility.corpCompName = '';
                    ace_utility.onlineBookingRef = '';
                    ace_utility.refByTelNo = '';
                    ace_utility.officeAddress2 = '';
                    ace_utility.custID = '';
                    ace_utility.ProspType = '';
                    ace_utility.LoadCarriedKg = '';
                    
                    ace_utility.KmsPerDay = '';
                    ace_utility.custMiddleName = '';
                    ace_utility.custSurName = '';
                    ace_utility.resiTehCode = '';
                    ace_utility.resiAddress2 = '';
                    ace_utility.resiAddress3 = '';
                    ace_utility.officePincode = '';
                    ace_utility.officeDistcode = '';
                    ace_utility.officeAddress1 = '';
                    ace_utility.officeTehCode = '';
                    ace_utility.officeAddress3 = '';
                    ace_utility.permanentAddress2 = '';
                    ace_utility.permanentAddress3 = '';
                    ace_utility.permanentTehCode = '';
                    ace_utility.prospusageArea = '';
                    ace_utility.Application = '';
                    ace_utility.campaign = '';
                    ace_utility.suveranceCustLink = '';
                    ace_utility.crmRemarks = '';
                    ace_utility.mitraId = '';
                    ace_utility.customerDelitPnts = '';
                    ace_utility.customerConcernPoints = '';
                    ace_utility.refByName = '';
                   
                    //ace_utility.visitorId = 'TEST1235';                     
                    /* Contact object related Fields added */
                    if(Opp.Contact__r.MobilePhone == null) {
                          throw new MyException('Contact Mobile No: Please fill the Required Field');
                    }
                    ace_utility.contactMobileNo = Opp.Contact__r.MobilePhone;
                    if(Opp.Contact__r.Email == null) {
                          //throw new MyException('Contact Email: Please fill the Required Field');
                          ace_utility.email = '';
                    }
                    ace_utility.email = Opp.Contact__r.Email;
                    if(Opp.Contact__r.Name == null) {
                          throw new MyException('Contact Name: Please fill the Required Field');
                    }
                    ace_utility.custFirstName = Opp.Contact__r.Name;
                    if(Opp.Contact__r.Salutation.toUppercase()== null){
                        ace_utility.titleCode = '';
                    }else{
                        String strtitleCode = Opp.Contact__r.Salutation.toUppercase();
                        ace_utility.titleCode = strtitleCode.removeEnd('.');
                    }
                    //ace_utility.titleCode = 'DR';
                    if(Opp.Contact__r.Customer_Type__c == null) {
                          throw new MyException('Contact Customer Type: Please fill the Required Field');
                    }
                    ace_utility.customerType = Opp.Contact__r.Customer_Type__c;
                    //ace_utility.customerType = 'IND';
                    if(Opp.Contact__r.Age__c == null) {
                          throw new MyException('Contact Age: Please fill the Required Field');
                    }
                    if(Opp.Contact__r.Age__c == '< 30 Yrs'){
                      ace_utility.age =  Integer.valueOf(System.Label.Age_30_Yrs); //value=7
                    }
                    if(Opp.Contact__r.Age__c == '30-45 Yrs'){
                      ace_utility.age =  Integer.valueOf(System.Label.Age30_45_Yrs); //value=8
                    }
                    if(Opp.Contact__r.Age__c == '> 45 Yrs'){
                      ace_utility.age =  Integer.valueOf(System.Label.Age_45_Yrs); //value=9
                    }
                    //String intage = String.valueOf(Opp.Contact__r.Age__c);
                    //ace_utility.age = Integer.valueOf(intage);
                    //ace_utility.age = 9;
                     if(Opp.Contact__r.Communicate_To__c == null) {
                          throw new MyException('Contact Communicate To: Please fill the Required Field');
                    }
                    ace_utility.communicateTo = Opp.Contact__r.Communicate_To__c;
                    //ace_utility.communicateTo = 'RES';
                    if(Opp.Contact__r.Wedding_Anniversary_Date__c == null){
                        ace_utility.anniversaryDate = '';
                    }
                    else{
                        Date dt1 = Date.valueOf(Opp.Contact__r.Wedding_Anniversary_Date__c);
                        String stranniversarydate = dt.format('dd/MM/yyyy'); //Parsing the date into string   
                        ace_utility.anniversaryDate = stranniversarydate;
                    }
                    if(Opp.Contact__r.Phone == null){
                        ace_utility.AlternateMobileNo = ''; 
                    }else{
                        ace_utility.AlternateMobileNo = Opp.Contact__r.Phone;  
                    }
                    
                    if(Opp.Contact__r.MailingPostalCode == null) {
                          throw new MyException('Contact Zip/Postal Code: Please fill the Required Field');
                    }
                    ace_utility.pinCodeResidence = Opp.Contact__r.MailingPostalCode;
                    if(Opp.Contact__r.MailingStreet == null) {
                          throw new MyException('Contact Street: Please fill the Required Field');
                    }
                    ace_utility.resiAddress1 =  String.valueOf(Opp.Contact__r.MailingStreet);
                    //ace_utility.resiAddress1 = 'Test';
                    if(Opp.Contact__r.Gender__c == null){
                        ace_utility.gender = '';
                    }else{
                        ace_utility.gender = Opp.Contact__r.Gender__c; 
                    }
                    //ace_utility.gender = 'M';                          
                    //ace_utility.permanentAddress1 = String.valueOf(Opp.Contact__r.MailingAddress);
                    ace_utility.permanentAddress1 = '';
                    if(Opp.Contact__r.Number_Of_Car_Owned__c == null){
                        ace_utility.NumbrOfCarsOwned = '';
                    }else{
                        ace_utility.NumbrOfCarsOwned = String.valueOf(Opp.Contact__r.Number_Of_Car_Owned__c);
                    }
                    if(String.valueOf(Opp.Contact__r.Family_Size__c) == null){
                       ace_utility.famlySize = '';
                    }else{
                        ace_utility.famlySize = String.valueOf(Opp.Contact__r.Family_Size__c);
                    }
                    ace_utility.whoDrives = '';
                    ace_utility.annualIncome = '';  
                    ace_utility.kmsDriven = '';
                    ace_utility.NoOfPassengers = '';
                    if(Opp.Contact__r.First_Time_User__c = true){
                            ace_utility.firstTimeUser =  'Y';  
                    }else{
                            ace_utility.firstTimeUser =  'N';
                    }
                    
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.EnquiredModelsList> enquiredModelslist = new List<ACE_Utility.EnquiredModelsList>();
                    ACE_Utility.EnquiredModelsList enquireModel = new ACE_Utility.EnquiredModelsList();
                    enquireModel.preferredModel = 'Y';
                    enquireModel.modelCode = 'JETOMM5021091082';
                    enquiredModelslist.add(enquireModel);
                    ace_utility.EnquiredModels.addAll(enquiredModelslist);  
                    //ace_utility.EnquiredModelList = enquiredModelslist;  
                    
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.ConsiderationSetList> considerationSetlist = new List<ACE_Utility.ConsiderationSetList>();
                    ACE_Utility.ConsiderationSetList considerationSet = new ACE_Utility.ConsiderationSetList();
                    considerationSet.makeConsidered = 'FM';
                    considerationSet.modelConsidered = 'MD';
                    considerationSetlist.add(considerationSet);
                    ace_utility.ConsiderationSet.addAll(considerationSetlist);  
                    //ace_utility.ConsiderationSetList= considerationSetlist;  
                   
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.CurrentOwnedDetailsList> currentOwnedDetailslist = new List<ACE_Utility.CurrentOwnedDetailsList>();
                    ACE_Utility.CurrentOwnedDetailsList currentOwnedDetails = new ACE_Utility.CurrentOwnedDetailsList();
                    currentOwnedDetails.currentOwnedMake = '';
                    currentOwnedDetails.currentOwnedModel = '';
                    currentOwnedDetails.currentOwnedQuantity = '';
                    currentOwnedDetailslist.add(currentOwnedDetails);
                    ace_utility.CurrentOwnedDetails.addAll(currentOwnedDetailslist); 
                    //ace_utility.CurrentOwnedDetailsList = currentOwnedDetailslist; 
                    
                    //Fields not Exist, Values passed as Hardcoded
                    List<ACE_Utility.ExchangeDetailsList> exchangeDetailslist = new List<ACE_Utility.ExchangeDetailsList>();
                    ACE_Utility.ExchangeDetailsList exchangeDetails = new ACE_Utility.ExchangeDetailsList();
                    exchangeDetails.exchangeModel = '';
                    exchangeDetails.exchangeVehRegNo = '';
                    exchangeDetails.exchangeVehPurchaseYear = '';
                    exchangeDetails.exchangeVehKms = '';
                    exchangeDetails.usage = '';
                    exchangeDetails.exchangeMake = '';
                    exchangeDetailslist.add(exchangeDetails);
                    ace_utility.ExchangeDetails.addAll(exchangeDetailslist); 
                    //ace_utility.ExchangeDetailsList = exchangeDetailslist;
                    
               }
            }            
            
           
                System.debug('ace_utility:' + ace_utility);
                String serializedData = JSON.serialize(ace_utility);
                System.debug('serializedData:' + serializedData);               
            
                //ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest(ace_mulesoft.EndpointURL__c.trim(),'',ace_mulesoft.MethodType__c.trim(),serializedData,'');
                ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest(EnquiryEndPointURL.trim(),'',APIMethodType.trim(),serializedData,'');
 
                System.debug('Jsonresponse:' + response); 
                WrapperReturnResponse wrapperinstance = (WrapperReturnResponse )JSON.deserialize(response.jsonBody, WrapperReturnResponse.class);
                   if(response.status == 'Created' && response.statusCode == 201 && wrapperinstance.EnquiryNumber != null){                         
                        wrapperToast.message = wrapperinstance.EnquiryNumber +'-'+ wrapperinstance.message;
                        wrapperToast.statusCode = response.statusCode;
                        wrapperToast.status = response.status;
                        wrapperToast.isSuccessful = wrapperinstance.IsSuccessful;                        
                           try{
                               If(wrapperinstance.IsSuccessful == '1'){
                                    newopplist[0].DMS_Enquiry_Number__c  = wrapperinstance.EnquiryNumber; //Assigned Enquiry Number                            
                                    update newopplist;
                               }
                           }Catch(Exception ex){
                               throw new aurahandledexception('An unexpected error has occurred: ' + ex.getMessage());
                           }
                        //return wrapperToast;    
                    } 
                        else{
                               WrapperResponseError wrappererrorinstance = (WrapperResponseError )JSON.deserialize(response.jsonBody, WrapperResponseError.class);
                                if(wrappererrorinstance.IsSuccessful != '1')
                                {
                                    //wrapperToast.message = response.jsonBody;
                                    wrapperToast.message = wrappererrorinstance.message;
                                    System.debug('Vmessage' + wrapperToast.message);
                                    wrapperToast.statusCode = response.statusCode;
                                    wrapperToast.status = response.status;
                                     
                                }
                                //return wrapperToast; 
                            }
                return wrapperToast;    
            }
            /*catch(Exception ex)
            {
                throw new aurahandledexception('An unexpected error has occurred: ' + ex.getMessage());
            }*/
            catch(Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0]);
              } else {
                     throw new AuraHandledException(err.getMessage());
                    }
            }
        
    }
	
    /* This wrapper class is using for check response success and failure from mulesoft */
    public class WrapperSuccessFailure {
        @auraEnabled public String message;
        @auraEnabled public Integer statusCode;
        @auraEnabled public String status;
        @auraEnabled public String isSuccessful;
    }
    
    /* This wrapper class is using for check response result from DMS */
    public class WrapperReturnResponse {
        public String IsSuccessful;	
        public String message;	
        public String messagecode;
        public String EnquiryNumber;
    }
    
    /* This wrapper class is using for check response Error result from DMS */
    public class WrapperResponseError {
        public String IsSuccessful;	
        public String message;	
        public String messagecode;
        public String EnquiryNumber;
      
    }
}