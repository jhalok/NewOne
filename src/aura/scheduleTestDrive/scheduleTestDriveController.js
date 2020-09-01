({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        //var listData = new Array(6);
        //var timeSheet = ['8:00 AM','9:00 AM','10:00 AM','11:00 AM','12:00 PM','1:00 PM','2:00 PM','3:00 PM','4:00 PM','5:00 PM','6:00 PM','7:00 PM','8:00 PM'];
        var listData = [];
        listData.push({value:true, key:'1', booked:''});
        listData.push({value:true, key:'2', booked:';11:00 AM;1:00 PM;'});
        listData.push({value:false, key:'3', booked:';9:00 AM;'});
        listData.push({value:true, key:'4', booked:';2:00 PM;'});
        listData.push({value:false, key:'5', booked:';4:00 PM;6:00 PM;7:00 PM;'});
        listData.push({value:false, key:'6', booked:';8:00 AM;11:00 AM;'});
        var timeSheet = [];
        timeSheet.push({value:true, key:'8:00 AM'});
        timeSheet.push({value:true, key:'9:00 AM'});
        timeSheet.push({value:false, key:'10:00 AM'});
        timeSheet.push({value:false, key:'11:00 AM'});
        timeSheet.push({value:false, key:'12:00 PM'});
        timeSheet.push({value:true, key:'1:00 PM'});
        timeSheet.push({value:true, key:'2:00 PM'});
        timeSheet.push({value:false, key:'3:00 PM'});
        timeSheet.push({value:true, key:'4:00 PM'});
        timeSheet.push({value:true, key:'5:00 PM'});
        timeSheet.push({value:true, key:'6:00 PM'});
        timeSheet.push({value:false, key:'7:00 PM'});
        timeSheet.push({value:true, key:'8:00 PM'});
        
        cmp.set("v.timeSheet", timeSheet);
        cmp.set("v.allData", listData);
        
        var disableSlotsMap=new Map();
        disableSlotsMap.set('2','10:00 AM');
        disableSlotsMap.set('5','11:00 AM');
        disableSlotsMap.set('3','2:00 PM');
        cmp.set("v.disableSlotsMap", disableSlotsMap);
        
        var tomorrow = new Date();
        tomorrow.setDate(new Date().getDate()+1);
        var d1 = String(tomorrow.getDate()).padStart(2, '0');
        var m1 = String(tomorrow.getMonth() + 1).padStart(2, '0'); //January is 0!
        var y1 = tomorrow.getFullYear();
        cmp.set("v.minDate", y1+'-'+m1+'-'+d1);
        var nthDay = new Date();
        nthDay.setDate(new Date().getDate()+7);
        var d2 = String(nthDay.getDate()).padStart(2, '0');
        var m2 = String(nthDay.getMonth() + 1).padStart(2, '0'); //January is 0!
        var y2 = nthDay.getFullYear();
        cmp.set("v.maxDate", y2+'-'+m2+'-'+d2);
        
    },
    isValidDate: function(component, event, helper) {
        var target = event.getSource();
        if(!$A.util.isUndefinedOrNull(target)) {
            var enteredValue = target.get("v.value");
            var today = new Date();
            if(Date.parse(enteredValue) <= today.getTime()){
                component.set("v.dateSelected",null);
                helper.showErrorMsg('Invalid Date Selected.');
            }else{
                var linkObjEvt = component.getEvent("linkObjEvt");
                linkObjEvt.setParams({"sObjectName":"Date","sObjRecId":null,"sObjRecName":component.get("v.dateSelected")});
                linkObjEvt.fire();
            }
        }
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.set("v.isModalOpen", true);
        var idx = event.target.id; 
        console.log('idx--'+idx);
        var splitStr=idx.split('_');
        var slot=splitStr[0];
        var hubId=splitStr[1];
        console.log('Slot='+slot+'--hubId='+hubId);
        component.set("v.hubVal", 'Hub '+hubId);
        component.set("v.slotVal", slot);
        component.set("v.isSlotSelected", true);
        var arrCmp = component.find("tabTime2");
        for(var cmp in arrCmp) {
            console.log('--arrCmp[cmp]='+arrCmp[cmp].id);
            //$A.util.toggleClass(arrCmp[cmp], 'clickSlot');
        }

    },
    
    /*chkRowColEnblDsbl: function(component, event, helper) {
        console.log('Test'+event.getSource().get("v.aura:Id"));
        return false;
    },*/
    
    slotClicked : function(component, event){
        component.set("v.isSlotSelected", false);
        var rowId = event.getParam("rowId");
        var colId = event.getParam("colId");
        var hubId = event.getParam("hubVal");
        var slot = event.getParam("slotVal");
        // set the handler attributes based on event data
        component.set("v.selSlotCell", rowId+'_'+colId);
        console.log('parent--'+component.get("v.selSlotCell"));
        console.log('Slot='+slot+'--hubId='+hubId);
        component.set("v.hubVal", 'Hub '+hubId);
        component.set("v.slotVal", slot);
        component.set("v.isSlotSelected", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    searchSlots:function(component, event, helper) {
        var dateSelected=component.get("v.dateSelected");
        if(dateSelected!=null && dateSelected!=''){
            console.log('fetch record....API');
        }else{
            helper.showErrorMsg("Please select a date for booking test drive.");
        }
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
    },
})