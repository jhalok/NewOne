/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Service Support Case Trigger Handler to check eligibility of support entitlements for 
  account and contact.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-18
* @modified       2019-11-18
* @systemLayer    ServiceSupportHandler
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.

* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
Change#     Modified On         Modified By                 Reason/Desrciption
---------------------------------------------------------------------------------------------------
C001        15-Nov-2019         PwC Developer               After Insert logic add
***************************************************************************************************/
public class ACE_ServiceSupportHelper {
    /*
     * When a case is created via Web-to-Case, Email-to-Case, or a community, 
     * it isn’t automatically associated with an entitlement. 
     * When a case’s Entitlement field is empty, this sample trigger checks whether
     *  the case contact has an active entitlement. If the contact has an active entitlement, 
     * the entitlement is added to the case. If the contact doesn’t have an active entitlement, 
     * the trigger then checks whether the case account has an active entitlement. 
     * If the case account has an active entitlement, the entitlement is added to the case. The trigger helps ensure that cases are resolved according to your customer support agreements.
     */
    public static void assignEntitlementSupport(List<Case> cases) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        
        for(Case c : cases){
            if(c.ContactId != null)
                contactIds.add(c.ContactId); 
            if(c.AccountId != null)
                acctIds.add(c.AccountId);
        }
        
        List <EntitlementContact> entlContacts = [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId 
                                                  From EntitlementContact e
                                                  Where e.ContactId in :contactIds
                                                  And e.Entitlement.EndDate >= Today 
                                                  And e.Entitlement.StartDate <= Today];
        if(entlContacts.size() > 0){
            for(Case c : cases)
            {
                if(c.EntitlementId == null && c.ContactId != null)
                {
                    for(EntitlementContact ec:entlContacts){
                        if(ec.ContactId==c.ContactId){
                            c.EntitlementId = ec.EntitlementId;
                            if(c.AssetId==null && ec.Entitlement.AssetId!=null)
                                c.AssetId=ec.Entitlement.AssetId;
                            break;
                        }
                    } 
                }
            }
        }
        else
        {
            List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, 
                                        e.AccountId, e.AssetId
                                        From Entitlement e
                                        Where e.AccountId in :acctIds And e.EndDate >= Today 
                                        And e.StartDate <= Today];
            
            if(entls.size()>0){
                for(Case c : cases){
                    if(c.EntitlementId == null && c.AccountId != null){
                        for(Entitlement e:entls){
                            if(e.AccountId==c.AccountId){
                                c.EntitlementId = e.Id;
                                if(c.AssetId==null && e.AssetId!=null)
                                    c.AssetId=e.AssetId;
                                break;
                            }
                        } 
                    }
                } 
            }
        }
    }
    
    public static void autoCompleteMilestoneforCase(List<Case> cases){
        if (UserInfo.getUserType() == 'Standard'){
            DateTime completionDate = System.now(); 
            List<Id> updateCases = new List<Id>();
            for (Case c : cases){
                if (((c.isClosed == true)||(c.Status == 'Closed'))&&((c.SlaStartDate 
                                                                      <= completionDate)&&(c.SlaExitDate == null)))
                    updateCases.add(c.Id);
            }
            if (updateCases.isEmpty() == false)
                ACE_MilestoneUtil.completeMilestone(updateCases, 'MRC Support Agents Resolution Time', completionDate);
        }
    }
}