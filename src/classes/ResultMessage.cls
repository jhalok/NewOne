/**
* @description This class is used for passing the results of Lightning Classes
*/
global class ResultMessage {
    // @description Flag for the result
    @AuraEnabled
    global Boolean success { get; set; }
    // @description Response/Error message
    @AuraEnabled
    global String message { get; set; }
    // @description Generic list of objects
    @AuraEnabled
    global List<Object> resultList { get; set; }
    //@description Generic map of objects
    @AuraEnabled
    global Map<String, Object> resultMap { get; set; }
    // @description Generic object for capturing an error
    @AuraEnabled
    global Object err { get; set; }
    
    /**
* @description Default constructor
*/
    global ResultMessage() {
        resultList = new List<Object> ();
        resultMap = new Map<String, Object>();
    }
    
}