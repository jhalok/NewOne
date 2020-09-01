/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : ACE_MRC_CallClosureController - Custom lightning component controller for agents 
									     to dispose call on lead.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-10
* @modified       2019-11-10
* @systemLayer    ACE_MRC_CallClosureController  - Authentication response used for closing the call for CTI
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ACE_MRC_CallClosureController {
    @AuraEnabled
    public static string loadMRCDispositions(string serviceId,string dispositionType, Id leadId){
        DispositionData data = new DispositionData();
        String dispositionsJSON = '';
        Set<Id> dispositionIds = new Set<Id>();
        //Lead leaddata = [select id, disposition__c, subdisposition__c,service__c, service__r.Service_Code__c from lead where Id =:leadId];
        
        if(serviceId != null && serviceId != ''){
            
            //Based on service code, we retrive all disposition for that service
            for(ACE_ServiceDisposition__c junctionRec: [SELECT Id, Disposition__c FROM ACE_ServiceDisposition__c where ServiceDisposition__c =:serviceId 
                                                    and Disposition__r.IsActive__c = true order by Name asc])
            {
                dispositionIds.add(junctionRec.Disposition__c);
            }
            
            //Once we get all the dispositions,prepare map of dispositionCode and SubDispositions
            if(dispositionIds.size()>0!=null){
                List<MRCMainDisposition> dispositions = new List<MRCMainDisposition>();
                Set<string> dispositionCodes = new Set<string>();
                string selectedDispositionValue = '';
                string selectedSubDispositionValue = '';
                Map<string,List<MRCSubDisposition>> subDispositionMap = new Map<string,List<MRCSubDisposition>>();
                for(ACE_SubDisposition__c subDispositions :[SELECT Id, Name,Disposition__c,Disposition__r.Name, Disposition__r.Disposition_Code__c, SubDisposition_Code__c, 
                                                            DialerBucket__c, Inbound__c, Outbound__c FROM ACE_SubDisposition__c Disposition__c
                                                            where Disposition__c in:dispositionIds and Disposition__r.DispositionType__c=:dispositionType and Disposition__r.IsActive__c = true order by Disposition__r.Name, Name asc])
                {
                    string disposition_Id = subDispositions.Disposition__r.Id;
                    string subdisposition_Id = subDispositions.Id;
                    string subdisposition_Name = subDispositions.Name;
                    
                    MRCSubDisposition wrapper = new MRCSubDisposition();
                    wrapper.subDispositionName = subdisposition_Name;
                    wrapper.subDispositionId = subdisposition_Id;
                    //if(leaddata.SubDisposition__c!=null &&  leaddata.SubDisposition__c == subdisposition_Id)
                      //  selectedSubDispositionValue = leaddata.SubDisposition__c;
                    
                   
                    if(!dispositionCodes.contains(subDispositions.Disposition__r.Disposition_Code__c)){
                        MRCMainDisposition disposition = new MRCMainDisposition();
                        disposition.mainDispositionName = subDispositions.Disposition__r.Name;
                        disposition.mainDispositionId = subDispositions.Disposition__r.Id;
                       // if(leaddata.Disposition__c!=null &&  leaddata.Disposition__c == subDispositions.Disposition__c)
                         //   selectedDispositionValue = leaddata.Disposition__c;
                        dispositions.add(disposition);
                        dispositionCodes.add(subDispositions.Disposition__r.Disposition_Code__c);
                    }
                    
                    //SubDisposition map
                    if(subDispositionMap.get(disposition_Id)==null)
                        subDispositionMap.put(disposition_Id,new List<MRCSubDisposition>{wrapper});
                    else
                        subDispositionMap.get(disposition_Id).add(wrapper);
                }
                data.selectedDispositionValue = selectedDispositionValue;
                data.selectedsubDispositionValue = selectedSubDispositionValue;
                data.dispositions=dispositions;
                data.subDispositionMap = subDispositionMap;
                dispositionsJSON = JSON.serialize(data);
                return dispositionsJSON;
            }
        }
        
        return dispositionsJSON;
    }
    
    @AuraEnabled
    public static string loadMRCServices(Id recordId){
        string servicejson = '';
        List<ACE_Service__c>  mrcServices = new List<ACE_Service__c>();
        mrcServices = [SELECT Id, Name, Service_Code__c FROM ACE_Service__c];
        //Lead leaddata = [select id, disposition__c, subdisposition__c,service__c, service__r.Service_Code__c from lead where Id =:leadId];
        if(mrcServices.size()>0)
        {
            MRCService service = new MRCService();
            service.serviceJSON = String.valueOf(JSON.serialize(mrcServices));
            servicejson = JSON.serialize(service);
            return servicejson;
        }
        return servicejson;
    }
    
    @AuraEnabled
    public static string closeCall(string dispositionCode, Datetime nextDialTime,
                                                           string comments, string recordId, string dispositionId, string subdispositionId)
    {
        ACE_APICalloutUtil.ApiResponse response;
        system.debug(dispositionCode);
        system.debug(nextDialTime);
        List<ACE_SubDisposition__c>  subdisposition = new List<ACE_SubDisposition__c>();
        
        if(dispositionCode!=null)
        subdisposition = [select id,SubDisposition_Code__c from ACE_SubDisposition__c where id=:dispositionCode limit 1]; 
            
        if(dispositionCode==null || dispositionCode==''){
            system.debug('inside 1');
            response = new ACE_APICalloutUtil.ApiResponse();
            response.status = 'Error';
            response.exceptionMessage = 'Please select Disposition and SubDisposition';
            return JSON.serialize(response);
        }
        else if(dispositionCode!=null && nextDialTime==null && subdisposition.size() ==1 &&  subdisposition[0].SubDisposition_Code__c=='CBK'){
            system.debug('inside 2');
            response = new ACE_APICalloutUtil.ApiResponse();
            response.status = 'Error';
            response.exceptionMessage = 'Please select Next Followup';
            return JSON.serialize(response);
        }
        else if(comments==null || comments == ''){
            response = new ACE_APICalloutUtil.ApiResponse();
            response.status = 'Error';
            response.exceptionMessage = 'Please enter comments';
            return JSON.serialize(response);
        }
        else
        {
            if(subdisposition.size()==1){
                string followupdatetime = string.valueOf(nextDialTime);
                response = ACE_APICalloutUtil.closeCall(subdisposition[0].SubDisposition_Code__c, followupdatetime, comments,recordId);
                List<Lead> lstLead = new List<Lead>();
                if(response.statusCode==200){
                    for(Lead lead : [select id, Disposition__c, SubDisposition__c,Next_FollowUp__c,Comments__c from Lead where Id =:recordId ]){
                        lead.Disposition__c = dispositionId;
                        lead.SubDisposition__c = subdispositionId;
                        lead.Next_FollowUp__c = nextDialTime;
                        lead.Comments__c = comments;
                        lstLead.add(lead);
                    }
                    if(lstLead.size()>0){
                        try{
                        update lstLead;
                        }
                        catch(Exception e){
                            response = new ACE_APICalloutUtil.ApiResponse();
                            response.status = 'Error';
                            response.exceptionMessage = e.getMessage()+' '+e.getStackTraceString();
                            return JSON.serialize(response);
                        }
                    }
                }else{
                     return JSON.serialize(response);
                }
                
                
            }
            
        }
        
       return JSON.serialize(response);
    }
    
	public class DispositionData{
        public List<MRCMainDisposition> dispositions {get;set;}
        public Map<string,List<MRCSubDisposition>> subDispositionMap{get;set;}
        public string selectedDispositionValue{get;set;}
        public string selectedSubDispositionValue{get;set;}
    }
    
    public class MRCSubDisposition{
        public string subDispositionName{get;set;}
        public string subDispositionId{get;set;}
    }
    
    public class MRCMainDisposition{
        public string mainDispositionName{get;set;}
        public string mainDispositionId{get;set;}
    }
    
    public class MRCService{
        public string serviceJSON{get;set;}
        public string serviceSelectedValue{get;set;}
    }
}