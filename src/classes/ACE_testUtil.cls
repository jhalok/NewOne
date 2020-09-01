/**
Test Class - Sagar
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_testUtil {
	/****************************** TECKINFO & MRC Calls ******************************************/
    /****************************** [      START       ] ******************************************/
    //delete this method once finished testing
    public static ACE_APICalloutUtil.ApiResponse pushLeads(){
       // string leadjson = '[{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IvbnUAC","cust_no":"7045533587","cust_name":"Sagar Kambli","model_name":"XUV300","priority":"1","batch_name":"","language":""},{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IwQSUA0","cust_no":"9881716261","cust_name":"Anagha","model_name":"XUV500","priority":"1","batch_name":"","language":""},"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002IxZ3UAK","cust_no":"9140694958","cust_name":"Saransh","model_name":"XUV500","priority":"1","batch_name":"","language":""}]';
        //string leadjson = '[{"Camp_id":"52","Camp_Name":"Test_Drive","sfa_id":"00Q5D000002JevrUAC","cust_no":"9664353167","cust_name":"Sagar Kambli","model_name":"XUV300","priority":"1","batch_name":"","language":""}]';
        //ACE_APICalloutUtil.ApiResponse response1 = ACE_APICalloutUtil.sendRequest('https://mrc.cequitycti.com/sf_data/api/customer/savecustomerdata','','POST',leadjson,'MRC');
        //string leaddataURL = 'https://103.81.88.80/elision-dialer/elisionapi/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=[{"phone_number":"7045533587","list_id":"33333","MobileNo":"7045533587","LeadformURL":"https:\/\/mahindradealerworld--acedev.lightning.force.com\/lightning\/r\/Lead\/00Q5D000002JbHWUA0\/view",Id":"00Q5D000002JbHWUA0","CustomerName":"Sagar Kambli","LeadSubSource":"WEB","LeadSource":"WEB","CustomField1":"00Q5D000002JbHWUA0"}]';
       /* string url = 'http://103.81.88.80/elision-dialer/elision-api/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=';
        string json = '[{"phone_number":"7045533587","list_id":"33333","prospects_id":"00Q5D000002JbHWUA0","CustomerName":"Sagar Kambli","MobileNo":"7045533587","EnquirySource":"FB","EnquiryType":"M2A","WebEnquiryNumber":"XUV300321607","LeadSubSource":"JOINSVE","LeadSource":"FB","LeadformURL":"https:\\/\\/mahindradealerworld--acedev.lightning.force.com\\/lightning\\/r\\/Lead\\/00Q5D000002JbHWUA0\\/view","CustomField1":"00Q5D000002JbHWUA0"}]';
        json= json.replace('"', '%22');
        json= json.replace(' ', '%20');
        url += json;
		system.debug(url);*/
        string url = 'http://103.81.88.80/elision-dialer/elision-api/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=[{%22phone_number%22:%227045533587%22,%22list_id%22:%2233333%22,%22prospects_id%22:%2200Q5D000002JbHWUA0%22,%22CustomerName%22:%22Sagar%20Kambli%22,%22MobileNo%22:%227045533587%22,%22EnquirySource%22:%22FB%22,%22EnquiryType%22:%22M2A%22,%22WebEnquiryNumber%22:%22XUV300321607%22,%22LeadSubSource%22:%22JOINSVE%22,%22LeadSource%22:%22FB%22,%22LeadformURL%22:%22https:\\/\\/mahindradealerworld--acedev.lightning.force.com\\/lightning\\/r\\/Lead\\/00Q5D000002JbHWUA0\\/view%22,%20%22CustomField1%22:%22%2000Q5D000002JbHWUA0%22}]';
        //string url = 'http://10.2.68.50/elision-dialer/elision-api/main.php?action=add_multi_lead&source=external&custom_fields=Y&multi_leads=[{%22phone_number%22:%227045533587%22,%22list_id%22:%2233333%22,%22prospects_id%22:%2200Q5D000002JbHWUA0%22,%22CustomerName%22:%22Sagar%20Kambli%22,%22MobileNo%22:%227045533587%22,%22EnquirySource%22:%22FB%22,%22EnquiryType%22:%22M2A%22,%22WebEnquiryNumber%22:%22XUV300321607%22,%22LeadSubSource%22:%22JOINSVE%22,%22LeadSource%22:%22FB%22,%22LeadformURL%22:%22https:\\/\\/mahindradealerworld--acedev.lightning.force.com\\/lightning\\/r\\/Lead\\/00Q5D000002JbHWUA0\\/view%22,%20%22CustomField1%22:%22%2000Q5D000002JbHWUA0%22}]';
        ACE_APICalloutUtil.ApiResponse response1 = ACE_APICalloutUtil.sendRequest(url,'','POST','','M2ALL');
        system.debug('Status Code: '+response1.statusCode);
        system.debug('Status: '+response1.status);
        system.debug('JsonBody: '+response1.jsonBody);
        return response1;
    }
    
    /****************************** [      END         ] ******************************************/
}