({
    //Specifying progress === 100 ? clearInterval(interval) : progress + 20 increases
    //the progress value by 20% and stops the animation when the progress reaches 100%
    //The progress bar is updated every 1000 milliseconds.
    doInit:  function (component, event, helper) {
        var interval = setInterval($A.getCallback(function () {
            var progress = component.get('v.progress');
            component.set('v.progress', progress === 100 ? clearInterval(interval) : progress + 20);
        }), 1000);
        // alert("Success");
    },
    getSampleFile: function (component, event, helper) {
        var csvSample = 'Lead Name, Contact Number, Email, Vehicle Model, Source, Sub-source';
        var sampleCSV = document.createElement('a');
        sampleCSV.href =  'data:text/csv;charset=utf-8,' +csvSample+ "\n";
        sampleCSV.download = 'SampleCSV.csv'; 
        sampleCSV.click();
    },
    getErrorItems: function (component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                helper.getErrorLog(component,csv);
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "No Document uploaded."
            });
            toastEvent.fire();
        }
    },
    processRecords: function (component, event, helper) {
        $A.util.removeClass(component.find("spinner"), "slds-hide");
        component.set('v.isLoading',true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                component.set('v.leadReport', result);
                window.setTimeout(function(){
                    var pageSize = component.get("v.pageSize"); 
                    //--------------------------------------
                    var reportRecord = result;        
                    var recordsNotToInsert = [];
                    var innerList = [];
                    console.log(reportRecord.leadRecords);
                    /*for(var i = 0; i < reportRecord.leadRecords.length; i++) {
                        if(!reportRecord.leadRecords[i].isValidated){
                            recordsNotToInsert.push(reportRecord.leadRecords[i]); 
                        } 
                    }*/
                    //var allRecs =recordsNotToInsert;
                    var allRecs =reportRecord.leadRecords;
                    //------------------------------------
                    var recsToShow =  helper.paginateRecords(component, pageSize, allRecs);  
                    component.set('v.recordsToShow', recsToShow);
                    $A.util.addClass(component.find("spinner"), "slds-hide");
                }, 100);
                
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type : "Error",
                title: "Error!",
                message: "No Document uploaded."
            });
            toastEvent.fire();
        }
        component.set('v.isLoading',false);
    },
    createRecords: function (component, event, helper) {
        $A.util.removeClass(component.find("spinner"), "slds-hide");
        console.log('Called---');
        var reportRecord = component.get('v.leadReport');        
        var recordsToInsert = [];
        //console.log(reportRecord);
        for(var i = 0; i < reportRecord.leadRecords.length; i++) {
            //console.log('Called---1');
            if(reportRecord.leadRecords[i].isValidated){
                //console.log('Called---2');
                var leRec = {};
                //console.log(reportRecord.leadRecords[i].leadRec);
                for(var j = 0; j < reportRecord.leadRecords[i].leadRec.length ; j++){                    
                    leRec[reportRecord.leadRecords[i].leadRec[j].fieldServiceUtilName] = reportRecord.leadRecords[i].leadRec[j].fieldData;
                }
                recordsToInsert.push(leRec);
            } 
        }
        console.log('Called---2');
        console.log(recordsToInsert);
        /*var leadpushList = [];
        for(var index in recordsToInsert){
            var leadobj = {};
            leadobj.leadName = recordsToInsert[index].leadName;
            leadobj.leadNumber = recordsToInsert[index].leadNumber;
            leadobj.city ='';
            leadobj.email = recordsToInsert[index].email;
            leadobj.state = '';
            leadobj.source = recordsToInsert[index].source
            leadobj.subsource = recordsToInsert[index].subsource;
            leadobj.groupCode = '';
            leadobj.model = recordsToInsert[index].model;
            leadobj.partnerAccountId = '';
            leadpushList.push(leadobj);
        }*/
        var leadDetailList = [];
        for(var index in recordsToInsert){
            var obj = recordsToInsert[index];
            var proInterestList = [];
            var leadDetail = {};
            var lead = {'sobjectType':'Lead','lastName':obj.leadName,'mobilePhone':obj.leadNumber,'city':obj.city,'email':obj.email,'state':obj.state};
            leadDetail.leadData = lead;
            leadDetail.leadStatus = '';
            leadDetail.leadExcetion = 'None';
            proInterestList.push(helper.getProductInterestInstance(component, obj, helper));
            leadDetail.relatedProductInterests = proInterestList;
            leadDetailList.push(leadDetail);
        }
        console.log('Called---3');
        console.log(leadDetailList);
        /*var recordCount = leadpushList.length;
        var chunkSize = recordCount/500;
        var listOfChunks = [];
        var count = 0;
        for(var i=0;i<chunkSize;i++){
            var chunk = [];
            for(var j=0;i<500;j++){
                if(count<recordCount){
                    chunk.push(leadpushList[count]);
                }
                count++;
            }
            listOfChunks.push(chunk);
        }*/
        
        var action = component.get('c.processCSVRecords');
        console.log('Success'+JSON.stringify(leadDetailList[0]));
        action.setParams({ CSVRecordsJson : JSON.stringify(leadDetailList)});
        action.setCallback(this,function(response){
            if( response.getState() == 'SUCCESS' ){
                helper.showSuccessToast(component, event, helper, 'Your request is processed !','Successflly Created','Success');
                console.log('Success');
                console.log(response.getReturnValue());
                var records = JSON.parse(response.getReturnValue());
                console.log(records);
                var pageSize =10;
                helper.processResponseFile(component, pageSize, records);
            } else{
                console.log(response.getError());
            }
            $A.util.addClass(component.find("spinner"), "slds-hide");
        });
        console.log('Called---7');
        $A.enqueueAction(action);
    },
    firstPage : function(component, event, helper){
        var listOfList = component.get('v.paginatedList');
        var jsonObject =  component.get('v.leadReport');
        var listToShow = listOfList[0];
        component.set('v.recordsToShow', listToShow);
        component.set('v.currentPageNum',1);
    },
    previousPage : function(component, event, helper){
        debugger;
        var listOfList = component.get('v.paginatedList');
        var crrntPage = component.get('v.currentPageNum');
        var listToShow = listOfList[crrntPage-2];
        component.set('v.recordsToShow', listToShow); 
        component.set('v.currentPageNum',crrntPage-1);
    },
    nextPage : function(component, event, helper){
        var listOfList = component.get('v.paginatedList');
        var crrntPage = component.get('v.currentPageNum');
        var listToShow = listOfList[crrntPage];
        component.set('v.recordsToShow', listToShow); 
        component.set('v.currentPageNum',crrntPage+1);
    },
    lastPage : function(component, event, helper){
        var listOfList = component.get('v.paginatedList');
        var length = listOfList.length;
        var listToShow = listOfList[length-1];
        component.set('v.recordsToShow', listToShow); 
        component.set('v.currentPageNum',length);
    },
    changelistSize : function(component, event, helper){
        component.set('v.showSpinner',true);
        console.log(component.find("spinner"));
        $A.util.removeClass(component.find("spinner"), "slds-hide");
        console.log(component.get('v.showSpinner'));
        window.setTimeout(function(){
            var pageSize = parseInt(component.find('select').get('v.value'));
            //component.set("v.pageSize", pageSize);
            console.log('2222');
            component.set('v.pageSize',pageSize);
            console.log('3333');
            //--------------------------------------
            var reportRecord = component.get('v.leadReport');        
            var recordsNotToInsert = [];
            var innerList = [];
            console.log(reportRecord.leadRecords);
            for(var i = 0; i < reportRecord.leadRecords.length; i++) {
                if(!reportRecord.leadRecords[i].isValidated){
                    recordsNotToInsert.push(reportRecord.leadRecords[i]);
                } 
            }
            console.log('4444');
            //var jsonObject = component.get('v.totalList');
            console.log('5555');
            //component.set('v.paginatedList',undefined);
            var recsToShow =  helper.paginateRecords(component, pageSize, recordsNotToInsert); 
            component.set('v.recordsToShow', recsToShow); 
            console.log('6666');
            //result.leadRecords = newlist;
            console.log('7777');
            //component.set('v.leadReport', result);
            console.log('8888');
            component.set('v.isLoading',false);
            $A.util.addClass(component.find("spinner"), "slds-hide");
        }, 100);
    },
    testfunction : function(component, event, helper){
        var responseList = [];
        var customSorce = {};
        customSorce.status = 'created';
        customSorce.sfProductIntrestRecId = '678';
        var customProduct = {};
        customProduct.status = 'created';
        customProduct.sfProductIntrestRecId = '456';
        customProduct.sourceTrackers = customSorce ;
        var customlead = {};
        customlead.status = 'Already Exsits';
        customlead.sfLeadRecId = '1234567890098765432';
        customlead.productInterests = customProduct;
        
        for(var i=0;i<40;i++){
            var responseWrapper = {};
            responseWrapper.LeadName = "Test";
            responseWrapper.leadNumber = "1234567890";
            responseWrapper.email = i+"1@g.com";
            responseWrapper.model = "XUV500";
            responseWrapper.source = "Advertise";
            responseWrapper.subsource = "facebook";
            responseWrapper.leadResponse = customlead;
            responseList.push(responseWrapper);
        }
        var pageSize = 10;
        var records =responseList;
        helper.processResponseFile(component, pageSize, records);
    },
    respFirstPage : function(component, event, helper){
        var listOfList = component.get('v.respListOfList');
        var listToShow = listOfList[0];
        component.set('v.responseToshow', listToShow);
        component.set('v.respCurrentPageNum',1);
    },
    respPreviousPage : function(component, event, helper){
        var listOfList = component.get('v.respListOfList');
        var crrntPage = component.get('v.respCurrentPageNum');
        var listToShow = listOfList[crrntPage-2];
        component.set('v.responseToshow', listToShow); 
        component.set('v.respCurrentPageNum',crrntPage-1);
    },
    respNextPage : function(component, event, helper){
        var listOfList = component.get('v.respListOfList');
        var crrntPage = component.get('v.respCurrentPageNum');
        var listToShow = listOfList[crrntPage];
        component.set('v.responseToshow', listToShow); 
        component.set('v.respCurrentPageNum',crrntPage+1);
    },
    respLastPage : function(component, event, helper){
        var listOfList = component.get('v.respListOfList');
        var length = listOfList.length;
        var listToShow = listOfList[length-1];
        component.set('v.responseToshow', listToShow); 
        component.set('v.respCurrentPageNum',length);
    },
    showPopup : function(component, event, helper){
        component.set("v.showDetail", true);
    },
    closePopup : function(component, event, helper){
        component.set("v.showDetail", false);
    },
    respchangelistSize :  function(component, event, helper){
        component.set('v.showSpinner',true);
        $A.util.removeClass(component.find("spinner"), "slds-hide");
        console.log(component.get('v.showSpinner'));
        window.setTimeout(function(){
            var pageSize = parseInt(component.find('selectresp').get('v.value'));
            var records = component.get('v.allRespRows');
            helper.setPageSize(component, pageSize, records); 
            
            component.set('v.isLoading',false);
            $A.util.addClass(component.find("spinner"), "slds-hide");
        }, 100);
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        
		console.log( );
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            console.log(openSections.join(', '));
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
            
        }
    }
})