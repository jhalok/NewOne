/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Helper - Mark milestone as completed when an email is sent to the case contact. 
  That way, the support agent doesn’t have to manually mark the milestone Completed after they email the case contact.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sagar Kambli   <sagar.kambli@pwc.com>
* @modifiedBy     Sagar Kambli   <sagar.kambli@pwc.com>
* @maintainedBy   Sagar Kambli   <sagar.kambli@pwc.com>
* @version        1.0
* @created        2019-11-18
* @modified       2019-11-18
* @systemLayer    ACE_AgentsServiceEmailMessageHelper
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
public class ACE_AgentsServiceEmailMessageHelper {
    public static void completeFirstResponseEmail(List<EmailMessage> messages){
        if (UserInfo.getUserType() == 'Standard'){
            DateTime completionDate = System.now();
            Map<Id, String> emIds = new Map<Id, String>();
            for (EmailMessage em : messages){
                if(em.Incoming == false)
                    emIds.put(em.ParentId, em.ToAddress);
            }
            if (emIds.isEmpty() == false){
                Set <Id> emCaseIds = new Set<Id>();
                emCaseIds = emIds.keySet();
                List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,
                                       c.OwnerId, c.Status,
                                       c.EntitlementId,
                                       c.SlaStartDate, c.SlaExitDate
                                       From Case c where c.Id IN :emCaseIds];
                if (caseList.isEmpty()==false){
                    List<Id> updateCases = new List<Id>();
                    for (Case caseObj:caseList) {
                        if ((emIds.get(caseObj.Id)==caseObj.Contact.Email)&&
                            (caseObj.Status == 'In Progress')&&
                            (caseObj.EntitlementId != null)&&
                            (caseObj.SlaStartDate <= completionDate)&&
                            (caseObj.SlaStartDate != null)&&
                            (caseObj.SlaExitDate == null))
                            updateCases.add(caseObj.Id);
                    }
                    if(updateCases.isEmpty() == false)
                        ACE_MilestoneUtil.completeMilestone(updateCases, 
                                                         'CTI Agents First Response Email', completionDate);
                }
            }
        }                
    }
}