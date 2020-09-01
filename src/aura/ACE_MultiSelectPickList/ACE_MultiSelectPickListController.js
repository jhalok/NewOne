({

    reInit: function (component, event, helper) {
        console.log('Enter in reInit method in controller');
        component.set("v.initialized", false);
        helper.init(component);
    },

    init: function (component, event, helper) {
        console.log('Enter in init method in controller');
        helper.init(component);
    },

    handleClick: function (component, event, helper) {
        console.log('Enter in handleClick method in controller');
        var mainDiv = component.find('main-div');
        $A.util.addClass(mainDiv, 'slds-is-open');
    },

    handleSelection: function (component, event, helper) {
        console.log('Enter in handleSelection method in controller');
        var item = event.currentTarget;
        if (item && item.dataset) {
            var value = item.dataset.value;
            console.log('value is ', value);
            var selected = item.dataset.selected;
            var flag = "false";
            if (value == "none") {
                flag = "true";
            }
            var options = component.get("v.options_");
            console.log('Enter in if ', options);
            options.forEach(function (element) {
                if (element.value == "none" && element.selected == true) {
                    element.selected=false;
                }
                if (element.value == value) {
                    element.selected = selected == "true" ? false : true;
                }
            });
            if (flag == "true") {
                options.forEach(function (elementForNone) {
                    if (elementForNone.value != "none") {
                        elementForNone.selected = false;
                    }
                });
            }
            component.set("v.options_", options);
            var values = helper.getSelectedValues(component);
            var labels = helper.getSelectedLabels(component);
            /*let totAcc = 0;
            for(let i = 0; i < values.length; i++){
                if(values.length == 1){
                    totAcc = values[0].price;
                }
                else{
                    totAcc += values[i].price;
                }
            }
            console.log('totAcc are ',totAcc);
            console.log('values are ',values);*/
            helper.setInfoText(component, labels);
            component.set("v.accessoriesSelected", values);
            //component.set("v.totAcc",totAcc);
            //helper.despatchSelectChangeEvent(component, values);

        }
    },

    handleMouseLeave: function (component, event, helper) {
        console.log('Enter in handleMouseLeave method in controller');
        component.set("v.dropdownOver", false);
        var mainDiv = component.find('main-div');
        $A.util.removeClass(mainDiv, 'slds-is-open');
    },

    handleMouseEnter: function (component, event, helper) {
        console.log('Enter in handleMouseEnter method in controller');
        component.set("v.dropdownOver", true);
    },

    handleMouseOutButton: function (component, event, helper) {
        window.setTimeout(
            $A.getCallback(function () {
                if (component.isValid()) {
                    //if dropdown over, user has hovered over the dropdown, so don't close.
                    if (component.get("v.dropdownOver")) {
                        return;
                    }
                    var mainDiv = component.find('main-div');
                    $A.util.removeClass(mainDiv, 'slds-is-open');
                }
            }), 200
        );
    }

})