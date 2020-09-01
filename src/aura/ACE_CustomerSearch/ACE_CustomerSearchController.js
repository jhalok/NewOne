({
	handleClick : function(component, event, helper) {
        var searchText = component.get('v.searchText');
        helper.fetchResults(component,searchText);
      /*var action = component.get('c.searchRecords');
      action.setParams({searchText: searchText});
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === 'SUCCESS') {
          var recordList = response.getReturnValue();
            component.set('v.recordList',recordList);
        }
      });
      $A.enqueueAction(action);*/
    }
    ,
    /*Added by Sanchayan*/
    doInit : function(component, event, helper) {
        var sPageURL = window.location.href;
        var dcodedUrl=decodeURIComponent(sPageURL);
        console.log('dcodedUrl='+dcodedUrl);
        var idx=dcodedUrl.indexOf("?")+1;
        var urlParams=dcodedUrl.substring(idx);
        console.log('urlParams='+urlParams);
        var sURLVariables = urlParams.split('&');
        console.log('sURLVariables='+sURLVariables);
        var paramMap=new Map();

        for (var i = 0; i < sURLVariables.length; i++) {
            if(sURLVariables[i].indexOf('=')>0){
                var rowDataList = sURLVariables[i].split('=');
                console.log('rowDataList='+rowDataList);
                paramMap.set(rowDataList[0],rowDataList[1]);
            }
        }
        
        if(paramMap.size>0){
            if(paramMap.has('c__mobile')){
                console.log('PARAM mobile==='+paramMap.get('c__mobile'));
                component.set('v.searchText',paramMap.get('c__mobile'));
                helper.fetchResults(component,paramMap.get('c__mobile'));
            }
        }
        
    }
})