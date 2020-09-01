/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MRC_TeckInfoCTIAPI - Authentication response paramters copied into custom wrappers
            for closing the call for CTI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_MRC_TeckInfoCTIAPI - Authentication response used for closing the call for CTI
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global class ACE_MRC_TeckInfoCTIAPI{
	
    //properties
    public Integer ResultCode;	//0
	public cls_ResultString ResultString;
    
    global Class CloseCall{
        public Integer ResultCode;	//0
        public string ResultString;
    }
	
    //Purpose : Used to push data from Salesforce to MRC Dialer to initiate calls for idle agents based on there availability
    //API Endpoint : https://mrc.cequitycti.com/sf_data/api/customer/savecustomerdata
    //Method = Post
    //Content-Type = application/json
    global class SFCTICallData{
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
   
    /*------------------------------------------ CLOSE API Response Wrapper Format - START -------------------------------------- 
    * Purpose : Response data from TeckInfo CTI used for closing the call
    * API Endpoint Below: 
    *   Step1:
    *   Get Token API - https://sfmrc.cequitycti.com/api/cti/GetAgentToken?hostId=SFUsername
    *   
    *   Step2:
    *   Get Status API for Callnumber -  https://sfmrc.cequitycti.com/api/cti/GetStatus?runningSeries=0&hostId=SFUsername&tspltoken=FromStep1
    *   
    *   Step 3:
    *   Close Call API - https://sfmrc.cequitycti.com/api/cti/CloseCall?disposition=NOA&nextDialTime=&remarks=test&callNumber=20310053&hostId=4120.1699&extraParameters=&tspltoken=3b2e3d93-3525-449f-97f8-214a9014c5f8
    */
    global class cls_ResultString {
		public callDispositionDetails callDispositionDetails;
	}
	
    global class callDispositionDetails {
		public String RCode;	//0
		public String AStatusCode;	//5
		public String AStatus;	//WRAPUP
		public String AStatusReason;	//0
		public String AStatusSince;	//19:12:46
		public Integer AStatusSince2;	//69166
		public String PStatus;	//idle
		public String PStatusSince;	//19:12:46
		public String PColor;	//#FFFFFF
		public String ACtiMessage;	//wrap up
		public Integer ASeries;	//17
		public Integer ABlockMode;	//0
		public String ACtiNews;	//
		public Integer InternalChatNotification;	//0
		public String DialerServiceName;	//MAHINDRA_Y400
		public Integer DialerServiceId;	//52
		public String TerminalId;	//4468
		public String MeetMeRoomText;	//
		public String MeetMeRoomCode;	//
		public String CTIResponseTime;	//12:06:01 PM
		public String HostId;	//sagar.kambli@pwc.com.acectibox
		public cls_callDetails[] callDetails;
		public String ScreenRecordingStatus;	//N
		public cls_ChildAgentInfo[] ChildAgentInfo;
		public String LoginId;	//
	}
    
	global class cls_callDetails {
		public Integer ServiceId;	//52
		public String ServiceName;	//MAHINDRA_Y400
		public Integer LeadId;	//230847
		public Integer CallNumber;	//20315050
		public String CallType;	//O
		public String CallTypeName;	//Outbound 
		public String CLI;	//7506225569
		public String MaskCLI;	//7506225569
		public String DNI;	//5910
		public String Module;	//
		public String AddOn;	//
		public String AddOn2;	//
		public String AddOn3;	//
		public String StartTime;	//2019-10-15 16:52:30
		public String Dialable;	//1
		public Integer PreviewTime;	//1
		public String City;	//
		public String State;	//
		public String Region;	//
		public Integer PIndex;	//1
		public String HostId;	//sagar.kambli@pwc.com.acectibox
		public String TerminalId;	//4468
		public String LoginId;	//sagar.kambli@pwc.com.acectibox
		public Integer AgentId;	//1704
		public String TSPLToken;	//
		public String QueueDuration;	//0
		public Integer QueueCount;	//0
		public Integer QueueSize;	//0
		public String ObjectType;	//IDG
		public String SourceDate;	//
		public Integer mail_number;	//0
		public Integer mail_id;	//0
		public Integer CRMID;	//0
		public String CRMTitle;	//
		public String EmailUrl;	//
		public String ChatUrl;	//
		public String CRMUrl;	//Form://486&CallNumber=20315050&CallType=O&CallTypeName=Outbound &ServiceId=52&ServiceName=MAHINDRA_Y400&DNI=5910&LeadId=230847&CLI=7506225569&Module=&HostId=sagar.kambli@pwc.com.acectibox&LoginId=sagar.kambli@pwc.com.acectibox&AgentId=1704&AddOn=&AddOn2=&AddOn3=&TSPLToken=f22b4df9-c826-46a1-a0e3-965109101ffc&Dialable=1
		public String HistoryUrl;	///WebAgent/History?&CallNumber=20315050&CallType=O&CallTypeName=Outbound &ServiceId=52&ServiceName=MAHINDRA_Y400&DNI=5910&LeadId=230847&CLI=7506225569&Module=&HostId=sagar.kambli@pwc.com.acectibox&LoginId=sagar.kambli@pwc.com.acectibox&AgentId=1704&AddOn=&AddOn2=&AddOn3=&TSPLToken=f22b4df9-c826-46a1-a0e3-965109101ffc&Dialable=1&GridType=CALLHISTORY
		public String ScriptUrl;	//
		public String AdditionalCRMUrl;	//
		public String EmailListUrl;	//
		public String ChatListUrl;	//
		public String FacebookUrl;	//
		public String SMSUrl;	//
		public String EMAILLIST_TAB_SHOW;	//N
		public String CHATLIST_TAB_SHOW;	//N
		public String EMAIL_TAB_SHOW;	//N
		public String CHAT_TAB_SHOW;	//N
		public String CRM_TAB_SHOW;	//Y
		public String HISTORY_TAB_SHOW;	//Y
		public String SCRIPT_TAB_SHOW;	//N
		public String FACEBOOK_TAB_SHOW;	//N
		public String SMS_TAB_SHOW;	//N
		public String CRMIsThirdParty;	//Y
		public String AdditionalCRMIsThirdParty;	//Y
		public String FORM_CLOSECALL;	//PANEL
		public String TEL_HANGUP;	//Y
		public String TEL_HOLD;	//Y
		public String TEL_CONFERENCE;	//Y
		public String TEL_XFER;	//Y
		public String TEL_CSAT;	//N
		public String TEL_MUTE;	//N
		public String PageHeader;	//
		public String HeaderType;	//
		public String GridType;	//
		public Integer CallUrlInNewTab;	//0
		public cls_GalaxyAuditTrail GalaxyAuditTrail;
		public cls_LeadData LeadData;
	}
    
	global class cls_GalaxyAuditTrail {}
    
	global class cls_LeadData {}
    
	global class cls_ChildAgentInfo {}
    /*------------------------------------------ CLOSE API Response Wrapper Format - END-------------------------------------- */
    
    
    /*-------------Service---------------------*/
    global class MRCService{
        public string ServiceCode{get;set;}
        public string ServiceName{get;set;}
    }
    
    /*-------------Dispositions---------------------*/
    global class MRCDisposition{
        public string DispositionCode{get;set;}
        public string ServiceCode{get;set;}
        public string DispositionName{get;set;}
        public string CallCenter{get;set;} //MRC
        public string DispositionType{get;set;}
        public Boolean Inbound{get;set;}
        public Boolean Outbound{get;set;}
        public Boolean IsActive{get;set;}
        public Integer DispositionSystemId{get;set;}
        public List<MRCSubDisposition> subdispositions{get;set;}
    }
    
    
    /*-------------SubDispositions---------------------*/
    global class MRCSubDisposition{
        public string SubDispositionCode{get;set;}
        public string SubDispositionName{get;set;}
        public string BucketCode{get;set;} 
    }
    
    
    global class MRCDialerBuckets{
        public string bucketName{get;set;}
        public string bucketCode{get;set;}
        public string ServiceCode{get;set;}
        public boolean isCallBackNeeded{get;set;}
        public Integer CallBackMinute{get;set;}
        public Integer NoOfAttempts{get;set;}
        public boolean isCallClosed{get;set;}
    }
    
    
    /*static testMethod void testParse() {
    String json=		'{"ResultCode":0,"ResultString":{"username":{"RCode":"0","AStatusCode":"5","AStatus":"WRAPUP","AStatusReason":"0","AStatusSince":"19:12:46","AStatusSince2":69166,"PStatus":"idle","PStatusSince":"19:12:46","PColor":"#FFFFFF","ACtiMessage":"wrap up","ASeries":17,"ABlockMode":0,"ACtiNews":"","InternalChatNotification":0,"DialerServiceName":"MAHINDRA_Y400","DialerServiceId":52,"TerminalId":"4468","MeetMeRoomText":"","MeetMeRoomCode":"","CTIResponseTime":"12:06:01 PM","HostId":"sagar.kambli@pwc.com.acectibox","callDetails":[{"ServiceId":52,"ServiceName":"MAHINDRA_Y400","LeadId":230847,"CallNumber":20315050,"CallType":"O","CallTypeName":"Outbound ","CLI":"7506225569","MaskCLI":"7506225569","DNI":"5910","Module":"","AddOn":"","AddOn2":"","AddOn3":"","StartTime":"2019-10-15 16:52:30","Dialable":"1","PreviewTime":1,"City":"","State":"","Region":"","PIndex":1,"HostId":"sagar.kambli@pwc.com.acectibox","TerminalId":"4468","LoginId":"sagar.kambli@pwc.com.acectibox","AgentId":1704,"TSPLToken":"","QueueDuration":"0","QueueCount":0,"QueueSize":0,"ObjectType":"IDG","SourceDate":"","mail_number":0,"mail_id":0,"CRMID":0,"CRMTitle":"","EmailUrl":"","ChatUrl":"","CRMUrl":"Form://486&CallNumber=20315050&CallType=O&CallTypeName=Outbound &ServiceId=52&ServiceName=MAHINDRA_Y400&DNI=5910&LeadId=230847&CLI=7506225569&Module=&HostId=sagar.kambli@pwc.com.acectibox&LoginId=sagar.kambli@pwc.com.acectibox&AgentId=1704&AddOn=&AddOn2=&AddOn3=&TSPLToken=f22b4df9-c826-46a1-a0e3-965109101ffc&Dialable=1","HistoryUrl":"/WebAgent/History?&CallNumber=20315050&CallType=O&CallTypeName=Outbound &ServiceId=52&ServiceName=MAHINDRA_Y400&DNI=5910&LeadId=230847&CLI=7506225569&Module=&HostId=sagar.kambli@pwc.com.acectibox&LoginId=sagar.kambli@pwc.com.acectibox&AgentId=1704&AddOn=&AddOn2=&AddOn3=&TSPLToken=f22b4df9-c826-46a1-a0e3-965109101ffc&Dialable=1&GridType=CALLHISTORY","ScriptUrl":"","AdditionalCRMUrl":"","EmailListUrl":"","ChatListUrl":"","FacebookUrl":"","SMSUrl":"","EMAILLIST_TAB_SHOW":"N","CHATLIST_TAB_SHOW":"N","EMAIL_TAB_SHOW":"N","CHAT_TAB_SHOW":"N","CRM_TAB_SHOW":"Y","HISTORY_TAB_SHOW":"Y","SCRIPT_TAB_SHOW":"N","FACEBOOK_TAB_SHOW":"N","SMS_TAB_SHOW":"N","CRMIsThirdParty":"Y","AdditionalCRMIsThirdParty":"Y","FORM_CLOSECALL":"PANEL","TEL_HANGUP":"Y","TEL_HOLD":"Y","TEL_CONFERENCE":"Y","TEL_XFER":"Y","TEL_CSAT":"N","TEL_MUTE":"N","PageHeader":"","HeaderType":"","GridType":"","CallUrlInNewTab":0,"GalaxyAuditTrail":null,"LeadData":null}],"ScreenRecordingStatus":"N","ChildAgentInfo":[],"LoginId":""}}}';
    ServiceDisposition obj = parse(json);
    System.assert(obj != null);
    }*/
}