({
    doInit : function(component, event, helper) {
        var objDetails = component.get("v.objDetail");   
        var Compfield = component.get("v.Salutation");
        helper.fetchPickListVal(component,objDetails,Compfield); 
        var Compfield = component.get("v.BusinessUnit");
        helper.fetchBuisnessListVal(component,objDetails,Compfield);  
        var LeadList = {
            'sobjectType': 'Lead',
            'LastName': '',
            'MobilePhone': '',
            'Company': 'testing',
            'Status': 'Open - Not Contacted',
            'Contact_Time__c' : '',
            'Referred_By__c' : '',
            'disable':false
        };
        var LeadListArray = [];
        LeadListArray.push(LeadList);
        component.set('v.LeadList',LeadListArray);
    },  
    toggle: function (component, event, helper) {
        var cm = component.find("radioGroupRequired").get("v.value");
        if(cm == 'YES'){
            component.set("v.toggleChange",true);
        }
        else
        {
            component.set("v.toggleChange",false);
        }
        
        
    },
    save : function(component,event,helper) {
        alert('save');
        var objDetails = component.get("v.objDetail");
        var LeadListArray = component.get('v.LeadList'); 
        helper.InsertRecord(component,objDetails,LeadListArray);
        
    },
    addRowData :  function(component, event, helper) {
        var LeadList = { 'sobjectType': 'Lead',
                        'LastName': '',
                        'MobilePhone': '',
                        'Company': 'testing',
                        'Status': 'Open - Not Contacted',
                        'Contact_Time__c' : '',
                        'Referred_By__c' : '',
                        'disable':false
                       };
        var LeadListArray = component.get('v.LeadList');
        LeadListArray.push(LeadList);
        component.set('v.LeadList',LeadListArray);
        
    },
    delSingleRow :  function(component, event, helper) {
        var id = event.target.id; 
        var LeadListArray = JSON.parse(JSON.stringify(component.get('v.LeadList')));
        LeadListArray.splice(id, 1);
        component.set('v.LeadList',LeadListArray);
    },
    clearName : function(cmp, evt) {
    window.location.reload();
}
    
 
})