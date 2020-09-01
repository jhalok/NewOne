({
    doInIt : function(component, event, helper) {
		helper.fetchFieldsHelper(component, event);
	},
    downloadCsvTemplate : function(component, event, helper) {
		helper.downloadCsvTemplateHelper(component, event);
	},
    uploadCSV : function(component, event, helper) {
        var files = event.getSource().get("v.files");
        var data = [];
        Papa.parse(files[0], {
            complete: function(results) {
                helper.uploadCsvHelper(component, event,results.data);
            }
        });
	},
    errorList : function(component, event, helper) {
		helper.errorListHelper(component, event);
	},
    scriptsLoaded : function(component, event, helper){
        
    }
})