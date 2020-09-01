public class ACE_comWizardController {
    @AuraEnabled
    public static MAP < String, LIST < FieldProperties >> getFieldsOnLayout(String layoutName) {

        LIST < FieldProperties > columnsFldsList;
        MAP < String, LIST < FieldProperties >> colFldMap = new MAP < String, LIST < FieldProperties >> ();
        List < Metadata.Metadata > layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List < String > {
            layoutName
        });


        Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);

        for (Metadata.LayoutSection section: layoutMd.layoutSections) {
            columnsFldsList = new LIST < FieldProperties > ();
            for (Metadata.LayoutColumn column: section.layoutColumns) {
                if (column.layoutItems != null) {
                    for (Metadata.LayoutItem item: column.layoutItems) {

                        System.debug(item.field + ' & behavior is ' + item.behavior);
                        if (String.valueOf(item.behavior) != 'ReadOnly') {
                            if (String.valueOf(item.field) == 'Name') {
                                columnsFldsList.add(new FieldProperties('Salutation', String.valueOf(section.style), 'False'));
                                columnsFldsList.add(new FieldProperties('FirstName', String.valueOf(section.style), 'True'));
                                columnsFldsList.add(new FieldProperties('LastName', String.valueOf(section.style), 'Required'));
                            } else if (String.valueOf(item.field) == 'Address') {
                                columnsFldsList.add(new FieldProperties('Street', String.valueOf(section.style), String.valueOf(item.behavior)));
                                columnsFldsList.add(new FieldProperties('City', String.valueOf(section.style), String.valueOf(item.behavior)));
                                columnsFldsList.add(new FieldProperties('PostalCode', String.valueOf(section.style), String.valueOf(item.behavior)));
                                columnsFldsList.add(new FieldProperties('State', String.valueOf(section.style), String.valueOf(item.behavior)));
                                columnsFldsList.add(new FieldProperties('Country', String.valueOf(section.style), String.valueOf(item.behavior)));
                            } else {
                                FieldProperties props = new FieldProperties(item.field, String.valueOf(section.style), String.valueOf(item.behavior));
                                columnsFldsList.add(props);
                            }


                        }
                    }
                }
            }
            if (columnsFldsList.size() > 0) {
                if (section.label == 'Additional Details' || section.label == 'Personal Details') {
                    System.debug('label ' + section.label);
                    colFldMap.put(section.label, columnsFldsList);
                }

            }

        }

        System.debug('colFldMap is ' + JSON.serialize(colFldMap));
        return colFldMap;
    }
    //For Add Product
    @AuraEnabled
    public static Lead getLeadRecord(String leadId) {
        return [Select Id, Name From Lead Where Id =: leadId];
    }
    @AuraEnabled
    public static List < ACE_Product_Interest__c > getExistingProducts(String Id) {
        system.debug(Id);
        List < ACE_Product_Interest__c > allProducts = [select id, Product__c, Lead__c From ACE_Product_Interest__c where Lead__c =: Id];
        System.debug(allProducts);
        return allProducts;
    }
    @AuraEnabled
    public static boolean updateProductInterest(List < ACE_Product_Interest__c > allProductInterests, List < ACE_Product_Interest__c > editedPIList) {
        try {
            Integer countPreferred = 0;
            for (ACE_Product_Interest__c piExisting: allProductInterests) {
                for (ACE_Product_Interest__c piEdited: editedPIList) {
                    System.debug('piEdited-->' + piEdited.Prefered__c);
                    if ((piExisting.Prefered__c && piEdited.Prefered__c && piExisting.Id != piEdited.Id) ||
                        piEdited.Prefered__c) {
                        countPreferred++;
                    }
                    if ((piExisting.Prefered__c && !piEdited.Prefered__c && piExisting.Id == piEdited.Id) ||
                        (!piExisting.Prefered__c && piEdited.Prefered__c && piExisting.Id == piEdited.Id)) {
                        countPreferred--;
                    }
                }
                if (countPreferred < 1 && piExisting.Prefered__c) {
                    countPreferred++;
                }
            }
            System.debug('countPreferred-->' + countPreferred);
            if (countPreferred == 1) {
                update editedPIList;
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }
    /*  @AuraEnabled
     public static boolean createProductInterestRecord(String selectedProduct, String currentLead){
         Boolean recordInserted = false;
        try{
         Product2 p = [select Id,Name from Product2 where Id=:selectedProduct];
         ACE_Product_Interest__c pi = new ACE_Product_Interest__c();
         //pi.Name= p.Name; 
         pi.Product__c =  selectedProduct;
         pi.Lead__c = currentLead;
         
         	insert pi;
             recordInserted = true;
         }
         catch(Exception ex){
             System.debug('=Exception='+ex);
             recordInserted = false;
         }
         
         return recordInserted;
     } */
    /* @AuraEnabled
    public static String saveInterests(List<ACE_Product_Interest__c> productInterests){
        List<ACE_Source_Tracker__c> allSourceTrack = new List<ACE_Source_Tracker__c>();
        try{
        List<String> allProducts = new List<String>();
            for(ACE_Product_Interest__c Interest :productInterests){
                   allProducts.add(Interest.Product__c) ;
            }
            List<product2> allProductFromObject = [select id,Name from Product2 Where Id IN: allProducts];
          for(product2 product :allProductFromObject){
              for(ACE_Product_Interest__c Interest :productInterests){
                  if(Interest.Product__c == product.id){
                      Interest.Name = product.Name;
                  }
              }
          }
            insert productInterests;
            for(ACE_Product_Interest__c interest :productInterests){
                ACE_Source_Tracker__c tracker = new ACE_Source_Tracker__c();
                tracker.ACE_Product_Interest__c = interest.Id;
                tracker.ACE_Source__c  = interest.Source__c;
                tracker.ACE_SubSource__c  = 	interest.Subsource__c;
                allSourceTrack.add(tracker);
            }
            insert allSourceTrack;
             return null;
        }
         catch(Exception ex){
           return ex.getMessage();
        }
       
    } */
    // To insert Lead records.
    @AuraEnabled
    public static void insertLead(String newLead, Boolean insertOpp, List < ACE_Product_Interest__c > lstProdInterest) {
        System.debug('@@@@ prod ' + lstProdInterest + 'size is ' + lstProdInterest.size());
        Lead leadToInsert = (Lead) JSON.deserialize(newLead, Lead.class);
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Dealer Leads').getRecordTypeId();
        System.debug('id is ' + recordTypeId);
        leadToInsert.company = leadToInsert.lastName;
        leadToInsert.recordTypeId = recordTypeId;
        System.debug('Lead ' + leadToInsert);
        Insert leadToInsert;
        // Convert Lead into Enquiry.
        if (insertOpp) {
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadToInsert.id);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
        if (lstProdInterest.size() > 0) {
            Set < Id > prodIdSet = new Set < Id > ();
            for (ACE_Product_Interest__c prod: lstProdInterest) {
                System.debug('@@@@@@@@@@ 172');
                if (prod.Product__c != null) {
                    System.debug('Enter in if at 173');
                    prodIdSet.add(prod.Product__c);
                }
            }
            System.debug('Set of id is ' + prodIdSet);
            List < Product2 > lstOfProduct = [select id, name from product2 where id IN: prodIdSet];
            System.debug('lst of Product is ' + lstOfProduct);
            Map < Id, List < Product2 >> mapOfProduct = new Map < Id, List < Product2 >> ();
            mapOfProduct.put(leadToInsert.id, lstOfProduct);
            System.debug('@@@@@## mapOfProduct at 183 ' + mapOfProduct);
            for (String fieldName: mapOfProduct.keySet()) {
                System.debug('field name is ' + fieldName+'value is '+ mapOfProduct.get(fieldName));
                
            }
            insertProductInterest(mapOfProduct);
        }

    }
    // To insert Product interest.
    public static void insertProductInterest(Map < Id, List < Product2 >> mapOfProduct) {
        List < ACE_Product_Interest__c > lstProd = new List < ACE_Product_Interest__c > ();
        for (String fieldName: mapOfProduct.keySet()) {
                for(Product2 prod : mapOfProduct.get(fieldName)){
                    ACE_Product_Interest__c prodInt = new ACE_Product_Interest__c();
                    prodInt.name = prod.Name;
                    prodInt.Lead__c = fieldName;
                   lstProd.add(prodInt);
                }
                //System.debug('field name is ' + fieldName +'value is '+ mapOfProduct.get(fieldName));
            }
        System.debug('lstProd is @@@@ ' + lstProd);
        if (lstProd.size() > 0) {
            System.debug('lstProd in insert method '+lstProd);
            insert lstProd;
        }
        /* for(Integer i=0;i<lstProdInterest.size();i++){
            ACE_Product_Interest__c prod = new ACE_Product_Interest__c();
            prod.Name=lstProdInterest[i].InterestName;
            prod.Product__c=lstProdInterest[i].Product__c;
            prod.Lead__c=leadId;
            lstProd.add(prod);
        } */
    }

    //For lookup
    /* @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String state = 'Active';
            String typed = 'Vehicle';
            String query = 'SELECT Id,color__c,' + filterField + ' FROM '+objectName+ ' Where Status__c = \'Active\'  and Type__c =\'Vehicle\' and   '+filterField+
                		' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
            system.debug(query);
	        for(SObject s : Database.query(query)) {
                System.debug('s is '+s);
	            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id'),(String)s.get('color__c')) );
	        }
            System.debug('recordDataList is '+recordsDataList);
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    } */

    // To fetch records
    @AuraEnabled
    public static List < RecordsData > getProds(String searchString) {
        LIST < Product2 > prodList = [SELECT ID, name, color__c, Vehicle_Model__c, Variant__c, Fuel_Type__c FROM Product2 WHERE name LIKE: ('%' + searchString + '%') ORDER BY name];
        List < RecordsData > recordsDataList = new List < RecordsData > ();
        for (Product2 pr: prodList) {
            recordsDataList.add(new RecordsData(pr.name, pr.id, pr.color__c, pr.Vehicle_Model__c, pr.variant__c, pr.Fuel_Type__c));
        }
        return recordsDataList;
    }

    // Wrapper class to search for products.
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String color;
        @AuraEnabled public String model;
        @AuraEnabled public String variant;
        @AuraEnabled public String fuel;
        public RecordsData(String label, String value, String color, String model, String variant, String fuel) {
            this.label = label;
            this.value = value;
            this.color = color;
            this.model = model;
            this.variant = variant;
            this.fuel = fuel;
        }
    }

    // Wrapper class to get fields on layout
    public class FieldProperties {

        @AuraEnabled
        public String columnName {
            get;
            set;
        }
        @AuraEnabled
        public String fieldName {
            get;
            set;
        }
        @AuraEnabled
        public String style;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public String val;

        public FieldProperties(String fld, String sty, String req) {
            fieldName = fld;
            style = sty;
            required = req == 'Required' ? true : false;
            val = '';
        }
    }
    public class ProdInterestField {
        @AuraEnabled
        public String sobjectType;


        @AuraEnabled
        public String InterestName;
    }
}