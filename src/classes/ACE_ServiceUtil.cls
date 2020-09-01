global class ACE_ServiceUtil {
    
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
    
    //For pushing leads into SF API -- ACE_CreateLeads_eteFlow
    public class ReferLeadFromEmployee{
        public string Salutation;	
        public String Name;
        public String contactNumber;
        public Boolean ownMahindraVehicle;
        public String businessUnit;
        public List<leadsPush> referleadsDeatil;  
    }
    public class ReferLeadFromEmployeeDetail{
        public string Salutation;	
        public String Name;
        public String contactNumber;
        public Boolean ownMahindraVehicle;
        public String businessUnit;
        public List<leadDetail> referleadsDeatil;  
    }
    global class leadsPush{
        public String leadName{get;set;}
        public String leadNumber{get;set;}
        public String city{get;set;}
        public String email{get;set;}
        public String state{get;set;}
        public String source{get;set;}
        public String subsource{get;set;}
        public String groupCode{get;set;}
        public String model{get;set;}
        public String partnerAccountId{get;set;}
        public String status ='';
        public LeadStatus leadResponse = new LeadStatus(); 
        public String preferredContactTime;
    }
    public Class LeadStatus{
        public String status;
        public String sfLeadRecId;
        public ProductInterest productInterests = new ProductInterest();
    }
    
    public Class ProductInterest{
        public String status;
        public String sfProductIntrestRecId;
        public SourceTracker sourceTrackers = new SourceTracker();
    }
    public Class SourceTracker{
        public String status;
        public String sfProductIntrestRecId;
    }
    public class leadDetail{  
        public Lead leadData;
        public string leadStatus;
        public string leadExcetion;
        public List<productInterestsDetail> relatedProductInterests;
        public List<ACE_Booking__c> bookings = new List<ACE_Booking__c>();
    }
    public class productInterestsDetail{
        public ACE_Product_Interest__c productInterest;
        public string productInterestStatus;
        public string productInterestExcetion;
        public List<sourceTrackerDetail> relatedSourceTrackers;
    }
    public class sourceTrackerDetail{
        public ACE_Source_Tracker__c sourceTracker;
        public string sourceTrackerStatus;
        public string sourceTrackerExcetion;
    }
    global class dialerUsers{
        
        public String userName{get;set;}
        public String password{get;set;}
        public String role{get;set;}
        public String email{get;set;}
        public String sfId{get;set;}
    }
    
    global class mrcdialerLeads{
        public string Camp_id {get;set;}
        public string Camp_Name {get;set;}
        public string sfa_id {get;set;}
        public string cust_no {get;set;}
        public string cust_name {get;set;}
        public string model_name {get;set;}
        public string priority {get;set;}
        public string batch_name {get;set;}
        public string language {get;set;}
    }
    
    global class m2alldialerLeads{
        //mandatory
        public string source {get;set;}
        public string action {get;set;}
        public string phone_number {get;set;}
        public string list_id {get;set;}
        public string custom_fields {get;set;}
        public string multi_leads{get;set;}
        //Optional
        public string Id {get;set;}
        public string CustomerName {get;set;}
        public string MobileNo {get;set;}
        public string EnquirySource {get;set;}
        public string EnquiryType {get;set;}
        public string CreateEnquiryID {get;set;}
        public string WebEnquiryNumber {get;set;}
        public string LeadSubSource {get;set;}
        public string LeadSource {get;set;}
        public string LeadfromURL {get;set;}
        public string CustomField1 {get;set;}
        public string CustomField2 {get;set;}
        
        
        
        
    }
    
    global class leadPushResponse{
        public string message {get;set;}
    }
    
    global class userPushResponse{
        public string sf_Id {get;set;}
        public string dialer_Id {get;set;}
    }
    
    global class disposedCallDetails{
        public string caller_no {get; set;}
        public string call_start_time {get; set;}
        public string call_end_time {get; set;}
        public string call_duration {get; set;}
        public string actual_calltime {get; set;}
        public string wrapup_time {get; set;}
        public string agent_id {get; set;}
        public string callcenterType {get;set;}
        public string comments {get;set;}
        public string next_followup_time {get;set;}
        public string service_code {get;set;}
        public string disposition {get;set;}
        public string subdisposition {get;set;}
        public string call_type {get;set;}
        public string sf_id {get;set;}
        public string dialerId {get;set;}
        
    }
    
    global class updateTD{
        public string td_id{get; set;}
        public string place{get; set;}
        public string start_time{get; set;} 
        public string end_time{get; set;}
        public string td_comments{get; set;}   
        public string td_status{get; set;}  
        public string td_cust_feedback{get; set;}                  
    }
    
    global class taskServices{
        public string disposition {get;set;}
        public string sub_disposition {get;set;}
        public string leadid {get;set;}
        public string service_code {get;set;}
        public string description {get;set;}
        public string dialerId {get;set;} 
    }
    
    global class bookingCancellation{
        public string Id {get; set;}
    }
    
}