/**
 * @File Name          : ACE_BookingPushAPICallout.cls
 * @Description        : 
 * @Author             : Ruchit Gupta<ruchit.r.gupta.pwc.com>
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 1/16/2020, 3:06:36 PM
 * @Modification Log   : 
 * Ver       Date          Author                                   Modification
 * 1.0    12/14/2019       Ruchit Gupta<ruchit.r.gupta.pwc.com>     Initial Version
**/
global with sharing class ACE_BookingPushAPICallout {
    
    /* This method is calling from quick action lightning button to Push Booking Data into DMS system using mulesoft */
    @AuraEnabled
    public static WrapperSuccessFailure getBookingDetails(Id BookingId){
        ACE_Utility.CreateBooking  ace_utilitycreateBooking =  new ACE_Utility.CreateBooking();      
        //ACE_MulesoftIntegrationBookingAPIDetail__c ace_mulesoft = ACE_MulesoftIntegrationBookingAPIDetail__c.getOrgDefaults(); 
        String BookingEndPointURL;
        String BookingType;        
        String APIMethodType = System.Label.APIMethodType;                 
        WrapperSuccessFailure wrapperToast = new WrapperSuccessFailure();
      
        List<ACE_Booking__c> newBookinglist;
        try{            
                  newBookinglist = [SELECT Id, Order_Date__c, Opportunity__r.Enquiry_Number__c, Opportunity__r.DMS_Enquiry_Number__c, Sales_Type__c,Price_Type__c,
                                    Customer_Id__c, Booking_Amount__c, Finance_Arranged_By__c , Committed_Delivery_Date__c, Customer_Expected_Delivery_Date__c, 
                                    Discounts_Total__c, DMS_Booking_Number__c  
                                    FROM ACE_Booking__c Where Id=: BookingId Limit 1];
                      
            if(newBookinglist!=null && !newBookinglist.isEmpty()){

               /* To assign Endpoint URL When Booking is Created */
                if(newBookinglist[0].DMS_Booking_Number__c == null){
                    BookingEndPointURL = System.Label.CreateBookingEndPointURL;                    
                    BookingType = System.Label.Booking_Created;
                    
                }
                /* To assign Endpoint URL When Booking is Updated */
                else{
                    BookingEndPointURL = System.Label.UpdateBookingEndPointURL;  
                    BookingType = System.Label.Booking_Updated;
                    
                }
                /* To assign Endpoint URL When Booking is Cancelled 
                else{
                    EnquiryEndPointURL = System.Label.CancelBookingEndPointURL;
                    Booking_Cancelled  
                }*/

               for(ACE_Booking__c objbooking: newBookinglist){
                    if(objbooking.Order_Date__c == null) {
                          throw new MyException('Order Date : Please fill the Required Field');
                    } 
                    String strOrderdate = (objbooking.Order_Date__c).format();
                    ace_utilitycreateBooking.orderDate = strOrderdate; 
                    ace_utilitycreateBooking.parentGroup = 'MV001';
                    ace_utilitycreateBooking.location = 'MV01';
                    ace_utilitycreateBooking.finYear = '2020';
                    if(objbooking.DMS_Booking_Number__c == null){
                        ace_utilitycreateBooking.orderId = '';
                        ace_utilitycreateBooking.insUpdInd = 'I';
                        
                    }else{
                        ace_utilitycreateBooking.orderId = objbooking.DMS_Booking_Number__c;
                        ace_utilitycreateBooking.insUpdInd = 'U';
                    }                    
                    ace_utilitycreateBooking.primModelUpdInd = 'I';
                    ace_utilitycreateBooking.modelCode = 'KUV1MM385902698';
                    //ace_utilitycreateBooking.insUpdInd = 'I';
                    ace_utilitycreateBooking.comtmntInsUpdInd = 'I';
                    ace_utilitycreateBooking.tentvDelivery = '1';
                    if(objbooking.Booking_Amount__c == null) {
                          throw new MyException('Booking Amount : Please fill the Required Field');
                    } 
                    ace_utilitycreateBooking.orderAmount = String.valueOf(objbooking.Booking_Amount__c);
                    ace_utilitycreateBooking.applnNumber = '';
                    ace_utilitycreateBooking.exchClaimInsUpInd = '';
                    ace_utilitycreateBooking.loyalityClaimInsUpInd = '';
                    ace_utilitycreateBooking.refStats = 'N';
                    ace_utilitycreateBooking.refCustCd = '';
                    ace_utilitycreateBooking.refChassNum = '';
                    ace_utilitycreateBooking.mitraId = '';
                    ace_utilitycreateBooking.edcmDeliveryDt = '';
                    ace_utilitycreateBooking.quotationFlag = '';
                    ace_utilitycreateBooking.orderStats = 'O';
                    ace_utilitycreateBooking.leadId = objbooking.Opportunity__r.DMS_Enquiry_Number__c;
                    if(objbooking.Committed_Delivery_Date__c == null) {
                          throw new MyException('Promised Date : Please fill the Required Field');
                    }
                    String strPromisedate = (objbooking.Committed_Delivery_Date__c).format();
                    ace_utilitycreateBooking.promisedDate = strPromisedate;
                    if(objbooking.Customer_Expected_Delivery_Date__c == null) {
                          throw new MyException('Expected Delivery Date : Please fill the Required Field');
                    }
                    String strExpecteddate = (objbooking.Customer_Expected_Delivery_Date__c).format();
                    ace_utilitycreateBooking.expectedDate = strExpecteddate;
                    //ace_utilitycreateBooking.saleType = objbooking.Sales_Type__c;
                    ace_utilitycreateBooking.saleType = 'WSGST';
                    //ace_utilitycreateBooking.priceType = objbooking.Price_Type__c;
                    ace_utilitycreateBooking.priceType = 'I/C';
                    ace_utilitycreateBooking.salesManCd = '13EK2782';
                    ace_utilitycreateBooking.delvryInd = '';
                    ace_utilitycreateBooking.delvryIndDesc = '';
                    ace_utilitycreateBooking.delvryPlace = 'SHOW';
                    ace_utilitycreateBooking.spclReqst = '';
                    ace_utilitycreateBooking.regPlace = '';
                    //ace_utilitycreateBooking.fincBy = objbooking.Finance_Arranged_By__c;
                    ace_utilitycreateBooking.fincBy = 'DSA';
                    ace_utilitycreateBooking.dsa = 'CHAND';
                    ace_utilitycreateBooking.custCd = 'C200000127';
                    //ace_utilitycreateBooking.discountAmnt = objbooking.Discounts_Total__c;
                    ace_utilitycreateBooking.discountAmnt = '';
                    ace_utilitycreateBooking.sellingPrice = '415573.49';
                    ace_utilitycreateBooking.totChargAmnt = '116360.56';
                    ace_utilitycreateBooking.totOtfAmnt = '531934.05';
                    ace_utilitycreateBooking.finrCd = '';
                    ace_utilitycreateBooking.finrBranch = '';
                    ace_utilitycreateBooking.fileNum = '';
                    ace_utilitycreateBooking.loanAmnt = '';
                    ace_utilitycreateBooking.emi = '';
                    ace_utilitycreateBooking.aadharNum = '';
                    ace_utilitycreateBooking.drvngLicNum = '';
                    ace_utilitycreateBooking.doRecvd = '';
                    ace_utilitycreateBooking.doNum = '';
                    ace_utilitycreateBooking.doDate = '';
                               
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.OrderComtmntDtlslist> OrderComtmntDtlslist = new List<ACE_Utility.OrderComtmntDtlslist>();
                    ACE_Utility.OrderComtmntDtlslist objOrderComtmntDtl = new ACE_Utility.OrderComtmntDtlslist();
                    objOrderComtmntDtl.comtmntSrl = '';
                    objOrderComtmntDtl.comtmntDesc = '';
                    objOrderComtmntDtl.comtmntAmnt = '';
                    objOrderComtmntDtl.insUpdInd = '';

                    OrderComtmntDtlslist.add(objOrderComtmntDtl);
                    ace_utilitycreateBooking.orderComtmntDtls.addAll(OrderComtmntDtlslist);  
                    
                    
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.ChargeDtlslist> ChargeDtlslist = new List<ACE_Utility.ChargeDtlslist>();
                    ACE_Utility.ChargeDtlslist objChargeDtls = new ACE_Utility.ChargeDtlslist();
                    objChargeDtls.chargType = 'CGST';
                    objChargeDtls.chargeCd = 'CGS28';
                    objChargeDtls.chargDesc = 'Centralv GST 14%';
                    objChargeDtls.calcType = 'P';
                    objChargeDtls.calcTypeDesc = 'Percentage';
                    objChargeDtls.chargeRate = '14.0';
                    objChargeDtls.chargeAmnt = '58180.28';
                    objChargeDtls.cmChargeSk = '178346';
                    objChargeDtls.primaryTaxInd = 'Y';
                    objChargeDtls.orderSrl = '1';
                    objChargeDtls.taxChargeInd = 'Y'; 

                    ChargeDtlslist.add(objChargeDtls);
                    ace_utilitycreateBooking.chargeDtls.addAll(ChargeDtlslist);  
                     
                   
                    //Fields not Exist, Values passed as Empty String
                    List<ACE_Utility.OtfLoyalityDtlslist> OtfLoyalityDtlslist = new List<ACE_Utility.OtfLoyalityDtlslist>();
                    ACE_Utility.OtfLoyalityDtlslist objOtfLoyalityDtls = new ACE_Utility.OtfLoyalityDtlslist();
                    objOtfLoyalityDtls.vehMake = '';
                    objOtfLoyalityDtls.vehModl = '';
                    objOtfLoyalityDtls.vehMakeDesc = '';
                    objOtfLoyalityDtls.vehModDesc = '';
                    objOtfLoyalityDtls.regNum = '';
                    objOtfLoyalityDtls.regYr = '';
                    objOtfLoyalityDtls.regYrDesc = '';
                    objOtfLoyalityDtls.regMonth = '';
                    objOtfLoyalityDtls.regMonthDesc = '';
                    objOtfLoyalityDtls.schemeID = '';
                    objOtfLoyalityDtls.schemeDesc = '';
                    objOtfLoyalityDtls.vehUsage = '';
                    objOtfLoyalityDtls.usgDesc = ''; 
                    objOtfLoyalityDtls.loyalityBonus = '';
                    objOtfLoyalityDtls.incntvSk = '';
                    objOtfLoyalityDtls.reltCustCd = '';
                    objOtfLoyalityDtls.reltCustName = '';
                    objOtfLoyalityDtls.reltDob = '';
                    objOtfLoyalityDtls.reltnCd = '';
                    objOtfLoyalityDtls.reltnDesc = '';
                    objOtfLoyalityDtls.varntCd = '';
                    objOtfLoyalityDtls.variantDesc = '';
                    objOtfLoyalityDtls.oldChassNum = '';

                    OtfLoyalityDtlslist.add(objOtfLoyalityDtls);
                    ace_utilitycreateBooking.otfLoyalityDtls.addAll(OtfLoyalityDtlslist); 

                    
                    //Fields not Exist, Values passed as Hardcoded
                    List<ACE_Utility.LeadQuotationDetailslist> LeadQuotationDetailslist = new List<ACE_Utility.LeadQuotationDetailslist>();
                    ACE_Utility.LeadQuotationDetailslist objLeadQuotationDetailslist = new ACE_Utility.LeadQuotationDetailslist();
                    objLeadQuotationDetailslist.parentGroup = '';
                    objLeadQuotationDetailslist.location = '';
                    objLeadQuotationDetailslist.chargDesc = '';
                    objLeadQuotationDetailslist.leadId = '';
                    objLeadQuotationDetailslist.quotNum = '';
                    objLeadQuotationDetailslist.quotDate = '';
                    objLeadQuotationDetailslist.custName = '';
                    objLeadQuotationDetailslist.quotationFile = '';
                    objLeadQuotationDetailslist.psleadHdrSk = '';
                    objLeadQuotationDetailslist.psInvHdrSk = '';
                    
                    LeadQuotationDetailslist.add(objLeadQuotationDetailslist);
                    ace_utilitycreateBooking.leadQuotationDetails.addAll(LeadQuotationDetailslist); 


                    //Fields not Exist, Values passed as Hardcoded
                    List<ACE_Utility.ExchangeVehicleDtlslist> ExchangeVehicleDtlslist = new List<ACE_Utility.ExchangeVehicleDtlslist>();
                    ACE_Utility.ExchangeVehicleDtlslist objExchangeVehicleDtlslist = new ACE_Utility.ExchangeVehicleDtlslist();
                    objExchangeVehicleDtlslist.vehMake = '';
                    objExchangeVehicleDtlslist.vehModl = '';
                    objExchangeVehicleDtlslist.vehMakeDesc = '';
                    objExchangeVehicleDtlslist.vehModDesc = '';
                    objExchangeVehicleDtlslist.regNum = '';
                    objExchangeVehicleDtlslist.regYr = '';
                    objExchangeVehicleDtlslist.regMonth = '';
                    objExchangeVehicleDtlslist.regMonthDesc = '';
                    objExchangeVehicleDtlslist.schemeID = '';
                    objExchangeVehicleDtlslist.schemeDesc = '';
                    objExchangeVehicleDtlslist.vehUsage = '';
                    objExchangeVehicleDtlslist.usgDesc = '';
                    objExchangeVehicleDtlslist.km = '';
                    objExchangeVehicleDtlslist.fincInd = '';
                    objExchangeVehicleDtlslist.fincName = '';
                    objExchangeVehicleDtlslist.custPrice = '';
                    objExchangeVehicleDtlslist.procPric  = '';
                    objExchangeVehicleDtlslist.schemAmt = '';
                    objExchangeVehicleDtlslist.incntvSk = '';
                    objExchangeVehicleDtlslist.reltCustCd = '';
                    objExchangeVehicleDtlslist.reltCustName = '';
                    objExchangeVehicleDtlslist.reltDob = '';
                    objExchangeVehicleDtlslist.reltnCd = '';
                    objExchangeVehicleDtlslist.reltnDesc = '';
                    objExchangeVehicleDtlslist.varntCd = '';
                    objExchangeVehicleDtlslist.variantDesc = '';
                    objExchangeVehicleDtlslist.oldChassNum = '';
                    objExchangeVehicleDtlslist.evlnId = '';
                    
                    ExchangeVehicleDtlslist.add(objExchangeVehicleDtlslist);
                    ace_utilitycreateBooking.exchangeVehicleDtls.addAll(ExchangeVehicleDtlslist); 
                   
                    
               }
            }
            
                System.debug('ace_utility:' + ace_utilitycreateBooking);
                String serializedData = JSON.serialize(ace_utilitycreateBooking);
                System.debug('serializedData:' + serializedData);               
            
                //ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest(ace_mulesoft.EndpointURL__c.trim(),'',ace_mulesoft.MethodType__c.trim(),serializedData,'');
                ACE_APICalloutUtil.ApiResponse response = ACE_APICalloutUtil.sendRequest(BookingEndPointURL.trim(),'',APIMethodType.trim(),serializedData,'');
 
                System.debug('Jsonresponse:' + response); 
                WrapperReturnResponse wrapperinstance = (WrapperReturnResponse )JSON.deserialize(response.jsonBody, WrapperReturnResponse.class);
                   if(response.status == 'OK'|| response.status == 'Created' && response.statusCode == 200 || response.statusCode == 201 && wrapperinstance.orderId != null){                         
                        /* The success message is modified when booking was Created/Updated/Cancelled and pushed to DMS */
                        if(wrapperinstance.orderId != null && BookingType.trim() == System.Label.Booking_Created)
                        {
                            wrapperToast.message = wrapperinstance.orderId +'-'+ System.Label.Create_Booking_Message;
                        }
                        if(wrapperinstance.orderId != null && BookingType.trim() == System.Label.Booking_Updated){
                            
                            wrapperToast.message = wrapperinstance.orderId +'-'+ System.Label.Update_Booking_Message;
                        }                       
                        //wrapperToast.message = wrapperinstance.orderId +'-'+ wrapperinstance.message;
                        wrapperToast.statusCode = response.statusCode;
                        wrapperToast.status = response.status;
                        wrapperToast.isSuccessful = wrapperinstance.IsSuccessful;                        
                           try{
                               If(wrapperinstance.IsSuccessful == '1'){
                                    newBookinglist[0].DMS_Booking_Number__c  = wrapperinstance.orderId; //Assigned Booking Number                            
                                    update newBookinglist;
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
        public String orderId;
    }
    
    /* This wrapper class is using for check response Error result from DMS */
    public class WrapperResponseError {
        public String IsSuccessful;	
        public String message;	
        public String messagecode;
        public String orderId;
      
    }
}