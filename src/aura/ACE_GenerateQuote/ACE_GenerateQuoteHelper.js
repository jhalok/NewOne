({
	handleSubmit : function(component,event,helper) {
		
		event.preventDefault();
		var quoteCharges = component.get("v.quoteCharges");
		let adOnValue = component.get("v.adOnValue");
		let prodList = [];
		let flagError = false;

		let accessoriesSelected = component.get("v.accessoriesSelected");
		let listCount = adOnValue.length > accessoriesSelected.length ? adOnValue.length : accessoriesSelected.length;
		
		
			for (let i = 0; i < listCount; i++) {
				if (adOnValue.length > i && !(adOnValue[i].prodId.startsWith('none'))) {
					console.log(' product value in if is ',adOnValue[i].prodId);
					prodList.push(adOnValue[i].prodId);
				}
				if (accessoriesSelected.length > i && !(accessoriesSelected[i].prodId.startsWith('none'))) {
					console.log('product value in if when product is accessories ',accessoriesSelected[i].prodId);
					prodList.push(accessoriesSelected[i].prodId);
				}
			}
			console.log("prodlist is ", prodList);
			
			let oppId = component.get("v.recordId");
			flagError =  helper.checkQuoteError(component, event, helper, quoteCharges);
	
			if (!flagError) {
				component.set("v.showSpinner", "true");
				let action = component.get("c.insertQuote");
				action.setParams({
					"oppId": oppId,
					"quoteCharges": quoteCharges,
					"quoteLineItems": prodList
				});
				action.setCallback(this, function (response) {
					let state = response.getState();
					if (state == "SUCCESS") {
						component.set("v.showSpinner", "false");
						let quoteId = action.getReturnValue();
						component.set("v.quoteId", quoteId[0]);
						component.set("v.baseURL",quoteId[1]);
						console.log("baseURL is ",quoteId[1]);
						console.log("quoteID is ", quoteId);
						component.set("v.hideLayer", "false");
						component.set("v.showPdf", "true");
					} else {
						component.set("v.showSpinner", "false");
						alert("ERROR");
					}
				});
				$A.enqueueAction(action);
			}
		
		if(listCount <=0 && flagError==false){

			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
				"type": "error",
				"message": "Please add Products before generating the quote in the enquiry."
    		});
    		toastEvent.fire();
		}

		
	},
	editQuoteSave : function(component,event,helper){
		console.log('before save in edit ',component.get("v.beforeSaveQuote"));
		console.log('before save in edit ',component.get("v.saveBefore"));
		//const beforeSaveQuote = component.get("v.beforeSaveQuote");
		let beforeSaveQuote = [];//Added on 18-12-2019
		beforeSaveQuote.push(component.get("v.beforeSaveQuote")); //Added on 18-12-2019.
		let quoteCharges    = component.get("v.quoteCharges");
		let defaultMap		= component.get("v.defaultMap");
		let adOnValue		= component.get("v.adOnValue");
		let quoteId			= component.get("v.quoteId");
        console.log("defaultMap in editQuote is ",defaultMap);
		let flagError 		= false;
		let prodList		= [];
		flagError 			=  helper.checkQuoteError(component, event, helper, quoteCharges);
		// Check whether any fields are changed of quote, If yes then only update quote.
		let quoteChange 	= helper.checkQuoteChange(quoteCharges,beforeSaveQuote);
		
		//Check for change in quoteLineItems.
		let accessoriesSelected  = component.get("v.accessoriesSelected");
		let listCount = adOnValue.length > accessoriesSelected.length ? adOnValue.length : accessoriesSelected.length;
		for (let i = 0; i < listCount; i++) {
			if (adOnValue.length > i && !(adOnValue[i].prodId.startsWith('none'))) {
				prodList.push(adOnValue[i].prodId);
			}
			if (accessoriesSelected.length > i && !(accessoriesSelected[i].prodId.startsWith('none'))) {
				prodList.push(accessoriesSelected[i].prodId);
			}
		}
		console.log("prodlist is ", prodList);
		
		console.log("adOnValue is ",adOnValue);
		console.log("accessoriesSelected is ",accessoriesSelected);
		if(!flagError){
			let action 			= component.get("c.updateQuote");
			action.setParams({
				"quoteId" : quoteId,
				"quoteCharges":quoteCharges,
				"updateQuote" :quoteChange,
				"qLi"		  : prodList
			});
			action.setCallback(this, function(response){

				let state = response.getState();
				if(state == "SUCCESS"){
					let url = action.getReturnValue();
					console.log('url in update is ',url);
						component.set("v.quoteId", quoteId);
						component.set("v.baseURL",url);
						console.log("baseURL is ",quoteId);
						console.log("quoteID is ", url);
						component.set("v.hideLayer", "false");
						component.set("v.showPdf", "true");

				}else{
					alert("ERROR in Editing");
				}
			});
			$A.enqueueAction(action);
		}
		
		/*let defaultAccObj			= defaultMap.has("Accessories") ? defaultMap.get("Accessories") : [];
		let newProdChangeMap= component.get("v.newProdChangeMap");
		let newAccessories			= [];
		let accToDel				= [];
		let accToInsert				= [];
		// Check for changes in apex side with quiery.
		let listCount				= accessoriesSelected.length > defaultAcc.length ? accessoriesSelected.length : defaultAcc.length;
		if(newProdChangeMap == null){
			newProdChangeMap = new Map();
		}
		if(defaultAccObj.length > 0){
			// Elements that aren't in accessories selected but are in defaultAcc. Use these to del acc.
			for(let i = 0; i < defaultAccObj.length; i ++){
				let notRemove = false;
				for(let j = 0; j < accessoriesSelectedObj.length; j++){
					if(defaultAccObj[i].id == accessoriesSelectedObj[j].prodId){
						notRemove = true;
						break;
					}
				}
				if(!notRemove){
					accToDel.push(defaultAccObj[i].id);
				}
			}
			// Remove elements that are common in both default and accessory selected list from accessory selected.
			for(let i = 0; i < accessoriesSelectedObj.length; i++){
				let toInsert = true;
				for(let j = 0; j < defaultAccObj.length; j++){
					if(accessoriesSelectedObj[i].prodId == defaultAccObj[j].id){
						toInsert = false;
						break;
					}
				}
				if(toInsert){
					accToInsert.push(accessoriesSelectedObj[i].prodId);
				}
			}
			console.log("accToDel are ",accToDel);
			console.log("accToInsert ",accToInsert);
			newProdChangeMap.set("Accessories",accToInsert);

		}
		else if(accessoriesSelected.length > 0){
			newProdChangeMap.set("Accessories",accessoriesSelected);
		}*/
		
	},
	checkQuoteError : function(component, event, helper, quoteCharges){
		// Check whether quote fields are filled or not.
		let flagError = false;
		if (quoteCharges.Incidental_Charges__c == null || quoteCharges.Registration__c == null || quoteCharges.Road_Safety_Tax__c == null || quoteCharges.Insurance__c == null || quoteCharges.Zero_Depreciation_Insurance_Cost__c == null || quoteCharges.Dealer_Discount_Special_Discount__c == null) {
			flagError = true;
			// Add toast component here.
			if (flagError == true) {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": 'error',
					"title": "Error",
					"message": "Please fill required field."
				});
				toastEvent.fire();
			}
		}
		return flagError;
	},
	checkQuoteChange : function(quoteCharges, bfreQuote){
		//Added on 18-12-2019.
		if(quoteCharges.Incidental_Charges__c != bfreQuote[0].Incidental_Charges__c || quoteCharges.Registration__c != bfreQuote[0].Registration__c || quoteCharges.Dealer_Discount_Special_Discount__c != bfreQuote[0].Dealer_Discount_Special_Discount__c || quoteCharges.Road_Safety_Tax__c != bfreQuote[0].Road_Safety_Tax__c || quoteCharges.Insurance__c != bfreQuote[0].Insurance__c || quoteCharges.Zero_Depreciation_Insurance_Cost__c != bfreQuote[0].Zero_Depreciation_Insurance_Cost__c){
			return true;
		}
		else{
			return false;
		}
	},
	doInitHelper:function(component,event,helper,fields){
		console.log('before save -- ',component.get("v.beforeSaveQuote"));
		console.log('before save -- ',component.get("v.beforeSaveQuote"));
		var saveBefore=component.get("v.beforeSaveQuote");
		component.set("v.saveBefore", saveBefore);
		console.log("fields are ", fields);
		let addOnFields = [];
		let addOnFieldsMap = new Map();
		let tempType = fields[0].prodType;
		console.log("tempType is ", tempType);
		let tempArr = [];
		let tempAccArr = [];
		let adOnValue = [];
		let defaultMap = component.get("v.defaultMap");
		let flagAddAcc = true;

		tempArr.push({
			label: "None",
			prodType: fields[0].prodType,
			unitPrice: 0,
			value: "none" + fields[0].prodType
		});
		tempAccArr.push({
			label: "None",
			prodId: "none12",
			prodType: "Accessories",
			selected: false,
			unitPrice: 0,
			value: "none"
		});
		console.log('tempAccArr in init is ', tempAccArr);
		console.log('defaultMap is ', defaultMap);
		if (defaultMap.size == undefined) {
			defaultMap = new Map();
		}

		for (let i = 0; i < fields.length; i++) {

			addOnFieldsMap.set(fields[i].value, fields[i]);
			addOnFieldsMap.set(("none" + fields[i].prodType), {
				label: "None",
				prodType: fields[i].prodType,
				unitPrice: 0,
				value: "none" + fields[0].prodType
			});
			console.log('addOnFieldsMap @@@@@@@@@', addOnFieldsMap);
			if (fields[i].prodType != 'Accessories') {
				if (tempType == fields[i].prodType) {
					tempArr.push(fields[i]);
				} else if (tempType != fields[i].prodType && i != fields.length - 1) {
					let opt = {};
					opt.label = tempType;
					opt.value = tempArr;
					opt.default = defaultMap.has(tempType) ? defaultMap.get(tempType).id : (tempArr[0].value).toString();
					// To pre populate adOnValues.
					let adOnObj = {};
					adOnObj.label = tempType;
					adOnObj.price = defaultMap.has(tempType) ? defaultMap.get(tempType).default : tempArr[0].unitPrice;
					adOnObj.prodId = defaultMap.has(tempType) ? defaultMap.get(tempType).id : tempArr[0].value;
					adOnValue.push(adOnObj);


					addOnFields.push(opt);
					console.log('########### addONFields are ', addOnFields);
					tempArr = [];
					tempArr.push({
						label: "None",
						prodType: fields[i].prodType,
						unitPrice: 0,
						value: "none" + fields[i].prodType
					});
					tempType = fields[i].prodType;
					tempArr.push(fields[i]);
					console.log('tempArr at 61 is ', tempArr);
				}
				if (i == fields.length - 1) {
					let opt = {};
					//tempArr.push({label: "None",prodType:"RSA" ,unitPrice: 0,value: "none1234"});
					opt.label = tempType;
					opt.value = tempArr;
					opt.default = defaultMap.has(tempType) ? defaultMap.get(tempType).id : (tempArr[0].value).toString();

					let adOnObj = {};
					adOnObj.label = tempType;
					adOnObj.price = defaultMap.has(tempType) ? defaultMap.get(tempType).default : tempArr[0].unitPrice;
					adOnObj.prodId = defaultMap.has(tempType) ? defaultMap.get(tempType).id : tempArr[0].value;
					adOnValue.push(adOnObj);

					addOnFields.push(opt);
				}
			}
			// IF it is Accessories.
			else if (fields[i].prodType == 'Accessories') {
				fields[i].prodId = fields[i].value;
				if (flagAddAcc && defaultMap.size == 0) {
					fields[i].selected = true;

					flagAddAcc = false;
				} else if (defaultMap.size == 0 && !flagAddAcc) {
					fields[i].selected = false;
				}
				// If defaultMap has values then add those all values as default in acc.
				else {
					let accVal = defaultMap.has(fields[i].prodType) ? defaultMap.get(fields[i].prodType) : [];
					console.log("accVal is ", accVal);
					for (let j = 0; j < accVal.length; j++) {
						fields[i].prodId = accVal[j].id;
						if (fields[i].value == accVal[j].id) {
							fields[i].selected = true;
							break;
						} else {
							fields[i].selected = false;
						}
					}
				}
				let fieldNone = [];


				tempAccArr.push(fields[i]);

				console.log('value of tempAccArr is ', tempAccArr);

				if (i == fields.length - 1) {
					console.log('Enter in if');
					let opt = {};
					opt.label = tempType;
					opt.value = tempArr;
					opt.default = defaultMap.has(tempType) ? defaultMap.get(tempType).id : (tempArr[0].value).toString();
					let adOnObj = {};
					console.log('temp Type is ', tempType);
					adOnObj.label = tempType;
					adOnObj.price = defaultMap.has(tempType) ? defaultMap.get(tempType).default : tempArr[0].unitPrice;
					adOnObj.prodId = defaultMap.has(tempType) ? defaultMap.get(tempType).id : tempArr[0].value;
					adOnValue.push(adOnObj);
					console.log('opt in accessories is ', opt);
					addOnFields.push(opt);
					console.log()
				}
			}

		}

		console.log("addOnFields is ", addOnFields);
		console.log("adOnValue ", adOnValue);
		component.set("v.adOnValue", adOnValue);
		console.log("addOnFieldsMap is ", addOnFieldsMap);
		component.set("v.addOnFieldsMap", addOnFieldsMap);
		component.set("v.prodType", addOnFields);
		component.set("v.accessoriesOptions", tempAccArr);
		
	}
});