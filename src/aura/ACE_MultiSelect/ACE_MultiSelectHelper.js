({
    init: function (component) {
        console.log('Enter in init method in helper');

        //note, we get options and set options_
        //options_ is the private version and we use this from now on.
        //this is to allow us to sort the options array before rendering
        if (component.get("v.initialized")) {
            return;
        }
        component.set("v.initialized", true);

        var options = component.get("v.options");
        console.log('options are @@@@@ ',options);
        /*options.sort(function compare(a, b) {
            if (a.value == 'All') {
                return -1;
            } else if (a.value < b.value) {
                return -1;
            }
            if (a.value > b.value) {
                return 1;
            }
            return 0;
        });*/
        console.log('options are in init ', options, options.length);
        
        console.log('option after adding none ',options);
        let totAcc = 0;
        let defaultAccSelected = [];
        for (let i = 0; i < options.length; i++) {
            if(options[i].selected==true){
                console.log('Enter in if@@@@@@@@@',i);
                totAcc += options[i].unitPrice;
                defaultAccSelected.push(options[i]);
            }
            
        }
        console.log('Enter in if in helper init', options);
        component.set("v.totAcc", totAcc);
        component.set("v.accessoriesSelected", defaultAccSelected);
        component.set("v.options_", options);
        var labels = this.getSelectedLabels(component);
        this.setInfoText(component, labels);
    },

    setInfoText: function (component, values) {
        console.log('Enter in setInfoText method in helper');
        if (values.length == 0) {
            component.set("v.infoText", "Select an option...");
        }
        if (values.length == 1) {
            component.set("v.infoText", values[0]);
        } else if (values.length > 1) {
            component.set("v.infoText", values.length + " options selected");
        }
    },

    getSelectedValues: function (component) {
        var options = component.get("v.options_");
        console.log('Enter in getSelectedValues method in helper',options);
        var values = [];
        let totAcc = 0;
        options.forEach(function (element) {
            if (element.selected) {
                let obj = {};
                obj.price = element.unitPrice;
                obj.prodId = element.value;
                obj.label = element.prodType;
                totAcc += element.unitPrice;
                values.push(obj);
            }
        });
        component.set("v.totAcc",totAcc);
        return values;
    },

    getSelectedLabels: function (component) {
        var options = component.get("v.options_");
        console.log('Enter in getSelectedLabels method in helper',options);
        var labels = [];
        options.forEach(function (element) {
            if (element.selected) {
                labels.push(element.label);
            }
        });
        return labels;
    },

    /* despatchSelectChangeEvent: function (component, values) {
        console.log('Enter in despatchSelectChangeEvent method in helper');
        var compEvent = component.getEvent("selectChange");
        compEvent.setParams({
            "values": values
        });
        compEvent.fire();
    } */
})