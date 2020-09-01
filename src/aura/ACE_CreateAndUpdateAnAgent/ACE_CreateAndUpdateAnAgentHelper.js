({
    chagePageSize: function (component, event, helper) {
        var pgsize = component.find('selectpageSize').get('v.value');
        component.set("v.pageSize",pgsize);
        component.set("v.pageNo",1);
        var pageSize = component.get("v.pageSize");
        var totalRecords = component.get("v.totalRecords");
        var allRecords = component.get("v.allRecords");
        var recordforshow=[];
        if(pageSize > totalRecords ){
            pageSize = totalRecords;
        }
        var i;
        for (i = 0; i < pageSize; i++) { 
            recordforshow.push(allRecords[i]);
        }
        var totalrecord = component.get("v.totalRecords");
        var totalpage1;
        if(totalrecord % component.get("v.pageSize")!==0){
            totalpage1 = totalrecord / component.get("v.pageSize");
            var totalpg = Math.floor(totalpage1);
            totalpage1 = totalpg+1;
        }else{
            totalpage1 = totalrecord / component.get("v.pageSize");
        }
        component.set("v.tatalPage",totalpage1);  
        this.showAndHidebtn(component, event, helper);
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        this.btns(component, event, helper);
    },
    
    first: function (component, event, helper) {
        component.set("v.show",!component.get("v.show"));
        component.set("v.Methodrun",false);
        var pgno = component.get("v.pageNo");
        var allRecords = component.get("v.allRecords");
        component.set("v.pageNo",1);
        
        var pageSize = component.get("v.pageSize");
        var recordforshow=[];
        var i;
        for (i = 0; i < pageSize; i++) { 
            recordforshow.push(allRecords[i]);
        }
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        helper.showAndHidebtn(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        this.btns(component, event, helper);
        component.set("v.show",!component.get("v.show"));
        
    },
    previous: function (component, event, helper) {
        var showVal = component.get('v.show'); 
        component.set("v.show",!component.get("v.show"));
        component.set("v.Methodrun",false);
        var pgno = component.get("v.pageNo");
        component.set("v.pageNo",pgno-1);
        var pgno = component.get("v.pageNo");
        var pgsize = component.get("v.pageSize");
        var allRecords = component.get("v.allRecords");
        var recordforshow=[];
        var i;
        for (i = (pgno-1)*pgsize; i <=(pgno*pgsize)-1; i++) { 
            recordforshow.push(allRecords[i]);
        }
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        helper.showAndHidebtn(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        this.btns(component, event, helper);
        component.set("v.show",!component.get("v.show"));
        
    },
    next: function (component, event, helper) {  
        var showVal = component.get('v.show');
        component.set("v.show",!component.get("v.show"));
        component.set("v.Methodrun",false);
        var pgno = component.get("v.pageNo");
        component.set("v.pageNo",pgno+1);
        var pgno = component.get("v.pageNo");
        var totalRecords = component.get("v.totalRecords");
        var allRecords = component.get("v.allRecords");
        var pgsize = component.get("v.pageSize");
        var recordforshow=[];
        var i;
        var end;
        if(((pgno*pgsize)-1) >totalRecords){
            end = totalRecords-1;
        }else{
            end =(pgno*pgsize)-1;
        }
        for (i = (pgno-1)*pgsize; i <= end; i++) {
            
            recordforshow.push(allRecords[i]);
        }
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        helper.showAndHidebtn(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        this.btns(component, event, helper);
        component.set("v.show",!component.get("v.show"));
        
    },
    last: function (component, event, helper) {
        component.set("v.show",!component.get("v.show"));
        var tatalPage = component.get("v.tatalPage");
        var pgsize = component.get("v.pageSize");
        var allRecords = component.get("v.allRecords");
        var totalRecords = component.get("v.totalRecords");
        var pgNo;
        if(totalRecords % component.get("v.pageSize")!==0){
            var totalpage = totalRecords / component.get("v.pageSize");
            var totalpg = Math.floor(totalpage);
            pgNo = totalpg+1;
        }else{
            pgNo = totalRecords / component.get("v.pageSize");
        }
        component.set("v.pageNo",pgNo);
        var recordforshow=[];
        var i;
        var end; 
        if(tatalPage*pgsize > totalRecords){
            end = totalRecords;
        }else{
            end = tatalPage*pgsize;
        }
        for (i = (tatalPage-1)*pgsize; i < end; i++) { 
            recordforshow.push(allRecords[i]);
        }
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        helper.showAndHidebtn(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        this.btns(component, event, helper);
        component.set("v.show",!component.get("v.show"));
        
    },
    showAndHidebtn: function (component, event, helper) {
        var pgno = component.get("v.pageNo");
        var totalRecords = component.get("v.totalRecords");
        var pgsize = component.get("v.pageSize");
        if(pgno <= 1){
            component.set("v.firstshow",true);
            component.set("v.previousshow",true);  
        }
        if(pgno >= totalRecords/pgsize){
            component.set("v.nextshow",true);
            component.set("v.lastshow",true); 
        }
        if(pgno > 1){
            component.set("v.firstshow",false);
            component.set("v.previousshow",false);  
        }
        if(pgno < totalRecords/pgsize){
            component.set("v.nextshow",false);
            component.set("v.lastshow",false); 
        }
        
        var tatalPage = component.get("v.tatalPage");
        if(tatalPage<5){
            tatalPage=tatalPage+1;
            for(tatalPage;tatalPage<=5;tatalPage++){
                let button = component.find(tatalPage);
                button.set('v.disabled',true);
            }
        }else{
            var k=1;
            for(k ; k<=5 ; k++){
                let button = component.find(k);
                button.set('v.disabled',false);
            } 
        }
        
    },
    btns : function (component, event, helper) {
        var tatalPage = component.get("v.tatalPage");
        var pgno = component.get("v.pageNo");
        if(pgno<=3){
            component.set("v.first1",1);
            component.set("v.previous1",2);
            component.set("v.middle",3);
            component.set("v.next1",4);
            component.set("v.Last1",5);
            
        }else if(pgno > 3 && pgno <= tatalPage-2 ){
            component.set("v.first1",pgno-2);
            component.set("v.previous1",pgno-1);
            component.set("v.middle",pgno);
            component.set("v.next1",pgno+1);
            component.set("v.Last1",pgno+2);
        }else { 
            component.set("v.first1",tatalPage-4);
            component.set("v.previous1",tatalPage-3);
            component.set("v.middle",tatalPage-2);
            component.set("v.next1",tatalPage-1);
            component.set("v.Last1",tatalPage);
        }
    },
    shiftPgno :  function (component, event, helper) {
        var btn = event.getSource().get('v.name');
        component.set("v.pageNo",btn);
        var pgno = component.get("v.pageNo");
        var pgsize = component.get("v.pageSize");
        var allRecords = component.get("v.allRecords");
        var totalRecords = component.get("v.totalRecords");
        var recordforshow=[];
        var i;
        var end;
        if(((pgno*pgsize)-1) >totalRecords){
            end = totalRecords-1;
        }else{
            end = (pgno*pgsize)-1;
        }
        for (i = (pgno-1)*pgsize; i <= end; i++) { 
            recordforshow.push(allRecords[i]);
        }
        component.set("v.data",recordforshow);
        this.masterCheckorNot(component, event, helper);
        var selectionval = component.get("v.allselectedrow");
        component.set("v.selection",selectionval);
        helper.showAndHidebtn(component, event, helper);
        this.btns(component, event, helper); 
    },
    masterCheckorNot : function (component, event, helper) {
       
        console.log('masterCheckorNot callsed');
        var allUser = component.get("v.data"); 
        var flag = true;
        for(var i=0; i<allUser.length; i++){
            console.log(allUser[i].selected);
            if(allUser[i].selected === false){
                console.log('in   ',allUser[i]);
                flag = false;
            }
        }
        console.log('Before Flag : '+component.get('v.isAllSelected'));
        if(flag == false){
            component.set('v.isAllSelected',false);
        }
        else{
            component.set('v.isAllSelected',true);
        }
        component.set('v.show',true);
        console.log('After Flag : '+component.get('v.isAllSelected'));
    }
})