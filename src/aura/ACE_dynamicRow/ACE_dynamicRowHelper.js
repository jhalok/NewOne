({
    createObjectData: function(component, event) {
        // get the AccList from component and add(push) New Object to List  
        var rowItemList = component.get("v.LeadList");
        rowItemList.push({
            'LastName': '',
            'MobilePhone': '',
            'Company': 'testing',
            'Status': 'Open - Not Contacted',
            'Contact_Time__c' : '',
            'disable':false
        });
        // set the updated list to attribute (AccList) again    
        component.set("v.LeadList", rowItemList);
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allLeadRows = component.get("v.LeadList");
        for (var indexVar = 0; indexVar < allLeadRows.length; indexVar++) {
            if (allLeadRows[indexVar].Name  == '') {
                isValid = false;
                alert('First Name Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;
    }
})