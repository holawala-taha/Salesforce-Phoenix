public without sharing class CtrTarifManager extends ClsManagementConsoleBase {

    public Tarif__c myTarif { get; set; }
    public String selectedService { get; set; }
    public String selectedProduct { get; set; }
    public String selectedServiceToDelete { get; set; }
    public String selectedProductToDelete { get; set; }
    public String selectedTarif { get; set; }
    public Map<Id, List_Service_Price__c> mapSelectedServices { get; set; }
    public Map<Id, List_Product_Price__c> mapSelectedProducts { get; set; }

    private transient Map<Id, List_Service_Price__c> servicesMapCache;
    public Map<Id, List_Service_Price__c> servicesMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (servicesMapCache == null) {
                servicesMapCache = new Map<Id, List_Service_Price__c>([
                    SELECT Id, Name, Commission_In_Percentage__c, Commission_Per_Order__c, Recurring_Fee__c, Recurring_interval__c, Default_Commission_In_Percentage__c, Is_Active__c, Maximum_Commission_In_Percentage__c, Minimum_Commission_in_Percentage__c, Type__c, Id_Country__c, Company__c
                    FROM List_Service_Price__c
                    WHERE Id_Country__c = : this.userCountryIds
                    AND Company__c = : this.userCompanyIds
                    ORDER BY LastModifiedDate DESC
                ]);
            }
            return servicesMapCache;
        }
    }

    private transient Map<Id, List_Product_Price__c> productsMapCache;
    public Map<Id, List_Product_Price__c> productsMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (productsMapCache == null) {
                productsMapCache = new Map<Id, List_Product_Price__c>([
                    SELECT Id, Default_Quantity__c, Installments__c, Is_Active__c, List_Price__c, Id_List_Product_Group__c, Id_List_Product_Group__r.Name, Product_Name__c, Id_Country__c, Company__c
                    FROM List_Product_Price__c
                    WHERE Id_Country__c IN : this.userCountryIds
                    AND Company__c IN : this.userCompanyIds
                    LIMIT 500
                ]);
            }
            return productsMapCache;
        }
    }

    private transient Map<Id, Tarif__c> tariffsMapCache;
    public Map<Id, Tarif__c> tariffsMap {
        get {
            // in this way we avoid to make the soql query multiple time during the same transaction
            // and on the same time we tremendously reduce the view state size
            if (tariffsMapCache == null) {
                tariffsMapCache = new Map<Id, Tarif__c>([
                    SELECT Id, Is_Active__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Id_Country__c, Id_Country__r.name, Company__c, (SELECT Id, Id_Tarif_Item__c, Tarif_Name__c, Type__c FROM Tarif_Members__r )
                    FROM Tarif__c
                    WHERE Id_Country__c IN : this.userCountryIds
                    AND Company__c IN : this.userCompanyIds
                    ORDER BY LastModifiedDate DESC
                    LIMIT 500
                ]);
            }
            return tariffsMapCache;
        }
        set;
    }

    public Integer selectedProductsSize {
        get {
            if (this.mapSelectedProducts == null) {
                return  0;
            } else {
                return this.mapSelectedProducts.size();
            }
        }
        set;
    }

    public Integer selectedServicesSize {
        get{
            if (this.mapSelectedServices == null) {
                return 0;
            } else {
                return this.mapSelectedServices.size();
            }

        }
        set;
    }

    public List<Tarif__c> tariffs {
        get{
            /*this.tariffsMap = new Map<Id, Tarif__c>([
                SELECT Id, Is_Active__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Id_Country__c,Id_Country__r.name, Company__c, (SELECT Id, Id_Tarif_Item__c, Tarif_Name__c, Type__c FROM Tarif_Members__r )
                FROM Tarif__c
                WHERE Id_Country__c IN : this.userCountryIds
                AND Company__c IN : this.userCompanyIds
                ORDER BY LastModifiedDate DESC
                LIMIT 500
            ]);*/
            system.debug('*tariffsmap' + tariffsMap );
            List<Tarif__c> tariffs = this.tariffsMap.values();
            //List<country__C> c =[select id, name from country__C];
            //system.debug('*tariffs'+ c);
            return tariffs;
        }
        private set;
    }

    public List<SelectOption> products {
        get{
            //this.productsMap = new Map<Id, List_Product_Price__c>([
            //    SELECT Id, Default_Quantity__c, Installments__c, Is_Active__c, List_Price__c, Id_List_Product_Group__c, Id_List_Product_Group__r.Name, Product_Name__c, Id_Country__c, Company__c
            //    FROM List_Product_Price__c
            //    WHERE Id_Country__c IN : this.userCountryIds
            //    AND Company__c IN : this.userCompanyIds
            //    LIMIT 500
            //]);

            List<SelectOption> products = new List<SelectOption>();
            products.add(new SelectOption('null', Label.Please_select));

            if (!this.productsMap.isEmpty()) {
                for (Id productId : this.productsMap.keySet()) {
                    if (((String)productsMap.get(productId).Id_Country__c).equals(this.selectedCountry) && ((String)productsMap.get(productId).Company__c).equals(this.selectedCompany) && productsMap.get(productId).Is_Active__c == true) {
                        products.add(new SelectOption(productsMap.get(productId).Id, productsMap.get(productId).Product_Name__c));
                    }
                }
            }
            return products;
        }
        private set;
    }

    public List<SelectOption> services {
        get {
            //this.servicesMap = new Map<Id, List_Service_Price__c>([
            //    SELECT Id, Name, Commission_In_Percentage__c, Commission_Per_Order__c, Recurring_Fee__c, Recurring_interval__c, Default_Commission_In_Percentage__c, Is_Active__c, Maximum_Commission_In_Percentage__c, Minimum_Commission_in_Percentage__c, Type__c, Id_Country__c, Company__c
            //    FROM List_Service_Price__c
            //    WHERE Id_Country__c = : this.userCountryIds
            //    AND Company__c = : this.userCompanyIds
            //    ORDER BY LastModifiedDate DESC
            //]);

            List<SelectOption> services = new List<SelectOption>();
            services.add(new SelectOption('null', Label.Please_select));
            if (!servicesMap.isEmpty()) {
                for (Id serviceId : servicesMap.keySet()) {
                    if (((String)servicesMap.get(serviceId).Id_Country__c).equals(this.selectedCountry) && ((String)servicesMap.get(serviceId).Company__c).equals(this.selectedCompany) && servicesMap.get(serviceId).Is_Active__c == true) {
                        services.add(new SelectOption(servicesMap.get(serviceId).Id, servicesMap.get(serviceId).Name));
                    }
                }
            }
            return services;
        }
        private set;
    }

    public CtrTarifManager() {
        this.mapSelectedServices = new Map<Id, List_Service_Price__c>();
        this.mapSelectedProducts = new Map<Id, List_Product_Price__c>();
        this.myTarif = new Tarif__c();
    }

    private void reset() {
        this.mapSelectedProducts.clear();
        this.mapSelectedServices.clear();
        this.selectedProduct = 'null';
        this.selectedService = 'null';
        this.myTarif = new Tarif__c();
    }

    public void addService() {
        if (selectedService != null && selectedService != 'null') {
            this.mapSelectedServices.put(selectedService, this.servicesMap.get(selectedService));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SMC_Tariff_Invalid_Service));
        }
    }

    public void addProduct() {
        if (selectedProduct != null && selectedProduct != 'null') {
            this.mapSelectedProducts.put(selectedProduct, this.productsMap.get(selectedProduct));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SMC_Tariff_Invalid_Product));
        }
    }

    public void deleteServiceItem() {
        if (selectedServiceToDelete != null) {
            mapSelectedServices.remove(selectedServiceToDelete);
        }
    }

    public void deleteProductItem() {
        if (selectedProductToDelete != null) {
            mapSelectedProducts.remove(selectedProductToDelete);
        }
    }

    public boolean saveValidation() {
        return true;
    }

    public void chooseTarifToDelete() {
        this.myTarif = this.tariffsMap.get(this.selectedTarif);
    }

    public void initiateTariffAdd() {

    }

    public void deleteTarif() {
        try {
            delete myTarif;
            reset();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SMC_Tariff_Successful_Delete));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SMC_Tariff_Delete_Error));
            system.debug('@@@@ calling deleteTarif - The following error occured while deleting tarif: ' + myTarif.Name + ' - ' + myTarif.Id + ' : ' + e.getMessage());
        }
    }

    public void editTarif() {
        try {
            this.myTarif = this.tariffsMap.get(this.selectedTarif);
            this.selectedCountry = this.myTarif.Id_Country__c;
            this.selectedCompany = this.myTarif.Company__c;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SMC_Tariff_Error_Loading_Tariff));
        }


        this.mapSelectedProducts.clear();
        this.mapSelectedServices.clear();

        for (Tarif_Member__c theTarifMember : this.myTarif.Tarif_Members__r) {
            if (getObject(theTarifMember.Id_Tarif_Item__c) == 'List_Product_Price__c') {
                if (this.productsMap.get(theTarifMember.Id_Tarif_Item__c) != null) {
                    this.mapSelectedProducts.put(theTarifMember.Id_Tarif_Item__c, this.productsMap.get(theTarifMember.Id_Tarif_Item__c));
                }
            } else if (getObject(theTarifMember.Id_Tarif_Item__c) == 'List_Service_Price__c') {
                if (this.servicesMap.get(theTarifMember.Id_Tarif_Item__c) != null) {
                    this.mapSelectedServices.put(theTarifMember.Id_Tarif_Item__c, this.servicesMap.get(theTarifMember.Id_Tarif_Item__c));
                }
            }
        }

    }

    private String getObject(String id) {
        Id theId = (Id)id;

        return theId.getSobjectType().getDescribe().getName();
    }

    public void save() {
        if (saveValidation()) {
            if (this.updateItem()) {
                String recordTypeDeveloperName = this.determineCompanyCode() + '_Tarif';
                RecordType rt = LibRecordTypeHelper.getRecordType(recordTypeDeveloperName,  'Tarif__c');
                this.myTarif.RecordTypeId = rt.Id;
                this.myTarif.Id_Country__c = this.selectedCountry;
                this.myTarif.Company__c = this.selectedCompany;
                try {
                    upsert myTarif;
                    delete myTarif.Tarif_Members__r;

                    List<Tarif_Member__c> listOfProductsToInsert = new List<Tarif_Member__c>();
                    List<Tarif_Member__c> listOfServicesToInsert = new List<Tarif_Member__c>();

                    for (String key : this.mapSelectedServices.keySet()) {
                        Tarif_Member__c theServiceMember = new Tarif_Member__c(Tarif_Name__c = myTarif.Id, Id_Tarif_Item__c = key, Type__c = 'Service');
                        listOfServicesToInsert.add(theServiceMember);
                    }

                    for (String key : this.mapSelectedProducts.keySet()) {
                        Tarif_Member__c theProductMember = new Tarif_Member__c(Tarif_Name__c = myTarif.Id, Id_Tarif_Item__c = key, Type__c = 'Product');
                        listOfProductsToInsert.add(theProductMember);
                    }

                    insert listOfServicesToInsert;
                    insert listOfProductsToInsert;

                    this.reset();
                    this.reInitCountryAndCompanyDropdowns();

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Save_Edit_Tarif_Success));
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                    system.debug('@@@@ The following error occured while saving changes to the tarif with name : ' + myTarif.Name + ' : ' + e.getMessage());
                }
            } else {
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, Label.SMC_Required_Fields_Missing));
            }

        }
    }

    public void cancel() {
        reset();
        this.reInitCountryAndCompanyDropdowns();
    }
}