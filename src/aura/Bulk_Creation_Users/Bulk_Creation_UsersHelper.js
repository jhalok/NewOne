({
    fetchFieldsHelper : function(component, event ){
        var action = component.get("c.userRequiredFields");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result', result);
            component.set("v.requiredFields", result);
            $A.util.addClass(component.find('Spinner'), 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    downloadCsvTemplateHelper : function(component, event ) {
        /*var reqFields = component.get('v.requiredFields');
        console.log('reqFields : '+reqFields);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + reqFields
        hiddenElement.download = 'ExportData.csv';  
        hiddenElement.click();*/
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI('"Name","Last Name","User Role","Service","Team"');
        hiddenElement.download = 'ExportData.csv';  
        hiddenElement.click();
    },
    uploadCsvHelper : function(component, event, data ) {
        $A.util.removeClass(component.find('Spinner'), 'slds-hide');
        component.set('v.indexNumber',[]);
        component.set('v.loading',true);
        var header = data[0];
        var index = [];
        var error = '';
        component.set('v.headerList',header);
        var header = component.get('v.headerList');
        console.log(header);
        console.log('DATA -- ',data);
        var action = component.get("c.insertBulkUsers");
        var newData = [];
        for(var ind = 0 ; ind < data.length ; ind++) {
            var flag = true;
            for(var temp = 0 ; temp < data[ind].length ; temp++) {
                if(!$A.util.isEmpty(data[ind][temp])) {
                    flag = false;
                }
            }
            if(!$A.util.getBooleanValue(flag)) {
                newData.push(data[ind]);
            }
        }
        console.log(newData);
        action.setParams({
        	'userData' : JSON.stringify(newData)
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result -:- ', result);
            error = result;
            component.set("v.errorMessage", result);
            var errorLogRecords = [];
            var successLogRecords = [];
            component.set('v.dataList',data);
            var systemErrorMessage = component.get('v.errorMessage');
            for(var i=0; i<result.length; i++){
                var row = data[i+1];
                if(row.length != null && row.length >1){
                    var reqErrorMsg = '';
                    var errorMsg = '';
                    for(var j=0; j<row.length; j++){
                        if (row[j] == null || row[j] == '' || row[j] == undefined){
                            reqErrorMsg += (reqErrorMsg == '' ? ' '+header[j] : ', '+header[j]);
                        }
                        if(header[j] == 'Email' && row[j] != ""){
                            if (!(row[j].includes('.') && row[j].includes('@'))){
                                errorMsg += ' Email format incorrect.';
                            }
                        }
                    }
                    if(reqErrorMsg != ''){
                        reqErrorMsg += ' required field missing.';
                        errorMsg += reqErrorMsg;
                    }
                    if(!result[i].isSuccess){//errorMsg != ''
                        var errorRec = JSON.parse(JSON.stringify(row));
                        errorRec.push('Error !');
                        errorRec.push(errorMsg);
                        console.log(result[i]);
                        errorRec.push(result[i].message);
                        errorLogRecords.push(errorRec);
                    }
                    else{
                        var successRec = JSON.parse(JSON.stringify(row));
                        successRec.push(result[i].message);
                        successLogRecords.push(successRec);
                    }
                }
            }
            component.set('v.errorRecordsList',errorLogRecords);
            component.set('v.successRecordsList',successLogRecords);
            component.set('v.isVisible',true);
            $A.util.addClass(component.find('Spinner'), 'slds-hide');
        });
        $A.enqueueAction(action);
    },
    errorListHelper : function(component, event ) {
        var errorRecordsList = component.get('v.errorRecordsList');
        var successRecordsList =component.get('v.successRecordsList');
        var headerList = component.get('v.headerList');
        var headerList1 = component.get('v.headerList');
        var dataList = [];
        if (! $A.util.isEmpty(errorRecordsList) ){
            headerList.push('Status');
            headerList.push('Error Description');
            headerList.push('System Error');
            headerList.push("\n");
            var hiddenElement = document.createElement('a');
            hiddenElement.href =  'data:text/csv;charset=utf-8,' + headerList + errorRecordsList.join("\n");
            hiddenElement.download = 'ExportData.csv'; 
            hiddenElement.click();
            if(! $A.util.isEmpty(successRecordsList)){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "title": "success",
                "type": "success",
                "message": "Successfully inserted."
            });
            toastEvent.fire();
                headerList1.push('Status');
                headerList1.push("\n");
                var successRecords = document.createElement('a');
                successRecords.href =  'data:text/csv;charset=utf-8,' + headerList + successRecordsList.join("\n");
                successRecords.download = 'ExportData.csv'; 
                successRecords.click();
            }
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "error!",
                "type": "error",
                "message": "Download error item is empty."
            });
            toastEvent.fire();
        }
    },
})