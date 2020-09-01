/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Summary : Controller for ACE_FormulaPath component.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @modifiedBy     Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @maintainedBy   Mrinal Vishal <mrinal.v.tpr@in.pwc.com>
* @version        1.0
* @created        2019-12-24
* @modified       2019-12-24
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
public with sharing class ACE_FormulaPathController {
    
    @AuraEnabled
    public static String getSobjectAPI_Name( Id recordId ){
        String sObjName = ACE_Utility.getSobjectAPI_Name( recordId );
        return sObjName;
    }
}