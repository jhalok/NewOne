({
    handleOnSubmit : function(component, event, helper) {
        component.set("v.bookingPDFURL",'https://'+window.location.hostname+'/apex/BookingPDF?id='+component.get("v.bookingId"));
        var parentOpp = window.location.href;
        parentOpp = parentOpp.slice(parentOpp.indexOf('Opportunity/')+12,parentOpp.indexOf('view')-1);
        var Name;
        if(component.find('bookingName').get('v.value') == null || component.find('bookingName').get('v.value') == 'None'){
            Name = '';  
        } 
        else{
            Name = component.find('bookingName').get('v.value');
        }
        var orderDate;
        if(component.find('orderDate').get('v.value') == null || component.find('orderDate').get('v.value') == 'None'){
            orderDate = '';  
        } 
        else{
            orderDate = component.find('orderDate').get('v.value');
        }
        var regBy;
        
        if(component.get('v.regBy') == null || component.get('v.regBy') == 'None'){
            regBy = '';  
        } 
        else{
            regBy = component.get('v.regBy');
        }
        var regType;
        if(component.get('v.regType') == null || component.get('v.regType') == 'None'){
            regType = '';  
        } 
        else{
            regType = component.get('v.regType');
        }
        var insBy;
        if(component.get('v.insBy') == null || component.get('v.insBy') == 'None'){
            insBy = '';  
        } 
        else{
            insBy = component.get('v.insBy');
        }
        var insCompany;
        if(component.find('insCompany').get('v.value') == null || component.find('insCompany').get('v.value') == 'None'){
            insCompany = '';  
        } 
        else{
            insCompany = component.find('insCompany').get('v.value');
        }
        var insType;
        if(component.get('v.insType') == null || component.get('v.insType') == 'None'){
            insType = '';  
        } 
        else{
            insType = component.get('v.insType');
        } 
        var shieldWarr;
        if(component.find('shieldWarr').get('v.value') == null || component.find('shieldWarr').get('v.value') == 'None'){
            shieldWarr = '';  
        } 
        else{
            shieldWarr = component.find('shieldWarr').get('v.value');
        }
        var Stage;
        if(component.find('Stage').get('v.value') == null || component.find('Stage').get('v.value') == 'None'){
            Stage = '';  
        } 
        else{
            Stage = component.find('Stage').get('v.value');
            console.log('-------Stage----'+Stage);
        }
        var expDeliveryDate;
        if(component.find('expDeliveryDate').get('v.value') == null || component.find('expDeliveryDate').get('v.value') == 'None'){
            expDeliveryDate = '';  
        } 
        else{
            expDeliveryDate = component.find('expDeliveryDate').get('v.value');
        }
        var commDeliveryDate;
        if(component.find('commDeliveryDate').get('v.value') == null || component.find('commDeliveryDate').get('v.value') == 'None'){
            commDeliveryDate = '';  
        } 
        else{
            commDeliveryDate = component.find('commDeliveryDate').get('v.value');
        }
        var commDeliveryWeek;
        if(component.find('commDeliveryWeek').get('v.value') == null || component.find('commDeliveryWeek').get('v.value') == 'None'){
            commDeliveryWeek = '';  
        } 
        else{
            commDeliveryWeek = component.find('commDeliveryWeek').get('v.value');
        }
        var bookAmt;
        if(component.find('bookAmt').get('v.value') == null || component.find('bookAmt').get('v.value') == 'None'){
            bookAmt = '0';  
        } 
        else{
            bookAmt = component.find('bookAmt').get('v.value');
        }
        var payMode;
        if(component.find('payMode').get('v.value') == null || component.find('payMode').get('v.value') == 'None'){
            payMode = '';  
        } 
        else{
            payMode = component.find('payMode').get('v.value');
        }
        var payDetail;
        if(component.find('payDetail').get('v.value') == null || component.find('payDetail').get('v.value') == 'None'){
            payDetail = '';  
        } 
        else{
            payDetail = component.find('payDetail').get('v.value');
        } 
        var amtRecieved;
        if(component.find('amtRecieved').get('v.value') == null || component.find('amtRecieved').get('v.value') == 'None'){
            amtRecieved = '0';  
        } 
        else{
            amtRecieved = component.find('amtRecieved').get('v.value');
        }
        var drawnOn;
        if(component.find('drawnOn').get('v.value') == null || component.find('drawnOn').get('v.value') == 'None'){
            drawnOn = '';  
        } 
        else{
            drawnOn = component.find('drawnOn').get('v.value');
        }
        var amtRecDate;
        if(component.find('amtRecDate').get('v.value') == null || component.find('amtRecDate').get('v.value') == 'None'){
            amtRecDate = '';  
        } 
        else{
            amtRecDate = component.find('amtRecDate').get('v.value');
        }
        var drawDate;
        if(component.find('drawDate').get('v.value') == null || component.find('drawDate').get('v.value') == 'None'){
            drawDate = '';  
        } 
        else{
            drawDate = component.find('drawDate').get('v.value');
        }
        var FinArrBy;
        if(component.get('v.FinArrBy') == null || component.get('v.FinArrBy') == 'None'){
            FinArrBy = '';  
        } 
        else{
            FinArrBy = component.get('v.FinArrBy');
        }
        var loanAmt;
        if(component.find('loanAmt').get('v.value') == null || component.find('loanAmt').get('v.value') == 'None'){
            loanAmt = '0';  
        } 
        else{
            loanAmt = component.find('loanAmt').get('v.value');
        }
        var finCompany;
        if(component.find('finCompany').get('v.value') == null || component.find('finCompany').get('v.value') == 'None'){
            finCompany = '';  
        } 
        else{
            finCompany = component.find('finCompany').get('v.value');
        }
        var tenure;
        if(component.find('tenure').get('v.value') == null || component.find('tenure').get('v.value') == 'None'){
            tenure = '0';  
        } 
        else{
            tenure = component.find('tenure').get('v.value');
        }
        var intRate;
        if(component.find('intRate').get('v.value') == null || component.find('intRate').get('v.value') == 'None'){
            intRate = '';  
        } 
        else{
            intRate = component.find('intRate').get('v.value');
        }
        var downPay;
        if(component.find('downPay').get('v.value') == null || component.find('downPay').get('v.value') == 'None'){
            downPay = '';  
        } 
        else{
            downPay = component.find('downPay').get('v.value');
        }
        /* var expEMI;
        if(component.find('expEMI').get('v.value') == null || component.find('expEMI').get('v.value') == 'None'){
            expEMI = '0';  
        } 
        else{
            expEMI = component.find('expEMI').get('v.value');
        }*/
        var OppId;
        if(component.find('OppId').get('v.value') == null || component.find('OppId').get('v.value') == 'None'){
            OppId = '';  
        } 
        else{
            OppId = component.find('OppId').get('v.value');
        }
        var custId;
        if(component.find('custId').get('v.value') == null || component.find('custId').get('v.value') == 'None'){
            custId = '';  
        } 
        else{
            custId = component.find('custId').get('v.value');
        }
        parentOpp = {
            "Name" : Name,
            "Order_Date" : orderDate,
            "Registration_By" : regBy,
            "Registration_Types" : regType,
            "Insurance_By" : insBy,
            "Insurance_Company" : insCompany,
            "Insurance_Types" : insType,
            "Shield_Warranty" : shieldWarr,
            "Customer_Expected_Delivery_Date" : expDeliveryDate,
            "Committed_Delivery_Date" : commDeliveryDate,
            "Committed_Delivery_Week" : commDeliveryWeek,
            "Booking_Amount" : bookAmt,
            "Mode_OF_Payment" : payMode,
            "Cheque_DD_PO_Details" : payDetail,
            "Amount_Received" : amtRecieved,
            "Drawn_On" : drawnOn,
            "Amount_Received_Date" : amtRecDate,
            "Drawn_Date" : drawDate,
            "Finance_Arranged_By" : FinArrBy,
            "Loan_Amount" : loanAmt,
            "Finance_Company" : finCompany,
            "Tenure" : tenure,
            "Interest_Rates" : intRate,
            "Down_Payment" : downPay,
            //"Expected_EMI_Amount__c" : expEMI,
            "Opportunity" : OppId,
            "Customer_Id" : custId,
            "Stage" : Stage
        };
        var result;
        if(result == null || result == '' || result == 'undefined' && component.get('v.doneCalculations') == false){
            
            var action = component.get('c.insertBooking'); 
            action.setParams({
                "serializedBookingData" : JSON.stringify(parentOpp)               
            });
            action.setCallback(this, function(response){
                if(response.getState() == 'SUCCESS'){
                    component.set('v.doneCalculations',true);
                    result = response.getReturnValue();
                    if(result.success) {
                        var urlId = result.message;
                        component.set('v.bookingPDFURL',result.message);
                        component.set('v.booking_id',urlId.split('?id=')[1]);
                        
                        if(component.get('v.booking_id') !== 'undefined' && component.get('v.bookingPDFURL') !== 'undefined'){
                            var action2 = component.get('c.storePDF');
                            action2.setParams({
                                "bookingId" : urlId.split('?id=')[1]
                            });
                            component.set('v.doneCalculations',false);
                            action2.setCallback(this,function(response){
                                if(response.getState() == 'SUCCESS'){
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type" : "Success",
                                        "title": "Success!",
                                        "message": "The booking has been created successfully."
                                    });
                                    toastEvent.fire();
                                } else {
                                    var cmpTarget = document.getElementById('pdf');
                                    $A.util.addClass(cmpTarget, 'slds-hide');
                                    $A.get("e.force:closeQuickAction").fire(); 
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type" : "Success",
                                        "title": "Success!",
                                        "message": "The booking has been created successfully."
                                    });
                                    toastEvent.fire();
                                }
                            });
                            $A.enqueueAction(action2); 
                        }
                    } else {
                        var cmpTarget = document.getElementById('pdf');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "error",
                            "title": "Error!",
                            "message": "Sorry the booking cannot be created because "+result.message+'.'
                        });
                        toastEvent.fire();
                    }  
                }
            });
            $A.enqueueAction(action);
        }
        component.set('v.showPdf', false);       
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
    handleSuccess : function(component, event, helper) {
    },
    handleError : function(component, event, helper) {
    },
    doInit:function(component,event,helper){
        var action = component.get('c.getCustID');
        action.setParams({
            "recordId" : window.location.href.slice(window.location.href.indexOf('/detail')+8,window.location.href.indexOf('/detail')+26)
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                component.set('v.custId',response.getReturnValue());
            }
            else{
            }
        });
        $A.enqueueAction(action);
    },
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');
        if (openSections.length === 0) {
            component.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            component.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    handleRegisteredBy : function ( component, event){
        var changeValue = event.getParam("value");
        component.set('v.regBy',changeValue);
    },
    handleRegisteredTypes : function ( component, event){
        var changeValue = event.getParam("value");
        component.set('v.regType',changeValue);
    },
    handleInsuredBy : function ( component, event){
        var changeValue = event.getParam("value");
        component.set('v.insBy',changeValue);
    },
    handleInsuranceTypes : function ( component, event){
        var changeValue = event.getParam("value");
        component.set('v.insType',changeValue);
    },
    handleFinanceArrangedBy : function ( component, event){
        var changeValue = event.getParam("value");
        component.set('v.FinArrBy',changeValue);
    },
})