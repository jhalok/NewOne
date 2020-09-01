/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Controller for ACE_CommunityCustomStyling component.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @modifiedBy     Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @maintainedBy   Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @version        1.0
* @created        2019-12-30
* @modified       2019-12-30
* @systemLayer    Controller
* @see            ????
* @see            ????
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            firstname.lastname@pwc.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class ACE_CommunityCustomStylingController {

    @AuraEnabled
    public static Integer getNavItemPosition( Id recordId ){
        Integer position;

        String sObjName = ACE_Utility.getSobjectAPI_Name( recordId );
        for( NavigationMenuItem nmi : [ SELECT Position
                                        FROM NavigationMenuItem 
                                        WHERE Status = :ACE_Constants.NAV_MENU_ITEM_STATUS_LIVE 
                                        AND Type = :ACE_Constants.API_RESPONSE_TYPE_SALESFORCEOBJECT 
                                        AND Target = :sObjName
                                        AND IsDeleted = FALSE
                                        LIMIT 1 ] ) {

            position = nmi.Position + 1;
        }

        return position;
    }
}