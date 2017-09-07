public with sharing class ClsAccountProcessor {

    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;

    //Done changes for Menu processing closing action for opportunity
    //Done changes for SP-392 on 21.04.2015 by Magesh
    public static void menuProcessingClosingAction(List<Account> acctList, Map<Id, Account> oldAccMap) {
        Map<Id, List<Case>> closedMenuProcessingCase = new Map<Id, List<Case>>();
        Set<Opportunity> updateOppSet = new Set<Opportunity>();
        //Map of Account and list of related menuprocessing case
        for ( Case cc : [select IsClosed, AccountId, recordType.developerName, Opportunity__c, Opportunity__r.stageName, closed_reason__c from Case where type = 'Menu Processing' and  Opportunity__r.stageName != 'Closed Won' and AccountId in : acctList ]) {
            if (closedMenuProcessingCase.get(cc.AccountId) != null) {
                List<Case> listCases = closedMenuProcessingCase.get(cc.AccountId);
                listCases.add(cc);
                closedMenuProcessingCase.remove(cc.AccountId);
                closedMenuProcessingCase.put(cc.AccountId, listCases);
            } else {
                closedMenuProcessingCase.put(cc.AccountId, new List<Case> {cc});
            }
        }
        try {
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuProcessingClosingAction');
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingClosingAction');
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Account acc : acctList) {
                    if (closedMenuProcessingCase.containsKey(acc.Id)) {
                        System.debug('closedMenuProcessingCase: ' + closedMenuProcessingCase.get(acc.id)[0].RecordType.DeveloperName);
                        if ((closedMenuProcessingCase.get(acc.id)[0].RecordType.DeveloperName).contains('Talabat')) {
                            ClsCaseProcessor.talabatFlag = true;
                        }
                        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(closedMenuProcessingCase.get(acc.id)[0].RecordType.DeveloperName);
                        if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                            Boolean checkIsTested;
                            Set<String> positiveReason = new Set<String>();
                            String[] ClosedReason = (mapBusinessRule.get('Closed_Reason__c').Business_Rule_Value__c).split(';');
                            String pReasons = '';
                            if (ClosedReason[0].toLowerCase().indexOf('positive') > -1) {
                                pReasons = (ClosedReason[0].split('='))[1];
                            } else {
                                pReasons = (ClosedReason[1].split('='))[1];
                            }
                            if (pReasons != null && pReasons.indexOf(',') > -1) {
                                for (String r : pReasons.split(',')) {
                                    positiveReason.add(r);
                                }
                            } else if (pReasons != null) {
                                positiveReason.add(pReasons);
                            }


                            if (mapBusinessRule.get('Check for Is_Tested__c') != null) {
                                checkIsTested = Boolean.valueOf(mapBusinessRule.get('Check for Is_Tested__c').Business_Rule_Value__c);
                            }
                            Map<String, String> closedPosMap = new Map<String, String>();
                            if (mapBusinessRule.get('Closed_Positive') != null) {
                                for (String str : (mapBusinessRule.get('Closed_Positive').Business_Rule_Value__c).split(',')) {
                                    List<String> fields = str.split('=');
                                    closedPosMap.put(fields[0], fields[1]);
                                }
                            }
                            System.debug('closedPosMap: ' + closedPosMap);
                            String stageName;
                            if (mapBusinessRule.get('StageName') != null && mapBusinessRule.get('StageName').Business_Rule_Value__c != null) {
                                stageName = mapBusinessRule.get('StageName').Business_Rule_Value__c;
                            }
                            if (checkIsTested == null || (checkIsTested == acc.Is_Tested__c && oldAccMap.get(acc.id).Is_Tested__c != checkIsTested) ) {
                                for (Case cs : closedMenuProcessingCase.get(acc.id)) {
                                    System.debug('case in acc: ' + cs);
                                    if (stageName != null && cs.Opportunity__r.stageName == stageName) {
                                        Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedPosMap.get('StageName'), probability = Decimal.valueOf(closedPosMap.get('Probability')));
                                        if (cs.isClosed && cs.Opportunity__c != null && positiveReason.contains(cs.Closed_Reason__c) && !updateOppSet.contains(opp)) {
                                            updateOppSet.add(opp);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                List<Opportunity> updateOppList = new List<Opportunity>();
                updateOppList.addAll(updateOppSet);
                update updateOppList;
            }
        } catch (Exception e) {
            acctList[0].addError(e.getMessage());
            System.debug('Exception: ' + e.getMessage());
        }


    }

    public static void assignRecordCountryToBillingCountry(List<Account> newList, Map<Id, Account> oldMap) {
        for (Account acc : newList) {
            if (acc.Record_Country__c != null && (oldMap == null || (oldMap != null && oldMap.get(acc.id) != null && acc.Record_Country__c != oldMap.get(acc.id).Record_Country__c))) {
                acc.BillingCountry = acc.Record_Country__c;
                System.debug('acc.BillingCountry: ' + acc.BillingCountry);
            }
        }
    }

    /**
     * According to RestrictBillingAndMailingCityValues business config checks that
     * BillingCity field's value is contained in a set of specific values.
     * Possible values are retrieved using the utility class ClsBEIntegrationUtils
     * @param newAccounts new accounts or updated one
     * @param oldAccounts old account map or an empty map
     */
    public static void checksBillingAndMailingCityValues(List<Account> newAccounts, Map<Id, Account> oldAccounts) {
        System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: start');

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestrictBillingAndMailingCityValues');

        if (mapBusinessLogic == null) {
            System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: mapBusinessLogic null');
            return; // nothing to do
        }

        Map<Id, String> accountIdToCountryName = new Map<Id, String>();
        Map<Id, RecordType> recType;
        Map<String, String> countryNameToIsoCode;
        Set<Id> recTypeIds = new Set<Id>();
        Set<String> countryNames = new Set<String>();

        List<Account> accountsToCheck = new List<Account>();

        // gets rec type ids
        for (Account acc : newAccounts) {

            System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: check 1, account: ' + acc);

            // checks that BillingCity has changed
            if (oldAccounts != null && oldAccounts.containsKey(acc.Id)) {
                if (acc.BillingCity == oldAccounts.get(acc.Id).BillingCity) {
                    System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: not changed');
                    continue;
                }
            }

            // checks for blank values
            if (String.isBlank(acc.BillingCity) || String.isBlank(acc.Record_Country__c)) {
                System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: empty city.');
                continue;
            }

            accountsToCheck.add(acc);
            countryNames.add(acc.Record_Country__c);
            recTypeIds.add(acc.RecordTypeId);
        }

        if (accountsToCheck.isEmpty()) {
            System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: no accounts to check');
            return; // nothing to do
        }

        // gets developer name
        recType = new Map<Id, RecordType>([Select DeveloperName From RecordType Where Id in: recTypeIds]);
        recTypeIds.clear();

        // gets country codes
        countryNameToIsoCode = new Map<String, String>();
        for (Country__c c : [Select Name, Iso__c from Country__c Where Name in: countryNames]) {
            countryNameToIsoCode.put(c.name, c.Iso__c);
        }
        countryNames.clear();

        for (Account acc : accountsToCheck) {

            System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: check 2, account is: ' + acc);

            if (!mapBusinessLogic.containsKey(recType.get(acc.RecordTypeId).DeveloperName)) {
                System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: no process data');
                continue; // nothing to do for this one
            }

            Map<String, Business_Config__c> mapProcessData = mapBusinessLogic.get(
                        recType.get(acc.RecordTypeId).DeveloperName);

            if (!mapProcessData.containsKey('checkBillingAndMailingCity')
                    || !Boolean.valueOf(mapProcessData.get('checkBillingAndMailingCity').Business_Rule_Value__c)) {
                System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: no need to check for city');
                continue; // check disabled
            }

            // checks city value
            if (!ClsBEIntegrationUtils.isValidCity(acc.BillingCity, countryNameToIsoCode.get(acc.Record_Country__c))) {
                // build error message
                String errMsg = String.format(System.Label.AccountBillingCityNotValid, new List<String> {
                    acc.BillingCity,
                    String.valueOf(ClsBEIntegrationUtils.getCitiesByCountryCode(countryNameToIsoCode.get(acc.Record_Country__c)))
                });

                System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: city not valid, adding error message');
                
                acc.BillingCity.addError(errMsg);
            }
        }

        System.debug('ClsAccountProcessor.checksBillingAndMailingCityValues: done');
    }
}