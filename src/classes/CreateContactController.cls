public class CreateContactController {
    
    @AuraEnabled
    public static Contact ContactSave{get;set;}
    
    
    @AuraEnabled
    public static Contact ContactSave(Map<String, String> cus){
        
        
       //List<contact> con = [select id,name,MobilePhone,firstname,lastname,recordtype.Devlopername from Contact] 
       Contact con = new Contact();
        con.MobilePhone = cus.get('MobileNumber');
        con.FirstName = cus.get('FirstName');
        con.LastName = cus.get('LastName');
        
        insert con;
        return con;
    }
    
}