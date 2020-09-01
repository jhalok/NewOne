/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Product Interest Updation in Lead.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Saikrishna   <saikrishna.omkaram@in.pwc.com>
* @modifiedBy     Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @maintainedBy   Saikrishna    <saikrishna.omkaram@in.pwc.com>
* @version        1.0
* @created        2019-11-8
* @modified       2019-11-8
* @systemLayer    
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class ACE_ProductInterestHandler {
    //kjhkj
    public ACE_ProductInterestHandler(){}
    
    public static void updateProductOnLead(List<ACE_Product_Interest__c> piList){
        Map<String,String> leadpiMap = new Map<String,String>(); 
        for(ACE_Product_Interest__c pi:piList){
            
            if(pi.Lead__c!=null && pi.Prefered__c == true){
                  leadpiMap.put(pi.Lead__c,pi.Name);
            }
            
                
        }
        
        List<Lead> leadLst = [select Id,Primary_Model__c from Lead where Id IN:leadpiMap.keyset()];
        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead l:leadLst){
            l.Primary_Model__c = leadpiMap.get(l.Id);
            leadToUpdate.add(l);
        }
        
        if(leadToUpdate.size()>0){
            
            try{
                
                update leadToUpdate;
                
            }  
            catch(Exception ex){
                System.debug('Exception'+ex);
            }
        }
        
    }
    

}