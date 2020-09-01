/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary :Utility class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @modifiedy      Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @maintainedBy   Krishnan Mishra   <krishnan.mishra@in.pwc.com>
* @version        1.0
* @created        2019-11-08
* @modified       Prerna Purwar	<prerna.purwar@pwc.com>
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @modified       Shailendra Tiwari	<shailendra.tiwari.tpr@pwc.com>
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* v1.0            mrinal.v.tpr@in.pwc.com
* 2019-12-30      added getSobjectAPI_Name(...) method to get object API name from record id.
*	
* v1.0            mrinal.v.tpr@in.pwc.com
* 2020-01-10      Updated the FollowUp, TestDrive, Booking and Feedback Wrapper for using salesforce Id instead of external id.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

//*****************************************Sales*************************************************************
global class ACE_Utility {
    public static Opportunity  getOpportunity(String name, String dealer, String stage, Date closeDate, Date enquiryDate, String owner){
        Opportunity opp = new Opportunity();
        opp.name = name;
        if(dealer != 'null'){
            System.debug('aceUtil 30');
            opp.Dealer__c = dealer;
        }
        opp.StageName = stage;
        opp.CloseDate = closeDate;
        opp.Enquiry_Date__c = enquiryDate;
        opp.OwnerId = owner;
        System.debug('ops is '+opp);
        return opp;
    }
    public static Task getTask(String ownerId, String whatId, String whoId, String status){
        
        Task tsk = new Task();
        System.debug('whoId id is '+whatId);
        tsk.OwnerId = ID.valueof(ownerId);
        
        if(whatId != ''){
            tsk.whatId = whatId;
        }
        if(whoId != ''){
            tsk.whoId  = whoid;
        }
        
        tsk.status  = status;
        
        return tsk;
        
    }
    public static String getSobjectAPI_Name( Id recordId ){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        return sObjName;
    }
    
    //*******************************************************Service**************************************************
    global class ServiceResponse{
        public String responseCode;
        public String responseMsg;
        public String sfRecordId;
        public String otherImpObjId;
    }
    
    global class SFServiceResponse{
        public String successMsg{get;set;}
        public String dmlStatus{get;set;}
        public String sfRecordId{get;set;}
        public String errorMsg{get;set;}
        public String[] errorFields{get;set;}
        
    }
    
    global class SfUserInfo {
        public String fName{get;set;}
        public String lName{get;set;}
        public String email{get;set;}
        public String usrName{get;set;}
        public String nickName{get;set;}
        public String emilEncodingKey{get;set;}
        public String alias{get;set;}
        public String timeZoneSidKey{get;set;}
        public String localeSidKey{get;set;}
        public String languageLocaleKey{get;set;}
        public String profileName{get;set;}
        public String roleName{get;set;}
        public String sfUserId{get;set;}
        public String dialerUserId{get;set;}
        public String queueName{get;set;}
        public String isActive{get;set;}
    }
    
    /*Create Enquiry API Fields Start */
    public class CreateEnquiry{ 
        public String LeadId; 
        public String nextAction;
        public String purpose;
        public String sfEnquiryId;
        public String firstTimeUser;
        public String enquiryType;
        public Integer age;
        public String webEnquiryNo;
        public String email;
        public String weblink;
        public String pinCodePermanent;
        public String distCodePermanent;
        public String resiAddress1;
        public String enquiryFollowUpdate;
        public String pinCodeResidence;
        public String custmrOtherRemrks;
        public String enquiryDate;
        public String parentCode;
        public String contactMobileNo;
        public String exchange;
        public String titleCode;
        public String custFirstName;
        public String occupation;
        public String permanentAddress1;
        public String customerType;
        public String distCodeResidence;
        public String likelyPurchase;
        public String communicateTo;
        public String location;
        public String segment;
        public String gender;
        public String usge;
        public String famlySize;
        public String whoDrives;
        public String kmsTravelDaily;
        public String webSitecd;
        public String roParntgrop;
        public String roId;
        public String wapCampcd;
        public String dgtlCampid;
        public String numberofPreviousowners;
        public String kmsDriven;
        public String vehicleType;
        public String finance;
        public String downPayment;
        public String valueAddedProduct;
        public String VAPOthers;
        public String corpType;
        public String corpCode;
        public String corpCompName;
        public String onlineBookingRef;
        public String enquirySource;
        public String refByTelNo;
        public String officeAddress2;
        public String custID;
        public String ProspType;
        public String LoadCarriedKg;
        public String NoOfPassengers;
        public String KmsPerDay;
        public String custMiddleName;
        public String custSurName;
        public String resiTehCode;
        public String resiAddress2;
        public String resiAddress3;
        public String officePincode;
        public String officeDistcode;
        public String officeAddress1;
        public String officeTehCode;
        public String officeAddress3;
        public String permanentAddress2;
        public String permanentAddress3;
        public String permanentTehCode;
        public String prospusageArea;
        public String Application;
        public String campaign;
        public String suveranceCustLink;
        public String crmRemarks;
        public String mitraId;
        public String customerDelitPnts;
        public String customerConcernPoints;
        public String refByName;
        public String annualIncome;
        public String anniversaryDate;
        public String NumbrOfCarsOwned;
        public String AlternateMobileNo;
        public String visitorId;
        public List<EnquiredModelsList> EnquiredModels = new List<EnquiredModelsList>(); 
        public List<ConsiderationSetList> ConsiderationSet = new List<ConsiderationSetList>();
        public List<CurrentOwnedDetailsList> CurrentOwnedDetails = new List<CurrentOwnedDetailsList>();
        public List<ExchangeDetailsList> ExchangeDetails = new List<ExchangeDetailsList>();
    }
    public class CurrentOwnedDetailsList {
        public String currentOwnedMake;
        public String currentOwnedModel;
        public String currentOwnedQuantity;
    }
    
    public class ExchangeDetailsList {
        public String exchangeModel;
        public String exchangeMake;
        public String exchangeVehRegNo;
        public String exchangeVehPurchaseYear;
        public String exchangeVehKms;
        public String usage;
    }
    
    public class ConsiderationSetList {
        public String makeConsidered;
        public String modelConsidered;
    }
    
    public class EnquiredModelsList {
        public String preferredModel;
        public String modelCode;
    } 
    /*Create Enquiry API Fields End */
    
    /* Create Booking API Fields Start */
    public class CreateBooking {
        public String parentGroup;
        public String location;
        public String finYear;
        public String orderId;
        public String primModelUpdInd;
        public String modelCode;
        public String insUpdInd;
        public String comtmntInsUpdInd;
        public String tentvDelivery;
        public String orderAmount;
        public String applnNumber;
        public String exchClaimInsUpInd;
        public String loyalityClaimInsUpInd;
        public String refStats;
        public String refCustCd;
        public String refChassNum;
        public String mitraId;
        public String edcmDeliveryDt;
        public String quotationFlag;
        public String orderDate;
        public String orderStats;
        public String leadId;
        public String promisedDate;
        public String expectedDate;
        public String saleType;
        public String priceType;
        public String salesManCd;
        public String delvryInd;
        public String delvryIndDesc;
        public String delvryPlace;
        public String spclReqst;
        public String regPlace;
        public String fincBy;
        public String dsa;
        public String custCd;
        public String discountAmnt;
        public String sellingPrice;
        public String totChargAmnt;
        public String totOtfAmnt;
        public String finrCd;
        public String finrBranch;
        public String fileNum;
        public String loanAmnt;
        public String emi;
        public String aadharNum;
        public String drvngLicNum;
        public String doRecvd;
        public String doNum;
        public String doDate;
        public List<OrderComtmntDtlslist> orderComtmntDtls = new List<OrderComtmntDtlslist>();
        public List<ChargeDtlslist> chargeDtls = new List<ChargeDtlslist>();
        public List<OtfLoyalityDtlslist> otfLoyalityDtls = new List<OtfLoyalityDtlslist>();
        public List<LeadQuotationDetailslist> leadQuotationDetails = new List<LeadQuotationDetailslist>();
        public List<ExchangeVehicleDtlslist> exchangeVehicleDtls = new List<ExchangeVehicleDtlslist>();
    }
    
    public class ExchangeVehicleDtlslist {
        public String vehMake;
        public String vehModl;
        public String vehMakeDesc;
        public String vehModDesc;
        public String regNum;
        public String regYr;
        public String regMonth;
        public String regMonthDesc;
        public String schemeID;
        public String schemeDesc;
        public String vehUsage;
        public String usgDesc;
        public String km;
        public String fincInd;
        public String fincName;
        public String custPrice;
        public String procPric;
        public String schemAmt;
        public String incntvSk;
        public String reltCustCd;
        public String reltCustName;
        public String reltDob;
        public String reltnCd;
        public String reltnDesc;
        public String varntCd;
        public String variantDesc;
        public String oldChassNum;
        public String evlnId;
    }
    
    public class ChargeDtlslist {
        public String chargType;
        public String chargeCd;
        public String chargDesc;
        public String calcType;
        public String calcTypeDesc;
        public String chargeRate;
        public String chargeAmnt;
        public String cmChargeSk;
        public String primaryTaxInd;
        public String orderSrl;
        public String taxChargeInd;
    }
    
    public class OtfLoyalityDtlslist {
        public String vehMake;
        public String vehModl;
        public String vehMakeDesc;
        public String vehModDesc;
        public String regNum;
        public String regYr;
        public String regYrDesc;
        public String regMonth;
        public String regMonthDesc;
        public String schemeID;
        public String schemeDesc;
        public String vehUsage;
        public String usgDesc;
        public String loyalityBonus;
        public String incntvSk;
        public String reltCustCd;
        public String reltCustName;
        public String reltDob;
        public String reltnCd;
        public String reltnDesc;
        public String varntCd;
        public String variantDesc;
        public String oldChassNum;
    }
    
    public class LeadQuotationDetailslist {
        public String parentGroup;
        public String location;
        public String chargDesc;
        public String leadId;
        public String quotNum;
        public String quotDate;
        public String custName;
        public String quotationFile;
        public String psleadHdrSk;
        public String psInvHdrSk;
    }
    
    public class OrderComtmntDtlslist {
        public String comtmntSrl;
        public String comtmntDesc;
        public String comtmntAmnt;
        public String insUpdInd;
    }
    /* Create Booking API Fields End */
    
    public class Feedback {
        //    public String externalId;
        public String id;
        public String aceFeedbackby;
        public Integer feedbackNumber;
        public Integer overallRating;
        public String repairOrder;
        public String testDrive; 
        public String comments;
    }
    
    public class FeedbackResponse {
        public String status;
        public String errorMessage;
        public Feedback record;
    }
    
    public class TestDrive {
        public String enquiryId;
        //	public String model;
        public String ownerId;
        public String place;
        public String rating;
        public String releaseNo;
        public String stage;
        public DateTime startDateTime;
        public DateTime endDateTime;
        public String testDriveBy;
        //	public String externalId;
        public String id;
    }
    
    public class Booking{
        public Integer amount;
        public Decimal amountReceived;
        public Date    amountReceivedDate;
        public Decimal bookingAmount;
        public Date    bookingDate;
        //	public String  bookingName;
        public String  chequeDD_PO_Details;
        public Integer consumerScheme;
        public Integer corporateBonus;
        public Date    customerExpectedDeliveryDate;
        public String  customerId;
        public Integer dealerDiscountSpecialDiscount;
        public String  deliveryLocation;
        public Decimal downPayment;
        public Date    drawnDate;
        public String  drawnOn;
        public Integer exchangeBonus;
        public Decimal expectedEMI;
        public String  financeArrangedBy;
        public String  financeCompany;
        public Integer insurance;
        public String  insuranceBy;
        public String  insuranceCompany;
        public String  insuranceTypes;
        public Decimal interestRates;
        public Decimal loanAmount;
        public Integer loyaltyBonus;
        //	public String  mobileAppId;
        public String  id;
        public String  modeOfPayment;
        public String  enquiryId;
        public Date    orderDate;
        public String  orderID;
        public String  otfNo;
        public String  ownerId;
        public String  priceType;
        public Date    committedDeliveryDate;
        public String  reasonsForCancellation;
        //	public String recordTypeId;
        public Integer registration;
        public String  registrationBy;
        public String  registrationPlace;
        public String  registrationTypes;
        public String  remarks;
        public Integer roadSafetyTax;
        public Integer RSA;
        public String  salesType;
        public String  schemeName;
        public Integer shield;
        public String  shieldWarranty;
        public String  status;
        public Integer tenure;
        public String  usage;
        public Integer zeroDepreciationInsuranceCost;
        public String stage;
    }
    
    public class Enquiry {
        //	public String externalId;        
        public String id;        
        public String title;//
        public String firstName;//
        public String lastName;//
        public String name;
        public String dealer;//
        public String Email;
        public String accountId;
        public DateTime enquiryDate;//
        public Date closeDate;
        public String contactId;
        public String stageName;
        public String referByName;
        public String nextStep;
        public String enquiryType;//
        public String enquirySource;//
        public String nextAction;
        public String usageArea;
        public String likelyPurchase;//
        public String age;//
        public String phoneNum;//
        public String mobileNo;
        public String LeadSource;//
        //	public String pricebook2Id;
        public Decimal amount;
        public String ownerId;
        public String dMSEnquiryNumber;
        //	public String completedStages;
        public String salesConsultantContactACE;//
        public String salesManagerContactACE;
        public String dealerManagerContactACE;
        public String branchManagerContactACE;
        public String quotationType;
        public Boolean custInterestedInLeasingVehicle;
        public Boolean quotationRequired;
        public Boolean leasingPolicyExpln;
        public String referralMobile;
        public String gender;
        public List<PrimaryInterest> primaryInterests;
    }
    
    public class PrimaryInterest{
        public String productName;
        public String color;
        public String variant;
        public String fuelType;
        public String transmissionType;
        public String quantity;
        public String seatingCapacity;
    }
    public class FollowUp {
        //	public String externalId;
        public String id;
        public String ownerId;
        public String description;
        //	public Boolean isRecurrence;
        public Date activityDate;
        public String whoId;
        public String phone;
        //	public Integer recurrenceInterval;		
        public String whatId;
        public String type;
        public String taskSubtype;
        public String subject;
        public String status;
        public String disposition;
        public String subDisposition;
        public String service;
        public DateTime nextFollowupTime;
        public String callType;
        public String callDisposition;
        public String callObject;
        public Integer callDurationInSeconds;
    }
    
    public class APIResponse {
        public String status;
        public List< String > errors;
        public Object record;
        
        public APIResponse() {
            errors = new List< String >();
        }
    }
    
    public static Contact searchExistingContact(List<String>phoneNos){
        Contact c= new Contact();
        try{
            c= [Select Id, MobilePhone, AccountId from Contact where MobilePhone IN: phoneNos OR otherPhone IN:phoneNos OR Email  IN: phoneNos OR HomePhone IN:phoneNos Limit 1];
        }
        catch(Exception e){
            ACE_Exception_Log__c el = new ACE_Exception_Log__c();
            el.Error_Message__c = e.getMessage();
            el.Exception_Type__c =e.getTypeName();
            el.Name = e.getTypeName();
            el.Line_Number__c = e.getLineNumber();
            insert el;
        }
        return c;
    }
}