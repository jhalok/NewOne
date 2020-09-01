@RestResource(urlMapping='/pushPrebookingDataintoSF/*') 
global with sharing class ACE_capturePreBookingData{

@HttpPost
global static void pushPrebookingData(){
      
      String jsonresp = '';
      RestRequest     request    = RestContext.request;
      RestResponse    response   = RestContext.response;    
      response.addHeader('Content-Type','application/json');
      
      
}


}