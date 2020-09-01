@RestResource(urlMapping='/BookingCancellation/*') 
global class ACE_BookingCancellation {
    
    @HttpPost
    global static String BookingCancellation(){
        String jsonresp = '';
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','application/json');
        
        List<ACE_ServiceUtil.bookingCancellation> cancellationApproval = 
        (List<ACE_ServiceUtil.bookingCancellation>)JSON.deserialize(request.requestBody.toString(),List<ACE_ServiceUtil.bookingCancellation>.class);
        List<ACE_Booking__c> bookingRecordList = [SELECT Id, Name FROM ACE_Booking__c where id =:cancellationApproval[0].Id];
        System.debug(bookingRecordList);
        if(cancellationApproval.size()>0){
            for(ACE_Booking__c recordIdList : bookingRecordList ){
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setObjectId(bookingRecordList.get(0).Id);
                approvalReq.setSubmitterId(userInfo.getUserId());
                approvalReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                Approval.ProcessResult result = Approval.process(approvalReq);
                if(!result.isSuccess()){
                    String errorMessage = '';
                    for(Database.Error error : result.getErrors()){
                        errorMessage += error.getMessage() +'\n';
                    }
                        System.debug(errorMessage);
                }
            }
            
        }
        return null;
    }
}