/**
 * @File Name          : ACE_CreateEnquiryAPIUtility.cls
 * @Description        : 
 * @Author             : Ruchit Gupta<ruchit.r.gupta.pwc.com>
 * @Group              : 
 * @Last Modified By   : Ruchit Gupta<ruchit.r.gupta.pwc.com>
 * @Last Modified On   : 11/19/2019, 11:21:09 AM
 * @Modification Log   : 
 * Ver       Date            Author      		             Modification
 * 1.0    11/18/2019   Ruchit Gupta<ruchit.r.gupta.pwc.com>  Initial Version
**/
public class ACE_CreateEnquiryAPIUtility {
    public class CreateEnquiry{  
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
	//public String visitorId;
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
        
}