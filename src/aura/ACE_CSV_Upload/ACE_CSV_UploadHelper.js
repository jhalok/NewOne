({
    CSV2JSON: function (component,csv) {        
        var arr = [];        
        var requiredFields = {"Lead Name":true,  "Contact Number":true, "Email": false,"Vehicle Model": true, "Source":true, "Sub-source":true};
        var headerWrapperfieldsMap = {"Lead Name":"leadName",  "Contact Number":"leadNumber", "Email": "email","Vehicle Model": "model", "Source":"source", "Sub-source":"subsource"};
        arr =  csv.split('\n');
        if(arr.length < 10001){
            arr.pop();
            var jsonObj = [];
            var headers = arr[0].split(',');
            for(var i = 1; i < arr.length; i++) {
                var data = arr[i].split(',');
                var obj = {};
                var leadRecFields = [];
                var checkFlag =  0;
                for(var j = 0; j < data.length; j++) {
                    var fieldDetail = {"validated": true, "ErrorDetail":'', "fieldData":'', "fieldServiceUtilName":''};
                    fieldDetail["fieldServiceUtilName"] = headerWrapperfieldsMap[headers[j].trim()];
                    if($A.util.isEmpty(data[j].trim())){
                        if(requiredFields[headers[j].trim()]){
                            fieldDetail["validated"] = false;
                            fieldDetail["ErrorDetail"] = 'This is required field.';
                            checkFlag = 1;
                        }
                    }else if(headers[j].trim() == 'Email' || headers[j].trim() == 'Contact Number'){
                        if(headers[j].trim() == 'Email'){
                            var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
                            var isValid = reg.test(data[j].trim());
                            if(!isValid){
                                fieldDetail["validated"] = false;
                                fieldDetail["ErrorDetail"] = 'The format is Invalid.';
                                checkFlag = 1;
                            }
                            fieldDetail["fieldData"] = data[j].trim();
                        }
                        if(headers[j].trim() == 'Contact Number'){
                            var contactReg = /([(+]*[0-9]+[()+. -]*)/;
                            var isValid = contactReg.test(data[j].trim());
                            if(isValid){
                                var regex = /^\d{10}$/;
                                if(!regex.test(data[j].trim())){
                                    fieldDetail["validated"] = false;
                                    fieldDetail["ErrorDetail"] = 'Contact Number is Invalid.';
                                    checkFlag = 1;
                                }
                            } else{
                                fieldDetail["validated"] = false;
                                fieldDetail["ErrorDetail"] = 'Contact Number is Invalid.';
                                checkFlag = 1;
                            }
                            fieldDetail["fieldData"] = data[j].trim();
                            
                        }
                    }else{
                        fieldDetail["fieldData"] = data[j].trim();
                    }
                    leadRecFields.push(fieldDetail);
                }
                obj["leadRec"] = leadRecFields;            
                obj["isValidated"] = checkFlag == 1 ? false : true;
                jsonObj.push(obj);
            }
            //component.set('v.totalList',jsonObj);
            var wrapperRecCollection =  {"headers": headers, "leadRecords": jsonObj};
            //var json = JSON.stringify(jsonObj);
            //console.log('@@@ json = '+ json);
            return wrapperRecCollection;
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "Record count should be less than 10000."
            });
            toastEvent.fire();
        }
    },
    getErrorLog : function (component,csv){
        console.log('getErrorLog');
        var arr = [];        
        var requiredFields = {"Lead Name":true,  "Contact Number":true, "Email": false,"Vehicle Model": true, "Source":true, "Sub-source":true};        
        arr =  csv.split('\n');        
        arr.pop();
        var errorRecords = [];
        var headers = arr[0].split(',');
        errorRecords.push(arr[0]);
        console.log('getErrorLog---2');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};            
            var checkFlag =  false;
            for(var j = 0; j < data.length; j++) {                
                if($A.util.isEmpty(data[j].trim())){
                    if(requiredFields[headers[j].trim()]){                    	
                        checkFlag = true;
                    }
                }
            }
            if(checkFlag){
                errorRecords.push(arr[i]);
            }
        }
        var errorCSV = document.createElement('a');
        errorCSV.href =  'data:text/csv;charset=utf-8,' +  errorRecords.join("\n");
        errorCSV.download = 'ExportData.csv'; 
        errorCSV.click();
        console.log(errorRecords);
    },
    paginateRecords : function(component, pageSize, allLeadRecs){
        var allRecs = [];
        var len = allLeadRecs.length;
        for(var z=0 ; z < len ; z++){
            allRecs.push(Object.assign({}, allLeadRecs[z]));
        }
        console.log('Start');
        var listOfList = [];
        var count = 0;
        var allRecordLength = allRecs.length;
        var totalPage = Math.ceil(allRecordLength/pageSize);
        component.set('v.lastPageNum',totalPage);
        console.log('Start-loop total page'+totalPage);
        for(var j=0 ; j < totalPage ; j++){
            var recordlistPack = [];
            for(var i=0;i<pageSize;i++){
                if (count <= allRecordLength){
                    recordlistPack.push(allRecs[count]);
                    count++;
                }
            }
            listOfList.push(recordlistPack);
        }
        console.log('end-loop');
        component.set('v.paginatedList',listOfList);        
        console.log('End');
        return listOfList[0];
    },
   processResponseFile : function(component, pageSize, records){
        var headerApi = ["leadResponse", "leadName","leadNumber", "email", "model", "source", "subsource"];
        var responseHeader = ["Status","Lead Name",  "Contact Number", "Email","Vehicle Model", "Source", "Sub-source"];
        var responseToShow = [];
        for(var index in records){
            var col = [];			
            var leadObj = records[index];
			col.push(leadObj);
            console.log(leadObj.leadData);
			col.push(leadObj.leadData.LastName);
			col.push(leadObj.leadData.MobilePhone);
			col.push(leadObj.leadData.Email);
			col.push(leadObj.relatedProductInterests[0].productInterest.Name);
			col.push(leadObj.relatedProductInterests[0].relatedSourceTrackers[0].sourceTracker.ACE_Source__c );
			col.push(leadObj.relatedProductInterests[0].relatedSourceTrackers[0].sourceTracker.ACE_SubSource__c );
			responseToShow.push(col);
        }               
       var count = 0;
        var listOfList = [];
        var totalPage = Math.ceil(responseToShow.length/pageSize);
        for(var j=0 ; j < totalPage ; j++){
            var listPack = [];
            for(var i=0;i<pageSize;i++){
                if (count <= responseToShow.length){
                    listPack.push(responseToShow[count]);
                    count++;
                }
            }
            listOfList.push(listPack);
        }
        console.log(listOfList[0]);
       component.set("v.respCurrentPageNum",1);
        component.set("v.respListOfList",listOfList);
        component.set("v.resplastPageNum",totalPage);
        component.set("v.responseHeader",responseHeader);
        component.set("v.responseToshow",listOfList[0]);
        component.set("v.allRespRows",responseToShow);
        component.set('v.activeSections','B');
       	
    },
    setPageSize : function(component, pageSize, records){
        var count = 0;
        var listOfList = [];
        var totalPage = Math.ceil(records.length/pageSize);
        for(var j=0 ; j < totalPage ; j++){
            var listPack = [];
            for(var i=0;i<pageSize;i++){
                if (count <= records.length){
                    listPack.push(records[count]);
                    count++;
                }
            }
            listOfList.push(listPack);
        }
        console.log(listOfList);
        component.set("v.respListOfList",listOfList);
        component.set("v.resplastPageNum",totalPage);
        component.set("v.responseToshow",listOfList[0]);
    },
    processCreatedRecord : function(component, event, helper){
        //get index Location on list
        //create list from that index to chunkSize or till all records.
        //
        
    },
    insertServerCall : function(component, event, recordList){
        //send records to the server side 
    },
    getProductInterestInstance : function(component, obj, helper){
        var SourceTrackerList = [];
        var proInterestObj = {};
        proInterestObj.productInterest = {'sobjectType':'ACE_Product_Interest__c','Name':obj.model};
        proInterestObj.productInterestStatus = '';
        proInterestObj.productInterestExcetion = '';
        SourceTrackerList.push(helper.getSourceTrackerInstance(component, obj, helper));
        proInterestObj.relatedSourceTrackers = SourceTrackerList;
        return proInterestObj;
    },
    getSourceTrackerInstance : function(component, obj, helper){
        var sourceTrackerObj = {};
        sourceTrackerObj.sourceTracker = {'sobjectType':' ACE_Source_Tracker__c','ACE_Source__c':obj.source,'ACE_SubSource__c':obj.subsource };
        sourceTrackerObj.sourceTrackerStatus='';
        sourceTrackerObj.sourceTrackerExcetion='';
        return sourceTrackerObj;
    },
     showSuccessToast : function(component, event, helper, message, title, Type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            type: Type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
})