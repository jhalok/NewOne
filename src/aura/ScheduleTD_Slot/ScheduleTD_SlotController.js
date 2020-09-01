({
	openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.set("v.isModalOpen", true);
        var rowId=component.get('v.row');
        var colId=component.get('v.col');
        
        
        var idx = event.target.id; 
        console.log('idx--'+idx);
        var splitStr=idx.split('_');
        var slot=splitStr[0];
        var hubId=splitStr[1];
        var cmpEvt=component.getEvent('slotEvt');
        cmpEvt.setParams({"rowId":rowId,"colId":colId,"hubVal":hubId,"slotVal":slot});
        cmpEvt.fire();
        console.log('rowId'+rowId+'--colId'+colId);
        console.log('Slot='+slot+'--hubId='+hubId);
        //component.set("v.hubVal", 'Hub '+hubId);
        //component.set("v.slotVal", slot);
        
        /*component.set("v.isSlotSelected", true);
        var arrCmp = component.find("tabTime2");
        for(var cmp in arrCmp) {
            console.log('--arrCmp[cmp]='+arrCmp[cmp].id);
            //$A.util.toggleClass(arrCmp[cmp], 'clickSlot');
        }*/
    },
})