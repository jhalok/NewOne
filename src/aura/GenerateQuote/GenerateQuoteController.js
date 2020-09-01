({
	doInit: function (component, event, helper) {
		component.set("v.showSpinner", "true");
		component.set("v.showButton", "false");
		let action = component.get("c.getProducts");
		let oppId = component.get("v.recordId");
		action.setParams({
			"oppId": oppId
		});

		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state == "SUCCESS") {
				component.set("v.showSpinner", "false");
				let fields = response.getReturnValue();
				if(fields.length > 0){
					helper.doInitHelper(component, event, helper,fields);
				}
				component.set("v.showButton", "true");
			}
		});
		$A.enqueueAction(action);
		let action1 = component.get("c.getOppDetails");
		
		action1.setParams({
			"oppId": oppId
		});

		action1.setCallback(this, function (response) {
			let state1 = response.getState();
			if (state1 == "SUCCESS") {
				component.set("v.showSpinner", "false");
				let opp = response.getReturnValue();
				console.log('opp 222222 is ',opp,opp.OpportunityLineItems[0].Product2.Name);
			
					component.set("v.oppDetails", "opp");
					component.set("v.primaryProdName", opp.OpportunityLineItems[0].Product2.Name);
					component.set("v.pimaryProdPrice", opp.OpportunityLineItems[0].UnitPrice);
					component.set("v.conName", opp.Contact__r.Name);
				
				component.set("v.showButton", "true");
			}
		});
		$A.enqueueAction(action1);
	},
	handleLoad: function (component, event, helper) {
		alert('handle Load ');
		component.set("v.showSpinner", "true");
		let fieldsValue = component.get("v.fields");
		if (fieldsValue != null) {
			component.set("v.showSpinner", "false");
			component.set("v.showButton", "true");
		}
	},
	handleSubmit: function (component, event, helper) {

		let isEdit = component.get("v.isEdit");
		// If used as Edit button or not.
		if (!isEdit) {
			helper.handleSubmit(component, event, helper);
		} else {
			helper.editQuoteSave(component, event, helper);
		}
	},
	handleSuccess: function (component, event, helper) {
		let oppId = component.get("v.recordId");
		let quoteId = component.get("v.quoteId");
	},
	handleCancel: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	prodChange: function (component, event, helper) {
		let adOnValue = component.get("v.adOnValue");
		let selectedOptionValue = event.getParam("value");
		let addOnFieldsMap = component.get("v.addOnFieldsMap");
		console.log("value is ", selectedOptionValue);
		let fields = addOnFieldsMap.get(selectedOptionValue);
		let label = fields.prodType;
		let addFlag = true;
		console.log("label is ", label);

		let obj = {};
		obj.label = label;
		obj.price = fields.unitPrice;
		obj.prodId = selectedOptionValue;

		for (let i = 0; i < adOnValue.length; i++) {
			if (adOnValue[i].label == label) {
				addFlag = false;
				adOnValue[i].price = fields.unitPrice;
				adOnValue[i].prodId = selectedOptionValue;
			}
		}
		if (addFlag) {
			adOnValue.push(obj);
		}
		component.set("v.adOnValue", adOnValue);

		// Check for change in addOnvalue with default Values.
		/*let defaultMap		 = component.get("v.defaultMap");
		let newProdChangeMap = component.get("v.newProdChangeMap");
		if(defaultMap.size == undefined){
			defaultMap =  new Map();
		}
		if(newProdChangeMap.size == undefined){
			newProdChangeMap = new Map();
		}
		if(defaultMap.has(label) && (defaultMap.get(label).id != selectedOptionValue)){
			newProdChangeMap.set(label, selectedOptionValue);
			component.set("v.newProdChangeMap",newProdChangeMap);
		}
		else if(!defaultMap.has(label)){
			newProdChangeMap.set(label, selectedOptionValue);
			component.set("v.newProdChangeMap",newProdChangeMap);
		}*/

	}
});