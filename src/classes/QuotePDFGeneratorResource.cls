@RestResource(urlMapping='/Quote/PDFGenerator/*')
global with sharing class QuotePDFGeneratorResource {
  
  @HttpPost
    global static String doPost(String Id) {
        QuotePDFController.AttachPDFToQuote(Id);
        return 'SUCCESS';
    }
    
}