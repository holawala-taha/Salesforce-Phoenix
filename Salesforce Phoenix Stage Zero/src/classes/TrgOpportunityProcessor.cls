public with sharing class TrgOpportunityProcessor {

    //private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Additional_Charges__c', 'Contract', 'Opportunity','Asset__c'});
    //private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Additional_Charges__c', 'Contract', 'Opportunity','Asset__c'});

    //moam call with process list goes here...
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    public TrgOpportunityProcessor() {
    }

    public static void updateOpportunityCurrency(List<Opportunity> opportunities) {
        Map<Id, Country__c> oppIdCountryMap = new Map<Id, Country__c>();
        Map<Id, String> oppMap = new Map<Id, String>();
        Set<String> oppCountryNames = new Set<String>();
        for (Opportunity opp : opportunities) {
            oppCountryNames.add(opp.Record_Country__c);
            oppMap.put(opp.Id, opp.Record_Country__c);
        }

        List<Country__c> countries = [SELECT Id, Name, Iso__c, CurrencyIsoCode FROM Country__c WHERE Name IN : oppCountryNames];
        if (!countries.isEmpty()) {
            for (Id oppId : oppMap.keySet()) {
                for (Country__c country : countries) {
                    if (country.Name.equals(oppMap.get(oppId))) {
                        oppIdCountryMap.put(oppId, country);
                    }
                }
            }
        }

        if (!oppIdCountryMap.isEmpty()) {
            for (Opportunity opp : opportunities) {
                opp.CurrencyIsoCode = oppIdCountryMap.get(opp.Id).CurrencyIsoCode;
            }
        }
    }

    static Decimal calculateTotal(Decimal listPrice, String discountStr) {
        Decimal total;
        Decimal totalResult;
        List<String> discountInPercent = new List<String>();
        if (discountStr != null && discountStr.length() > 0) {
            if (discountStr.indexOf('%') > -1) {
                discountInPercent = discountStr.split('%');
                Decimal discount = listPrice * (Decimal.valueOf(discountInPercent[0]) / 100);
                total = listPrice - discount;

            } else {
                total = listPrice - Decimal.valueOf(discountStr);
            }
        } else {
            total = listPrice;
        }
        totalResult = total.setScale(2);

        return totalResult;
    }

    //Stamps Online_Since date on Account when an Opportunity is closed won(Contract is created)
    public static void populateAccOnOppCloseWon(List<Opportunity> listOpportunities, Map<id, Opportunity> oldOppMap) {

        Set<Id> recordTypeIds = new Set<Id>();
        for (Opportunity opp_updated : listOpportunities) {
            If(opp_updated.StageName == 'Closed Won' && oldOppMap.get(opp_updated.id).StageName != opp_updated.StageName) {
                recordTypeIds.add(opp_updated.RecordTypeId);
            }
        }
        Set<Id> oppIdSet = new Set<Id>();
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('Opportunity Contract Process');
        Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
        String fieldToUpdate;
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            List<Opportunity> processOpp = new List<Opportunity>();
            for (Opportunity oppi : listOpportunities) {
                if (oppi.Is_DataLoaded__c == false) {
                    mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppi.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('opportunity stage') != null && mapBusinessRules.get('opportunity stage').Business_Rule_Value__c == oppi.StageName && oldOppMap.get(oppi.id).StageName != oppi.StageName) {
                            oppIdSet.add(oppi.Id);
                        }
                    } else {
                        oppi.addError(Label.Opportunity_Contract_Business_Rule_Required);
                    }
                }
            }

        }
    }

    //Creates Contracts, Additional charges and Assets for a Quote
    public static void contractProcess(List<Opportunity> listOpportunities, Map<id, Opportunity> oldOppMap) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (Opportunity opp : listOpportunities) {
            recordTypeIds.add(opp.RecordTypeId);
        }
        Map<Id, RecordType> oppIdRecordType = new Map<Id, RecordType>();
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE Id IN : recordTypeIds]);
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('Opportunity Contract Process');

        List<Contract> listNewContracts = new List<Contract>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            List<Opportunity> processOpp = new List<Opportunity>();
            system.debug('listOpportunities : ' + listOpportunities);
            for (Opportunity oppi : listOpportunities) {
                System.debug('oppi.Is_DataLoaded__c: ' + oppi.Is_DataLoaded__c);
                if (oppi.Is_DataLoaded__c == false) {
                    oppIdRecordType.put(oppi.Id, recordTypeMap.get(oppi.RecordTypeId));
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(recordTypeMap.get(oppi.RecordTypeId).DeveloperName);
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('opportunity stage') != null && mapBusinessRules.get('opportunity stage').Business_Rule_Value__c == oppi.StageName && oldOppMap.get(oppi.id).StageName != oppi.StageName) {
                            processOpp.add(oppi);
                        }
                    } else {
                        oppi.addError(Label.Opportunity_Contract_Business_Rule_Required);
                    }
                }
            }
            List<Opportunity_Quote__c> oppQuoteIds = [SELECT Id FROM Opportunity_Quote__c WHERE Id_Opportunity__c IN:processOpp AND Status__c = 'Accepted'];
            Map<Id, Account> updateNonContractAccount = new Map<Id, Account>();
            //added by magesh
            List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();
            //merged Asset creation with the contratc process
            List<Asset__c> listProcessAssetForAddCharge = new List<Asset__c>();
            List<Asset__c> listAssets = new List<Asset__c>();
            //List<Add_on_Service__c> listAddOn = new List<Add_on_Service__c>();
            List<Branding_Content__c>listBranding = new List<Branding_Content__c>();
            Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id, Opportunity_Quote_Line_Item__c>();
            //SP-304
            List<Opportunity_Quote_Line_Item__c> listProductsWithFlexiblePremiumPlacement = new List<Opportunity_Quote_Line_Item__c>();
            //SP-304
            Set<String> premiumPlacementProductTypes = new Set<String> {'Premium placement - 1 Month', 'Premium placement - 3 Months', 'Premium placement - 6 Months', 'Premium placement - 12 Months'};
            if (oppQuoteIds != null && !oppQuoteIds.isEmpty()) {
                for (Opportunity_Quote_Line_Item__c oppQlineItem : [Select Id, Name, Line_Item_Type__c, Sub_type__c, Id_List_Service_Price__c, CurrencyIsoCode, Commission_In_Percentage__c, Commission_Per_Order__c, Start_Date__c, End_Date__c,
                        Id_Opportunity_Quote__c, Recurring_Fee__c, Id_Opportunity__r.OwnerId, Id_Opportunity__r.RecordTypeId, Id_Opportunity__r.AccountId, Id_Opportunity__r.Account.Non_Contracted__c,
                        recordtype.DeveloperName, Id_Replacement_Order__c,
                        (select name, Account__c, CurrencyIsoCode, RecordTypeId, Id_Opportunity_Quote_Line_Item__c, Opportunity__c, Status__c from Assets__r), (select id from branding_content__r),
                        Id_Opportunity__c, Id_Opportunity__r.CloseDate, Id_List_Product_Price__r.Requires_Asset__c, Id_List_Product_Price__r.Requires_Additional_Charge__c,
                        Id_List_Product_Price__r.Requires_Add_On__c, Id_List_Product_Price__r.Requires_Branding__c, Id_List_Product_Price__r.Product_Type__c, Id_List_Product_Price__r.Product_Name__c,
                        Has_Related_Tarif__c, Id_List_Product_Price__c, Installments__c, Listed_Price__c, weight__c, size__c, Min__c, Max__c, index__c, IsTiered__c,
                        Product_Group__c, Quantity__c, Discount__c, Deposit_Method__c, Id_Opportunity_Quote__r.Non_Standard_Contract_Components__c, Number_of_Copies__c, Total_Amount__c, Category__c, Category_Id__c, District__c, District_Id__c, City_ZipCode__c, Booking_Api_Id__c, Position__c, Online_Payment_Fee__c
                        FROM Opportunity_Quote_Line_Item__c
                        WHERE Id_Opportunity_Quote__c IN :oppQuoteIds order by index__c]) {
                    Id ownerId = oppQlineItem.Id_Opportunity__r.OwnerId;
                    Id oppId = oppQlineItem.Id_Opportunity__c;
                    Id accId = oppQlineItem.Id_Opportunity__r.AccountId;
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppQlineItem.Id_Opportunity__r.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (oppQlineItem.Line_Item_Type__c == 'Service') {
                            System.debug('oppQlineItem.Id_Opportunity__r.AccountId: ' + oppQlineItem.Id_Opportunity__r.AccountId);
                            if (updateNonContractAccount.get(oppQlineItem.Id_Opportunity__r.AccountId) == null && oppQlineItem.Id_Opportunity__r.Account.Non_Contracted__c == true) {
                                updateNonContractAccount.put(oppQlineItem.Id_Opportunity__r.AccountId, new Account(id = oppQlineItem.Id_Opportunity__r.AccountId, Non_Contracted__c = false));
                            }
                            System.debug('updateNonContractAccount: ' + updateNonContractAccount);
                            Contract contr = new Contract();
                            contr.AccountId  = accId;
                            contr.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.id;
                            contr.Id_Opportunity__c = oppId;
                            contr.Online_Payment_Fee__c = oppQlineItem.Online_Payment_Fee__c;
                            contr.Id_Opportunity_Quote__c = oppQlineItem.Id_Opportunity_Quote__c;
                            contr.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('contract_RecordType').Business_Rule_Value__c);
                            contr.Service_Type__c = oppQlineItem.Sub_type__c;
                            contr.OwnerId = ownerId;
                            if (String.isNotblank(string.valueof(oppQlineItem.Commission_In_Percentage__c))) {
                                contr.Commission__c = oppQlineItem.Commission_In_Percentage__c;
                            }
                            if (String.isNotblank(string.valueof(oppQlineItem.Recurring_Fee__c))) {
                                contr.Recurring_Fee__c = oppQlineItem.Recurring_Fee__c;
                            }
                            if (oppQlineItem.Commission_Per_Order__c != null) {
                                contr.Commission_Per_Order__c = oppQlineItem.Commission_Per_Order__c;
                            }
                            contr.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                            contr.Name__c = oppQlineItem.Name;
                            contr.Status = 'Draft'; //Activated
                            contr.StartDate = oppQlineItem.Start_Date__c;
                            if (oppQlineItem.IsTiered__c) {
                                contr.Min__c = oppQlineItem.Min__c;
                                contr.Max__c = oppQlineItem.Max__c;
                                contr.index__c = oppQlineItem.index__c;
                                contr.IsTiered__c = oppQlineItem.IsTiered__c;
                                if (contr.Min__c == null) {
                                    break;
                                }
                            }
                            //system.debug('@@@ end date'+oppQlineItem.End_Date__c);
                            if (String.isNotblank(string.valueof(oppQlineItem.End_Date__c))) {
                                contr.End_Date__c = oppQlineItem.End_Date__c;
                                //system.debug('@@@con end date'+contr.End_Date__c);
                            }
                            listNewContracts.add(contr);
                        } else if (oppQlineItem.Line_Item_Type__c == 'Product') {
                            mapOppQuoteProd.put(oppQlineItem.Id, oppQlineItem);
                            //Asset creation merged
                            system.debug('**opp quote oppQlineItem:' + oppQlineItem);
                            if (oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c) {
                                if (oppQlineItem.Assets__r == null || oppQlineItem.Assets__r.isEmpty()) {
                                    for (integer i = 1; i <= oppQlineItem.Quantity__c; i++  ) {
                                        Asset__c newAsset = new Asset__c();
                                        newAsset.OwnerId = ownerId;
                                        newAsset.name = oppQlineItem.name;
                                        newAsset.Account__c = accId;
                                        newAsset.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                        newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('Asset RecordType').Business_Rule_Value__c);
                                        newAsset.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.Id;
                                        newAsset.Opportunity__c = oppId;
                                        newAsset.Status__c = mapBusinessRules.get('AssetStatus').Business_Rule_Value__c;
                                        listAssets.add(newAsset);
                                    }
                                } else {
                                    listProcessAssetForAddCharge.addAll(oppQlineItem.Assets__r);
                                }
                            }
                            if (mapBusinessRules.get('flexiblePremiumPlacementRuntime') != null && Boolean.valueOf(mapBusinessRules.get('flexiblePremiumPlacementRuntime').Business_Rule_Value__c) &&
                                    premiumPlacementProductTypes.contains(oppQlineItem.Id_List_Product_Price__r.Product_Type__c)) {
                                listProductsWithFlexiblePremiumPlacement.add(oppQlineItem);
                            } else if (oppQlineItem.Id_List_Product_Price__r.Requires_Additional_Charge__c && !oppQlineItem.Id_List_Product_Price__r.Requires_Asset__c) {
                                //create all other Additional Charge except for Asset
                                Additional_Charges__c add1 = new Additional_Charges__c();
                                add1.Has_Related_Tarif__c = oppQlineItem.Has_Related_Tarif__c;
                                add1.Id_List_Product_Price__c = oppQlineItem.Id_List_Product_Price__c;
                                add1.Installments__c = oppQlineItem.Installments__c;
                                add1.Listed_Price__c = oppQlineItem.Listed_Price__c;
                                add1.Id_Opportunity_Quote__c = oppQlineItem.Id_Opportunity_Quote__c;
                                add1.Product_Group__c = oppQlineItem.Product_Group__c;
                                add1.product__c = oppQlineItem.name;
                                add1.Quantity__c = oppQlineItem.Quantity__c;
                                add1.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                add1.Rabbat__c = oppQlineItem.Discount__c;
                                add1.Total_Amount__c = oppQlineItem.Total_Amount__c;
                                add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c);
                                add1.Id_Account__c = accId;
                                add1.Id_Opportunity__c = oppId;
                                //add1.Ad_Sales_Type__c=oppQlineItem.Ad_Sales_Type__c;
                                add1.Category__c = oppQlineItem.Category__c;
                                add1.Category_Id__c = oppQlineItem.Category_Id__c;
                                add1.District__c = oppQlineItem.District__c;
                                add1.District_Id__c = oppQlineItem.District_Id__c;
                                add1.Type__c = oppQlineItem.Sub_type__c;
                                add1.Position__c = oppQlineItem.Position__c;
                                add1.Booking_Api_Id__c = oppQlineItem.Booking_Api_Id__c;
                                add1.City_ZipCode__c = oppQlineItem.City_ZipCode__c;
                                add1.Id_Replacement_Order__c = mapOppQuoteProd.get(oppQlineItem.Id).Id_Replacement_Order__c;

                                //SP-759
                                if (mapBusinessRules.get('startDateIsOppCloseDate') != null && Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)) {
                                    add1.Start_Date__c = oppQlineItem.Id_Opportunity__r.CloseDate;
                                } else if (oppQlineItem.Start_Date__c != null) {
                                    add1.Start_Date__c = oppQlineItem.Start_Date__c;
                                } else {
                                    add1.Start_Date__c = Date.today();
                                }
                                add1.Termination_Date__c = oppQlineItem.End_Date__c;
                                listAdditional.add(add1);
                            }

                            /*if(oppQlineItem.Id_List_Product_Price__r.Requires_Add_On__c){
                                for(integer i=1; i<=oppQlineItem.Quantity__c; i++  ){
                                    Add_on_Service__c newAddOn = new Add_on_Service__c();
                                    newAddOn.Account_Name__c = accId;
                                    newAddOn.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                    newAddOn.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AddOnRecordType').Business_Rule_Value__c);
                                    newAddOn.Opportunity__c = oppId;
                                    if(oppQlineItem.Start_Date__c!=null){
                                        newAddOn.Start_Date__c = oppQlineItem.Start_Date__c;
                                    }else{
                                        newAddOn.Start_Date__c = Date.today();
                                    }
                                    listAddOn.add(newAddOn);
                                }
                            }*/

                            if (oppQlineItem.Id_List_Product_Price__r.Requires_Branding__c) {
                                integer qty = 0;
                                if (oppQlineItem.branding_content__r == null || oppQlineItem.branding_content__r.isEmpty()) {
                                    Set<string> prodtTypeSet = new Set<String>();
                                    if (mapBusinessRules.get('DefaultBrandingQtyProdType') != null) {
                                        if (mapBusinessRules.get('DefaultBrandingQtyProdType').Business_Rule_Value__c.contains(',')) {
                                            prodtTypeSet = new set<String>(mapBusinessRules.get('DefaultBrandingQtyProdType').Business_Rule_Value__c.split(','));
                                        } else
                                            prodtTypeSet.add(mapBusinessRules.get('DefaultBrandingQtyProdType').Business_Rule_Value__c);
                                    }
                                    if (mapBusinessRules.get('DefaultBrandingQtyProdType') != null && prodtTypeSet.contains(oppQlineItem.Id_List_Product_Price__r.Product_Type__c)) {
                                        qty = 1;
                                    } else
                                        qty = Integer.valueof(oppQlineItem.Quantity__c);
                                    for (integer i = 1; i <= qty; i++  ) {
                                        Branding_Content__c newBranding = new Branding_Content__c();
                                        newBranding.OwnerId = ownerId;
                                        newBranding.Restaurant_Name__c = accId;
                                        newBranding.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                        newBranding.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c);
                                        newBranding.Opportunity__c = oppId;
                                        newBranding.type__c = oppQlineItem.Id_List_Product_Price__r.Product_Type__c;
                                        newBranding.Id_Opportunity_Quote_Line_Item__c = oppQlineItem.id;
                                        newBranding.Number_of_Copies__c = oppQlineItem.Number_of_Copies__c;
                                        newBranding.Size__c = oppQlineItem.size__c;
                                        newBranding.weight__c = oppQlineItem.weight__c;
                                        newBranding.product__c = oppQlineItem.Id_List_Product_Price__c;
                                        if (mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c == 'UK_Branding_Content')
                                            newBranding.Quantity__c = 1;
                                        if (qty == 1)
                                            newBranding.Quantity__c = oppQlineItem.Quantity__c;
                                        if (mapBusinessRules.get('TemplateType') != null && Boolean.valueof(mapBusinessRules.get('TemplateType').Business_Rule_Value__c)) {
                                            if (oppQlineItem.Id_List_Product_Price__r.Product_Name__c != null && oppQlineItem.Id_List_Product_Price__r.Product_Name__c.containsIgnorecase('With Website')) {
                                                newBranding.Template_type__c = 'With Website';
                                            } else if (oppQlineItem.Id_List_Product_Price__r.Product_Name__c != null && oppQlineItem.Id_List_Product_Price__r.Product_Name__c.containsIgnorecase('Without Website'))
                                                newBranding.Template_type__c = 'Without Website';
                                        }
                                        newBranding.Deposit_Method__c = oppQlineItem.Deposit_Method__c;
                                        listBranding.add(newBranding);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            system.debug('list values--listNewContracts' + listNewContracts + 'listAssets' + listAssets +/*'listAddOn'+listAddOn+*/'listBranding' +listBranding);
            insert listNewContracts;
            insert listAssets;
            //insert listAddOn;
            insert listBranding;
            if (!listAssets.isEmpty()) {
                listProcessAssetForAddCharge.addAll(listAssets);
            }
            //create Additional charge for Assets

            for (Asset__c asst : listProcessAssetForAddCharge) {
                Decimal totalCalculated = calculateTotal(mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Listed_Price__c, mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Discount__c);
                Id oppId = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__c;
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppIdRecordType.get(oppId).DeveloperName);
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                    Additional_Charges__c add1 = new Additional_Charges__c();
                    add1.Has_Related_Tarif__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Has_Related_Tarif__c;
                    add1.Id_List_Product_Price__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_List_Product_Price__c;
                    add1.Installments__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Installments__c;
                    add1.Listed_Price__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Listed_Price__c;
                    add1.Id_Opportunity_Quote__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity_Quote__c;
                    add1.Product_Group__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Product_Group__c;
                    add1.product__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).name;
                    add1.Quantity__c = 1;
                    add1.CurrencyIsoCode = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).CurrencyIsoCode;
                    add1.Rabbat__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Discount__c;
                    add1.Total_Amount__c = totalCalculated;
                    add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c);
                    add1.Id_Account__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__r.AccountId;
                    add1.Id_Opportunity__c = oppId;
                    add1.Id_Asset__c = asst.id;
                    add1.Type__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Sub_type__c;
                    add1.Id_Replacement_Order__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Replacement_Order__c;
                    //SP-759
                    if (mapBusinessRules.get('startDateIsOppCloseDate') != null && Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)) {
                        add1.Start_Date__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Id_Opportunity__r.CloseDate;
                    } else if (mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Start_Date__c != null) {
                        add1.Start_Date__c = mapOppQuoteProd.get(asst.Id_Opportunity_Quote_Line_Item__c).Start_Date__c;
                    } else {
                        add1.Start_Date__c = Date.today();
                    }
                    listAdditional.add(add1);
                }
            }

            //end of asset creation


            //SP-304
            if (!listProductsWithFlexiblePremiumPlacement.isEmpty()) {
                List<Additional_Charges__c> listAddChargeFlexiblePP = createPremiumPlacementAdditionalCharges(listProductsWithFlexiblePremiumPlacement);
                listAdditional.addAll(listAddChargeFlexiblePP);
            }
            system.debug('*listAdditional-' + listAdditional);
            insert listAdditional;
            for (Contract c : listNewContracts) {
                Boolean donotAutoActivate = false;
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(oppIdRecordType.get(c.Id_Opportunity__c).DeveloperName);
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && mapBusinessRules.get('donotAutoActivate') != null ) {
                    donotAutoActivate = Boolean.valueof(mapBusinessRules.get('donotAutoActivate').Business_Rule_Value__c);


                }
                if (!donotAutoActivate)
                    c.Status = 'Activated';

            }
            update listNewContracts;
            //if the noncontracted account is given contract then the Account becames contracted
            System.debug('updateNonContractAccount: ' + updateNonContractAccount);
            if (!updateNonContractAccount.isEmpty()) {
                update updateNonContractAccount.values();
            }
            system.debug('@@@@ calling contractProcess - listNewContracts : ' + listNewContracts);
            if (!listNewContracts.isEmpty()) {
                ClsContractProcessor.preventDuplicateContracts(listNewContracts);
            }
        }

    }
    //helper method for SP-304
    private static List<Date> createListOfMonthlyStartDates(String initDate, Integer numberOfMonths) {
        String[] sdateparts = initDate.split('-');

        Date startDate = Date.newInstance(Integer.valueOf(sdateparts[0]), Integer.valueOf(sdateparts[1]), Integer.valueOf(sdateparts[2]));

        List<Date> listStartDates = new List<Date>();

        for (Integer i = 0; i < numberOfMonths; i++) {
            Date singleStartDate = startDate.addMonths(1);
            listStartDates.add(singleStartDate);
            startDate = singleStartDate;
        }

        return listStartDates;
    }

    //SP-304
    private static List<Additional_Charges__c> createPremiumPlacementAdditionalCharges(List<Opportunity_Quote_Line_Item__c> listOppQuoteProducts) {

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('flexiblePremiumPlacement');


        List<Additional_Charges__c> listAdditional = new List<Additional_Charges__c>();

        Map<String, Integer> mapNumberOfRecords = new Map<String, Integer> {'Premium placement - 1 Month' => 1 , 'Premium placement - 3 Months' => 3 , 'Premium placement - 6 Months' => 6, 'Premium placement - 12 Months' => 12};

        for (Opportunity_Quote_Line_Item__c quoteProduct : listOppQuoteProducts) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(quoteProduct.RecordType.DeveloperName);
            if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {

                Integer numberOfRecords = mapNumberOfRecords.get(quoteProduct.Id_List_Product_Price__r.Product_Type__c);

                for (Integer i = 0; i < numberOfRecords; i++) {
                    Additional_Charges__c add1 = new Additional_Charges__c();
                    add1.Has_Related_Tarif__c = quoteProduct.Has_Related_Tarif__c;
                    add1.Id_List_Product_Price__c = quoteProduct.Id_List_Product_Price__c;
                    add1.Installments__c = quoteProduct.Installments__c;
                    add1.Listed_Price__c = quoteProduct.Listed_Price__c;
                    add1.Id_Opportunity_Quote__c = quoteProduct.Id_Opportunity_Quote__c;
                    add1.Product_Group__c = quoteProduct.Product_Group__c;
                    add1.status__c = 'Active';
                    if (quoteProduct.City_ZipCode__c == null) {
                        add1.product__c = quoteProduct.name;
                    } else {
                        add1.product__c = quoteProduct.name + ' / ' + quoteProduct.City_ZipCode__c;
                    }
                    add1.Quantity__c = 1;
                    add1.CurrencyIsoCode = quoteProduct.CurrencyIsoCode;
                    add1.Rabbat__c = quoteProduct.Discount__c;
                    if (quoteProduct.Discount__c != null && quoteProduct.Discount__c != '0') {
                        Decimal discountAmount = 0;
                        if (quoteProduct.Discount__c.indexOf('%') > -1) {
                            Decimal rabatInPercentage = Decimal.valueOf(quoteProduct.Discount__c.split('%')[0]);
                            discountAmount = quoteProduct.Listed_Price__c * (rabatInPercentage / 100);

                        } else {
                            discountAmount = Decimal.valueOf(quoteProduct.Discount__c);
                        }
                        add1.Total_Amount__c = quoteProduct.Listed_Price__c - discountAmount;

                    } else {
                        add1.Total_Amount__c = quoteProduct.Listed_Price__c;
                    }

                    //add1.recordTypeId = mapRecordTypes.get(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c).id;
                    add1.recordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AdditionalCharges RecordType').Business_Rule_Value__c);
                    add1.Id_Account__c = quoteProduct.Id_Opportunity__r.AccountId;
                    add1.Id_Opportunity__c = quoteProduct.Id_Opportunity__c;
                    /*add1.Ad_Sales_Type__c=quoteProduct.Ad_Sales_Type__c;
                    add1.Category__c=quoteProduct.Category__c;
                    add1.Category_Id__c=quoteProduct.Category_Id__c;
                    add1.District__c=quoteProduct.District__c;
                    add1.District_Id__c=quoteProduct.District_Id__c;*/
                    add1.Type__c = quoteProduct.Sub_type__c;
                    add1.City_ZipCode__c = quoteProduct.City_ZipCode__c;
                    //SP-759
                    /*if(mapBusinessRules.get('startDateIsOppCloseDate') != null && Boolean.valueOf(mapBusinessRules.get('startDateIsOppCloseDate').Business_Rule_Value__c)){
                        add1.Start_Date__c = quoteProduct.Id_Opportunity__r.CloseDate;
                    }else*/

                    if (quoteProduct.Start_Date__c != null) {
                        if (i == 0) {
                            add1.Start_Date__c = quoteProduct.Start_Date__c.toStartOfMonth();
                            add1.Termination_Date__c = add1.Start_Date__c.addDays(Date.daysInMonth(add1.Start_Date__c.year(), add1.Start_Date__c.month()) - 1);
                        } else {
                            add1.Start_Date__c = quoteProduct.Start_Date__c.addMonths(i).toStartOfMonth();
                            add1.Termination_Date__c = add1.Start_Date__c.addDays(Date.daysInMonth(add1.Start_Date__c.year(), add1.Start_Date__c.month()) - 1);
                        }
                    }

                    listAdditional.add(add1);
                }

            }

        }


        return listAdditional;
    }

    //creation of menu processing case for non contracted opportunities SP-35
    public static void nonContractedMenuProcessing(List<Opportunity> newOpps) {
        List<Opportunity> nonContractedOppList = new List<Opportunity>();
        List<Case> listCase = new List<Case>();
        Map<Id, Boolean> existingMenuProcessingMap = new Map<Id, Boolean>();
        List<Id> accList = new List<Id>();
        for (Opportunity ops : newOpps) {
            accList.add(ops.AccountId);
        }
        for (Case c : [select id, Opportunity__c, AccountId from Case where Type = 'Menu Processing' and Opportunity__r.Non_Contracted__c = true and Opportunity__c in : newOpps]) {
            existingMenuProcessingMap.put(c.Opportunity__c, true);
        }
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('NonContractedMenuProcessing');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMenuProcessing');

        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Opportunity opp : newOpps) {
                    if (opp.Is_DataLoaded__c == false) {
                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (!existingMenuProcessingMap.containsKey(opp.id)) {

                            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && opp.Non_Contracted__c == Boolean.valueOf(mapBusinessRules.get('Non_Contracted__c').Business_Rule_Value__c)) {
                                Opportunity clonedOpp = opp.clone(true);
                                clonedOpp.Probability = Decimal.valueOf(mapBusinessRules.get('set Probability').Business_Rule_Value__c);
                                clonedOpp.StageName = mapBusinessRules.get('set StageName').Business_Rule_Value__c;
                                Map<String, String> mapFields = new Map<String, String>();
                                if (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c != null) {
                                    Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                                    for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c).split(',')) {
                                        List<String> fields = fieldAndValue.split('=');
                                        cs.put(fields[0], fields[1]);
                                    }
                                    listCase.add(cs);
                                }
                                nonContractedOppList.add(clonedOpp);
                            }
                        }
                    }
                }
                insert listCase;
                update nonContractedOppList;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }

    //creation of menu processing case for contracted opportunities SP-35
    //Updated changes for SP-392 by Magesh on 23.04.2015
    public static void contractedMenuProcessing(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> listCase = new List<Case>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> oppTypes = new Set<String>();
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('ContractedMenuProcessing');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ContractedMenuProcessing');

        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Opportunity opp : newOpps) {
                    if (opp.Is_DataLoaded__c == false) {
                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && opp.Non_Contracted__c  == Boolean.valueOf(mapBusinessRules.get('Non_Contracted__c').Business_Rule_Value__c)) {
                            if (mapBusinessRules.get('StageName').Business_Rule_Value__c != null && ((mapBusinessRules.get('StageName').Record_Type_Id__c == 'Yogiyo_Opportunity' && opp.StageName != oldMap.get(opp.Id).StageName) || mapBusinessRules.get('StageName').Record_Type_Id__c != 'Yogiyo_Opportunity') && opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c) {
                                //added the following lines for SP-399
                                if (mapBusinessRules.get('OpportunityType') != null && mapBusinessRules.get('OpportunityType').Business_Rule_Value__c != null) {
                                    if ((mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).indexOf(',') > -1) {
                                        for (String ctype : (mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).split(',')) {
                                            if (!oppTypes.contains(ctype)) {
                                                oppTypes.add(ctype);
                                            }
                                        }
                                    } else {
                                        oppTypes.add(mapBusinessRules.get('OpportunityType').Business_Rule_Value__c);
                                    }
                                    if (oppTypes.contains(opp.type)) {
                                        oppMap.put(opp.Id, opp);
                                    }
                                }
                            }
                        }
                    }
                }
                // loop for removing opportunity from the map if the closed reason of menu processing case is Not Successfull or open
                for (Case c : [select id, Opportunity__c, Opportunity__r.Recordtype.developerName, AccountId, Status, Closed_Reason__c, isClosed from Case where Type = 'Menu Processing' and Opportunity__c in : oppMap.keySet()]) {
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(c.Opportunity__r.Recordtype.developerName);
                    if (mapBusinessRules.get('ClosedReason') != null && mapBusinessRules.get('ClosedReason').Business_Rule_Value__c != null) {
                        Set<String> closedReason = new Set<String>();
                        String closedStr = mapBusinessRules.get('ClosedReason').Business_Rule_Value__c;
                        if (closedStr.indexOf(',') > -1) {
                            for (String r : closedStr.split(',')) {
                                closedReason.add(r);
                            }
                        } else {
                            closedReason.add(closedStr);
                        }
                        if (c.isClosed && !closedReason.contains(c.Closed_Reason__c)) {
                            oppMap.remove(c.Opportunity__c);
                        } else if (!c.isClosed) {
                            oppMap.remove(c.Opportunity__c);
                        }
                    }
                }
                // loop for the creation of Menu processing case
                for (Opportunity opp : oppMap.values()) {
                    //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('Menu Processing Case') != null && mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c != null) {
                            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                            for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            listCase.add(cs);
                        }
                    }
                }
                insert listCase;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }

    //creation of menu change case for non contracted opportunities SP-35
    public static void nonContractedMenuChange(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> listCase = new List<Case>();
        Map<Id, Boolean> existingMenuChangeMap = new Map<Id, Boolean>();
        List<Id> accList = new List<Id>();
       
        for (Opportunity ops : newOpps) {
            accList.add(ops.AccountId);
        }
        try {
            for (Case c : [select id, Opportunity__c, AccountId from Case where Type = 'Convert to Contract' and AccountId in : accList]) {
                existingMenuChangeMap.put(c.AccountId, true);
            }
            Map<Id, String> menuProcessingStatusMap = new Map<Id, String>();
            for (Case c : [select id, Opportunity__c, AccountId, status from Case where Type = 'Menu Processing' and Opportunity__c in : newOpps]) {
                if (menuProcessingStatusMap.get(c.AccountId) == null) {
                    menuProcessingStatusMap.put(c.AccountId, c.status);
                }
            }
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('NonContractedMenuChange');
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMenuChange');
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Opportunity opp : newOpps) {

                    if (opp.Is_DataLoaded__c == false) {

                        if (opp.Non_Contracted__c && !existingMenuChangeMap.containsKey(opp.AccountId)) {
                            //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                            if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && mapBusinessRules.get('StageName').Business_Rule_Value__c != null && ((mapBusinessRules.get('StageName').Record_Type_Id__c == 'Yogiyo_Opportunity' && opp.StageName != oldMap.get(opp.Id).StageName) || mapBusinessRules.get('StageName').Record_Type_Id__c != 'Yogiyo_Opportunity') && opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c && menuProcessingStatusMap.get(opp.AccountId) == mapBusinessRules.get('Menu Processing Status').Business_Rule_Value__c) {
                                /*if(mapBusinessRules.get('totalInternalTaskCount')!=null && mapBusinessRules.get('totalInternalTaskCount').Business_Rule_Value__c!=null){
                                    listTask.addAll(LibJSONHelper.parseJsonToCustomTasks(mapBusinessRules,opp));
                                }*/
                                if (mapBusinessRules.get('Menu Change Case').Business_Rule_Value__c != null) {
                                    Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                                    for (String fieldAndValue : (mapBusinessRules.get('Menu Change Case').Business_Rule_Value__c).split(',')) {
                                        List<String> fields = fieldAndValue.split('=');
                                        //mapFields.put(fields[0],fields[1]);
                                        cs.put(fields[0], fields[1]);
                                    }
                                    listCase.add(cs);
                                }
                            }
                        }

                    }
                }
                if (!listCase.isEmpty()) {
                    insert listCase;
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }

    //Last updated for SP-399 by magesh on 22.04.15
    public static void genericMenuProcessing(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> listCase  = new List<Case>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> oppTypes = new Set<String>();
        Set<ID> oppAT = new Set<ID>();
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('GenericMenuProcessing');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('GenericMenuProcessing');
        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                // loop for picking selected opportunity
                for (Opportunity opp : newOpps) {

                    if (opp.Is_DataLoaded__c == false) {

                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                            if ( mapBusinessRules.get('StageName').Business_Rule_Value__c != null && ((mapBusinessRules.get('StageName').Record_Type_Id__c == 'Yogiyo_Opportunity' && oldMap != null && opp.StageName != oldMap.get(opp.Id).StageName) || mapBusinessRules.get('StageName').Record_Type_Id__c != 'Yogiyo_Opportunity') && opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c) {
                                //added the following lines for SP-399
                                if (mapBusinessRules.get('OpportunityType') != null && mapBusinessRules.get('OpportunityType').Business_Rule_Value__c != null) {
                                    if ((mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).indexOf(',') > -1) {
                                        for (String ctype : (mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).split(',')) {
                                            if (!oppTypes.contains(ctype)) {
                                                oppTypes.add(ctype);
                                            }
                                        }
                                    } else {
                                        oppTypes.add(mapBusinessRules.get('OpportunityType').Business_Rule_Value__c);
                                    }
                                    if (oppTypes.contains(opp.type)) {
                                        oppMap.put(opp.Id, opp);
                                    }
                                }

                            }
                        }

                    }
                }
                // loop for removing opportunity from the map if the closed reason of menu processing case is Not Successfull or open
                for (Case c : [select id, Opportunity__c, Opportunity__r.Recordtype.developerName,Type, AccountId, Status, Closed_Reason__c, isClosed from Case where (Type = 'Menu Processing' Or Type ='Arabic Translation') and Opportunity__c in : oppMap.keySet()]) {
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(c.Opportunity__r.Recordtype.developerName);
                    if (mapBusinessRules.get('ClosedReason') != null && mapBusinessRules.get('ClosedReason').Business_Rule_Value__c != null) {
                        Set<String> closedReason = new Set<String>();
                        
                        String closedStr = mapBusinessRules.get('ClosedReason').Business_Rule_Value__c;
                        if (closedStr.indexOf(',') > -1) {
                            for (String r : closedStr.split(',')) {
                                closedReason.add(r);
                            }
                        } else {
                            closedReason.add(closedStr);
                        }
                        if(c.type=='Menu Processing'){
                            if (c.isClosed && !closedReason.contains(c.Closed_Reason__c)) {
                                oppMap.remove(c.Opportunity__c);
                            } else if (!c.isClosed) {
                                oppMap.remove(c.Opportunity__c);
                            }
                        }else if(c.type=='Arabic Translation'){
                            oppAT.add(c.Opportunity__c);
                        }
                    }
                }
                // loop for the creation of Menu processing case
                for (Opportunity opp : oppMap.values()) {
                    //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('Menu Processing Case') != null && mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c != null) {
                            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                            for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case').Business_Rule_Value__c).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            //Added as part of SP-492
                            if (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c) != null && mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c != null) {
                                if (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c.indexOf(',') > 1) {
                                    for (String fieldAndValue : (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c).split(',')) {
                                        List<String> fields = fieldAndValue.split('=');
                                        cs.put(fields[0], fields[1]);
                                    }
                                } else {
                                    List<String> fields = (mapBusinessRules.get('BusinessType-' + opp.Business_Type__c).Business_Rule_Value__c).split('=');
                                    cs.put(fields[0], fields[1]);
                                }
                            }
                            listCase.add(cs);
                        }
                        if (mapBusinessRules.get('Menu Processing Case 2') != null && mapBusinessRules.get('Menu Processing Case 2').Business_Rule_Value__c != null) {
                            if(oppAt.isEmpty() || !(!oppAt.isEmpty() && oppAT.contains(opp.id))){
                                Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                                for (String fieldAndValue : (mapBusinessRules.get('Menu Processing Case 2').Business_Rule_Value__c).split(',')) {
                                    List<String> fields = fieldAndValue.split('=');
                                    cs.put(fields[0], fields[1]);
                                }
                            //Added as part of SP-492
                            /*if(mapBusinessRules.get('BusinessType-'+opp.Business_Type__c)!=null && mapBusinessRules.get('BusinessType-'+opp.Business_Type__c).Business_Rule_Value__c!=null){
                                if(mapBusinessRules.get('BusinessType-'+opp.Business_Type__c).Business_Rule_Value__c.indexOf(',')>1){
                                    for(String fieldAndValue : (mapBusinessRules.get('BusinessType-'+opp.Business_Type__c).Business_Rule_Value__c).split(',')){
                                        List<String> fields = fieldAndValue.split('=');
                                        cs.put(fields[0],fields[1]);
                                    }
                                }else{
                                    List<String> fields = (mapBusinessRules.get('BusinessType-'+opp.Business_Type__c).Business_Rule_Value__c).split('=');
                                    cs.put(fields[0],fields[1]);
                                }
                            }*/
                                listCase.add(cs);
                            }
                        }
                    }

                }
                insert listCase;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }

    public static void setDefaultValueForOpportunityQuoteComment(List<Opportunity> opportunities, Boolean isMenuPrinting) {
        ClsQuoteProcessor cqp = new ClsQuoteProcessor();
        cqp.setDefaultValueForOpportunityQuoteComment(opportunities, isMenuPrinting);
    }

    /**
    * SP-293 check for open menu processing case and throws exception if the opportunity is set to closed won
    * @param
    *   opportunities: List of new Trigger values
    * @return void
    */
    public static void MenuProcessingCaseCheck(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        Map<Id, Case> menuProcessingCaseMap = new Map<Id, Case>();
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuProcessingClosingAction');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingClosingAction');
        for (Case cs : [select id, Opportunity__c, isClosed, RecordType.DeveloperName from Case where type = 'Menu Processing' and isClosed = false and Opportunity__c in: opportunities]) {
            menuProcessingCaseMap.put(cs.Opportunity__c, cs);
        }
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Opportunity opp : opportunities) {
                if (opp.Is_DataLoaded__c == false) {
                    if (!menuProcessingCaseMap.isEmpty() && menuProcessingCaseMap.get(opp.Id) != null ) {
                        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(menuProcessingCaseMap.get(opp.Id).RecordType.DeveloperName);
                        if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                            if (opp.stageName == 'Closed Won' && opp.stageName != oldMap.get(opp.id).stageName && !ClsCaseProcessor.talabatFlag) {
                                opp.addError(Label.MenuProcessing_Opp_Validation);
                            }
                        }
                    }
                }
            }
        }

    }

    /**
    * SP-373 creation of Quality Check internal case
    * @param
    *   opportunities: List of new Trigger values
    * @return void
    */
    public static void qualityCheckInternalCase(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        List<Case> listCase  = new List<Case>();
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckInternalCase');
        Set<String> caseTypes = new Set<String>();
        Map<Id, Opportunity> idToOpp = new Map<Id, Opportunity>();
        Map<Id, Account> idToAccount;
        Set<Id> oppWithFirstStageQC = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        if (mapBusinessLogic == null) {
            return;
        }

        try {
            for (Opportunity opp : opportunities) {

                // skips data loaded opps
                if (opp.Is_DataLoaded__c) {
                    continue;
                }

                Set<String> stageNameSet;
                Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

                if (rules == null
                        || !rules.containsKey('StageName')) {
                    continue;
                }

                stageNameSet = new Set<String>(rules.get('StageName').Business_Rule_Value__c.split(','));

                if (stageNameSet.contains(opp.stageName) && oldMap.get(opp.id).stageName != opp.stageName) {
                    idToOpp.put(opp.id, opp);
                    if (rules.containsKey('CheckOpenCaseType')) {
                        caseTypes.addAll(rules.get('CheckOpenCaseType').Business_Rule_Value__c.split(','));
                    }
                }
            }

            if (!caseTypes.isEmpty()) {
                // loop for checking open cases which has types of CaseTypes and removes opportunity from the Map
                for (Case cs : [
                            SELECT
                            Opportunity__c,
                            Type,
                            isClosed,
                            Stage_1_Completed__c
                            FROM Case
                            WHERE Opportunity__c IN :idToOpp.keySet()
                            AND Type IN: caseTypes]) {

                    if (!cs.isClosed) {
                        idToOpp.remove(cs.Opportunity__c);
                    } else if (cs.Type == 'Quality Check' && cs.Stage_1_Completed__c) {
                        oppWithFirstStageQC.add(cs.Opportunity__c);
                    }
                }
            }

            if (idToOpp.isEmpty()) {
                return;
            }

            // get opps account
            for (Opportunity opp : idToOpp.values()) {
                accountIds.add(opp.AccountId);
            }

            idToAccount = new Map<Id, Account>([Select Type From Account Where Id in: accountIds]);

            //loop for creating Quality check case for the selected opportunity
            for (Opportunity opp : idToOpp.values()) {

                Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

                Case cs = new Case(
                    Opportunity__c = opp.Id,
                    AccountId = opp.AccountId,
                    CurrencyIsoCode = opp.CurrencyIsoCode
                );

                /* following logic was added for talabat SP-1447
                Only for New Business Opp related to Brand Account the Quality Check
                could have two different stages */

                Set<String> validAccountForSecondStage = rules.containsKey('validAccountForSecondStage') ? new Set<String>(rules.get('validAccountForSecondStage').Business_Rule_Value__c.split(',')) : new Set<String>();
                Set<String> validOppBusinessTypeForSecondStage = rules.containsKey('validOppBusinessTypeForSecondStage') ? new Set<String>(rules.get('validOppBusinessTypeForSecondStage').Business_Rule_Value__c.split(',')) : new Set<String>();

                String ruleName = 'QualityCheckCase'; // default one

                if (validAccountForSecondStage.contains(idToAccount.get(opp.AccountId).Type)
                        && validOppBusinessTypeForSecondStage.contains(opp.Business_Type__c)) {

                    if (!oppWithFirstStageQC.contains(opp.Id)) {
                        ruleName = 'QualityCheckCaseFirstStage';
                    } else {
                        ruleName = 'QualityCheckCaseSecondStage';
                    }
                }

                for (String fieldAndValue : rules.get(ruleName).Business_Rule_Value__c.split(',')) {
                    List<String> fields = fieldAndValue.split('=');
                    cs.put(fields[0], fields[1]);
                }

                /* SP-491
                needs to be hardcoded, since concatination
                with fieldnames doesnt work from business configs */
                if (rules.containsKey('UseBusinessTypeForCaseSubject')
                        && Boolean.valueOf(rules.get('UseBusinessTypeForCaseSubject').Business_Rule_Value__c)) {
                    cs.Subject += ' ' + opp.Business_Type__c;
                }

                listCase.add(cs);
            }

            insert listCase;

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            opportunities[0].addError(e.getMessage());
        }
    }

    /**
    * SP-434 Validation for Opportunity closure if any nonaccepted Quote is present
    * @param
    *   opportunities: List of new Trigger values
    * @return void
    */
    public static void validateClosedOpportunity(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        System.debug('TrgOpportunityProcessor.validateClosedOpp: start');

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
        Set<String> oppTypes = new Set<String>();
        Map<Id, Boolean> skipValidOppMap = new Map<Id, Boolean>();
        Set<Id> validOppIds = new Set<Id>();
        Set<Id> validOppWithQC = new Set<Id>();
        Set<Id> validOppwithOnb = new Set<Id>();
        Set<Id> validOppwithAsset = new Set<Id>();
        Set<Id> validOppwithMP = new Set<Id>();
        Set<Id> validOppWithBranding = new Set<Id>();
        Set<Id> validOppWithShipment = new Set<Id>();
        Set<Id> validOppWithSetupBackend = new Set<Id>();
        Set<Id> validOppWithBEDataEntry = new Set<Id>();

        if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
            System.debug('TrgOpportunityProcessor.validateClosedOpp: no business logic');
            return;
        }

        //Loop for putting accepted and nonaccepted state value in Map for each opportuity
        for (Opportunity_Quote__c quote : [select id, status__c, Id_Opportunity__c from Opportunity_Quote__c where Id_Opportunity__c in : opportunities]) {
            if (quote.status__c == 'Accepted') {

                System.debug('TrgOpportunityProcessor.validateClosedOpp: skipping validation for: ' + quote.Id_Opportunity__c);

                skipValidOppMap.put(quote.Id_Opportunity__c, true);
            } else if (!skipValidOppMap.containsKey(quote.Id_Opportunity__c)) {

                skipValidOppMap.put(quote.Id_Opportunity__c, false);
            }
        }

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checking opps...');
        for (Opportunity opp : opportunities) {

            if (opp.Is_DataLoaded__c || String.isBlank(opp.Id)) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: opp is data loaded: ' + opp.Id);
                continue;
            }

            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

            if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: no rules for this opp: ' + opp.Id);
                continue;
            }

            if (mapBusinessRule.containskey('AllowCheckForQCOpen') && Boolean.valueOf(mapBusinessRule.get('AllowCheckForQCOpen').Business_Rule_Value__c)) {
                validOppIds.add(opp.Id);
            }
            if (mapBusinessRule.containskey('CheckForAtleastOnePositiveQC') && Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveQC').Business_Rule_Value__c)) {
                validOppWithQC.add(opp.Id);
            }
            if (mapBusinessRule.containskey('CheckForAtleastOnePositiveOnboarding') && Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveOnboarding').Business_Rule_Value__c)) {
                validOppWithOnb.add(opp.Id);
            }
            if (mapBusinessRule.containskey('checkForAsset') && Boolean.valueOf(mapBusinessRule.get('checkForAsset').Business_Rule_Value__c)) {
                validOppWithAsset.add(opp.Id);
            }
            if (mapBusinessRule.containskey('checkForMP') && Boolean.valueOf(mapBusinessRule.get('checkForMP').Business_Rule_Value__c)) {
                validOppWithMP.add(opp.Id);
            }
            if (mapBusinessRule.containskey('CheckForBranding') && Boolean.valueOf(mapBusinessRule.get('CheckForBranding').Business_Rule_Value__c)) {
                validOppWithBranding.add(opp.Id);
            }
            if (mapBusinessRule.containsKey('checkForBEDataEntryCase') && Boolean.valueOf(mapBusinessRule.get('checkForBEDataEntryCase').Business_Rule_Value__c)) {
                validOppWithBEDataEntry.add(opp.Id);
            }
            if (mapBusinessRule.containsKey('checkForSetupBackEndCase') && Boolean.valueOf(mapBusinessRule.get('checkForSetupBackEndCase').Business_Rule_Value__c)) {
                validOppWithSetupBackend.add(opp.Id);
            }
            if (mapBusinessRule.containsKey('checkForShipmentCase') && Boolean.valueOf(mapBusinessRule.get('checkForShipmentCase').Business_Rule_Value__c)) {
                validOppWithShipment.add(opp.Id);
            }

            // checks on the status map
            if (mapBusinessRule.get('statusMap') != null) {
                Set<string> notAllowedStatus = new set <string>();
                Map<String, String> theMap = (Map<String, String>)JSON.deserialize(mapBusinessRule.get('statusMap').Business_Rule_Value__c, Map<String, String>.class);

                if (theMap.containskey(oldMap.get(opp.id).stageName)) {
                    if (theMap.get(oldMap.get(opp.id).stageName).contains(';')) {
                        notAllowedStatus = new set<String>(theMap.get(oldMap.get(opp.id).stageName).split(';'));
                    } else {
                        notAllowedStatus.add(theMap.get(oldMap.get(opp.id).stageName));
                    }

                    if (notAllowedStatus.contains(opp.stageName) && (opp.type != 'Product Only' || oldMap.get(opp.id).stageName != 'Menu received')  && !ClsCaseProcessor.donotValidateOppStage) {
                        opp.addError(Label.Opportunity_Stage_Update + ' ' + opp.stageName);
                        return;
                    }
                }
            }
            // checks if can skip validation
            if (!skipValidOppMap.containsKey(opp.id) || (!skipValidOppMap.get(opp.id) && !ClsRemoteController.chkAcceptQuote  && !ClsCaseProcessor.donotValidateOppStage) ) {
                if (mapBusinessRule.get('notAllowedWithoutAcceptQuote') != null ) {
                    Set<string> notAllowedStages = new set<String>(mapBusinessRule.get('notAllowedWithoutAcceptQuote').Business_Rule_Value__c.split(','));
                    if (notAllowedStages.contains(opp.stageName)) {
                        opp.addError(Label.Opportunity_Stage_Update + ' ' + opp.stageName);
                        return;
                    }
                }
            }
        }

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checking opps completed.');

        Set<Id> oppsRelatedToCase = new Set<Id>();
        oppsRelatedToCase.addAll(validOppWithBEDataEntry);
        oppsRelatedToCase.addAll(validOppWithSetupBackend);
        oppsRelatedToCase.addAll(validOppWithShipment);
        oppsRelatedToCase.addAll(validOppIds);
        oppsRelatedToCase.addAll(validOppWithQC);
        oppsRelatedToCase.addAll(validOppWithMP);
        oppsRelatedToCase.addAll(validOppWithOnb);

        Set<Id> assetNotActivated = new Set<Id>();
        Set<Id> brandingNotActivated = new Set<Id>();

        /*
            for cases we need to check for:
                - open cases or closed not successful
                - closed cases successful
            this is because an Opportunity could go through more
            quality checks, menu processing etc...

            If at least one of these cases is closed then the Opportunity
            could be closed
         */
        Set<Id> qcCaseOpenOrNotSuccessful = new Set<Id>();
        Set<Id> onBoardCaseOpenOrNotSuccessful = new Set<Id>();
        Set<Id> menuPrCaseOpenOrNotSuccessful = new Set<Id>();
        Set<Id> shipmentCaseOpenOrNotSuccessful = new Set<Id>();
        Set<Id> setupBECaseOpenOrNotSuccessful = new Set<Id>();
        Set<Id> beDataEntryCaseOpenOrNotSuccessful = new Set<Id>();

        Set<Id> qcCaseSuccessful = new Set<Id>();
        Set<Id> onBoardCaseSuccessful = new Set<Id>();
        Set<Id> menuPrCaseSuccessful = new Set<Id>();
        Set<Id> shipmentCaseSuccessful = new Set<Id>();
        Set<Id> setupBECaseSuccessful = new Set<Id>();
        Set<Id> beDataEntryCaseSuccessful = new Set<Id>();

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checking related cases...');

        // checks open or non successful cases
        if (!oppsRelatedToCase.isEmpty()) {
            for (Case cs : [SELECT
                            Opportunity__c,
                            isClosed,
                            Closed_Reason__c,
                            type
                            FROM Case
                            WHERE Type in ('Quality Check', 'Menu Processing', 'Onboarding', 'Shipment', 'Setup Backend', 'BE Data Entry')
                            AND Opportunity__c in :oppsRelatedToCase]) {

                if (cs.Type == 'Quality Check') {

                    if (!validOppIds.contains(cs.Opportunity__c) && !validOppWithQC.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for QC cases
                        continue;
                    }

                    if (!cs.isClosed || cs.Closed_Reason__c == 'Not Successful') {
                        // still open or closed unsuccessful
                        qcCaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Successful') {
                        qcCaseSuccessful.add(cs.Opportunity__c);
                    }

                } else if (cs.Type == 'Onboarding') {

                    if (!validOppWithOnb.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for On Boarding cases
                        continue;
                    }

                    if (!cs.IsClosed || cs.Closed_Reason__c == 'Not Successful') {
                        onBoardCaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Successful') {
                        onBoardCaseSuccessful.add(cs.Opportunity__c)  ;
                    }

                } else if (cs.Type == 'Menu Processing') {

                    if (!validOppwithMP.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for menu processing cases
                        continue;
                    }

                    if (!cs.isClosed || cs.Closed_Reason__c != 'Take Online') {
                        menuPrCaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Take Online') {
                        menuPrCaseSuccessful.add(cs.Opportunity__c);
                    }

                } else if (cs.Type == 'Shipment') {

                    if (!validOppWithShipment.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for shipment cases
                        continue;
                    }

                    if (!cs.isClosed || cs.Closed_Reason__c == 'Not Successful') {
                        shipmentCaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Successful') {
                        shipmentCaseSuccessful.add(cs.Opportunity__c)   ;
                    }

                } else if (cs.Type == 'Setup Backend') {

                    if (!validOppWithSetupBackend.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for setup BE cases
                        continue;
                    }

                    if (!cs.isClosed || cs.Closed_Reason__c == 'Not Successful') {
                        setupBECaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Successful') {
                        setupBECaseSuccessful.add(cs.Opportunity__c)   ;
                    }

                } else if (cs.Type == 'BE Data Entry') {

                    if (!validOppWithBEDataEntry.contains(cs.Opportunity__c)) {
                        // nothing to do, we shouldn't check for BE data entry cases
                        continue;
                    }

                    if (!cs.isClosed || cs.Closed_Reason__c == 'Not Successful') {
                        beDataEntryCaseOpenOrNotSuccessful.add(cs.Opportunity__c);
                    } else if (cs.Closed_Reason__c == 'Successful') {
                        beDataEntryCaseSuccessful.add(cs.Opportunity__c)   ;
                    }
                }
            }
        }

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checking related assets...');

        // checks open assets
        if (!validOppWithAsset.isEmpty()) {
            for (Asset__c a : [select id, Opportunity__c, status__c from asset__c where opportunity__c in : validOppWithAsset ]) {
                if (a.Status__c != 'Activated Successfully') {
                    assetNotActivated.add(a.Opportunity__c);
                }
            }
        }

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checking related branding...');

        // checks open branding
        if (!validOppWithBranding.isEmpty()) {
            for (Branding_Content__C b : [select id, Opportunity__c, status__c from branding_content__c where opportunity__c in : validOppWithBranding and type__c Like 'White Label%']) {
                if (b.status__c != 'Installed successfully') {
                    brandingNotActivated.add(b.Opportunity__c);
                }
            }
        }

        // clear some heap memory, we don't need these sets anymore
        validOppWithBEDataEntry.clear();
        validOppWithSetupBackend.clear();
        validOppWithShipment.clear();
        validOppIds.clear();
        validOppWithQC.clear();
        validOppWithMP.clear();
        validOppWithOnb.clear();

        // remove duplicate entries in case sets
        qcCaseOpenOrNotSuccessful.removeAll(qcCaseSuccessful);
        onBoardCaseOpenOrNotSuccessful.removeAll(onBoardCaseSuccessful);
        menuPrCaseOpenOrNotSuccessful.removeAll(menuPrCaseSuccessful);
        shipmentCaseOpenOrNotSuccessful.removeAll(shipmentCaseSuccessful);
        setupBECaseOpenOrNotSuccessful.removeAll(setupBECaseSuccessful);
        beDataEntryCaseOpenOrNotSuccessful.removeAll(beDataEntryCaseSuccessful);

        System.debug('TrgOpportunityProcessor.validateClosedOpp: checks if there are any invalid opps...');

        for (Opportunity opp : opportunities) {
            if (opp.Is_DataLoaded__c) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: this one is data loaded: ' + opp.Id);
                continue;
            }

            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));

            if (mapBusinessRule == null || mapBusinessRule.isEmpty()) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: no rules for this one: ' + opp.Id);
                continue;
            }

            // stage name is changed and is equals tp Stage Name business rule
            System.debug('TrgOpportunityProcessor.validateClosedOpp: starting checks when stage name changed');

            if (String.isNotBlank(opp.StageName) && oldMap != null && opp.StageName == mapBusinessRule.get('StageName').Business_Rule_Value__c && opp.StageName != oldMap.get(opp.id).stageName) {

                if (opp.type != null && mapBusinessRule.get('OpportunityType') != null && (mapBusinessRule.get('OpportunityType').Business_Rule_Value__c).contains(opp.type)) {
                    if (skipValidOppMap.containsKey(opp.id) && skipValidOppMap.get(opp.id) == false) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: quote validation error for: ' + opp.Id);
                        opp.addError(Label.Opportunity_Quote_Validation);
                        break;
                    }
                }

                if (!ClsRemoteController.chkAcceptQuote) {

                    if (qcCaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful qc case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_QC_Validation);
                        break;
                    }

                    if (menuPrCaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful mp case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_MP_Validation);
                        break;
                    }

                    if (onBoardCaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful ob case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_Onb_Validation);
                        break;
                    }

                    if (brandingNotActivated.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open branding for : ' + opp.Id);
                        opp.addError(Label.Opportunity_branding_Validation);
                        break;
                    }

                    if (assetNotActivated.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: asset not activated for: ' + opp.Id);
                        opp.addError(Label.Opportunity_Asset_Validation);
                        break;
                    }

                    if (shipmentCaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful shipment case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_Sh_Validation);
                        break;
                    }

                    if (setupBECaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful setup be case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_StBE_Validation);
                        break;
                    }

                    if (beDataEntryCaseOpenOrNotSuccessful.contains(opp.Id)) {
                        System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful be data entry case for : ' + opp.Id);
                        opp.addError(Label.Opportunity_DtEntry_Validation);
                        break;
                    }
                }
            }

            // stage name could not be changed or not equals to business rule
            System.debug('TrgOpportunityProcessor.validateClosedOpp: starting checks when stage name not changed');

            if (qcCaseOpenOrNotSuccessful.contains(opp.Id)
                    && opp.stageName == 'Editorial Queue'
                    && opp.type != 'Product Only') {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful qc case for : ' + opp.Id);
                opp.addError(Label.Opportunity_QC_Validation);
                break;
            }

            if (menuPrCaseOpenOrNotSuccessful.contains(opp.Id)
                    && opp.type != 'Product Only'
                    && opp.stageName == 'Onboarding'
                    && !ClsRemoteController.chkAcceptQuote) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: open or unsuccessful mp case for : ' + opp.Id);
                opp.addError(Label.Opportunity_MP_Validation);
                break;
            }

            if (!skipValidOppMap.containsKey(opp.id) && opp.StageName == mapBusinessRule.get('StageName').Business_Rule_Value__c ) {
                System.debug('TrgOpportunityProcessor.validateClosedOpp: not possible to skip validation for : ' + opp.Id);
                opp.addError(Label.Opportunity_without_Quote);
                break;
            }
        }
    }
    /* ******************** this is the old method, when eli finish testing remove it ********************************/

    //public static void validateClosedOpportunity(List<Opportunity> opportunities,Map<Id,Opportunity> oldMap){
    //    //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('validateClosedOpportunity');
    //    Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
    //    Set<String> oppTypes = new Set<String>();
    //    Map<Id,Boolean> skipValidOppMap = new Map<Id,Boolean>();
    //    //Loop for putting accepted and nonaccepted state value in Map for each opportuity
    //    for(Opportunity_Quote__c quote : [select id,status__c,Id_Opportunity__c from Opportunity_Quote__c where Id_Opportunity__c in : opportunities]){
    //        if(quote.status__c=='Accepted'){
    //            if(skipValidOppMap.get(quote.Id_Opportunity__c)==null){
    //            skipValidOppMap.put(quote.Id_Opportunity__c,true);
    //            }else{
    //                skipValidOppMap.remove(quote.Id_Opportunity__c);
    //                skipValidOppMap.put(quote.Id_Opportunity__c,true);
    //            }
    //        }else if(skipValidOppMap.get(quote.Id_Opportunity__c)==null){
    //            skipValidOppMap.put(quote.Id_Opportunity__c,false);
    //        }
    //    }

    //    Set<Id> validOppIds = new Set<Id>();
    //    Set<Id> validOppWithQC = new Set<Id>();
    //    Set<Id> validOppwithOnb = new Set<Id>();
    //    Set<Id> validOppwithAsset = new Set<Id>();
    //    Set<Id> validOppwithMP = new Set<Id>();
    //    Set<Id> validOppWithBranding = new Set<Id>();

    //    for(Opportunity opp : opportunities){
    //        if(!opp.Is_DataLoaded__c && opp.id!=null){
    //            if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
    //                //Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
    //                Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
    //                if(mapBusinessRule!=null && !mapBusinessRule.isEmpty()){
    //                    if(mapBusinessRule.get('AllowCheckForQCOpen')!=null && Boolean.valueOf(mapBusinessRule.get('AllowCheckForQCOpen').Business_Rule_Value__c)){
    //                        validOppIds.add(opp.Id);
    //                    }
    //                    if(mapBusinessRule.get('CheckForAtleastOnePositiveQC')!=null && Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveQC').Business_Rule_Value__c)){
    //                        validOppWithQC.add(opp.Id);
    //                    }
    //                    if(mapBusinessRule.get('CheckForAtleastOnePositiveOnboarding')!=null && Boolean.valueOf(mapBusinessRule.get('CheckForAtleastOnePositiveOnboarding').Business_Rule_Value__c)){
    //                        validOppWithOnb.add(opp.Id);
    //                    }
    //                    if(mapBusinessRule.get('checkForAsset')!=null && Boolean.valueOf(mapBusinessRule.get('checkForAsset').Business_Rule_Value__c)){
    //                        validOppWithAsset.add(opp.Id);
    //                    }
    //                    if(mapBusinessRule.get('checkForMP')!=null && Boolean.valueOf(mapBusinessRule.get('checkForMP').Business_Rule_Value__c)){
    //                        validOppWithMP.add(opp.Id);
    //                    }

    //                    if(mapBusinessRule.get('CheckForBranding')!=null && Boolean.valueOf(mapBusinessRule.get('CheckForBranding').Business_Rule_Value__c)){
    //                        validOppWithBranding.add(opp.Id);

    //                    }

    //                    if( mapBusinessRule.get('statusMap')!=null){
    //                        set<string> notAllowedStatus=new set <string>();
    //                        Map<String,String> theMap = (Map<String,String>)JSON.deserialize(mapBusinessRule.get('statusMap').Business_Rule_Value__c, Map<String, String>.class);
    //                        if(theMap.containskey(oldMap.get(opp.id).stageName)){
    //                            if(theMap.get(oldMap.get(opp.id).stageName).contains(';')){
    //                                notAllowedStatus = new set<String>(theMap.get(oldMap.get(opp.id).stageName).split(';'));
    //                            }
    //                            else
    //                                notAllowedStatus.add(theMap.get(oldMap.get(opp.id).stageName));
    //                            if(notAllowedStatus.contains(opp.stageName) && (opp.type!='Product Only' || oldMap.get(opp.id).stageName!='Menu received')){
    //                                opp.addError(Label.Opportunity_Stage_Update+' '+opp.stageName);
    //                                break;

    //                            }
    //                         }


    //                    }

    //                    if(!skipValidOppMap.containsKey(opp.id) || (skipValidOppMap!=null && skipValidOppMap.containsKey(opp.id) && skipValidOppMap.get(opp.id)!=null && !skipValidOppMap.get(opp.id) && ClsRemoteController.chkAcceptQuote!=null && !ClsRemoteController.chkAcceptQuote) ){
    //                        system.debug('&&if');
    //                        if(mapBusinessRule.get('notAllowedWithoutAcceptQuote')!=null ){
    //                         set<string> notAllowedStages = new set<String>(mapBusinessRule.get('notAllowedWithoutAcceptQuote').Business_Rule_Value__c.split(','));
    //                         if(notAllowedStages.contains(opp.stageName)){
    //                             opp.addError(Label.Opportunity_Stage_Update+' '+opp.stageName);
    //                                break;
    //                            }
    //                        }

    //                    }
    //                }
    //            }
    //        }
    //    }
    //    Set<Id> validAllOppIds = new Set<Id>();
    //    System.debug('validAllOppIds:ini '+validAllOppIds);
    //    system.debug('validOppIds: '+validOppIds+' validOppWithQC: '+validOppWithQC);
    //    if(!validOppIds.isEmpty()){
    //        validAllOppIds.addAll(validOppIds);
    //    }
    //    if(!validOppWithQC.isEmpty()){
    //        validAllOppIds.addAll(validOppWithQC);
    //    }

    //    if(!validOppWithMP.isEmpty()){
    //        validAllOppIds.addAll(validOppWithMP);
    //    }
    //    if(!validOppWithOnb.isEmpty()){
    //        validAllOppIds.addAll(validOppWithOnb);
    //    }




    //    System.debug('validAllOppIds: '+validAllOppIds);
    //    Map<Id,Boolean> mapQCaseOpen =  new Map<Id,Boolean>();
    //    Map<Id,Boolean> closedSuccessfully = new Map<Id,Boolean>();
    //    Map<Id,Boolean> closedNotSuccessfully = new Map<Id,Boolean>();
    //    Map<Id,Boolean> onbCasesNotSuccessful = new Map<Id,Boolean>();
    //    Map<Id,Boolean> onbCasesSuccessful = new Map<Id,Boolean>();
    //    Map<Id,Boolean> MPCasesNotSuccessful = new Map<Id,Boolean>();
    //    Map<Id,Boolean> MPCasesSuccessful = new Map<Id,Boolean>();
    //    Map<Id,Boolean> AssetActivated = new Map<Id,Boolean>();
    //    Map<ID,Boolean> AssetNotActivated = new Map<ID,Boolean>();
    //    Map<ID,Boolean> BrandingNotActivated = new Map<ID,Boolean>();
    //     Map<ID,Boolean> BrandingActivated = new Map<ID,Boolean>();


    //    if(validAllOppIds!=null && !validAllOppIds.isEmpty()){
    //        for(Case cs : [select id,Opportunity__c,isClosed,Closed_Reason__c,type from case where (type='Quality Check' or type='Menu Processing' or type='Onboarding') and Opportunity__c in :validAllOppIds]){
    //            if(cs.type=='Quality Check'){
    //                if(validOppIds.contains(cs.Opportunity__c)){
    //                    if(!cs.isClosed){
    //                        if( mapQCaseOpen.get(cs.Opportunity__c)==null){
    //                            mapQCaseOpen.put(cs.Opportunity__c,true);
    //                        }
    //                    }
    //                    if(cs.isClosed && cs.Closed_Reason__c=='Not Successful'){
    //                        if(closedNotSuccessfully.get(cs.Opportunity__c)==null){
    //                            closedNotSuccessfully.put(cs.Opportunity__c,true);
    //                        }
    //                    }
    //                    if(cs.isClosed && cs.Closed_Reason__c=='Successful'){
    //                        closedSuccessfully.put(cs.Opportunity__c,true);
    //                    }
    //                }

    //                if(validOppWithQC.contains(cs.Opportunity__c)!=null && cs.isClosed && cs.Closed_Reason__c=='Successful'){
    //                    validOppWithQC.remove(cs.Opportunity__c);
    //                }
    //            }
    //            else if(cs.type=='Onboarding'){
    //                if(validOppWithOnb.contains(cs.Opportunity__c)){
    //                    if(!cs.isClosed || (cs.isClosed && cs.Closed_Reason__c!='Successful')){
    //                        if(closedNotSuccessfully.get(cs.Opportunity__c)==null)
    //                            onbCasesNotSuccessful.put(cs.opportunity__c,true);
    //                    }
    //                    else if(cs.isClosed && cs.Closed_Reason__c=='Successful'){
    //                        onbCasesSuccessful.put(cs.opportunity__c,true);
    //                    }
    //                }
    //            }
    //            else if(cs.type=='Menu Processing'){
    //                if(validOppWithMP.contains(cs.Opportunity__c)){
    //                    if(!cs.isClosed || (cs.isClosed && cs.Closed_Reason__c!='Take Online')){
    //                        if(closedNotSuccessfully.get(cs.Opportunity__c)==null)
    //                            MPCasesNotSuccessful.put(cs.opportunity__c,true);
    //                    }
    //                    else if(cs.isClosed && cs.Closed_Reason__c=='Take Online'){
    //                        MPCasesSuccessful.put(cs.opportunity__c,true);
    //                    }
    //                }
    //            }


    //        }

    //    }
    //    if(validOppWithAsset!=null && !validOppWithAsset.isEmpty()){
    //     for(Asset__c a: [select id, Opportunity__c,status__c from asset__c where opportunity__c in : validOppWithAsset ]){
    //                if(a.status__c=='Activated Successfully'){
    //                    AssetActivated.put(a.Opportunity__c,true);
    //                }else
    //                    AssetNotActivated.put(a.opportunity__c,true);
    //            }

    //    }

    //    if(validOppWithBranding!=null && !validOppWithBranding.isEmpty()){
    //        for(Branding_Content__C b: [select id, Opportunity__c,status__c from branding_content__c where opportunity__c in : validOppWithBranding and type__c Like 'White Label%']){

    //               //if(status_c=='Activated Successfully'){
    //                if(b.status__c!='Installed successfully')
    //                    BrandingNotActivated.put(b.Opportunity__c,true);

    //        }


    //    }

    //    for(Id ids : closedSuccessfully.keySet()){
    //        if(closedNotSuccessfully.get(ids)!=null){
    //            closedNotSuccessfully.remove(ids);
    //        }
    //    }
    //    for(Id ids : onbCasesSuccessful.keySet()){
    //        if(onbCasesNotSuccessful.get(ids)!=null){
    //            onbCasesNotSuccessful.remove(ids);
    //        }
    //    }
    //    for(Id ids : MPCasesSuccessful.keySet()){
    //        if(MPCasesNotSuccessful.get(ids)!=null){
    //            MPCasesNotSuccessful.remove(ids);
    //        }
    //    }
    //    for(Id ids : closedNotSuccessfully.keySet()){
    //        mapQCaseOpen.put(ids,true);
    //    }

    //    system.debug(mapQCaseOpen);
    //    for(Opportunity opp : opportunities){
    //        if(!opp.Is_DataLoaded__c){
    //            if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
    //                //Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
    //                Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
    //                if(mapBusinessRule!=null && !mapBusinessRule.isEmpty()){
    //                    if(opp.StageName!=null && oldMap!=null && opp.StageName == mapBusinessRule.get('StageName').Business_Rule_Value__c && opp.StageName!=oldMap.get(opp.id).stageName){
    //                        if(opp.type!=null && mapBusinessRule.get('OpportunityType')!=null && (mapBusinessRule.get('OpportunityType').Business_Rule_Value__c).contains(opp.type)){
    //                            if(skipValidOppMap.get(opp.id)!=null && skipValidOppMap.get(opp.id)==false){
    //                                opportunities[0].addError(Label.Opportunity_Quote_Validation);
    //                                break;
    //                            }

    //                        }
    //                        if( ClsRemoteController.chkAcceptQuote!=null && !ClsRemoteController.chkAcceptQuote){
    //                            if(!mapQCaseOpen.isEmpty() && mapQCaseOpen.get(opp.id)!=null){
    //                                opportunities[0].addError(Label.Opportunity_QC_Validation);
    //                                break;
    //                            }
    //                            if(!validOppWithQC.isEmpty() && validOppWithQC.contains(opp.Id) ){
    //                                opportunities[0].addError(Label.Opportunity_QC_Validation);
    //                                break;
    //                            }

    //                            if(!MPCasesNotSuccessful.isEmpty() && MPCasesNotSuccessful.get(opp.Id) && opp.type!='Product Only' ){
    //                                opportunities[0].addError(Label.Opportunity_MP_Validation);
    //                                break;
    //                            }
    //                            if(!OnbCasesNotSuccessful.isEmpty() && OnbCasesNotSuccessful.get(opp.Id) && opp.type!='Product Only'){
    //                                opportunities[0].addError(Label.Opportunity_Onb_Validation);
    //                                break;
    //                            }
    //                            if(!BrandingNotActivated.isEmpty()  && BrandingNotActivated!=null &&  BrandingNotActivated.containsKey(opp.Id)!=null ){
    //                                 opportunities[0].addError(Label.Opportunity_branding_Validation);
    //                                break;

    //                            }

    //                           /* if(((AssetActivated.isEmpty() && mapBusinessRule.get('checkForAsset')!=null && Boolean.valueof(mapBusinessRule.get('checkForAsset').Business_Rule_value__C))  || (!AssetActivated.isEmpty() && !AssetActivated.containskey(opp.id) ) )&&  opp.type!='Product Only' && opp.type!='Contract Only'){
    //                                 opportunities[0].addError(Label.Opportunity_Asset_Validation);
    //                                break;


    //                            }*/
    //                              if(!AssetNotActivated.isEmpty() && AssetNotActivated.get(opp.id)!=null && AssetNotActivated.get(opp.id)==true  &&  AssetActivated.get(opp.id)==null){
    //                                   opportunities[0].addError(Label.Opportunity_Asset_Validation);
    //                                   break;
    //                              }

    //                          }

    //                    }
    //                    if(!mapQCaseOpen.isEmpty() && mapQCaseOpen.get(opp.id)!=null && opp.stageName=='Editorial Queue' && opp.type!='Product Only'){
    //                            opp.addError(Label.Opportunity_QC_Validation);
    //                            break;
    //                        }

    //                    if(!validOppWithQC.isEmpty() && validOppWithQC.contains(opp.Id) && opp.stageName!=oldMap.get(opp.id).stageName && opp.stageName=='Editorial Queue' && opp.type!='Product Only'){
    //                           opp.addError(Label.Opportunity_QC_Validation);
    //                            break;
    //                        }

    //                        if(!MPCasesNotSuccessful.isEmpty() && MPCasesNotSuccessful.get(opp.Id)!=null && MPCasesNotSuccessful.get(opp.Id) && opp.type!='Product Only' && opp.stageName=='Onboarding' && ClsRemoteController.chkAcceptQuote!=null && !ClsRemoteController.chkAcceptQuote){
    //                            opp.addError(Label.Opportunity_MP_Validation);
    //                            break;
    //                        }


    //                        if(!skipValidOppMap.containsKey(opp.id) && opp.StageName == mapBusinessRule.get('StageName').Business_Rule_Value__c ){
    //                                opp.addError(Label.Opportunity_without_Quote);
    //                                break;

    //                        }
    //                }
    //            }
    //        }
    //    }
    //}

    /**
    * SP-463 special AdSalesCase processing
    * @param
    *   opportunities: List of new Trigger values
    * @return void
    */
    public static void adSalesCaseProcessing(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> listCase  = new List<Case>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> oppTypes = new Set<String>();

        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('AdSalesCaseProcessing');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AdSalesCaseProcessing');
        System.debug('moam.keySet(): ' + moam.keySet());
        System.debug('mapBusinessLogic: ' + mapBusinessLogic);

        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                // loop for picking selected opportunity
                for (Opportunity opp : newOpps) {
                    System.debug('$$$ entering adSalesCaseProcessing loop');
                    if (opp.Is_DataLoaded__c == false) {
                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                            System.debug('opp.StageName: ' + opp.StageName);
                            System.debug(' oldMap:' + oldMap);
                            System.debug(' mapBusinessRules: ' + mapBusinessRules);

                            if (oldMap != null && !oldMap.isEmpty() && opp.StageName != oldMap.get(opp.Id).StageName && mapBusinessRules.get('StageName').Business_Rule_Value__c != null && opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c) {
                                if (mapBusinessRules.get('OpportunityType') != null && mapBusinessRules.get('OpportunityType').Business_Rule_Value__c != null) {
                                    oppTypes.add(mapBusinessRules.get('OpportunityType').Business_Rule_Value__c);

                                    if (oppTypes.contains(opp.type)) {
                                        System.debug('$$$ adding opp type to map');
                                        oppMap.put(opp.Id, opp);
                                    }
                                }
                            }
                        }
                    }
                }
                // loop for the creation of AdSalesEntry Case
                for (Opportunity opp : oppMap.values()) {
                    //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('AdSales Processing Case') != null && mapBusinessRules.get('AdSales Processing Case').Business_Rule_Value__c != null) {
                            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                            for (String fieldAndValue : (mapBusinessRules.get('AdSales Processing Case').Business_Rule_Value__c).split(',')) {

                                System.debug('$$$ creating case');

                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            listCase.add(cs);
                        }
                    }

                }
                insert listCase;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }


    /**
    * SP-496 AU - Trigger Asset when Opportunity Stage = Terminal Queue
    * @param
    *   opportunities: List of new Trigger values
    * @return void
    */
    public static void assetCreationProcess(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Opportunity> processOpps = new List<Opportunity>();
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('AssetCreationProcess');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('AssetCreationProcess');
        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Opportunity opp : newOpps) {
                    if (opp.Is_DataLoaded__c == false) {
                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                            if (opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c && opp.StageName != oldMap.get(opp.id).StageName && opp.Type == mapBusinessRules.get('Type').Business_Rule_Value__c) {
                                processOpps.add(opp);
                            }
                        }
                    }
                }
                createAssets(processOpps, mapBusinessLogic);
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }

    }


    /**
    * creates Assets
    * SP-496 Assets creation based on opp stage
    * @param
    *   oppList: List of Opportunities
    *    mapBusinessLogic:  Map of Business rules AssetCreationProcess
    * @return void
    */
    private static void createAssets(List<Opportunity> oppList, Map<String, Map<String, Business_Config__c>> mapBusinessLogic) {
        if (!oppList.isEmpty()) {
            List<Asset__c> listAssets = new List<Asset__c>();
            Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id, Opportunity_Quote_Line_Item__c>([select (select id from Assets__r), id, name, CurrencyIsoCode, Id_List_Product_Price__r.Requires_Asset__c, Id_List_Product_Price__r.Product_Type__c,
                    Id_Opportunity_Quote__r.Id_Account__c, Id_Opportunity__c, Id_Opportunity__r.OwnerId, Id_Opportunity__r.RecordType.DeveloperName, Quantity__c
                    from Opportunity_Quote_Line_Item__c where Id_Opportunity__c in: oppList and Line_Item_Type__c = 'Product' and Id_Opportunity_Quote__r.status__c = 'Accepted']);
            for (Opportunity_Quote_Line_Item__c qq1 : mapOppQuoteProd.values()) {
                //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(qq1.Id_Opportunity_Quote__r.Id_Opportunity__r.RecordTypeId).DeveloperName);
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(qq1.Id_Opportunity__r.RecordType.DeveloperName);
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {

                    if (qq1.Id_List_Product_Price__r.Requires_Asset__c) {
                        System.debug('qq1.Assets__r: ' + qq1.Assets__r);
                        //Check if Assets exist for the Opportunity
                        if (qq1.Assets__r == null || qq1.Assets__r.isEmpty()) {
                            if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                                Boolean createAsset = false;
                                //Itereate over number of quantity
                                for (integer i = 1; i <= qq1.Quantity__c; i++  ) {
                                    Asset__c newAsset = new Asset__c();
                                    newAsset.name = qq1.name;
                                    newAsset.OwnerId = qq1.Id_Opportunity__r.OwnerId;
                                    newAsset.Account__c = qq1.Id_Opportunity_Quote__r.Id_Account__c;
                                    newAsset.CurrencyIsoCode = qq1.CurrencyIsoCode;
                                    //newAsset.RecordTypeId = mapRecordTypes.get(mapBusinessRules.get('AssetRecordType').Business_Rule_Value__c).id;
                                    newAsset.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('AssetRecordType').Business_Rule_Value__c);
                                    newAsset.Id_Opportunity_Quote_Line_Item__c = qq1.Id;
                                    newAsset.Opportunity__c = qq1.Id_Opportunity__c;
                                    newAsset.Status__c = mapBusinessRules.get('AssetStatus').Business_Rule_Value__c;

                                    listAssets.add(newAsset);
                                }
                            }
                        }
                    }
                }
            }
            insert listAssets;
        }
    }



    public static void flatCommissionEntryCaseProcess(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Case> listCase  = new List<Case>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> oppTypes = new Set<String>();
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('FlatCommissionEntryCaseProcess');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('FlatCommissionEntryCaseProcess');
        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                // loop for picking selected opportunity
                for (Opportunity opp : newOpps) {

                    if (opp.Is_DataLoaded__c == false) {

                        //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                        Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                        if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                            if ( mapBusinessRules.get('StageName').Business_Rule_Value__c != null && ((mapBusinessRules.get('StageName').Record_Type_Id__c == 'Yogiyo_Opportunity' && oldMap != null && opp.StageName != oldMap.get(opp.Id).StageName) || mapBusinessRules.get('StageName').Record_Type_Id__c != 'Yogiyo_Opportunity') && opp.StageName == mapBusinessRules.get('StageName').Business_Rule_Value__c) {
                                //added the following lines for SP-399
                                if (mapBusinessRules.get('OpportunityType') != null && mapBusinessRules.get('OpportunityType').Business_Rule_Value__c != null) {
                                    if ((mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).indexOf(',') > -1) {
                                        for (String ctype : (mapBusinessRules.get('OpportunityType').Business_Rule_Value__c).split(',')) {
                                            if (!oppTypes.contains(ctype)) {
                                                oppTypes.add(ctype);
                                            }
                                        }
                                    } else {
                                        oppTypes.add(mapBusinessRules.get('OpportunityType').Business_Rule_Value__c);
                                    }

                                    if (oppTypes.contains(opp.type)) {
                                        oppMap.put(opp.Id, opp);
                                    }
                                }

                            }
                        }

                    }
                }

                Map<Id, Opportunity> validOppsMap = new Map<Id, Opportunity>();

                for (Opportunity opp : [select Id, Id_Tarif__r.Name, RecordTypeId from Opportunity where Id in :oppMap.keySet()]) {
                    //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(oppProd.Id_Opportunity__r.RecordTypeId).DeveloperName);
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('OpportunityTarif') != null) {
                            if (oppMap.get(opp.Id) != null && opp.Id_Tarif__r.Name == mapBusinessRules.get('OpportunityTarif').Business_Rule_Value__c) {
                                validOppsMap.put(opp.Id, oppMap.get(opp.Id));
                            }
                        } else {
                            oppMap.clear();
                        }
                    }
                }

                // loop for removing opportunity from the map if the closed reason of menu processing case is Not Successfull or open
                /*for(Case c : [select id,Opportunity__c,Opportunity__r.Recordtype.developerName,AccountId,Status,Closed_Reason__c,isClosed from Case where Type='0% Commission Entry' and Opportunity__c in : validOppsMap.keySet()]){
                    Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(c.Opportunity__r.Recordtype.developerName);
                    if(mapBusinessRules.get('ClosedReason')!=null && mapBusinessRules.get('ClosedReason').Business_Rule_Value__c!=null){
                        String closedReason = mapBusinessRules.get('ClosedReason').Business_Rule_Value__c;
                        if(c.isClosed && c.Closed_Reason__c!=closedReason){
                            validOppsMap.remove(c.Opportunity__c);
                        }else if(!c.isClosed){
                            validOppsMap.remove(c.Opportunity__c);
                        }
                    }

                }*/
                // loop for the creation of Entry case
                for (Opportunity opp : validOppsMap.values()) {
                    //Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(mapRecordTypesForIds.get(opp.RecordTypeId).DeveloperName);
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('EntryCase') != null && mapBusinessRules.get('EntryCase').Business_Rule_Value__c != null) {
                            Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                            for (String fieldAndValue : (mapBusinessRules.get('EntryCase').Business_Rule_Value__c).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            listCase.add(cs);
                        }
                    }

                }
                insert listCase;
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            newOpps[0].addError(e.getMessage());
        }
    }


    public static void checkOppStageOnCreation(List<opportunity> oppLst) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('validateClosedOpportunity');
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (opportunity opp : oppLst) {
                if (!opp.Is_DataLoaded__c && !ClsCaseProcessor.donotValidateOppStage) {
                    system.debug('@@opp' + opp.stageName);
                    set<string> stageNameSet = new Set<string>();
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (mapBusinessRules.get('stageNameNotAllowedOnCreation') != null) {
                            if (mapBusinessRules.get('stageNameNotAllowedOnCreation').Business_Rule_Value__c.contains(',')) {
                                stageNameSet = new Set<String>(mapBusinessRules.get('stageNameNotAllowedOnCreation').Business_Rule_Value__c.split(','));

                            } else
                                stageNameSet.add(mapBusinessRules.get('stageNameNotAllowedOnCreation').Business_Rule_Value__c);



                        }
                        system.debug('@@stageNameSet' + stageNameSet + stageNameSet.contains(opp.stageName));
                        if (stageNameSet.contains(opp.stageName)) {
                            opp.addError(Label.Opportunity_Initial_Stage + ' ' + opp.stageName);
                        }


                    }
                }

            }
        }

    }

    //Sales target
    /* 07-12-2016 Taj: Disabled as it's not part of the opp trigger
    public static void updateSalesTargetRecords(List<Opportunity> newOpps, Map<Id,Opportunity> oldMaps){
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('SalesTargetProcess');
        List<Opportunity> listOppps = new List<Opportunity>();
        Map<Id, Set<String>> mapStageNameSet = new Map<Id, Set<String>>();
        Map<Id,Sales_Target__c> updateSalesTrgtMap = new Map<Id,Sales_Target__c>();
        Map<String,List<Sales_Target__c>> mapTypeSalesTarget = new Map<String,List<Sales_Target__c>>();
        Set<Opportunity_Quote__c> updateOppQuote = new Set<Opportunity_Quote__c>();
        Map<Id,Opportunity_Quote__c> updateOppQuoteMap = new Map<Id,Opportunity_Quote__c>();
        Map<String,Id> oppIdWithProductId =  new Map<String,Id>();

        for(Sales_Target__c st : [Select Id,TotalCommissionForAvgCal__c,NoOfCommissionInPercent__c,RecordType.developerName,Name,Business_Type__c,Product_Group__c,Closed_Deals__c,Commission_Target__c,From__c,Product_Target__c,Revenue_Achieved__c,Sales_Rep__c,Target_Deals__c,Target_Product_Name__c,Target_Revenue__c,Target_Units__c,To__c,Type__c,Units_Achieved__c
        from Sales_Target__c where Sales_Rep__c=: UserInfo.getUserId()]){
            if(mapTypeSalesTarget.get(st.Type__c)==null){
                mapTypeSalesTarget.put(st.Type__c,new List<Sales_Target__c>{st});
            }else{
                List<Sales_Target__c> listSalesTrg = mapTypeSalesTarget.get(st.Type__c);
                listSalesTrg.add(st);
                mapTypeSalesTarget.put(st.Type__c,listSalesTrg);
            }
        }
        String stage;
        if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
            if(newOpps.size()==1){
                for(Opportunity_Quote_Line_Item__c oppQLines : [SELECT Id_Opportunity__c,Id_Opportunity_Quote__c,Id_Opportunity__r.StageName,Id_Opportunity__r.RecordTypeId,Id_Opportunity__r.Is_DataLoaded__c,Id_Opportunity__r.Business_Type__c,Id_Opportunity__r.Type, Category__c,Commission_Type__c,Id_List_Product_Price__c,Id_List_Product_Price__r.Id_List_Product_Group__c,Id_List_Service_Price__c,Line_Item_Type__c,Product_Group__c,Sub_type__c,Quantity__c,Total_Amount__c,Commission_In_Percentage__c FROM Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__r.Status__c='Accepted' and Id_Opportunity_Quote__r.SalesCloseDate__c=null and Id_Opportunity__c in : newOpps]){
                    if(!oppQLines.Id_Opportunity__r.Is_DataLoaded__c){
                        Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(oppQLines.Id_Opportunity__r.RecordTypeId));
                        set<string> stageNameSet = new Set<string>();
                        if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                            if(oppQLines.Id_Opportunity__r.Type=='Contract & Product' || oppQLines.Id_Opportunity__r.Type=='Additional Contract' || oppQLines.Id_Opportunity__r.Type=='Contract Only' ){
                                if(mapBusinessRules.get('Service_Stage')!=null){
                                    stage = mapBusinessRules.get('Service_Stage').Business_Rule_Value__c;
                                }
                            }else if(oppQLines.Id_Opportunity__r.Type=='Product Only' || oppQLines.Id_Opportunity__r.Type=='AdSales'){
                                if(mapBusinessRules.get('Product_Stage')!=null){
                                    stage = mapBusinessRules.get('Product_Stage').Business_Rule_Value__c;
                                }
                            }

                            if(stage == oppQLines.Id_Opportunity__r.stageName && oppQLines.Id_Opportunity__r.stageName!=oldMaps.get(oppQLines.Id_Opportunity__c).stageName && mapTypeSalesTarget.containsKey(oppQLines.Line_Item_Type__c)){
                                for(Sales_Target__c st : mapTypeSalesTarget.get(oppQLines.Line_Item_Type__c)){
                                    Date todays = Date.today();
                                    if(todays >= st.From__c &&  todays <= st.To__c){
                                        Boolean conditionMet = false;
                                        if(st.Type__c=='Product' && oppQLines.Id_List_Product_Price__c!=null){
                                            if(st.Product_Group__c!=null && st.Product_Group__c==oppQLines.Id_List_Product_Price__r.Id_List_Product_Group__c){
                                                conditionMet = true;
                                            }else if(st.Product_Group__c==null && st.Product_Target__c!=null  && oppQLines.Id_List_Product_Price__c==st.Product_Target__c){
                                                conditionMet = true;
                                            }else if(st.Product_Group__c==null && st.Product_Target__c==null ){
                                                conditionMet = true;
                                            }

                                            if(conditionMet){
                                                String keyElements = oppQLines.Id_Opportunity__c+''+st.Product_Target__c+''+st.Product_Group__c;
                                                if(oppQLines.Quantity__c!=null){
                                                    if(st.Units_Achieved__c==null)
                                                        st.Units_Achieved__c = oppQLines.Quantity__c;
                                                    else
                                                        st.Units_Achieved__c += oppQLines.Quantity__c;
                                                }
                                                if(oppQLines.Total_Amount__c!=null){
                                                    if(st.Revenue_Achieved__c==null)
                                                        st.Revenue_Achieved__c = oppQLines.Total_Amount__c;
                                                    else
                                                        st.Revenue_Achieved__c += oppQLines.Total_Amount__c;
                                                }


                                                if(oppIdWithProductId.get(keyElements)==null){
                                                    if(st.Closed_Deals__c==null){
                                                        st.Closed_Deals__c = 1;
                                                    }else{
                                                        st.Closed_Deals__c += 1;
                                                    }
                                                    oppIdWithProductId.put(keyElements,oppQLines.Id_Opportunity__c);
                                                }

                                                //updateSalesTrgt.add(st);
                                                updateSalesTrgtMap.put(st.Id,st);
                                                if(stage!='Closed Won ' && oppQLines.Id_Opportunity__r.Type!='Contract & Product'){
                                                    updateOppQuoteMap.put(oppQLines.Id_Opportunity_Quote__c,new Opportunity_Quote__c(Id=oppQLines.Id_Opportunity_Quote__c,SalesCloseDate__c=todays));
                                                }
                                            }
                                        }else if(st.Type__c=='Service'){
                                            if(st.Business_Type__c!=null && st.Business_Type__c==oppQLines.Id_Opportunity__r.Business_Type__c && st.Commission_Target__c==null){
                                                conditionMet = true;
                                            }else if(st.Business_Type__c!=null && st.Business_Type__c==oppQLines.Id_Opportunity__r.Business_Type__c && st.Commission_Target__c!=null && st.Commission_Target__c==oppQLines.Id_List_Service_Price__c){
                                                conditionMet = true;
                                            }else if(st.Business_Type__c==null && st.Commission_Target__c!=null && st.Commission_Target__c==oppQLines.Id_List_Service_Price__c){
                                                conditionMet = true;
                                            }else if(st.Business_Type__c==null && st.Commission_Target__c==null){
                                                conditionMet = true;
                                            }
                                            if(conditionMet){
                                                if(st.Closed_Deals__c==null){
                                                    st.Closed_Deals__c = 1;
                                                }else{
                                                    st.Closed_Deals__c += 1;
                                                }
                                                if(oppQLines.Commission_In_Percentage__c!=null && oppQLines.Commission_In_Percentage__c > 0){
                                                    if(st.NoOfCommissionInPercent__c!=null){
                                                        st.NoOfCommissionInPercent__c += 1;
                                                    }else{
                                                        st.NoOfCommissionInPercent__c = 1;
                                                    }
                                                    if(st.TotalCommissionForAvgCal__c!=null){
                                                        st.TotalCommissionForAvgCal__c += oppQLines.Commission_In_Percentage__c;
                                                    }else{
                                                        st.TotalCommissionForAvgCal__c = oppQLines.Commission_In_Percentage__c;
                                                    }
                                                }
                                                //updateSalesTrgt.add(st);
                                                updateSalesTrgtMap.put(st.Id,st);
                                                updateOppQuoteMap.put(oppQLines.Id_Opportunity_Quote__c,new Opportunity_Quote__c(Id=oppQLines.Id_Opportunity_Quote__c,SalesCloseDate__c=todays));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                update updateSalesTrgtMap.values();
                update updateOppQuoteMap.values();
                System.debug('updateSalesTrgt: '+updateSalesTrgtMap.size());
            }
        }
    }
    */
    /*public static void resetFields(List<Opportunity> newList){
        for(Opportunity opp : newList){
            opp.subTotal__c = null;
            opp.Total__c = null;
            opp.VAT__c = null;
        }
    }*/



    public static void restaurantCareCaseCreation(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestaurantCare');
        List<Case> listCase = new List<Case>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Opportunity opp : newList) {
                if (opp.Is_DataLoaded__c == false) {
                    Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                        if (opp.StageName == mapBusinessRules.get('stageName').Business_Rule_Value__c && opp.StageName != oldMap.get(opp.id).StageName) {
                            oppMap.put(opp.id, opp);
                        }
                    }
                }
            }
        }

        /*List<Opportunity_Quote_Line_Item__c> oqli = [select id,Id_List_Product_Price__c,id_opportunity__c,Id_Opportunity__r.RecordTypeId,Id_List_Product_Price__r.Requires_Asset__c from Opportunity_Quote_Line_Item__c where id_opportunity__c in :oppMAp.keyset()];
        Set<String> opplineWithAsset = new Set<String>();
        Set<String>opplineWithoutAsset =new Set<String>();
        for(Opportunity_Quote_Line_Item__c o:oqli ){

            Map<String,Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(o.Id_Opportunity__r.RecordTypeId));
            if(mapBusinessRules!=null && !mapBusinessRules.isEmpty()){
                if(mapBusinessRules.get('chkForProdType')!=null && Boolean.valueof(mapBusinessRules.get('chkForProdType').Business_Rule_Value__c) ){
                    if(o.Id_List_Product_Price__r.Requires_Asset__c)
                        opplineWithAsset.add(o.id_opportunity__c);
                    else
                        opplineWithoutAsset.add(o.id_opportunity__c);
                }
            }
         }
            for(string opp:opplineWithAsset){
                if(opplineWithoutAsset.contains(opp)){
                    opplineWithoutAsset.remove(opp);
                }
            }

            for(String o:opplineWithoutAsset){
                oppMap.remove(o);
            }*/





        // loop for removing opportunity from the map if the closed reason of onboarding case is Not Successfull or open
        for (Case c : [select id, Opportunity__c, Opportunity__r.Recordtype.developerName, AccountId, Status, Closed_Reason__c, isClosed from Case where Type = 'Onboarding' and Opportunity__c in : oppMap.keySet()]) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(c.Opportunity__r.Recordtype.developerName);
            if (mapBusinessRules.get('ClosedReason') != null && mapBusinessRules.get('ClosedReason').Business_Rule_Value__c != null) {
                Set<String> closedReason = new Set<String>();
                String closedStr = mapBusinessRules.get('ClosedReason').Business_Rule_Value__c;
                if (closedStr.indexOf(',') > -1) {
                    for (String r : closedStr.split(',')) {
                        closedReason.add(r);
                    }
                } else {
                    closedReason.add(closedStr);
                }
                if (c.isClosed && !closedReason.contains(c.Closed_Reason__c)) {
                    oppMap.remove(c.Opportunity__c);
                } else if (!c.isClosed) {
                    oppMap.remove(c.Opportunity__c);
                }
            }
        }
        for (Opportunity opp : oppMap.values()) {
            Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
            if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                if (mapBusinessRules.get('Case') != null) {
                    Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                    Account acc = [select Id, Delivery_ServicePicklist__c from account where id = :opp.AccountId];
                    if (acc.Delivery_ServicePicklist__c == 'Mixed') {
                        cs.Case_reason__c  = 'Mixed';
                    } else if (acc.Delivery_ServicePicklist__c == 'All Inclusive') {
                        cs.Case_reason__c  = 'All Inclusive';
                    }

                    for (String fieldAndValue : (mapBusinessRules.get('Case').Business_Rule_Value__c).split(',')) {
                        List<String> fields = fieldAndValue.split('=');
                        cs.put(fields[0], fields[1]);
                    }
                    listCase.add(cs);
                }
            }
        }
        insert listCase;
    }

    public static void createBackendID(List<opportunity> newLst, Map<Id, opportunity> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('SendToBackendProcess');
        Map<Id, Opportunity> accOppMap = new Map<Id, Opportunity>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {

            List<String> accIDLst = new List<String>();
            List<string> accIds = new List<String>();
            for (Opportunity opp : newLst) {
                set<string> opptype = new set<string>();
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && mapBusinessRules.get('BusinessType') != null ) {
                    if ( mapBusinessRules.get('BusinessType').Business_Rule_Value__c.contains(','))
                        opptype = new set<String>(((mapBusinessRules.get('BusinessType').Business_Rule_Value__c).split(',')));
                    else
                        opptype.add(mapBusinessRules.get('BusinessType').Business_Rule_Value__c);
                }
                /*if(opp.recordtypeid==LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity') && opp.stageName=='Editorial Queue' && opp.Business_Type__c=='New Business' && opp.stagename!= oldMap.get(opp.id).stageName){
                    accIDLst.add(opp.accountId);

                }*/
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && mapBusinessRules.get('stageName') != null && opp.stageName == mapBusinessRules.get('stageName').Business_Rule_Value__c
                        && mapBusinessRules.get('BusinessType') != null && opptype.contains(opp.Business_Type__c) && opp.stagename != oldMap.get(opp.id).stageName) {
                    accIDLst.add(opp.accountId);

                }
            }
            //String accIds;
            List<string> accLst = new List<string>();
            if (accIDLst != null && !accIDLst.isEmpty()) {
                List<Account> acc = [select id, restaurant_name__c, backend_id__c, BillingPostalCode, Record_Country__c from account where id IN:accIDLst and Backend_ID__c = null and type != 'Parent' and restaurant_name__c != null ];
                for (Account a : acc) {
                    accLst.add(JSON.serialize(a));
                    accIds.add(a.id);
                }
                if (accLst != null && !accLst.isEmpty()) {
                    createBackendCallout(accLst, accIds);
                }
            }
        }
    }

    @future(callout = true)
    private static void createBackendCallout(List<String> accLst, List<string> accIds) {
        List<Account>accsToUpd = new List<Account>();
        List<opportunity_Quote_Line_Item__c> oppQuoteLine = [select Start_Date__c, Id_Opportunity__r.accountid from opportunity_Quote_Line_Item__c where sub_type__c = 'Commission Fee' and Id_Opportunity_Quote__r.status__c = 'Accepted' and Id_Opportunity__r.accountid = :accIds];
        Map<string, String> accLeadMap = new Map<string, string>();
        Map<string, string> accOQliMap = new Map<string, string>();
        Map<string, string> accBackendIdMap = new Map<string, string>();
        //List<Lead> convLeadSrc = [Select  LeadSource,ConvertedAccountId From Lead Where IsConverted = True and ConvertedAccountId=: accIds];

        /*for(Lead l:convLeadSrc){
            accLeadMap.put(l.ConvertedAccountId,l.LeadSource);
        }*/
        for (opportunity_Quote_Line_Item__c oq : oppQuoteLine) {
            accOQliMap.put(oq.Id_Opportunity__r.accountid, String.Valueof(oq.start_date__c));
        }


        for (String a : accLst) {
            Account acc = (Account) JSON.deserialize(a, Account.class);
            Map<string, string> fieldValueMap = new Map<string, string>();
            fieldValueMap.put('name', acc.restaurant_name__c);
            fieldValueMap.put('salesforce_id', acc.id);
            fieldValueMap.put('date_joined', accOQliMap.get(acc.id));
            fieldValueMap.put('postcode', acc.BillingPostalCode);

            String jsonStr = LibJSONHelper.generateJSONMsg(fieldValueMap);
            List<string> calloutValues = LibWebserviceHelper.createBackendCalloutHeader(acc.record_country__c, 'create');

            System.debug(LoggingLevel.Error, 'm.zeuli - record country is: ' + acc.Record_Country__c);

            //String jsonStr= generateJSONMsg(acc.restaurant_name__c, acc.id,accOQliMap.get(acc.id)/*,accLeadMap.get(acc.id)*/, acc.BillingPostalCode);

            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(calloutValues[0]);
            req.setMethod('POST');
            req.setHeader('Authorization', calloutValues[1] );
            req.setBody(jsonStr);


            try {
                res = http.send(req);
                System.debug('Send account response :' + res.getBody());
                system.debug('##status code' + res.getStatusCode());
                if (res.getStatusCode() == 201) {

                    String  sBackendId = parseResponseForId(res.getBody());
                    acc.backend_id__c = sBackendId;
                    accsToUpd.add(acc);
                    accBackendIdMap.put(acc.id, sBackendId);

                }
            } catch (System.CalloutException e) {
                system.debug(e.getMessage());
            }
        }
        if (accsToUpd != null && !accsToUpd.isEmpty()) {
            Map<String, String> conFieldValueMap = new Map<string, string>();
            List<contact> conLstToUpd = new List<contact>();
            List<contact> conLst = [select id, accountid, Backend_sync__c, account.backend_id__c, account.record_country__c, Contact_Role__c, lastname, firstname, MobilePhone, salutation, email from contact where accountid = :accsToUpd and Contact_Role__c != null and Backend_sync__c = false and recordtype.developername = 'UK_Contact'];
            String jsonBdy = '[';
            for (Contact c : conLst) {

                jsonBdy += '{"restaurant_id":' + accBackendIdMap.get(c.accountid) + ',"surname":"' + c.lastname + '","email":"' + c.email + '","position":"' + c.Contact_Role__c + '"';
                if (c.MobilePhone != null) {
                    String mob = c.mobilePhone.removeStart('0044');
                    mob = '0' + mob;
                    if (mob.length() == 11)
                        jsonBdy += ',"mobile":"' + mob + '"';
                }
                if (c.firstname != null)
                    jsonBdy += ',"first_name":"' + c.firstname + '"';

                if (c.salutation != null)
                    jsonBdy += ',"title":"' + c.salutation + '"';


                jsonBdy += '},';
            }
            String body = jsonBdy.removeEnd(',') + ']';
            List<string>calloutValues = LibWebserviceHelper.createBackendCalloutHeader('United Kingdom', 'add-contacts');
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(calloutValues[0]);
            req.setMethod('POST');
            req.setHeader('Authorization', calloutValues[1]);
            req.setBody(body);

            try {
                integer i = 0;
                res = http.send(req);
                /* if(res.getStatusCode()==201) {
                     c.Backend_sync__c=true;
                     conLstToUpd.add(c);
                     System.debug('Send account response :'+res.getBody());
                     system.debug('##status code'+res.getStatusCode());
                  }   */
                if (res.getStatusCode() == 207 ) {
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                            while (parser.nextToken() != null) {
                                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                    ClsRoganAddContactResponseWrapper result = (ClsRoganAddContactResponseWrapper)parser.readValueAs(ClsRoganAddContactResponseWrapper.class);

                                    if (result.success) {
                                        conLst[i].Backend_sync__c = true;
                                        conLstToUpd.add(conLst[i]);
                                        i++;
                                    } else
                                        i++;
                                }
                            }
                        }
                    }
                }

            } catch (System.CalloutException e) {
                system.debug(e.getMessage());
            }



            try {

                update accsToUpd;
                if (conLstToUpd != null && !conLstToUpd.isEmpty()) {
                    update conLstToUpd;
                }
            } catch (Exception e) {
                system.debug(e.getMessage());

            }
        }

    }



    private static String parseResponseForId(String responseBody) {
        String sBackendId;
        JSONParser parser = JSON.createParser(responseBody);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'restaurant_id') {
                parser.nextToken();
                //System.debug('repsonse id: '+parser.getText());
                sBackendId = parser.getText();
                return sBackendId;
                //break;
            }
        } return null;

    }



    public static void closedLostPPandUpdateMidasAPI(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        if (newList.size() == 1 && newList[0].Company_Code__c == 'UK' && newList[0].StageName == 'Closed Lost' && oldMap.get(newList[0].id).stageName != newList[0].stageName && newList[0].Id_Tarif__c != null) {
            if (([SELECT Id, Id_Tarif__r.name FROM Opportunity where Id = :newList[0].id].Id_Tarif__r.name).equalsIgnoreCase('premium placement')) {
                Boolean interested = false;
                String reason = 'no_interest';
                String intrestedData = InterestedOppClosedLost__c.getValues('Interested').values__c;
                if (intrestedData == null) {
                    newList[0].addError('Custom setting InterestedOppClosedLost__c is not defined with values');
                    return;
                }
                Set<String> intrestedReasons = new Set<String>();
                if (intrestedData.indexOf(',') > 0) {
                    for (String str : intrestedData.split(',')) {
                        intrestedReasons.add(str);
                    }
                } else {
                    intrestedReasons.add(intrestedData);
                }
                if (intrestedReasons.contains(newList[0].Lost_Reason__c)) {
                    interested = true;
                    reason = 'opp_interest';
                }
                callMidasOPPLostAPI(newList[0].Id, newList[0].AccountId, interested, reason );
            }
        }
    }

    @future(callout = true)
    public static void callMidasOPPLostAPI(String oppId, String accId, Boolean interested, String reason) {
        Opportunity opp = [select id, MidasAPIException__c from Opportunity where id = :oppId];
        try {

            //String bodyparam = '{"interested":'+interested+'}';
            Id currentUserId = UserInfo.getUserId();
            User userData = [SELECT Id, Email, UserRole.Name FROM User where id = :currentUserId];
            String bodyparam = '{"meta": {"username": "' + userData.Email + '","sf_role": "' + userData.UserRole.Name + '","sf_opportunity_id": "' + oppId + '"},"data": {"reason":"' + reason + '","expressed_interest":' + interested + '}}';
            HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK', '/v2/sites/UKHH/restaurants/sf:' + accId + '/register_interest', 'POST', bodyparam);
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            System.debug('bodyparam: ' + bodyparam);
            if (req != null) {
                //req.setHeader('opportunity-info','{"opportunity_id":"'+oppId+'","account_id":"'+accId+'"}');
                //req.setHeader('user-info','{"user_email":"'+userData.Email+'", "user_role":"'+userData.UserRole.Name+'"}');
                res = http.send(req);
                System.debug('response :' + res.getBody());
                system.debug('##status code' + res.getStatusCode());
                if (res.getStatusCode() == 201) {
                    if (opp.MidasAPIException__c != null) {
                        opp.MidasAPIException__c = null;
                        update opp;
                    }
                } else {
                    opp.MidasAPIException__c = res.getStatusCode() + '-' + res.getBody();
                    update opp;
                }

            } else {
                opp.MidasAPIException__c = 'MidasIntegration__c is not configured';
                update opp;
            }

        } catch (System.CalloutException e) {
            system.debug('Error: ' + e.getMessage());
            String err = e.getMessage();
            if (err.length() > 250) {
                err = err.left(250);
            }
            opp.MidasAPIException__c = 'Er-' + err;
            update opp;
        }
    }

    public static void createBackendShippingCase(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BackendShippingCase');
        List<Case> listCase = new List<Case>();
        Set<String> caseTypes = new Set<String>();

        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            if (newList.size() == 1 && newList[0].Is_DataLoaded__c == false) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(newList[0].RecordTypeId));
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                    Set<String> stageNameSet = new Set<String>();
                    if (mapBusinessRules.get('StageName') != null && mapBusinessRules.get('StageName').Business_Rule_Value__c != null) {
                        if (mapBusinessRules.get('StageName').Business_Rule_Value__c.indexOf(',') > 1) {
                            stageNameSet.addAll(mapBusinessRules.get('StageName').Business_Rule_Value__c.split(','));
                        } else {
                            stageNameSet.add(mapBusinessRules.get('StageName').Business_Rule_Value__c);
                        }
                        if (stageNameSet.contains(newList[0].stageName) && oldMap.get(newList[0].id).stageName != newList[0].stageName) {
                            if (mapBusinessRules.get('CheckOpenCaseType') != null && mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c != null) {
                                if (mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c.indexOf(',') > 1) {
                                    caseTypes.addAll(mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c.split(','));
                                } else {
                                    caseTypes.add(mapBusinessRules.get('CheckOpenCaseType').Business_Rule_Value__c);
                                }
                            }
                            if (!caseTypes.isEmpty()) {
                                // loop for checking open cases which has types of CaseTypes and removes opportunity from the Map
                                for (Case cs : [select id, type, Closed_Reason__c, isClosed from Case where Opportunity__c = :newList[0].id and type in:caseTypes] ) {
                                    if ((cs.isClosed && (cs.Closed_Reason__c == 'Take Online' || cs.Closed_Reason__c == 'Successful')) || (!cs.isClosed)) {
                                        caseTypes.remove(cs.type);
                                    }
                                }
                            }
                            if (!caseTypes.isEmpty()) {
                                Map<String, Boolean> mapOfProductType = new Map<String, Boolean>();
                                mapOfProductType.put('ShippingProducts', false);
                                mapOfProductType.put('BackendProducts', false);

                                Set<String> shippingProd = new Set<String>();
                                Set<String> backendProd = new Set<String>();
                                Set<String> brandingProd = new Set<String>();
                                if (mapBusinessRules.get('ProductTypeForShipping') != null) {
                                    if (mapBusinessRules.get('ProductTypeForShipping').Business_Rule_Value__c.indexOf(',') > -1) {
                                        shippingProd.addAll(mapBusinessRules.get('ProductTypeForShipping').Business_Rule_Value__c.split(','));
                                    } else {
                                        shippingProd.add(mapBusinessRules.get('ProductTypeForShipping').Business_Rule_Value__c);
                                    }
                                }
                                if (mapBusinessRules.get('ProductTypeForBackend') != null) {
                                    if (mapBusinessRules.get('ProductTypeForBackend').Business_Rule_Value__c.indexOf(',') > -1) {
                                        backendProd.addAll(mapBusinessRules.get('ProductTypeForBackend').Business_Rule_Value__c.split(','));
                                    } else {
                                        backendProd.add(mapBusinessRules.get('ProductTypeForBackend').Business_Rule_Value__c);
                                    }
                                }
                                /*if(mapBusinessRules.get('ProductTypeForBranding')!=null){
                                    if(mapBusinessRules.get('ProductTypeForBranding').Business_Rule_Value__c.indexOf(',') >-1){
                                       brandingProd.addAll(mapBusinessRules.get('ProductTypeForBranding').Business_Rule_Value__c.split(','));
                                    }else{
                                       brandingProd.add(mapBusinessRules.get('ProductTypeForBranding').Business_Rule_Value__c);
                                    }
                                }*/
                                if (!shippingProd.isEmpty() || !backendProd.isEmpty() /*||!BrandingProd.isEmpty()*/) {

                                    for (Opportunity_Quote_Line_Item__c oppQline : [select id, sub_type__c from  Opportunity_Quote_Line_Item__c where Id_Opportunity_Quote__r.Id_Opportunity__c = :newList[0].Id AND Line_Item_Type__c = 'Product' AND sub_type__c != null]) {
                                        system.debug(oppQline.sub_type__c);
                                        system.debug(backendProd);
                                        if (shippingProd.contains(oppQline.sub_type__c)) {

                                            mapOfProductType.put('ShippingProducts', true);
                                        } else if (backendProd.contains(oppQline.sub_type__c)) {
                                            mapOfProductType.put('BackendProducts', true);
                                        }/*else if(!BrandingProd.isEmpty() && BrandingProd.contains(oppQline.sub_type__c)){
                                            mapOfProductType.put('BrandingProducts',true);
                                        }*/
                                    }
                                    if (mapOfProductType.get('ShippingProducts') && mapBusinessRules.get('ShippingCase') != null) {
                                        Case cs = new Case(Opportunity__c = newList[0].id, AccountId = newList[0].AccountId, CurrencyIsoCode = newList[0].CurrencyIsoCode);
                                        for (String fieldAndValue : (mapBusinessRules.get('ShippingCase').Business_Rule_Value__c).split(',')) {
                                            List<String> fields = fieldAndValue.split('=');
                                            cs.put(fields[0], fields[1]);
                                        }
                                        if (caseTypes.contains(cs.type)) {
                                            listCase.add(cs);
                                        }
                                    }
                                    if (mapOfProductType.get('BackendProducts') && mapBusinessRules.get('BackendCase') != null) {
                                        Case cs = new Case(Opportunity__c = newList[0].id, AccountId = newList[0].AccountId, CurrencyIsoCode = newList[0].CurrencyIsoCode);
                                        for (String fieldAndValue : (mapBusinessRules.get('BackendCase').Business_Rule_Value__c).split(',')) {
                                            List<String> fields = fieldAndValue.split('=');
                                            cs.put(fields[0], fields[1]);
                                        }
                                        if (caseTypes.contains(cs.type)) {
                                            listCase.add(cs);
                                        }
                                    }
                                    /*if(mapOfProductType.get('BrandingProducts') && mapBusinessRules.get('BrandingCase')!=null){
                                        Case cs = new Case(Opportunity__c=newList[0].id,AccountId=newList[0].AccountId,CurrencyIsoCode=newList[0].CurrencyIsoCode);
                                        for(String fieldAndValue : (mapBusinessRules.get('BrandingCase').Business_Rule_Value__c).split(',')){
                                            List<String> fields = fieldAndValue.split('=');
                                            cs.put(fields[0],fields[1]);
                                        }
                                        if(caseTypes.contains(cs.type)){
                                            listCase.add(cs);
                                        }
                                    }*/
                                    insert listCase;
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    public Static void createBrandingOnAcceptQuote(List<opportunity> newOppLst, Map<id, Opportunity> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('Opportunity Contract Process');
        Map<Id, Opportunity> accOppMap = new Map<Id, Opportunity>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Set<String> BrandingStatus = new Set<string>();
            List<string> oppIds = new List<String>();
            List<string> accIds = new List<String>();
            Set<ID> brandingTobeCreated = new Set<ID>();
            Map<id, string> oppQueueId = new Map<id, string>();
            for (Opportunity opp : newOppLst) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty() && opp.stageName != oldMap.get(opp.id).stagename && mapBusinessRules.get('createBrandingOnQuoteAccept') != null && mapBusinessRules.get('createBrandingOnQuoteAccept') != null && mapBusinessRules.get('stageNameBranding') != null &&  Boolean.valueOf(mapBusinessRules.get('createBrandingOnQuoteAccept').Business_Rule_Value__c) && opp.stageName == mapBusinessRules.get('stageNameBranding').Business_Rule_Value__c && oldMap.get(opp.id).stagename != mapBusinessRules.get('stageNameBranding').Business_Rule_Value__c ) {
                    oppIds.add(opp.id);
                    oppQueueId.put(opp.id, mapBusinessRules.get('DesignQueueId').Business_Rule_Value__c);


                }
            }

            if (oppIds != null && !oppIds.isEmpty()) {
                List<Branding_Content__C> newBrandingContentLst = new List<Branding_content__c>();
                List<Opportunity_Quote__c> oppQuoteIds = [SELECT Id FROM Opportunity_Quote__c WHERE Id_Opportunity__c IN:oppIds AND Status__c = 'Accepted'];
                for (Opportunity_quote_line_item__C oqli : [select (select id from Branding_Content__r)id, id_opportunity__c, id_opportunity__r.accountid, Id_List_Product_Price__c, id_opportunity__r.Company_Code__c, Id_List_Product_Price__r.Product_Type__c, Number_of_Copies__c, quantity__c from opportunity_quote_line_item__c where id_opportunity__c in :oppIds and Id_List_Product_Price__r.Requires_Branding__c = true and Id_Opportunity_Quote__c in :oppQuoteIds]) {

                    if (oqli.branding_content__r == null || oqli.branding_content__r.isEmpty()) {
                        Branding_Content__C branding = new Branding_Content__c();
                        branding.Opportunity__c = oqli.id_opportunity__c;
                        branding.Id_Opportunity_Quote_Line_Item__c = oqli.id;
                        branding.Quantity__c = oqli.quantity__c;
                        branding.Restaurant_Name__c = oqli.id_opportunity__r.accountid;
                        branding.type__c = oqli.Id_List_Product_Price__r.Product_Type__c;
                        branding.Number_of_Copies__c = oqli.Number_of_Copies__c;
                        branding.Product__c = oqli.Id_List_Product_Price__c;
                        branding.status__c = 'New';
                        branding.recordtypeid = LibRecordTypeHelper.getRecordTypeValue(oqli.id_opportunity__r.Company_Code__c + '_Branding_Content');
                        branding.ownerid = oppQueueId.get(oqli.id_opportunity__c);
                        //branding.Size__c=oqli.size__c;
                        // branding.weight__c=oqli.weight__c;

                        newBrandingContentLst.add(branding);
                    }
                }
                if (newBrandingContentLst != null && !newBrandingContentLst.isEmpty()) {
                    insert newBrandingContentLst;
                }
            }
        }
    }

}