global class ACE_AssignDealer {
    @AuraEnabled
    public static Lead getLeadRecord(String Id) {
        return [SELECT Id, LastName, FirstName, Suffix, Name, City, ACE_Dealer__c, PostalCode, Address FROM Lead Where Id =: Id];
    }
    @AuraEnabled
    public static List < ModelWrapper > getModel(String Id) {
        Map < Id, ACE_Product_Interest__c > allProduct_Interest = new Map < Id, ACE_Product_Interest__c > ();
        list < ModelWrapper > allProductInterWithVari = new list < ModelWrapper > ();
        for (ACE_Product_Interest__c interProduct: [SELECT Id, Name, Product__c,Dealer_Name__c, Interest_Category__c, Vehicle_Variant__c, Vehicle_Colors__c, Vehicle_Variant__r.Name FROM ACE_Product_Interest__c where Lead__c =: Id]) {

            if (interProduct.Interest_Category__c == null) {
                interProduct.Interest_Category__c = '';
            }
            allProduct_Interest.put(interProduct.Product__c, interProduct);
        }

        List < Vehicle_Variant__c > listOfVehicle_Variant = [select Id, Name, Color__c, Product__c from Vehicle_Variant__c where Product__c IN: allProduct_Interest.Keyset()];
        for (ACE_Product_Interest__c productInter: allProduct_Interest.values()) {
            ModelWrapper wrapperInst = new ModelWrapper();
            List < Vehicle_Variant__c > VehicleVariantByModel = new List < Vehicle_Variant__c > ();
            for (Vehicle_Variant__c vr: listOfVehicle_Variant) {
                if (vr.Product__c == productInter.Product__c) {
                    VehicleVariantByModel.add(vr);
                }
                if (productInter.Vehicle_Variant__c == vr.Id) {
                    wrapperInst.selectedColors = vr.Color__c.split(';');
                }
            }
            wrapperInst.interestedModel = productInter;
            wrapperInst.allVariant = VehicleVariantByModel;
            allProductInterWithVari.add(wrapperInst);
        }
        return allProductInterWithVari;
    }
    @AuraEnabled
    public static List < Account > getDealer(String City) {
        return [SELECT Id, Name FROM Account where BillingCity =: City];
    }

    @AuraEnabled
    public static List <String> getColorOfVariant(String VariantId) {
        Vehicle_Variant__c VehicleVariantColors = [SELECT Id, Name, Color__c FROM Vehicle_Variant__c where Id =: VariantId];
		
        return VehicleVariantColors.Color__c.split(';');
    }
    @AuraEnabled
    public static void updateProduct_Interest(List < ACE_Product_Interest__c > Product_Interest) {
        system.debug(Product_Interest);
        for(ACE_Product_Interest__c idData:Product_Interest){
            if(!(idData.Quantity__c >0)){
                idData.Quantity__c = 1;
            }
        }
        update Product_Interest;
    }

    global class ModelWrapper {
        @AuraEnabled
        global ACE_Product_Interest__c interestedModel;
        @AuraEnabled
        global List < Vehicle_Variant__c > allVariant;
        @AuraEnabled
        global List < String > selectedColors;
        @AuraEnabled
        global String productInterest;
    }


    /* @AuraEnabled
            public static void ledGeoCode(){
            String  geoAddress = EncodingUtil.urlEncode('jaipur', 'UTF-8');
            // build and make the callout to the Geocoding API
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='
            +
            geoAddress + '&key=AIzaSyAcC43SdohkxbJicShwm2j7fK42zoPdA-Q&sensor=false');
            request.setMethod('GET');
            request.setTimeout(60000);
            
            //make the http callout
            HttpResponse response = http.send(request);
            //parse JSON to extract co-ordinates
            
            system.debug(response.getBody());
            } */
}