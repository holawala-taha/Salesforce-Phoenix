public with sharing class ClsCaseProcessor {
//private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Asset__c'});
//private static Map<Id,RecordType> mapRecordTypesForIds = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Case','Opportunity'});
    private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public static Boolean talabatFlag = false;
    public static Boolean donotValidateOppStage = false;

//Boolean createTakeOfflineCase = doesChildExists(caseMap, c, mapBusinessRule.get('takeOfflineCaseType').Business_Rule_Value__c, null);

    public static Boolean doesChildExists(Map<Id, List<Case>> caseMap, Case cc, String typ, String closedReason) {
        Boolean childDoesNotExist = true;
        if (caseMap.containsKey(cc.Id)) {
            for (Case c : caseMap.get(cc.Id)) {
                if (c.Type.equals(typ) || (c.Closed_Reason__c != null && c.Closed_Reason__c.equals(closedReason))) {
                    childDoesNotExist = false;
                    break;
                }
            }
        }
        if (cc.ParentId != null && caseMap.containsKey(cc.ParentId)) {
            for (Case c : caseMap.get(cc.ParentId)) {
                if (c.Type.equals(typ) || (c.Closed_Reason__c != null && c.Closed_Reason__c.equals(closedReason))) {
                    childDoesNotExist = false;
                    break;
                }
            }
        }
        return childDoesNotExist;
    }



    public static Boolean doesOpenChildExists(Map<Id, List<Case>> caseMap, Case cc, String typ) {
        Boolean openChildExists = false;
        Set<String> caseTypes = new  Set<String>();
        if (typ.indexOf(',') > 1) {
            caseTypes.addAll(typ.split(','));
        } else {
            caseTypes.add(typ);
        }
        if (caseMap.containsKey(cc.Id)) {
            for (Case c : caseMap.get(cc.Id)) {

                if (caseTypes.contains(c.Type)) {
                    openChildExists = true;
                    break;
                }
            }
        }
        if (cc.ParentId != null && caseMap.containsKey(cc.ParentId)) {
            for (Case c : caseMap.get(cc.ParentId)) {
                if (caseTypes.contains(c.Type)) {
                    openChildExists = true;
                    break;
                }
            }
        }
        return openChildExists;
    }







    /*****************************************
    last update by AF on 17.04.2015
    JIRA: SP-394
    update: process did not check if parent case gets closed, so the process run at every update, causing duplicate cases
            changed signature to use Trigger.newMap and Trigger.oldMap to see if parent case got closed
            (if(mapOld.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ))
    ******************************************/
    public static void terminationCaseFlow(Map<Id, Case> mapNew, Map<Id, Case> mapOld) {
        Set<Id> parentIds = new Set<Id>();
        for (Case cl : mapNew.values()) {
            if (mapOld.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ) {
                parentIds.add(cl.Id);
                if (cl.ParentId != null) {
                    parentIds.add(cl.ParentId);
                }
            }
        }

        if (!parentIds.isEmpty()) {
            List<Case> listCasesToInsert = new List<Case>();
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('TerminationCaseFlow');
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('TerminationCaseFlow');
            Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();

            List<Case> cases = [SELECT Id, Type, ParentId, Closed_Reason__c FROM Case WHERE ParentId IN :parentIds];
            for (Case ca : cases) {
                if (caseMap.containsKey(ca.ParentId)) {
                    caseMap.get(ca.ParentId).add(ca);
                } else {
                    caseMap.put(ca.ParentId,  new List<Case> {ca});
                }
            }

            for (Case c : mapNew.values()) {
                //if(mapOld.get(c.Id).Status != c.Status){
                List<String> fieldsToCopy = new List<String>();

                if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                    if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                        if (mapBusinessRule.get('FieldsToCopy') != null && String.isNotBlank(mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c)) {
                            fieldsToCopy = mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c.split(',');
                        }

                        if (c.Type == mapBusinessRule.get('Type').Business_Rule_Value__c && c.IsClosed && c.Closed_Reason__c == mapBusinessRule.get('createRetentionCaseClosingReason').Business_Rule_Value__c) {
                            Boolean createRetentionCase = doesChildExists(caseMap, c, mapBusinessRule.get('RetentionCaseType').Business_Rule_Value__c, mapBusinessRule.get('createRetentionCaseClosingReason').Business_Rule_Value__c);
                            if (createRetentionCase) {
                                //Map<String,RecordType> mapRecordTypeName = LibRecordTypeHelper.getRecordTypeForNames(new Set<String>{mapBusinessRule.get('RetentionCaseRecordType').Business_Rule_Value__c} , 'Case');
                                Case retentionCase = new Case(
                                    Type = mapBusinessRule.get('RetentionCaseType').Business_Rule_Value__c,
                                    Status = mapBusinessRule.get('RetentionCaseStatus').Business_Rule_Value__c,
                                    Origin = mapBusinessRule.get('RetentionCaseOrigin').Business_Rule_Value__c,
                                    Subject = mapBusinessRule.get('RetentionCaseSubject').Business_Rule_Value__c,
                                    //RecordTypeId = mapRecordTypeName.get(mapBusinessRule.get('RetentionCaseRecordType').Business_Rule_Value__c).Id,
                                    RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('RetentionCaseRecordType').Business_Rule_Value__c),
                                    ParentId = c.Id
                                );
                                if (!fieldsToCopy.isEmpty()) {
                                    for (String str : fieldsToCopy) {
                                        retentionCase.put(str, c.get(str));
                                    }
                                }
                                listCasesToInsert.add(retentionCase);
                            }
                        } else if (c.Type == mapBusinessRule.get('Type').Business_Rule_Value__c && c.IsClosed && c.Closed_Reason__c == mapBusinessRule.get('createTakeOfflineCaseClosingReason').Business_Rule_Value__c) {
                            Boolean createTakeOfflineCase = doesChildExists(caseMap, c, mapBusinessRule.get('TakeOfflineCaseType').Business_Rule_Value__c, mapBusinessRule.get('createTakeOfflineCaseClosingReason').Business_Rule_Value__c);
                            if (createTakeOfflineCase) {
                                //Map<String,RecordType> mapRecordTypeName = LibRecordTypeHelper.getRecordTypeForNames(new Set<String>{mapBusinessRule.get('TakeOfflineCaseTypeRecordType').Business_Rule_Value__c} , 'Case');
                                Case takeOfflineCase = new Case(
                                    //RecordTypeId = mapRecordTypeName.get(mapBusinessRule.get('TakeOfflineCaseTypeRecordType').Business_Rule_Value__c).Id,
                                    RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('TakeOfflineCaseTypeRecordType').Business_Rule_Value__c),
                                    Status = mapBusinessRule.get('TakeOfflineCaseStatus').Business_Rule_Value__c,
                                    Origin = mapBusinessRule.get('TakeOfflineCaseTypeOrigin').Business_Rule_Value__c,
                                    Subject = mapBusinessRule.get('TakeOfflineCaseTypeSubject').Business_Rule_Value__c,
                                    Type = mapBusinessRule.get('TakeOfflineCaseType').Business_Rule_Value__c,
                                    Case_Reason__c = mapBusinessRule.get('TakeOfflineCaseReason').Business_Rule_Value__c,
                                    ParentId = c.Id
                                    //OwnerId = mapBusinessRule.get('TakeOfflineOwnerId').Business_Rule_Value__c,
                                );
                                if(mapBusinessRule.get('TakeOfflineOwnerId')!=null){
                                    takeOfflineCase.OwnerId = mapBusinessRule.get('TakeOfflineOwnerId').Business_Rule_Value__c;
                                }
                                if (!fieldsToCopy.isEmpty()) {
                                    for (String str : fieldsToCopy) {
                                        takeOfflineCase.put(str, c.get(str));
                                    }
                                }
                                listCasesToInsert.add(takeOfflineCase);
                            }
                        }


                        if (!listCasesToInsert.isEmpty()) {
                            insert listCasesToInsert;
                        }
                    }
                }
            }
        }

    }
    /*****************************************
    last update by AF on 17.04.2015
    JIRA: SP-394
    update: process did not check if parent case gets closed, so the process run at every update, causing duplicate cases
            changed signature to use Trigger.newMap and Trigger.oldMap to see if parent case got closed
            (if(mapOld.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ))
    ******************************************/
    public static void retentionCaseFlow(Map<Id, Case> mapNew, Map<Id, Case> mapOld) {
        Set<Id> parentIds = new Set<Id>();
        for (Case cl : mapNew.values()) {
            if (mapOld.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ) {
                parentIds.add(cl.Id);
                if (cl.ParentId != null) {
                    parentIds.add(cl.ParentId);
                }
            }
        }

        if (!parentIds.isEmpty()) {
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('RetentionCaseFlow');
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RetentionCaseFlow');
            List<Case> listCasesToInsert = new List<Case>();

            Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
            List<Case> cases = [SELECT Id, Type, ParentId, Closed_Reason__c FROM Case WHERE ParentId IN :parentIds];
            for (Case ca : cases) {
                if (caseMap.containsKey(ca.ParentId)) {
                    caseMap.get(ca.ParentId).add(ca);
                } else {
                    caseMap.put(ca.ParentId,  new List<Case> {ca});
                }
            }

            for (Case c : mapNew.values()) {
                List<String> fieldsToCopy = new List<String>();
                if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                    System.debug('tweededede');
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                    if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                        if (mapBusinessRule.get('FieldsToCopy') != null && String.isNotBlank(mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c)) {
                            fieldsToCopy = mapBusinessRule.get('FieldsToCopy').Business_Rule_Value__c.split(',');
                        }
                        //System.debug('Retention = ' + c.Type + 'Closed_Reason__c = ' + c.Closed_Reason__c + ' map = ' + mapBusinessRule.get('closingReasonUnsuccesful').Business_Rule_Value__c);
                        if (c.Type == 'Retention' && c.Closed_Reason__c == mapBusinessRule.get('closingReasonUnsuccesful').Business_Rule_Value__c) {
                            Boolean createTakeOfflineCase = doesChildExists(caseMap, c, mapBusinessRule.get('takeOfflineCaseType').Business_Rule_Value__c, null);
                            if (createTakeOfflineCase) {
                                //Map<String,RecordType> mapRecordTypeName = LibRecordTypeHelper.getRecordTypeForNames(new Set<String>{mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c} , 'Case');
                                //create take offline case
                                Case takeOfflineCase = new Case(
                                    //RecordTypeId = mapRecordTypeName.get(mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c).Id,
                                    RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c),
                                    Status = mapBusinessRule.get('takeOfflineCaseStatus').Business_Rule_Value__c,
                                    Origin = mapBusinessRule.get('takeOfflineCaseOrigin').Business_Rule_Value__c,
                                    Subject = mapBusinessRule.get('takeOfflineCaseSubject').Business_Rule_Value__c,
                                    Type = mapBusinessRule.get('takeOfflineCaseType').Business_Rule_Value__c,
                                    Case_Reason__c = mapBusinessRule.get('takeOfflineCaseReason').Business_Rule_Value__c,
                                    ParentId = c.ParentId
                                   
                                );
                                if(mapBusinessRule.get('takeOfflineOwnerId')!=null){
                                    takeOfflineCase.OwnerId = mapBusinessRule.get('takeOfflineOwnerId').Business_Rule_Value__c;
                                }
                                if (!fieldsToCopy.isEmpty()) {
                                    for (String str : fieldsToCopy) {
                                        takeOfflineCase.put(str, c.get(str));
                                    }
                                }
                                listCasesToInsert.add(takeOfflineCase);
                            }

                            /*Case parentCase = new Case(
                                                        Id = c.ParentId,
                                                        Status = 'Take Offline'
                                                        );

                            listCasesToUpdate.add(parentCase);*/
                        }

                        //added the positive case
                        if (c.Type == 'Retention' && c.Closed_Reason__c == mapBusinessRule.get('closingReasonSuccessful').Business_Rule_Value__c) {
                            System.debug('asdsad');
                            //Boolean createTakeOfflineCase = doesChildExists(caseMap, c, mapBusinessRule.get('takeOfflineCaseType').Business_Rule_Value__c, null);
                            //if(createTakeOfflineCase){
                            //Map<String,RecordType> mapRecordTypeName = LibRecordTypeHelper.getRecordTypeForNames(new Set<String>{mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c} , 'Case');
                            //create take offline case
                            if ( mapBusinessRule.get('takeOnlineCaseStatus') != null) {
                                Case takeOnlineCase = new Case(
                                    //RecordTypeId = mapRecordTypeName.get(mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c).Id,
                                    RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('takeOfflineCaseRecordType').Business_Rule_Value__c),
                                    Status = mapBusinessRule.get('takeOnlineCaseStatus').Business_Rule_Value__c,
                                    Origin = mapBusinessRule.get('takeOnlineCaseOrigin').Business_Rule_Value__c,
                                    Subject = mapBusinessRule.get('takeOnlineCaseSubject').Business_Rule_Value__c,
                                    Type = mapBusinessRule.get('takeOnlineCaseType').Business_Rule_Value__c,
                                    Case_Reason__c = mapBusinessRule.get('takeOnlineCaseType').Business_Rule_Value__c,

                                    ParentId = c.ParentId,
                                     OwnerId = mapBusinessRule.get('takeOfflineOwnerId').Business_Rule_Value__c
                                );
                                if (!fieldsToCopy.isEmpty()) {
                                    for (String str : fieldsToCopy) {
                                        takeOnlineCase.put(str, c.get(str));
                                    }
                                }
                                listCasesToInsert.add(takeOnlineCase);
                            }
                            //}

                            /*Case parentCase = new Case(
                                                        Id = c.ParentId,
                                                        Status = 'Take Offline'
                                                        );

                            listCasesToUpdate.add(parentCase);*/
                        }



                    }

                }

            }


            if (!listCasesToInsert.isEmpty()) {
                insert listCasesToInsert;
            }

        }
    }

    /*public static void takeOfflineCaseFlow(List<Case> caseList){
        List<Case> listCasesToUpdate = new List<Case>();

        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('TakeOfflineCaseFlow');

        for(Case c : caseList){
            Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(c.RecordTypeId).DeveloperName);
            if(mapBusinessRule != null && !mapBusinessRule.isEmpty()){
                if(c.Closed_Reason__c == mapBusinessRule.get('closeReasonSuccessful').Business_Rule_Value__c && mapBusinessRule.get('closeParentCaseOnSuccessful').Business_Rule_Value__c == 'true'){
                    Case parentCase = new Case(
                                                Id = c.ParentId,
                                                Closed_Reason__c = mapBusinessRule.get('closingReasonSuccessfulCloseParentCaseStatus').Business_Rule_Value__c,
                                                Status = 'Closed'
                                                );

                    listCasesToUpdate.add(parentCase);

                }
            }
        }

        if(!listCasesToUpdate.isEmpty()){
            update listCasesToUpdate;
        }
    }*/



    /**
    * creation of Menu change case based on opportunity stage name
    * @param
    *   caseList: List of new Trigger values
    * @return void
    */
    public static void nonContractedMenuChange(List<Case> caseList) {
        List<Case> listCase  = new List<Case>();
        Map<Id, String> mapCaseStatusOppIds = new Map<Id, String>();
        List<Id> accList = new List<Id>();
        Map<Id, Boolean> existingMenuChangeMap = new Map<Id, Boolean>();
        for (Case cs : caseList) {
            if (cs.type == 'Menu Processing') {
                mapCaseStatusOppIds.put(cs.Opportunity__c, cs.Status);
                accList.add(cs.AccountId);
            }
        }
        if (!mapCaseStatusOppIds.isEmpty()) {
            for (Case c : [select id, Opportunity__c, AccountId from Case where Type = 'Convert to Contract' and AccountId in : accList]) {
                existingMenuChangeMap.put(c.AccountId, true);
            }
            //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('NonContractedMenuChange');
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMenuChange');
            try {
                if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                    for (Opportunity opp : [select stageName, AccountId, RecordTypeId, CurrencyIsoCode, Non_Contracted__c from Opportunity where id in: mapCaseStatusOppIds.keySet()]) {
                        if (!existingMenuChangeMap.containsKey(opp.AccountId)) {
                            //System.debug('debug: 1: '+mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId)));
                            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                            if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                                String menuProcessingStatus = mapBusinessRule.get('Menu Processing Status').Business_Rule_Value__c;
                                if ( opp.Non_Contracted__c == Boolean.valueOf(mapBusinessRule.get('Non_Contracted__c').Business_Rule_Value__c) && mapCaseStatusOppIds.get(opp.id) == menuProcessingStatus && opp.stageName == mapBusinessRule.get('StageName').Business_Rule_Value__c) {
                                    /*if(mapBusinessRule.get('totalInternalTaskCount')!=null && mapBusinessRule.get('totalInternalTaskCount').Business_Rule_Value__c!=null){
                                        listCase.addAll(LibJSONHelper.parseJsonToCustomTasks(mapBusinessRule,opp));
                                    }*/
                                    if (mapBusinessRule.get('Menu Change Case').Business_Rule_Value__c != null) {
                                        Case cs = new Case(Opportunity__c = opp.id, AccountId = opp.AccountId, CurrencyIsoCode = opp.CurrencyIsoCode);
                                        for (String fieldAndValue : (mapBusinessRule.get('Menu Change Case').Business_Rule_Value__c).split(',')) {
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
                    insert listCase;
                }
            } catch (Exception e) {
                caseList[0].addError(e.getMessage());
            }

        }



    }

    /**
    * Actions performed when Menu processing case is closed
    * @param
    *   caseList: List of new Trigger values
    *    mapOldCase:  Map of old trigger values
    * @return void
    * Done changes for SP-392 on 21.04.2015 by Magesh
    */
    public static void menuProcessingClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuProcessingClosingAction');
        talabatFlag = false;
        //SP-706
        //Boolean sendNotification = false;
        List<Case> listClosedPositive = new List<Case>();
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingClosingAction');
        Map<Id, Case> AccountIsTested = new Map<Id, Case>();
        Boolean childCaseValidation = false;
        Boolean openChildExists = false;
        for (Case cc : [Select Account.Is_Tested__c, Opportunity__r.stageName from Case where type = 'Menu Processing' and id in: caseList]) {
            AccountIsTested.put(cc.id, cc);
        }

        Set<Id> parentIds = new Set<Id>();
        Set<ID> accIDs = new Set<ID>();
        for (Case cl : caseList) {
            accIDs.add(cl.accountid);
            if (mapOldCase.get(cl.Id).isClosed != cl.IsClosed && cl.isClosed == true ) {
                parentIds.add(cl.Id);
                if (cl.ParentId != null) {
                    parentIds.add(cl.ParentId);
                }
            }
        }

        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        List<Case> cases = [SELECT Id, Type, ParentId, isClosed, Closed_Reason__c FROM Case WHERE ParentId IN :parentIds and isClosed = false];

        for (Case ca : cases) {

            if (caseMap.containsKey(ca.ParentId)) {
                caseMap.get(ca.ParentId).add(ca);
            } else {
                caseMap.put(ca.ParentId,  new List<Case> {ca});
            }
        }
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Case> csList = new List<Case>();
        //Map<string, boolean> existingOnboardingMap = new Map<string, boolean>();

        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {

                //for (Case c : [select id, Opportunity__c, AccountId from Case where Type IN ('Onboarding', 'License/Doc Check') and accountid in : accIDs]) {
                //    existingOnboardingMap.put(c.AccountId , true);
                //}


                for (Case cs : caseList) {
                    if (cs.type == 'Menu Processing' && !AccountIsTested.isEmpty()) {
                        //Boolean isIgnoreMP=false;
                        Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));
                        if ((LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId)).contains('Talabat')) {
                            talabatFlag = true;
                        }
                        if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                            /*if(mapBusinessRule.get('NotificationAfterClosing')!=null && mapBusinessRule.get('NotificationAfterClosing').Business_Rule_Value__c!=null && mapBusinessRule.get('NotificationAfterClosing') != null){
                                sendNotification = Boolean.valueOf(mapBusinessRule.get('NotificationAfterClosing').Business_Rule_Value__c);
                            }*/
                            Set<String> skipStages = new Set<String>();
                            if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null && mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.indexOf(',') > 1) {
                                skipStages.addAll(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.split(','));
                            } else if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null) {
                                skipStages.add(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c);
                            }

                            if (mapBusinessRule.get('AllowChildCaseCloseValidation') != null && mapBusinessRule.get('AllowChildCaseCloseValidation').Business_Rule_Value__c != null) {
                                childCaseValidation = Boolean.valueOf(mapBusinessRule.get('AllowChildCaseCloseValidation').Business_Rule_Value__c);
                            }
                            /*if(mapBusinessRule.get('SkipArabicMPStgUpd')!=null && cs.Subject==mapBusinessRule.get('SkipArabicMPStgUpd').Business_Rule_Value__c ){
                                isIgnoreMP=true;
                            }*/
                            if (childCaseValidation) {
                                if (caseMap.get(cs.id) != null && caseMap.get(cs.id).size() > 0) {
                                    openChildExists = doesOpenChildExists(caseMap, cs, mapBusinessRule.get('ChildCaseTypes').Business_Rule_Value__c);
                                    if (openChildExists) {
                                        caseList[0].addError(Label.Close_Child_Case_Validation);
                                        return;
                                    }
                                }
                            }
                            if (!skipStages.contains(AccountIsTested.get(cs.id).Opportunity__r.stageName) /*&& !isIgnoreMP*/) {
                                Set<String> positiveReason = new Set<String>();
                                Set<String> negativeReason = new Set<String>();
                                String[] ClosedReason = (mapBusinessRule.get('Closed_Reason__c').Business_Rule_Value__c).split(';');
                                //gets positive and negative reasons from the business rules
                                String pReasons = '';
                                String nReasons = '';

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

                                if (ClosedReason[0].toLowerCase().indexOf('negative') > -1) {
                                    nReasons = (ClosedReason[0].split('='))[1];
                                } else {
                                    nReasons = (ClosedReason[1].split('='))[1];
                                }
                                if (nReasons != null && nReasons.indexOf(',') > -1) {
                                    for (String r : nReasons.split(',')) {
                                        negativeReason.add(r);
                                    }
                                } else if (nReasons != null) {
                                    negativeReason.add(nReasons);
                                }


                                Boolean checkIsTested;
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
                                Map<String, String> closedNegMap = new Map<String, String>();
                                if (mapBusinessRule.get('Closed_Negative') != null) {
                                    for (String str : (mapBusinessRule.get('Closed_Negative').Business_Rule_Value__c).split(',')) {
                                        List<String> fields = str.split('=');
                                        closedNegMap.put(fields[0], fields[1]);
                                    }
                                }
                                String stageName;
                                if (mapBusinessRule.get('StageName') != null && mapBusinessRule.get('StageName').Business_Rule_Value__c != null) {
                                    stageName = mapBusinessRule.get('StageName').Business_Rule_Value__c;
                                }
                                //Updates the opportunity with the stage and probability for positive and negative Menu Processing case reasons
                                //System.debug('$$$ cs.Opportunity__c ' + cs.Opportunity__c);
                                //System.debug('$$$ AccountIsTested.get(cs.id).Account.Is_Tested__c ' + AccountIsTested.get(cs.id).Account.Is_Tested__c);
                                //System.debug('$$$ cs.isClosed ' + cs.isClosed);
                                //System.debug('$$$ mapOldCase.get(cs.id).isClosed ' + mapOldCase.get(cs.id).isClosed);
                                //System.debug('$$$ positiveReason ' + positiveReason);
                                //System.debug('$$$ cs.Closed_Reason__c ' + cs.Closed_Reason__c);
                                //System.debug('$$$ AccountIsTested.get(cs.id).Opportunity__r.stageName ' + AccountIsTested.get(cs.id).Opportunity__r.stageName);
                                System.debug('$$$ stageName ' + stageName);


                                if (cs.Opportunity__c != null) {
                                    if ((checkIsTested == null || (checkIsTested == AccountIsTested.get(cs.id).Account.Is_Tested__c)) && cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && positiveReason.contains(cs.Closed_Reason__c) && AccountIsTested.get(cs.id).Opportunity__r.stageName == stageName) {
                                        Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedPosMap.get('StageName'), probability = Decimal.valueOf(closedPosMap.get('Probability')));
                                        updateOppList.add(opp);
                                        //if(mapBusinessRule.get('RestaurantCare')!=null && !existingOnboardingMap.containsKey(cs.accountid)){
                                        //    system.debug('**resCase');
                                        //    Case c = new Case(RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(mapBusinessRule.get('RestaurantCare').Business_Rule_Value__c), Type=mapBusinessRule.get('RestaurantCareType').Business_Rule_Value__c, Subject=mapBusinessRule.get('RestaurantCareSubject').Business_Rule_Value__c, Accountid=cs.accountid, Opportunity__c=cs.opportunity__c,Origin='Automatic',ownerid=mapBusinessRule.get('Owner').Business_Rule_Value__c);
                                        //    csList.add(c);
                                        //}
                                        System.debug('updateOppList: ' + updateOppList);
                                        //SP-706
                                        //listClosedPositive.add(cs);

                                    }
                                    if (cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && negativeReason.contains(cs.Closed_Reason__c) ) {
                                        Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedNegMap.get('StageName'), probability = Decimal.valueOf(closedNegMap.get('Probability')));
                                        updateOppList.add(opp);
                                    }
                                }
                            }
                        }
                    }
                }

                update updateOppList;
                if (csList != null && !csList.isEmpty()) {
                    insert csList;
                }
                //SP-706
                /*System.debug('$$$ listClosedPositive ' + listClosedPositive);
                System.debug('$$$ sendNotification ' + sendNotification);
                if(!listClosedPositive.isEmpty() && sendNotification){
                    notifyCustomerAndHOS(listClosedPositive);
                }*/
            }
        } catch (Exception e) {
            caseList[0].addError(e.getMessage());
            System.debug('Exception: ' + e.getMessage());
        }

    }

    /**
    * SP-373 Actions performed when quality check case is closed
    * @param
    *   caseList: List of new Trigger values
    *   mapOldCase:  Map of old trigger values
    * @return void
    */
    public static void qualityCheckClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('QualityCheckInternalCaseClosingAction');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckInternalCaseClosingAction');
        List<Opportunity> updateOppList = new List<Opportunity>();
        Map<Id, String> mapOppIdCaseRecordType = new Map<Id, String>();
        Map<Id, Case> csMap = new Map<Id, Case>();
        Set<Id> oppIds = new Set<Id>();
        for (Case cs : [select id, Opportunity__c, Opportunity__r.StageName, Opportunity__r.type, Opportunity__r.Business_Type__c, recordtype.developername from Case where type = 'Quality Check' and id in: caseList]) {
            csMap.put(cs.Id, cs);
            if (cs.Opportunity__r.type == 'Product Only' || cs.Opportunity__r.type == 'Additional Contract') {
                oppIds.add(cs.Opportunity__c);
            }
        }
        Map<Id, Boolean> mapIsAssetProducts = new Map<Id, Boolean>();
        Map<Id, Boolean> mapIsBrandingProd = new Map<Id, Boolean>();
        for (Opportunity_Quote_Line_Item__c oppline : [select id, Id_Opportunity__c, Id_Opportunity__r.type, Id_List_Product_Price__r.Requires_Asset__c, Id_List_Product_Price__r.Product_Type__c from Opportunity_Quote_Line_Item__c where Id_Opportunity__c in : oppIds and Id_Opportunity_Quote__r.Status__c = 'Accepted' ]) {
            if (oppline.Id_List_Product_Price__r.Requires_Asset__c == true && (oppline.Id_Opportunity__r.type == 'Product Only' || oppline.Id_Opportunity__r.type == 'Additional Contract'))
                mapIsAssetProducts.put(oppline.Id_Opportunity__c, true);
            if (oppline.Id_List_Product_Price__r.Product_Type__c != null && oppline.Id_List_Product_Price__r.Product_Type__c.containsignorecase('White Label'))
                mapIsBrandingProd.put(oppline.Id_Opportunity__c, true);
        }
        Map<Id, String> oppIdWithRStatus = new Map<Id, String>();

        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Case cs : caseList) {
                    String caseRecordtypeName = LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId);
                    system.debug('**caseRecordtypeName ' + caseRecordtypeName );
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(caseRecordtypeName);
                    system.debug(mapBusinessRule );
                    if (cs.type == 'Quality Check' && mapBusinessRule != null && !mapBusinessRule.isEmpty() && !csMap.isEmpty()) {
                        String[] closedPositive;
                        String[] closedNegative;
                        String positiveReason;
                        String negativeReason;
                        Set<String> skipMPForBtypes = new Set<String>();
                        set<String> skipMPForTypes = new Set<String>();
                        String[] ClosedReason = (mapBusinessRule.get('Closed_Reason__c').Business_Rule_Value__c).split(',');
                        Set<String> skipStages = new Set<String>();
                        if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null && mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.indexOf(',') > 1) {
                            skipStages.addAll(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.split(','));
                        } else if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null) {
                            skipStages.add(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c);
                        }
                        if (!skipStages.contains(csMap.get(cs.id).Opportunity__r.StageName)) {
                            //gets positive and negative reasons from the business rules
                            if (ClosedReason[0].toLowerCase().indexOf('positive') > -1) {
                                positiveReason = (ClosedReason[0].split('='))[1];
                                negativeReason = (ClosedReason[1].split('='))[1];
                            } else {
                                positiveReason = (ClosedReason[1].split('='))[1];
                                negativeReason = (ClosedReason[0].split('='))[1];
                            }

                            Map<String, String> closedPosMap = new Map<String, String>();
                            if (mapBusinessRule.get('Closed_Positive') != null) {
                                for (String str : (mapBusinessRule.get('Closed_Positive').Business_Rule_Value__c).split(',')) {
                                    List<String> fields = str.split('=');
                                    closedPosMap.put(fields[0], fields[1]);
                                }
                            }

                            Map<String, String> closedNegMap = new Map<String, String>();
                            if (mapBusinessRule.get('Closed_Negative') != null) {
                                for (String str : (mapBusinessRule.get('Closed_Negative').Business_Rule_Value__c).split(',')) {
                                    List<String> fields = str.split('=');
                                    closedNegMap.put(fields[0], fields[1]);
                                }

                            }
                            Set<String> oppTypesSet = new Set<String>();
                            if (mapBusinessRule.get('SkipClosedPositiveForType') != null && mapBusinessRule.get('SkipClosedPositiveForType').Business_Rule_Value__c != null) {
                                if (mapBusinessRule.get('SkipClosedPositiveForType').Business_Rule_Value__c.indexOf(',') > 1) {
                                    oppTypesSet.addAll(mapBusinessRule.get('SkipClosedPositiveForType').Business_Rule_Value__c.split(','));
                                } else {
                                    oppTypesSet.add(mapBusinessRule.get('SkipClosedPositiveForType').Business_Rule_Value__c);
                                }

                            }
                            if (mapBusinessRule.get('skipMPForType') != null && mapBusinessRule.get('skipMPForType').Business_Rule_Value__c != null) {
                                if (mapBusinessRule.get('skipMPForType').Business_Rule_Value__c.indexOf(',') > 1) {
                                    skipMPForTypes.addAll(mapBusinessRule.get('skipMPForType').Business_Rule_Value__c.split(','));
                                } else {
                                    skipMPForTypes.add(mapBusinessRule.get('skipMPForType').Business_Rule_Value__c);
                                }

                            }
                            if (mapBusinessRule.get('skipMPForBtype') != null && mapBusinessRule.get('skipMPForBtype').Business_Rule_Value__c != null) {
                                if (mapBusinessRule.get('skipMPForBtype').Business_Rule_Value__c.indexOf(',') > 1) {
                                    skipMPForBTypes.addAll(mapBusinessRule.get('skipMPForBtype').Business_Rule_Value__c.split(','));
                                } else {
                                    skipMPForBTypes.add(mapBusinessRule.get('skipMPForBtype').Business_Rule_Value__c);
                                }

                            }
                            //Updates the opportunity with the stage and probability for positive and negative Quality check case reasons
                            if (cs.Opportunity__c != null) {
                                system.debug('**QC close');
                                system.debug('mapIsBrandingProducts' + mapIsBrandingProd.get(cs.Opportunity__c));
                                system.debug('mapIsAssetProducts' + mapIsAssetProducts.get(cs.opportunity__C));

                                if (cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && positiveReason == cs.Closed_Reason__c && ((!oppTypesSet.isEmpty() && !oppTypesSet.contains(csMap.get(cs.id).Opportunity__r.type)) ||  oppTypesSet.isEmpty())) {
                                    Opportunity opp = new Opportunity(Id = cs.Opportunity__c);
                                    //system.debug('**skipMPForTypes'+skipMPForTypes);
                                    //system.debug('**skipMPForBTypes'+skipMPForBTypes);
                                    //system.debug(csMap.get(cs.id).Opportunity__r.type);
                                    //system.debug(csMap.get(cs.id).Opportunity__r.Business_Type__c);
                                    //system.debug(skipMPForTypes.contains(csMap.get(cs.id).Opportunity__r.type) );
                                    //system.debug(skipMPForTypes.contains(csMap.get(cs.id).Opportunity__r.business_type__c) );
                                    if (!skipMPForTypes.isempty() && !skipMPForBTypes.isEmpty() && skipMPForTypes.contains(csMap.get(cs.id).Opportunity__r.type)
                                            && skipMPForBTypes.contains(csMap.get(cs.id).Opportunity__r.Business_Type__c)) {
                                        if (mapBusinessRule.get('SkipMPStageName') != null) {
                                            Map<String, String> typeStageMap = (Map<String, String>)JSON.deserialize(mapBusinessRule.get('SkipMPStageName').Business_Rule_Value__c, Map<String, String>.class);
                                            Map<String, String> closedPosContractNoMP = new Map<String, String>();
                                            String stgNameProb = typeStageMap.get(csMap.get(cs.id).Opportunity__r.type);
                                            for (String str : (stgNameProb).split(',')) {
                                                List<String> fields = str.split('=');
                                                closedPosContractNoMP.put(fields[0], fields[1]);
                                            }
                                            donotValidateOppStage = true;
                                            opp.stageName = closedPosContractNoMP.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosContractNoMP.get('Probability'));
                                            mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);

                                        }

                                    }


                                    else if ((mapBusinessRule.get('ClosedPositive_ProductOnly') != null || mapBusinessRule.get('ClosedPositive_ProductOnlyAsset') != null || mapBusinessRule.get('ClosedPositive_ProductOnlyBranding') != null) && (csMap.get(cs.id).Opportunity__r.type == 'Product Only' /*|| csMap.get(cs.id).Opportunity__r.type=='Additional Contract'*/)) {
                                        if (mapBusinessRule.get('ClosedPositive_ProductOnlyAsset') != null && !mapIsAssetProducts.isempty() && mapIsAssetProducts.get(cs.Opportunity__c) != null && csMap.get(cs.id).Opportunity__r.type == 'Product Only') {
                                            Map<String, String> closedPosPOnlyAssetMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_ProductOnlyAsset') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_ProductOnlyAsset').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosPOnlyAssetMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosPOnlyAssetMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosPOnlyAssetMap.get('Probability'));
                                            mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);
                                        } else if (mapIsAssetProducts.isempty() && mapIsAssetProducts.get(cs.Opportunity__c) == null && mapBusinessRule.get('ClosedPositive_ProductOnlyBranding') != null && !mapIsBrandingProd.isEmpty() && mapIsBrandingProd.get(cs.Opportunity__c) != null /*&& csMap.get(cs.id).Opportunity__r.type=='Additional Contract'*/) {
                                            Map<String, String> closedPosPOnlyBrandingMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_ProductOnlyBranding') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_ProductOnlyBranding').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosPOnlyBrandingMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosPOnlyBrandingMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosPOnlyBrandingMap.get('Probability'));
                                            mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);

                                        } else if (!mapIsAssetProducts.isempty() && mapIsAssetProducts.get(cs.Opportunity__c) != null &&  mapIsBrandingProd.isEmpty() && mapIsBrandingProd.get(cs.Opportunity__c) == null && csMap.get(cs.id).Opportunity__r.type == 'Additional Contract') {
                                            Map<String, String> closedPosPOnlyBrandingMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_AddContract') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_AddContract').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosPOnlyBrandingMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosPOnlyBrandingMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosPOnlyBrandingMap.get('Probability'));
                                            mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);

                                        } else {
                                            Map<String, String> closedPosPOnlyMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_ProductOnly') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_ProductOnly').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosPOnlyMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosPOnlyMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosPOnlyMap.get('Probability'));
                                        }
                                    } else if ((mapBusinessRule.get('ClosedPositive_AddContract') != null ) && csMap.get(cs.id).Opportunity__r.type == 'Additional Contract') {
                                        if ((!mapIsBrandingProd.isEmpty() && mapIsBrandingProd.get(cs.Opportunity__c) != null ||  csMap.get(cs.id).recordtype.developername.contains('UK') )) {
                                            Map<String, String> closedPosPOnlyBrandingMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_AddContract') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_AddContract').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosPOnlyBrandingMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosPOnlyBrandingMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosPOnlyBrandingMap.get('Probability'));
                                            mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);

                                        } else if ((mapBusinessRule.get('ClosedPositive_AddContract') != null  && csMap.get(cs.id).Opportunity__r.type == 'Additional Contract') && mapIsBrandingProd.isEmpty() ) {
                                            Map<String, String> closedPosAddMap = new Map<String, String>();
                                            if (mapBusinessRule.get('ClosedPositive_ProductOnly') != null) {
                                                for (String str : (mapBusinessRule.get('ClosedPositive_ProductOnly').Business_Rule_Value__c).split(',')) {
                                                    List<String> fields = str.split('=');
                                                    closedPosAddMap.put(fields[0], fields[1]);
                                                }
                                            }
                                            opp.stageName = closedPosAddMap.get('StageName');
                                            opp.probability = Decimal.valueOf(closedPosAddMap.get('Probability'));
                                            // mapOppIdCaseRecordType.put(opp.id,caseRecordtypeName);
                                        }


                                    } else {
                                        opp.stageName = closedPosMap.get('StageName');
                                        opp.probability = Decimal.valueOf(closedPosMap.get('Probability'));
                                        mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);
                                    }
                                    updateOppList.add(opp);
                                    if (mapBusinessRule.get('PositiveRepStatus') != null) {
                                        oppIdWithRStatus.put(cs.Opportunity__c, mapBusinessRule.get('PositiveRepStatus').Business_Rule_Value__c);
                                    }
                                } else if (cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && negativeReason == cs.Closed_Reason__c ) {
                                    Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedNegMap.get('StageName'), probability = Decimal.valueOf(closedNegMap.get('Probability')));
                                    updateOppList.add(opp);
                                    if (mapBusinessRule.get('NegativeRepStatus') != null) {
                                        oppIdWithRStatus.put(cs.Opportunity__c, mapBusinessRule.get('NegativeRepStatus').Business_Rule_Value__c);
                                    }
                                }

                            }
                        }

                    }
                }
                System.debug('updateOppList' + updateOppList);
                update updateOppList;
                if (!oppIdWithRStatus.isEmpty()) {
                    ClsCaseProcessor.updateReplacementOrder(oppIdWithRStatus);
                }
                createAssets(mapOppIdCaseRecordType, mapBusinessLogic);
                createBranding(mapOppIdCaseRecordType, mapBusinessLogic);
            }

        } catch (Exception e) {
            caseList[0].addError(e.getMessage());
            System.debug('Exception: ' + e.getMessage());
        }


    }

    /**
    * creates Assets
    * SP-373 Assets creation based on quality checked positively
    * @param
    *   OppIDCaseRecordtypeMap: Map of Opp ID with Recordtype
    *    mapBusinessLogic:  Map of Business rules CreateAsset
    * @return void
    */
    private static void createAssets(Map<Id, String> OppIDCaseRecordtypeMap, Map<String, Map<String, Business_Config__c>> mapBusinessLogic) {
        if (!OppIDCaseRecordtypeMap.keySet().isEmpty()) {
            /*List<Opportunity_Quote__c> opquote = [SELECT Id, Name, Id_Account__c, Status__c, Id_Opportunity__c, RecordType.DeveloperName
                    FROM Opportunity_Quote__c
                    WHERE Id_Opportunity__c in : OppIDCaseRecordtypeMap.keySet()
                    AND Status__c='Accepted' limit 1];*/

            List<Asset__c> listAssets = new List<Asset__c>();
            Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id, Opportunity_Quote_Line_Item__c>([select (select id from Assets__r), id, name, CurrencyIsoCode, Id_List_Product_Price__r.Requires_Asset__c, Id_List_Product_Price__r.Product_Type__c,
                    Id_Opportunity_Quote__r.Id_Account__c, Id_Opportunity__c, Id_Opportunity__r.OwnerId, Id_Opportunity__r.RecordType.DeveloperName, Quantity__c
                    from Opportunity_Quote_Line_Item__c where Id_Opportunity__c in: OppIDCaseRecordtypeMap.keySet() and Line_Item_Type__c = 'Product' and Id_Opportunity_Quote__r.status__c = 'Accepted']);
            for (Opportunity_Quote_Line_Item__c qq1 : mapOppQuoteProd.values()) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(OppIDCaseRecordtypeMap.get(qq1.Id_Opportunity__c));
                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                    if (qq1.Id_List_Product_Price__r.Requires_Asset__c) {
                        System.debug('qq1.Assets__r: ' + qq1.Assets__r);
                        //Check if Assets exist for the Opportunity
                        if (qq1.Assets__r == null || qq1.Assets__r.isEmpty()) {
                            if (mapBusinessRules != null && !mapBusinessRules.isEmpty()) {
                                Boolean createAsset = false;
                                if (mapBusinessRules.get('CreateAsset') != null)
                                    createAsset = Boolean.valueOf(mapBusinessRules.get('CreateAsset').Business_Rule_Value__c);
                                
                                if (createAsset) {
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
            }

            insert listAssets;
        }
    }

    private static void createBranding(Map<Id, String> OppIDCaseRecordtypeMap, Map<String, Map<String, Business_Config__c>> mapBusinessLogic) {
        if (!OppIDCaseRecordtypeMap.keySet().isEmpty()) {

            List<Branding_Content__c> listBranding = new List<Branding_Content__c>();
            Map<Id, Opportunity_Quote_Line_Item__c> mapOppQuoteProd = new Map<Id, Opportunity_Quote_Line_Item__c>([select id, name, CurrencyIsoCode, (select id from Branding_Content__r), Id_List_Product_Price__r.Requires_Branding__c,
                    Id_Opportunity_Quote__r.Id_Account__c, Id_Opportunity__c, Id_Opportunity__r.OwnerId, Id_Opportunity__r.RecordType.DeveloperName, Quantity__c, Id_List_Product_Price__c, Id_List_Product_Price__r.Product_Type__c, Number_of_Copies__c, weight__c, size__c, Id_List_Product_Price__r.Product_Name__c, Deposit_Method__c
                    from Opportunity_Quote_Line_Item__c where Id_Opportunity__c in: OppIDCaseRecordtypeMap.keySet() and Line_Item_Type__c = 'Product' and Id_Opportunity_Quote__r.status__c = 'Accepted']);

            for (Opportunity_Quote_Line_Item__c oppQlineItem : mapOppQuoteProd.values()) {
                Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(OppIDCaseRecordtypeMap.get(oppQlineItem.Id_Opportunity__c));
                system.debug('**mapBusinessRules ' + mapBusinessRules );
                Boolean createBranding = false;

                if (mapBusinessRules != null && !mapBusinessRules.isEmpty()  ) {
                    if (mapBusinessRules.get('CreateBranding') != null)
                        createBranding = Boolean.valueOf(mapBusinessRules.get('CreateBranding').Business_Rule_Value__c);
                    if (CreateBranding) {
                        if (oppQlineItem.Id_List_Product_Price__r.Requires_Branding__c) {

                            if (oppQlineItem.branding_content__r == null || oppQlineItem.branding_content__r.isEmpty()) {
                                integer qty = 0;
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
                                    newBranding.OwnerId = oppQlineItem.Id_Opportunity__r.ownerId;
                                    newBranding.Restaurant_Name__c = oppQlineItem.Id_Opportunity_Quote__r.Id_Account__c;
                                    newBranding.CurrencyIsoCode = oppQlineItem.CurrencyIsoCode;
                                    newBranding.RecordTypeId = LibRecordTypeHelper.getRecordTypeValue(mapBusinessRules.get('BrandingContentRecordType').Business_Rule_Value__c);
                                    newBranding.Opportunity__c = oppQlineItem.Id_Opportunity__c;
                                    newBranding.type__c = oppQlineItem.Id_List_Product_Price__r.Product_Type__c;
                                    newBranding.Number_of_Copies__c = oppQlineItem.Number_of_Copies__c;
                                    newBranding.id_Opportunity_quote_line_item__c = oppQlineItem.id;
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
            system.debug('**listBranding' + listBranding);
            insert listBranding;
        }

    }

    /**
    * Actions performed when Non contracted menu processing case is closed
    * @param
    *   caseList: List of new Trigger values
    *   mapOldCase:  Map of old trigger values
    * @return void
    */
    public static void NonContractedMenuProcessingClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('NonContractedMPClosingAction');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('NonContractedMPClosingAction');
        List<Opportunity> updateOppList = new List<Opportunity>();
        Map<Id, String> mapOppIdCaseRecordType = new Map<Id, String>();
        Map<Id, Case> mapNonContractedOpportunity = new Map<Id, Case>();
        for (Case cs : [select id, Opportunity__r.Non_Contracted__c, Opportunity__r.stageName, Opportunity__c from Case where type = 'Menu Processing' and id in : caseList]) {
            if (mapNonContractedOpportunity.get(cs.id) == null) {
                mapNonContractedOpportunity.put(cs.id, cs);
            }
        }
        System.debug('mapNonContractedOpportunity: ' + mapNonContractedOpportunity);
        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Case cs : caseList) {
                    String caseRecordtypeName = LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId);
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(caseRecordtypeName);
                    if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                        if (!mapNonContractedOpportunity.isEmpty() && cs.type == 'Menu Processing' && mapNonContractedOpportunity.get(cs.id).Opportunity__r.Non_Contracted__c == Boolean.valueOf(mapBusinessRule.get('Non_Contracted__c').Business_Rule_Value__c) && mapNonContractedOpportunity.get(cs.id).Opportunity__r.stageName == mapBusinessRule.get('StageName').Business_Rule_Value__c) {
                            Set<String> positiveReason = new Set<String>();
                            Set<String> negativeReason = new Set<String>();
                            String pReasons = '';
                            String nReasons = '';
                            String[] ClosedReason = (mapBusinessRule.get('Closed_Reason__c').Business_Rule_Value__c).split(';');
                            Set<String> skipStages = new Set<String>();
                            if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null && mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.indexOf(',') > 1) {
                                skipStages.addAll(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c.split(','));
                            } else if (mapBusinessRule.get('SkipForStage').Business_Rule_Value__c != null) {
                                skipStages.add(mapBusinessRule.get('SkipForStage').Business_Rule_Value__c);
                            }
                            if (!skipStages.contains(mapNonContractedOpportunity.get(cs.id).Opportunity__r.StageName)) {
                                //gets positive and negative reasons from the business rules
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

                                if (ClosedReason[0].toLowerCase().indexOf('negative') > -1) {
                                    nReasons = (ClosedReason[0].split('='))[1];
                                } else {
                                    nReasons = (ClosedReason[1].split('='))[1];
                                }
                                if (nReasons != null && nReasons.indexOf(',') > -1) {
                                    for (String r : nReasons.split(',')) {
                                        negativeReason.add(r);
                                    }
                                } else if (nReasons != null) {
                                    negativeReason.add(nReasons);
                                }

                                Map<String, String> closedPosMap = new Map<String, String>();
                                if (mapBusinessRule.get('Closed_Positive') != null) {
                                    for (String str : (mapBusinessRule.get('Closed_Positive').Business_Rule_Value__c).split(',')) {
                                        List<String> fields = str.split('=');
                                        closedPosMap.put(fields[0], fields[1]);
                                    }

                                }

                                Map<String, String> closedNegMap = new Map<String, String>();
                                if (mapBusinessRule.get('Closed_Negative') != null) {
                                    for (String str : (mapBusinessRule.get('Closed_Negative').Business_Rule_Value__c).split(',')) {
                                        List<String> fields = str.split('=');
                                        closedNegMap.put(fields[0], fields[1]);
                                    }

                                }
                                //Updates the opportunity with the stage and probability for positive and negative Quality check case reasons
                                if (cs.Opportunity__c != null) {
                                    if (cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && positiveReason.contains(cs.Closed_Reason__c) ) {
                                        Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedPosMap.get('StageName'), probability = Decimal.valueOf(closedPosMap.get('Probability')));
                                        updateOppList.add(opp);
                                        mapOppIdCaseRecordType.put(opp.id, caseRecordtypeName);
                                    }
                                    if (cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && negativeReason.contains(cs.Closed_Reason__c) ) {
                                        Opportunity opp = new Opportunity(Id = cs.Opportunity__c, stageName = closedNegMap.get('StageName'), probability = Decimal.valueOf(closedNegMap.get('Probability')));
                                        if (opp.stageName == 'Closed Lost') {
                                            opp.Lost_Reason__c = mapBusinessRule.get('LostReasonIfOppClosedLost').Business_Rule_Value__c;
                                        }
                                        updateOppList.add(opp);
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('updateOppList' + updateOppList);
                update updateOppList;
            }

        } catch (Exception e) {
            caseList[0].addError(e.getMessage());
            System.debug('Exception: ' + e.getMessage());
        }
    }

    /*private static Map<String,List<Case>> sortCasesByRecordType(Map<Id,Case> mapCases){
        Map<String,List<Case>> mapResult = new Map<String,List<Case>>();

        for(Case theCase : mapCases.values()){
            System.debug('record type id : ' + theCase.RecordTypeId);
            String theRecordTypeName = mapRecordTypesForIds.get(theCase.RecordTypeId).DeveloperName;

            System.debug('record type name: ' + theRecordTypeName);

            if(!mapResult.containsKey(theRecordTypeName)){
                mapResult.put(theRecordTypeName, new List<Case>{theCase});
            }else{
                mapResult.get(theRecordTypeName).add(theCase);
            }
        }

        return mapResult;
    }*/

    //Work in progress

    public static void linkCasesToAccountBasedOnFieldValue(Map<Id, Case> mapCases) {
        System.debug('LINKAGE METHOD CALLED!');
        Set<String> setFieldValues = new Set<String>();
        Set<String> setCaseRecordTypes = new Set<String>();
        List<Case> listCases2Update = new List<Case>();
        Map<String, Business_Config__c> mapBusinessRule = new Map<String, Business_Config__c>();
        Map<String, Id> mapAccounts = new Map<String, Id>();
        Map<String, Id> mapContacts = new Map<String, Id>();

        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('EmailConfiguration');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('EmailConfiguration');

        //Map<String,List<Case>> mapSortedCasesByRecordTypeName = sortCasesByRecordType(mapCases);

        //for(String theRecordTypeName : mapSortedCasesByRecordTypeName.keySet()){

        String theRecordTypeName = LibRecordTypeHelper.getRecordTypeValue(mapCases.values()[0].RecordTypeId);

        System.debug('theRecordTypeName: ' + theRecordTypeName);
        mapBusinessRule = mapBusinessLogic.get(theRecordTypeName);

        if (mapBusinessRule != null) {
            /*String lookUpField = mapBusinessRule.get('lookUpField').Business_Rule_Value__c;
            String connectionField = mapBusinessRule.get('connectionField').Business_Rule_Value__c;
            String lookUpObject = mapBusinessRule.get('lookUpObject').Business_Rule_Value__c;*/
            String caseField = mapBusinessRule.get('caseField').Business_Rule_Value__c;
            String accountField = mapBusinessRule.get('accountField').Business_Rule_Value__c;
            String contactField = mapBusinessRule.get('contactField').Business_Rule_Value__c;
            String accountRecordTypeId = mapBusinessRule.get('accountRecordTypeId').Business_Rule_Value__c;
            String contactRecordTypeId = mapBusinessRule.get('contactRecordTypeId').Business_Rule_Value__c;

            List<Case> listCases = mapCases.values();
            Map<String, sObject> mapTypedObjects = new Map<String, sObject>();

            for (Case c : listCases) {
                String fieldValue = (String)c.get(caseField);
                if (fieldValue != null) {
                    fieldValue = fieldValue.trim();
                    if (!setFieldValues.contains(fieldvalue)) {
                        setFieldValues.add(fieldvalue);
                    }
                }
            }

            if (!setFieldValues.isEmpty()) {


                String queryAccounts = 'SELECT Id, ' + accountField + ' FROM Account WHERE ' + accountField + ' IN: setFieldValues AND RecordTypeId = \'' + accountRecordTypeId + '\'';
                String queryContacts = 'SELECT Name,Id,AccountId, ' + contactField + ' FROM Contact WHERE ' + contactField + ' IN: setFieldValues AND RecordTypeId = \'' + contactRecordTypeId + '\'';

                System.debug('contacts query: ' + queryContacts);

                List<Account> listAccounts = Database.query(queryAccounts);
                List<Contact> listContacts = Database.query(queryContacts);

                System.debug('list accounts size: ' + listAccounts.size());
                System.debug('list contacts size: ' + listContacts.size());

                if (!listAccounts.isEmpty()) {
                    for (Account a : listAccounts) {
                        mapAccounts.put((String)a.get(accountField), a.Id);
                    }
                }

                if (!listContacts.isEmpty()) {
                    for (Contact c : listContacts) {
                        System.debug('found contact: ' + c);
                        mapContacts.put((String)c.get(contactField), c.AccountId);
                    }
                }


                System.debug('mapAccounts ' + mapAccounts);
                System.debug('mapContacts ' + mapContacts);


                for (Case c : listCases) {
                    Id theAccountId = null;
                    System.debug('getting something out of mapAccounts ' + mapAccounts.get((String)c.get(caseField)));
                    System.debug('getting something out of mapContacts ' + mapContacts.get((String)c.get(caseField)));

                    if (mapAccounts.get((String)c.get(caseField)) != null) {
                        System.debug('found something in account map');
                        theAccountId = mapAccounts.get((String)c.get(caseField));
                    }

                    if (mapContacts.get((String)c.get(caseField)) != null && theAccountId == null) {
                        System.debug('found something in contact map');
                        System.debug('mapContacts: ' + mapContacts);
                        System.debug('found value in contact map : ' + c);
                        theAccountId = mapContacts.get((String)c.get(caseField));
                    }

                    c.AccountId = theAccountId;

                }
            }


            //String fieldValue = (String)c.get(lookUpField);
            /* System.debug('$$$ the case field: ' + caseField);
             String fieldValue = (String)c.get(caseField);
             System.debug('lookUpField : ' + lookUpField);
             System.debug('fieldValue : ' + fieldvalue);
             fieldValue = fieldValue.trim();


             if(!setFieldValues.contains(fieldvalue)){
                 setFieldValues.add(fieldvalue);
             }
             System.debug('setFieldValues : ' + setFieldValues);
             //String query = 'SELECT lookUpField FROM lookUpObject WHERE lookUpField IN: setFieldValues';
             String query = 'SELECT '+ lookUpField + ', ' + connectionField + ' FROM ' + lookUpObject + ' WHERE ' + lookUpField + ' IN: setFieldValues';
             System.debug('the query : ' + query);


             List<sObject> listObjects = Database.query(query);
             System.debug('listObjects: ' + listObjects);

             for(sObject generalObject : listObjects){

                 sObject typedObject = Schema.getGlobalDescribe().get(lookUpObject).newSobject();
                 typedObject = generalObject;


                 System.debug('typedObject: ' + typedObject);
                 mapTypedObjects.put((String)typedObject.get(lookUpField),typedObject);

                 System.debug('mapTypedObjects: ' + mapTypedObjects);
             }

             System.debug('trying to get some out of the map' + mapTypedObjects.get(fieldValue));

             if(mapTypedObjects.get(fieldValue) != null){
                 System.debug('connectionField: ' + connectionField);
                 String linkageField = 'AccountId';
                 c.put(linkageField, mapTypedObjects.get(fieldValue).get(connectionField));
             }

            }*/

        }
        //}
        update mapCases.values();
    }


    /**
    * SP-480
    * Actions performed when menu processing case status is changed to in progress
    * @param
    *   newCases: List of new Trigger values
    * @return void
    */
    public static void backendAccountCaseCreation(List<Case> newCases) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('BEAccountCaseProcess');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BEAccountCaseProcess');
        List<Case> listCase = new List<Case>();
        System.debug('mapBusinessLogic: ' + mapBusinessLogic);
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<Id, Boolean> existingBackendCase = new Map<Id, Boolean>();
            for ( Case cs : [select id, parentid from Case where parentid in : newCases and type = 'Create Backend Id']) {
                if (existingBackendCase.get(cs.parentId) == null) {
                    existingBackendCase.put(cs.parentid, true);
                }
            }
            Map<Id, Case> caseOppDetailsMap = new Map<Id, Case>([select id, Opportunity__r.Business_Type__c from Case where id in : newCases]);
            for (Case c : newCases) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty() && c.type == mapBusinessRule.get('Type').Business_Rule_Value__c && c.status == mapBusinessRule.get('Status').Business_Rule_Value__c) {
                    if ( (!existingBackendCase.isEmpty() && existingBackendCase.get(c.id) == null ) || existingBackendCase.isEmpty()) {
                        //Added as part of SP-492
                        Boolean allowCase = false;
                        if (mapBusinessRule.get('OpportunityBusinessType') != null && mapBusinessRule.get('OpportunityBusinessType').Business_Rule_Value__c == caseOppDetailsMap.get(c.id).opportunity__r.Business_Type__c) {
                            allowCase = true;
                        } else if (mapBusinessRule.get('OpportunityBusinessType') == null) {
                            allowCase = true;
                        }
                        if (mapBusinessRule.get('BEAccountCase').Business_Rule_Value__c != null && allowCase) {
                            Case cs = new Case(Opportunity__c = c.Opportunity__c, AccountId = c.AccountId, CurrencyIsoCode = c.CurrencyIsoCode, ParentId = c.id);
                            for (String fieldAndValue : (mapBusinessRule.get('BEAccountCase').Business_Rule_Value__c).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            if (c.Person_in_charge_BE__c != null) {
                                cs.Person_in_charge_BE__c = c.Person_in_charge_BE__c;
                            }
                            listCase.add(cs);
                        }
                    }
                }
            }
            insert listCase;
        }
    }

    /**
    * SP-480
    * Actions performed when Create Backend Id case is closed successfully
    * @param
    *   newCases: List of new Trigger values
    *   oldCaseMap:  Map of old trigger values
    * @return void
    */
    public static void menuTypingCaseCreation(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuTypingCaseProcess');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuTypingCaseProcess');
        List<Case> listCase = new List<Case>();
        List<Case> updateParentCase = new List<Case>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<Id, Id> parentCaseIdMap = new Map<Id, Id>();
            for (Case c : newCases) {
                if (c.Type == 'Create Backend Id' && c.parentId != null) {
                    parentCaseIdMap.put(c.Id, c.parentId);
                }
            }
            Map<Id, Case> parentCaseMap = new Map<Id, Case>([select id, Person_in_charge_Menu_Typing__c, Person_in_charge_BE__c, opportunity__r.Business_Type__c from Case where id in : parentCaseIdMap.values()]);

            Map<Id, Boolean> existingMenuTypingCase = new Map<Id, Boolean>();
            for ( Case cs : [select id, parentid from Case where parentid in : parentCaseIdMap.values() and type = 'Menu Typing']) {
                if (existingMenuTypingCase.get(cs.parentId) == null) {
                    existingMenuTypingCase.put(cs.parentid, true);
                }
            }
            for (Case c : newCases) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty() && c.type == mapBusinessRule.get('Type').Business_Rule_Value__c && c.IsClosed == Boolean.valueOf(mapBusinessRule.get('IsClosed').Business_Rule_Value__c) && oldCaseMap.get(c.id).IsClosed != c.IsClosed) {
                    if (c.Closed_Reason__c == mapBusinessRule.get('ClosedReason').Business_Rule_Value__c) {
                        if ( (!existingMenuTypingCase.isEmpty() && existingMenuTypingCase.get(parentCaseIdMap.get(c.id)) == null ) || existingMenuTypingCase.isEmpty()) {
                            //Added as part of SP-492
                            Boolean allowCase = false;
                            System.debug('');
                            System.debug('parentCaseMap.get(c.parentId).opportunity__r.Business_Type__c' + parentCaseMap.get(c.parentId).opportunity__r.Business_Type__c);
                            if (mapBusinessRule.get('OpportunityBusinessType') != null && mapBusinessRule.get('OpportunityBusinessType').Business_Rule_Value__c == parentCaseMap.get(c.parentId).opportunity__r.Business_Type__c) {
                                allowCase = true;
                            } else if (mapBusinessRule.get('OpportunityBusinessType') == null) {
                                allowCase = true;
                            }
                            if (mapBusinessRule.get('MenuTypingCase').Business_Rule_Value__c != null && allowCase) {
                                Case cs = new Case(Opportunity__c = c.Opportunity__c, AccountId = c.AccountId, CurrencyIsoCode = c.CurrencyIsoCode, ParentId = c.parentId);
                                for (String fieldAndValue : (mapBusinessRule.get('MenuTypingCase').Business_Rule_Value__c).split(',')) {
                                    List<String> fields = fieldAndValue.split('=');
                                    cs.put(fields[0], fields[1]);
                                }
                                if (parentCaseMap.get(cs.ParentId).Person_in_charge_Menu_Typing__c != null) {
                                    cs.Person_in_charge_Menu_Typing__c = parentCaseMap.get(cs.ParentId).Person_in_charge_Menu_Typing__c;
                                }
                                listCase.add(cs);
                            }
                        }
                    }
                    if (!parentCaseMap.isEmpty() && c.Person_in_charge_BE__c != null && c.Person_in_charge_BE__c != parentCaseMap.get(c.ParentId).Person_in_charge_BE__c) {
                        updateParentCase.add(new Case(id = c.ParentId, Person_in_charge_BE__c = c.Person_in_charge_BE__c));
                    }
                }
            }
            insert listCase;
            update updateParentCase;
        }
    }

    public static void menuTypingCaseClosingAction(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuProcessingStatusUpdateValidation');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingStatusUpdateValidation');
        Map<Case, Id> parentCaseIdMap = new Map<Case, Id>();
        Set<Case> parentCases = new Set<Case>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Case c : newCases) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty() && c.Type == mapBusinessRule.get('LastChildType').Business_Rule_Value__c && c.isClosed && oldCaseMap.get(c.Id).isClosed != c.isClosed && c.parentId != null) {
                    parentCaseIdMap.put(c, c.parentId);
                }
            }

            Map<Id, Case> parentCaseMap = new Map<Id, Case>([select id, Person_in_charge_Menu_Typing__c, Person_in_charge_BE__c from Case where id in : parentCaseIdMap.values()]);

            Map<Id, Set<Case>> caseMap = new Map<Id, Set<Case>>();
            for (Case ca : [SELECT Id, Type, ParentId, isClosed, Closed_Reason__c FROM Case WHERE ParentId IN :parentCaseIdMap.values() and isClosed = false]) {
                if (caseMap.containsKey(ca.ParentId)) {
                    caseMap.get(ca.ParentId).add(ca);
                } else {
                    caseMap.put(ca.ParentId,  new Set<Case> {ca});
                }
            }

            for (Case c : parentCaseIdMap.keySet()) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                    System.debug('case:  ' + caseMap.get(parentCaseIdMap.get(c)));
                    System.debug('caseMap: ' + caseMap);
                    Case ppCase;
                    if (caseMap.isEmpty()) {
                        if (c.Closed_Reason__c == mapBusinessRule.get('LastChildClosedReason').Business_Rule_Value__c) {
                            ppCase = new Case(id = c.ParentId, Status = mapBusinessRule.get('Status').Business_Rule_Value__c);
                        }
                    }
                    if (c.Person_in_charge_Menu_Typing__c != null && parentCaseMap.get(c.ParentId).Person_in_charge_Menu_Typing__c != c.Person_in_charge_Menu_Typing__c) {
                        if (ppCase != null) {
                            ppCase.Person_in_charge_Menu_Typing__c = c.Person_in_charge_Menu_Typing__c;
                        } else {
                            ppCase = new Case(id = c.ParentId, Person_in_charge_Menu_Typing__c = c.Person_in_charge_Menu_Typing__c);
                        }
                    }
                    if (ppCase != null) {
                        parentCases.add(ppCase);
                    }
                }
            }
            update new List<Case>(parentCases);
        }

    }

    //SP-706
    public static void updateAccountOnlineStatusByMenuProcessing(Map<Id, Case> newMap, Map<Id, Case> oldMap) {

        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingAccountUpdate');


        system.debug('##mapBusinessLogic ' + mapBusinessLogic );
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(newMap.values()[0].RecordTypeId));
            system.debug(LibRecordTypeHelper.getRecordTypeValue(newMap.values()[0].RecordTypeId));
            if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                Map<String, Integer> theMap = (Map<String, Integer>)JSON.deserialize(mapBusinessRule.get('orderMap').Business_Rule_Value__c, Map<String, Integer>.class);
                //========================================
                system.debug('&&ordermap' + mapBusinessRule.get('orderMap').Business_Rule_Value__c);

                //List<String> listStatusValues = mapBusinessRule.get('statusValues').Business_Rule_Value__c.split(',');
                Set<String> listCaseType = new set<string>(mapBusinessRule.get('Type').Business_Rule_Value__c.split(','));
                Set<String> setStatusValues = new Set<String>();
                if (mapBusinessRule.get('statusValues').Business_Rule_Value__c.contains(','))
                    setStatusValues = new Set<String>(mapBusinessRule.get('statusValues').Business_Rule_Value__c.split(','));
                else
                    setStatusValues.add(mapBusinessRule.get('statusValues').Business_Rule_Value__c);
                Set<Id> setAccountIds = new Set<Id>();

                for (Case c : newMap.values()) {
                    if (c.type != null && listCaseType.contains(c.type) && c.AccountID != null && !setAccountIds.contains(c.AccountId)) {
                        setAccountIds.add(c.AccountId);
                    }
                }

                if (setAccountIds != null && !setAccountIds.isEmpty()) {

                    Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Online_Status_Backend__c FROM Account WHERE Id IN: setAccountIds]);
                    String ParentAccStatus;
                    for (Case theCase : newMap.values()) {
                        if (setAccountIds.contains(theCase.AccountId)) {
                            Account parentAccount = mapAccounts.get(theCase.AccountId);
                            if (parentAccount != null && parentAccount.Online_Status_Backend__c != null ) {
                                if ( parentAccount.Online_Status_Backend__c.contains('MP')) {
                                    ParentAccStatus = parentAccount.Online_Status_Backend__c.split('- ')[1];

                                } else if (parentAccount.Online_Status_Backend__c == 'MP - Initiated') {
                                    ParentAccStatus = 'New';

                                } else
                                    ParentAccStatus = parentAccount.Online_Status_Backend__c;
                            }
                            if (listCaseType.contains(theCase.Type) && theCase.isClosed && mapBusinessRule.get(theCase.Type + ' closingStatus') != null && theCase.Closed_Reason__c == mapBusinessRule.get(theCase.Type + ' closingStatus').Business_Rule_Value__c && parentAccount.Online_Status_Backend__c != mapBusinessRule.get(theCase.Type + ' closingStatus').Business_Rule_Value__c && checkIfStatusIsProgressing(parentAccount.Online_Status_Backend__c, mapBusinessRule.get(theCase.Type + ' closingStatus').Business_Rule_Value__c, LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId), theMap)) {
                                parentAccount.Online_Status_Backend__c = mapBusinessRule.get(theCase.Type + ' closingStatus').Business_Rule_Value__c;

                                if (mapBusinessRule.get(theCase.Type + ' finalStatus') != null ) {
                                    system.debug('**final');
                                    parentAccount.Online_Status_Backend__c = mapBusinessRule.get(theCase.Type + ' finalStatus').Business_Rule_Value__c;
                                }

                            } else if (listCaseType.contains(theCase.Type) && theCase.AccountId != null && oldMap != null &&  theCase.Status != oldMap.get(theCase.Id).Status && mapBusinessRule.get(theCase.Type + ' closingStatus') != null && setStatusValues.contains(theCase.Status) && checkIfStatusIsProgressing(oldMap.get(theCase.Id).Status, theCase.Status, LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId), theMap)) { // see if new case status is one of the to-update statuses

                                if (parentAccount.Online_Status_Backend__c != theCase.Status && checkIfStatusIsProgressing(ParentAccStatus, theCase.Status, LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId), theMap)) {
                                    if (theCase.Status == 'New') {
                                        parentAccount.Online_Status_Backend__c = mapBusinessRule.get('newStatus').Business_Rule_Value__c;
                                    } else
                                        parentAccount.Online_Status_Backend__c = 'MP - ' + theCase.Status;

                                }
                            } else if (listCaseType.contains(theCase.Type) && theCase.AccountId != null && oldMap == null && mapBusinessRule.get(theCase.Type + ' closingStatus') != null &&  setStatusValues.contains(theCase.Status) && checkIfStatusIsProgressing(ParentAccStatus, theCase.Status, LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId), theMap)) {
                                if (theCase.Status == 'New') {
                                    parentAccount.Online_Status_Backend__c = mapBusinessRule.get('newStatus').Business_Rule_Value__c;
                                } else {
                                    parentAccount.Online_Status_Backend__c = 'MP - ' + theCase.Status;

                                }
                            } else if (listCaseType.contains(theCase.Type) && theCase.AccountId != null &&  mapBusinessRule.get(theCase.Type + ' closingStatus') == null && !thecase.isClosed && checkIfStatusIsProgressing(ParentAccStatus, theCase.type, LibRecordTypeHelper.getRecordTypeValue(theCase.RecordTypeId), theMap)) {

                                parentAccount.Online_Status_Backend__c = theCase.type;
                            }
                        }
                    }
                    if (!mapAccounts.isEmpty()) {
                        update mapAccounts.values();
                    }
                }
                //---------------------------------------------
            }



            //Map<String,Business_Config__c> mapBusinessRule = moam.get('MenuProcessingAccountUpdate').get('Talabat_Account');
        }
    }
    //helper method for 'updateAccountOnlineStatusByMenuProcessing' SP-706
    private static boolean checkIfStatusIsProgressing(String oldStatus, String newStatus, String rtDevelopername, Map<String, Integer> theMap) {
        Boolean result = false;

        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingAccountUpdate');

        //if(mapBusinessLogic != null && !mapBusinessLogic.isEmpty()){
        // Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(rtDevelopername/*mapRecordTypesForIds.get(c.RecordTypeId).DeveloperName*/);

        // if(mapBusinessRule != null && !mapBusinessRule.isEmpty()){


        system.debug('*themap' + theMap);
        system.debug(oldStatus);
        if (theMap.get(oldStatus) == null && theMap.get(newStatus) != null) {
            System.debug('entered branch 1');
            result = true;
        } else if (theMap.get(oldStatus) != null && theMap.get(newStatus) == null) {
            System.debug('entered branch 2');
            result = false;
        } else if (theMap.get(oldStatus) != null && theMap.get(newStatus) != null) {
            System.debug('entered branch 3');
            if ( theMap.get(oldStatus) != 6  && theMap.get(newStatus) == 0) {
                System.debug('entered branch 3.2');
                result = true;
            } else if (theMap.get(oldStatus) < theMap.get(newStatus)) {
                System.debug('entered branch 3.3');
                result = true;
            } else {
                System.debug('entered branch 3.4');
                result = false;
            }
        }
        //}
        //}

        return result;

    }



    public static void menuProcessingStatusUpdateValidation(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        //Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('MenuProcessingStatusUpdateValidation');
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('MenuProcessingStatusUpdateValidation');
        Boolean openChildExists;
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
            List<Case> cases = [SELECT Id, Type, ParentId, isClosed FROM Case WHERE ParentId IN :newCases and isClosed = false];
            for (Case ca : cases) {
                if (caseMap.containsKey(ca.ParentId)) {
                    caseMap.get(ca.ParentId).add(ca);
                } else {
                    caseMap.put(ca.ParentId,  new List<Case> {ca});
                }
            }
            for (Case c : newCases) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty() && c.type == mapBusinessRule.get('Type').Business_Rule_Value__c && c.status == mapBusinessRule.get('Status').Business_Rule_Value__c && oldCaseMap.get(c.id).status != c.status) {
                    if (caseMap.get(c.id) != null && caseMap.get(c.id).size() > 0) {
                        openChildExists = doesOpenChildExists(caseMap, c, mapBusinessRule.get('OpenChildCaseType').Business_Rule_Value__c);
                        if (openChildExists) {
                            newCases[0].addError(Label.menu_processing_status_update_validation);
                            return;
                        }
                    }
                }
            }

        }
    }



    /* public static void caseCloseStatusUpdateValidation(List<Case> newCases){
         Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('CaseClosureMenuChange');
             if(mapBusinessLogic!=null){
                 for(case c: newCases){
                     Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(mapRecordTypesForIds.get(c.RecordTypeId).DeveloperName);
                     if( mapBusinessRule!=null && !mapBusinessRule.isEmpty()  && c.type==mapBusinessRule.get('caseType').Business_Rule_Value__c && c.status==mapBusinessRule.get('InitialStatus').Business_Rule_Value__c   && c.Final_Check_Date__c==null){
                         c.status=mapBusinessRule.get('StatusValueToUpdate').Business_Rule_Value__c;

                     }
                 }
             }

     }*/



    public static void preventParentCaseClose(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('ParentCaseClosure');
        Boolean openChildExists;
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
            List<Case> cases = [SELECT Id, Type, ParentId, isClosed FROM Case WHERE ParentId IN :newCases and isClosed = false];
            for (Case ca : cases) {
                if (caseMap.containsKey(ca.ParentId)) {
                    caseMap.get(ca.ParentId).add(ca);
                } else {
                    caseMap.put(ca.ParentId,  new List<Case> {ca});
                    system.debug('**casemap' + caseMap);
                }
            }
            for (Case c : newCases) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
                if (mapBusinessRule != null && !mapBusinessRule.isEmpty() && oldCaseMap.get(c.id).status != c.status  && c.status == mapBusinessRule.get('Status').Business_Rule_Value__c ) {
                    if (caseMap.get(c.id) != null && caseMap.get(c.id).size() > 0) {
                        c.addError(Label.Prevent_Parent_Case_Closure);
                        system.debug('erro');
                        return;
                    }
                }
            }

        }
    }

    /**
     * Handle closing action on Onboarding case. Push Opportunity to next stage if
     * closed successfully or back
     * @param newList [description]
     * @param oldMap  [description]
     */
    public static void onboardingCaseClosingAction(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('RestaurantCareClosingAction');

        List<Case> validCasesWithOpp = new List<Case>();
        List<Opportunity> toUpdate = new List<Opportunity>();

        Set<Id> brandingOppsToCheck = new Set<Id>();
        Set<Id> assetOppsToCheck = new Set<Id>();
        Set<Id> oppWithInactiveAsset = new Set<Id>();
        Set<Id> oppWithUninstalledBranding = new Set<Id>();

        Set<Id> hasToCheckAssets = new Set<Id>();
        Set<Id> hasToCheckBrandings = new Set<Id>();

        if (mapBusinessLogic == null) {
            return;
        }

        // filter valid cases
        for (Case c : newList) {
            Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));

            if (rules == null) {
                continue;
            }

            if (oldMap.get(c.Id).Status != c.Status
                    && c.isClosed
                    && c.Type == rules.get('Type').Business_Rule_Value__c
                    && String.isNotBlank(c.Opportunity__c)) {

                // this is an onboarding case
                validCasesWithOpp.add(c);

                // should check assets status before changing stage name
                if (rules.containsKey('chkAssetStatus')
                        && Boolean.valueOf(rules.get('chkAssetStatus').Business_Rule_Value__c)) {
                    assetOppsToCheck.add(c.Opportunity__c);
                    hasToCheckAssets.add(c.Id);
                }

                // should check branding before changing stage name
                if (rules.containsKey('chkBrandingStatus')
                        && Boolean.valueOf(rules.get('chkBrandingStatus').Business_Rule_Value__c)) {
                    brandingOppsToCheck.add(c.Opportunity__c);
                    hasToCheckBrandings.add(c.Id);
                }

            }
        }

        // gets assets
        if (!assetOppsToCheck.isEmpty()) {
            for (Asset__c a : [
                        SELECT
                        Opportunity__c,
                        Status__c
                        FROM Asset__c
                        WHERE Opportunity__c IN :assetOppsToCheck
                    ]) {

                if (a.Status__c != 'Activated Successfully') {
                    oppWithInactiveAsset.add(a.Opportunity__c);
                }
            }
        }

        // gets brandings
        if (!brandingOppsToCheck.isEmpty()) {
            for (Branding_Content__c b : [
                        SELECT
                        Opportunity__c,
                        Status__c
                        FROM Branding_content__c
                        WHERE Opportunity__c in :brandingOppsToCheck
                        AND Type__c Like 'White Label%'
                    ]) {

                if (b.status__c != 'Installed successfully') {
                    oppWithUninstalledBranding.add(b.Opportunity__c);
                }
            }
        }

        // free heap mem
        assetOppsToCheck.clear();
        brandingOppsToCheck.clear();

        for (Case c : validCasesWithOpp) {

            Map<String, Business_Config__c> rules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId));
            Map<String, String> closedReason = (Map<String, String>)JSON.deserialize(rules.get('closingReason').Business_Rule_Value__c, Map<String, String>.class);

            Set<String> positiveReason = new Set<String>(closedReason.get('Positive').split(','));
            Set<String> negativeReason = new Set<String>(closedReason.get('Negative').split(','));

            if (
                positiveReason.contains(c.Closed_Reason__c)
                && rules.containsKey('PositiveStageName')

                // does not need to check asset, or opps has no inactive assets
                && (!hasToCheckAssets.contains(c.Id)
                    || !oppWithInactiveAsset.contains(c.Opportunity__c))

                // does not need to check branding, or opps has no uninstalled branding
                && (!hasToCheckBrandings.contains(c.Id)
                    || !oppWithUninstalledBranding.contains(c.Opportunity__c))) {

                toUpdate.add(new Opportunity(Id = c.opportunity__c, StageName = rules.get('PositiveStageName').Business_Rule_Value__c));

            } else if (negativeReason.contains(c.Closed_Reason__c)
                       && rules.containsKey('NegativeStageProbability')) {

                List<String> stageProb = rules.get('NegativeStageProbability').Business_Rule_Value__c.split(';');
                toUpdate.add(new Opportunity(Id = c.opportunity__c, StageName = stageProb[0], Probability = Decimal.valueOf(stageProb[1])));
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

public static void updateMenuProcessingCaseOwner(List<case> newList, Map<Id, Case>oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BackToQueueBtn');
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Case c : newList) {
                String recordtypeDevName = LibRecordTypeHelper.getRecordTypeValue(c.RecordTypeId);
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(recordtypeDevName);
                if (mapBusinessRule != null && !mapBusinessRule.isempty() && mapBusinessRule.get('MPRecType') != null && recordtypeDevName == mapBusinessRule.get('MPRecType').Business_Rule_Value__c && mapBusinessRule.get('MPStatus') != null && c.status == mapBusinessRule.get('MPStatus').Business_Rule_Value__c && oldMap.get(c.id).status != c.status && mapBusinessRule.get('ownerId') != null && c.ownerid != mapBusinessRule.get('ownerId').Business_Rule_Value__c) {
                    c.ownerid = mapBusinessRule.get('ownerId').Business_Rule_Value__c;

                }
            }

        }

    }

    public static void inboundUKPPUpdateMidasAPI(List<Case> newList, Map<Id, Case> oldMap) {
        List<String> csLst = new List<String>();
    for (case cs: newList) {
                if ( LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId) == 'UK_Internal_Case' && cs.type == 'Sales Task' && oldMap.get(cs.id).status != cs.status && cs.isclosed == true && cs.Case_Reason__c == 'Premium Placement') {
                    Boolean interested = false;
                    String intrestedData = InterestedOppClosedLost__c.getValues('Interested').caseClosingReason__c;
                    if (intrestedData == null) {
                        cs.addError('Custom setting InterestedOppClosedLost__c is not defined with values');
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
                    if (intrestedReasons.contains(cs.closed_reason__c)) {
                        csLst.add(cs.Id);


                    }

                }
            }
        if (csLst != null && !csLSt.isEmpty())
            callMidasCaseLostAPI(csLSt);
    }


    @future(callout = true)
    public static void callMidasCaseLostAPI(List<string> csIDs) {
    List<case> csToUpd = new List<case>();
        List<Case> cList = [select id, MidasAPIException__c, closed_reason__c, Root_Cause__c, accountid from Case where id = :csIDs];
        String reason = 'case_interest';
    for (case cs: cList) {
                try {
                    if (cs.Root_Cause__c != null) {
                        if (cs.Root_Cause__c.contains(';')) {
                            reason = cs.Root_cause__c.split(';')[0];
                        } else {
                            reason = cs.Root_cause__c;

                        }
                    }
                    Boolean interested = true;
                    //String bodyparam = '{"interested":'+interested+'}';

                    Id currentUserId = UserInfo.getUserId();
                    User userData = [SELECT Id, Email, UserRole.Name FROM User where id = :currentUserId];
                    String bodyparam = '{"meta": {"username": "' + userData.Email + '","sf_role": "' + userData.UserRole.Name + '","sf_opportunity_id": "' + cs.Id + '"},"data": {"reason":"' + reason + '","expressed_interest":' + interested + '}}';
                    HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK', '/v2/sites/UKHH/restaurants/sf:' + cs.accountid + '/register_interest', 'POST', bodyparam);
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    System.debug('bodyparam: ' + bodyparam);
                    if (req != null) {
                        //req.setHeader('opportunity-info','{"opportunity_id":"'+cs.id+'","account_id":"'+cs.accountid+'"}');
                        //req.setHeader('user-info','{"user_email":"'+userData.Email+'", "user_role":"'+userData.UserRole.Name+'"}');
                        res = http.send(req);
                        System.debug('response :' + res.getBody());
                        system.debug('##status code' + res.getStatusCode());
                        if (res.getStatusCode() == 201) {
                            if (cs.MidasAPIException__c != null) {
                                cs.MidasAPIException__c = null;
                                csToUpd.add(cs);
                            }
                        } else {
                            cs.MidasAPIException__c = res.getStatusCode() + '-' + res.getBody();
                            csToUpd.add(cs);
                        }

                    } else {
                        cs.MidasAPIException__c = 'MidasIntegration__c is not configured';
                        csToUpd.add(cs);
                    }

                } catch (System.CalloutException e) {
                    system.debug('Error: ' + e.getMessage());
                    String err = e.getMessage();
                    if (err.length() > 250) {
                        err = err.left(250);
                    }
                    cs.MidasAPIException__c = 'Er-' + err;
                    csToUpd.add(cs);
                }
            }
        update csToUpd;
    }
    /*public static void updateDueDateoncase(List<case> newCsLst, Map<id,case>oldCsMap){
    Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('updateDueDateForCase');
    system.debug(mapBusinessLogic );
    if(mapBusinessLogic!=null && !mapBusinessLogic.isEmpty()){
        for(case c:newCsLst){
            system.debug(c);
             Set<String> recordtypes = new set<string>();
             Set<String> casetype= new set<string>();
            Map<String,Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid));
            system.debug(mapBusinessRule );
            if(mapBusinessRule!=null && !mapBusinessRule.isEmpty()){
                if((mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c).contains(','))
                    recordtypes= new Set<String>((mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c).split(','));
                   else
                    recordtypes.add(mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c);
                   if((mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c).contains(','))
                    casetype= new Set<String>((mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c).split(','));

                    casetype.add(mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c);
                   if(c.id==null){
                       system.debug('**c'+C);
                    if( recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid)) && casetype.contains(c.type)){
                        calculateDueDate(c,2);

                     }
                   }
                 else{
                     if((c.type!=oldCsMap.get(c.id).type ||(c.recordtypeid!=oldCsMap.get(c.id).recordtypeid &&LibRecordTypeHelper.getRecordTypeValue(oldCsMap.get(c.id).recordtypeid)== mapBusinessRule.get('inboundCaseRecordType').Business_Rule_Value__c)) && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid)) && c.type=='Menu Change'){
                        calculateDueDate(c,2);
                     }

                 }
            }
        }
    }
    }

    private static void calculateDueDate(case c, integer days){

    datetime today =datetime.now();
    c.due_date__c=today.adddays(days);

        if (today.format('EEE') == 'FRI' || today .format('EEE') == 'THU') {
            c.due_date__c = c.due_date__c.addDays(2);
        }
        else if(today.format('EEE') == 'SAT'){
             c.due_date__c = c.due_date__c.addDays(1);

        }

    }*/
    public static void updateDueDateoncase(List<Case> newCsLst, Map<id, Case>oldCsMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('updateDueDateForCase');
        system.debug(mapBusinessLogic );
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            for (Case c : newCsLst) {
                system.debug(c);
                Set<String> recordtypes = new set<string>();
                Set<String> casetype = new set<string>();
                Set<String> casetypeUpd = new set<string>();
                String rtDevName = LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid);
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(rtDevName);

                if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {

                    if ((mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c).contains(','))
                        recordtypes = new Set<String>((mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c).split(','));
                    else
                        recordtypes.add(mapBusinessRule.get('recordtypesOnCreate').Business_Rule_Value__c);
                    if ((mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c).contains(','))
                        casetype = new Set<String>((mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c).split(','));
                    else
                        casetype.add(mapBusinessRule.get('casetypeOnCreate').Business_Rule_Value__c);
                    if ((mapBusinessRule.get('casetypeOnUpd').Business_Rule_Value__c).contains(','))
                        casetypeUpd = new Set<String>((mapBusinessRule.get('casetypeOnUpd').Business_Rule_Value__c).split(','));
                    else
                        casetypeUpd.add(mapBusinessRule.get('casetypeOnUpd').Business_Rule_Value__c);

                    /*if (LibRecordTypeHelper.getRecordTypeValue(oldCsMap.get(c.id).recordtypeid) == mapBusinessRule.get('inboundCaseRecordType').Business_Rule_Value__c || (oldCsMap.get(c.id).type != null && oldCsMap.get(c.id).type != c.type) && casetypeUpd.contains(c.type) && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid))) {

                        c.menu_Change_date__c = datetime.now();
                    }*/
                    if ((c.recordtypeid != oldCsMap.get(c.id).recordtypeid || c.type != oldCsMap.get(c.id).type || c.status != oldCsMap.get(c.id).status) && (mapBusinessRule.get('MenuChangeCaseStatus') != null && c.status == mapBusinessRule.get('MenuChangeCaseStatus').Business_Rule_Value__c &&  casetypeUpd.contains(c.type) && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid))))
                        c.menu_Change_date__c = datetime.now();

                    // should calculate menu age?
                    if (oldCsMap.get(c.id).status == mapBusinessRule.get('CaseStatus').Business_Rule_Value__c
                            && recordtypes.contains(LibRecordTypeHelper.getRecordTypeValue(c.recordtypeid))) {

                        Datetime startDate, endDate;


                        // menu change or created date?
                        if (c.menu_Change_date__c == null && casetype.contains(c.type)) {
                            // menu not changed
                            startDate = c.CreatedDate;
                            endDate = rtDevName.startsWith('UK') ? c.First_Check_Date__c : c.Menu_Typed_Date__c;
                        } else if (c.Menu_Change_Date__c != null && c.status != oldCsMap.get(c.id).status && casetypeUpd.contains(c.type)) {
                            // menu changed
                            startDate = c.Menu_Change_Date__c;
                            endDate = rtDevName.startsWith('UK') ? c.First_Check_Date__c : c.Menu_Typed_Date__c;
                        }


                        // checks if has to update formula
                        if (startDate != null && endDate != null) {
                            c.Menu_Type_Age__c = menuAgeAmazingFormula(startDate, endDate);
                        }

                    }
                }
            }
        }
    }


    /**
    * @return    Returns number of hours between start and end excluding weekends
    */
    private static Integer menuAgeAmazingFormula(Datetime startDate, Datetime endDate) {
        Long res;

        Long startTime = startDate.getTime();
        Long endTime = endDate.getTime();
        Long startDays = startTime / (3600000);
        Long endDays = endTime / (3600000);
        endDays = Math.Mod(endDays, 24);
        startDays = Math.mod(startDays, 24);

        Date magicDate = Date.newInstance(1996, 01, 01);

        res = Math.abs( Math.ROUND(24 * ((5 * math.FLOOR((DATE.VALUEof(endDate).Daysbetween(magicDate)) / 7) + math.MIN(5, math.MOD(DATE.VALUEof(endDate).Daysbetween(magicDate), 7)) )
                                         - (5 * Math.FLOOR((DATE.VALUEof(startDate).Daysbetween(magicDate)) / 7) + math.MIN(5, math.MOD(DATE.VALUEof(startDate).Daysbetween(magicDate), 7))))));

        if (res == 24) {
            res = (24 - startDays) + endDays;
        } else {
            res += (24 - startDays) + endDays;
            res = Math.abs(res - 24);
        }

        // amaaaaazing isn't it?
        return res.intValue();
    }

    public static void qualityCheckReplacementClosingAction(List<Case> caseList, Map<Id, Case> mapOldCase) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QCReplacementClosingAction');
        Map<Id, String> oppIdWithRStatus = new Map<Id, String>();
        Map<Id, Boolean> mapOppWithOnboarding = new Map<Id, Boolean>();
        Map<Id, String> mapOppWithONBoardData = new Map<Id, String>();
        Map<Id, Id> mapOppAccount = new Map<Id, Id>();
        Map<Id, Opportunity> updateOppStage = new Map<Id, Opportunity>();
        List<Id> caseIds = new List<Id>();
        try {
            if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                for (Case cs : caseList) {
                    String caseRecordtypeName = LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId);
                    system.debug('**caseRecordtypeName ' + caseRecordtypeName );
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(caseRecordtypeName);
                    system.debug(mapBusinessRule );
                    if (cs.type == 'Quality Check Replacement' && cs.isClosed &&  !mapOldCase.get(cs.id).isClosed && mapBusinessRule != null && !mapBusinessRule.isEmpty()) {

                        String[] ClosedReason = (mapBusinessRule.get('Closed_Reason__c').Business_Rule_Value__c).split(',');
                        String positiveReason;
                        String negativeReason;
                        if (ClosedReason[0].toLowerCase().indexOf('positive') > -1) {
                            positiveReason = (ClosedReason[0].split('='))[1];
                            negativeReason = (ClosedReason[1].split('='))[1];
                        } else {
                            positiveReason = (ClosedReason[1].split('='))[1];
                            negativeReason = (ClosedReason[0].split('='))[1];
                        }
                        if (cs.Opportunity__c != null) {
                            if (positiveReason == cs.Closed_Reason__c) {
                                if (mapBusinessRule.get('PositiveRepStatus') != null) {
                                    oppIdWithRStatus.put(cs.Opportunity__c, mapBusinessRule.get('PositiveRepStatus').Business_Rule_Value__c);
                                    if (mapBusinessRule.get('OnboardingCase') != null) {
                                        mapOppWithONBoardData.put(cs.Opportunity__c, mapBusinessRule.get('OnboardingCase').Business_Rule_Value__c);
                                    } else {
                                        mapOppWithONBoardData.put(cs.Opportunity__c, null);
                                    }
                                    mapOppAccount.put(cs.Opportunity__c, cs.AccountId);
                                }
                            } else if (negativeReason == cs.Closed_Reason__c) {
                                if (mapBusinessRule.get('NegativeRepStatus') != null) {
                                    oppIdWithRStatus.put(cs.Opportunity__c, mapBusinessRule.get('NegativeRepStatus').Business_Rule_Value__c);
                                    if (mapBusinessRule.get('OppStageForNegative') != null) {
                                        caseIds.add(cs.Id);
                                        updateOppStage.put(cs.Opportunity__c, new Opportunity(Id = cs.Opportunity__c, StageName = mapBusinessRule.get('OppStageForNegative').Business_Rule_Value__c));
                                    }
                                }
                            }
                        }
                    }
                }

                if (!updateOppStage.isempty()) {
                    for (Case cs : [select id, Opportunity__c, Opportunity__r.StageName from Case where id in : caseIds ]) {
                        if (cs.Opportunity__r.StageName == 'Closed Won' || cs.Opportunity__r.StageName == 'Closed Lost') {
                            updateOppStage.remove(cs.Opportunity__c);
                        }
                    }
                }


                List<Case> onboardingCs = new List<Case>();
                if (!oppIdWithRStatus.isEmpty()) {
                    for (Case cs : [select id, Closed_Reason__c, isClosed, Opportunity__c, Opportunity__r.stageName from case where Type = 'Onboarding' and Opportunity__c in:oppIdWithRStatus.keySet()]) {
                        if (cs.isClosed && cs.Closed_Reason__c != 'Successful') {
                            if (cs.Opportunity__r.stageName == 'Onboarding Failed') {
                                updateOppStage.put(cs.Opportunity__c, new Opportunity(Id = cs.Opportunity__c, StageName = 'Onboarding'));
                            } else {
                                mapOppWithOnboarding.put(cs.Opportunity__c, true);
                            }
                        } else if (cs.isClosed && cs.Closed_Reason__c == 'Successful') {
                            mapOppWithOnboarding.put(cs.Opportunity__c, false);
                        } else if (!cs.isClosed) {
                            mapOppWithOnboarding.put(cs.Opportunity__c, false);
                        }
                    }
                    for (Id oppID : oppIdWithRStatus.keySet()) {
                        if (mapOppWithONBoardData.get(oppID) != null && (mapOppWithOnboarding.get(oppID) == null || (mapOppWithOnboarding.get(oppID) != null && mapOppWithOnboarding.get(oppID) == true))) {
                            Case cs = new Case(Opportunity__c = oppID, AccountId = mapOppAccount.get(oppID));
                            Account acc = [select Id, Delivery_ServicePicklist__c from account where id = :mapOppAccount.get(oppID)];

                            if (acc.Delivery_ServicePicklist__c == 'Mixed') {
                                cs.Case_reason__c  = 'Mixed';
                            } else if (acc.Delivery_ServicePicklist__c == 'All Inclusive') {
                                cs.Case_reason__c  = 'All Inclusive';
                            }

                            for (String fieldAndValue : mapOppWithONBoardData.get(oppID).split(',')) {
                                List<String> fields = fieldAndValue.split('=');
                                cs.put(fields[0], fields[1]);
                            }
                            onboardingCs.add(cs);
                        }
                    }
                    ClsCaseProcessor.updateReplacementOrder(oppIdWithRStatus);
                    //System.debug('onboardingCs: '+onboardingCs);
                    insert onboardingCs;
                    if (!updateOppStage.isEmpty()) {
                        update updateOppStage.values();
                    }
                }
            }

        } catch (Exception e) {
            caseList[0].addError(e.getMessage());
            System.debug('Exception: ' + e.getMessage());
        }
    }


    public static void updateReplacementOrder(Map<Id, String> oppIdWithRStatus) {
        List<Replacement_Order__c> rps = new List<Replacement_Order__c>();
        for (Replacement_Order__c rp : [select id, status__c, Id_Opportunity__c from Replacement_Order__c where Id_Opportunity__c in: oppIdWithRStatus.keySet() and status__c = 'BackOffice-Pending'] ) {
            rp.status__c = oppIdWithRStatus.get(rp.Id_Opportunity__c);
            rps.add(rp);
        }
        update rps;
    }

    public static void backendShippingCaseClosure(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('BackendShippingCaseClosure');
        List<Opportunity> updateOppList = new List<Opportunity>();
        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            if (newList.size() == 1 && newList[0].isClosed && newList[0].Closed_Reason__c != oldMap.get(newList[0].id).Closed_Reason__c) {
                Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(newList[0].RecordTypeId));
                Set<String> caseTypes = new Set<String>();
                Set<String> positiveReason = new Set<String>();
                Set<String> negativeReason = new Set<String>();
                String pReasons = '';
                String nReasons = '';

                if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {
                    if (mapBusinessRule.get('CheckForTypes') != null) {
                        caseTypes.addAll(mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.split(','));
                    }
                    if (mapBusinessRule.get('ClosedReason_' + newList[0].type) != null) {
                        String[] ClosedReason = (mapBusinessRule.get('ClosedReason_' + newList[0].type).Business_Rule_Value__c).split(';');
                        //gets positive and negative reasons from the business rules
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
                        if (ClosedReason[0].toLowerCase().indexOf('negative') > -1) {
                            nReasons = (ClosedReason[0].split('='))[1];
                        } else {
                            nReasons = (ClosedReason[1].split('='))[1];
                        }
                        if (nReasons != null && nReasons.indexOf(',') > -1) {
                            for (String r : nReasons.split(',')) {
                                negativeReason.add(r);
                            }
                        } else if (nReasons != null) {
                            negativeReason.add(nReasons);
                        }
                        system.debug('negativeReason: ' + negativeReason);
                        system.debug('positiveReason: ' + positiveReason);


                        if (newList[0].Opportunity__c != null && positiveReason.contains(newList[0].Closed_Reason__c)) {
                            caseTypes.remove(newList[0].type);
                            System.debug('caseTypes: ' + caseTypes);
                            List<Case> cs = [select id, isClosed, Closed_Reason__c from Case where opportunity__c = :newList[0].Opportunity__c and type in : caseTypes and id != :newList[0].Id];
                            if (cs != null && !cs.isEmpty()) {
                                for (Case c : cs) {
                                    if (c.isClosed && (c.Closed_Reason__c == 'Successful' || c.Closed_Reason__c == 'Take Online')) {
                                        Opportunity opp = new Opportunity(Id = newList[0].Opportunity__c, stageName = mapBusinessRule.get('OppStageForPositiveIfBothClosed').Business_Rule_Value__c);
                                        updateOppList.add(opp);
                                        break;
                                    }
                                }
                            } else {
                                Opportunity opp = new Opportunity(Id = newList[0].Opportunity__c, stageName = mapBusinessRule.get('OppStageForPositiveIfBothClosed').Business_Rule_Value__c);
                                updateOppList.add(opp);
                            }
                        } else if (newList[0].Opportunity__c != null &&  negativeReason.contains(newList[0].Closed_Reason__c)) {
                            Opportunity opp = new Opportunity(Id = newList[0].Opportunity__c, stageName = mapBusinessRule.get('OppStageForNegative').Business_Rule_Value__c);
                            updateOppList.add(opp);
                        }
                        update updateOppList;
                    }
                }
            }
        }
    }




    public Static void brandingCaseClosure(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('brandingCaseClosure');
        List<Opportunity> updateOppList = new List<Opportunity>();
        Set<String> positiveReason = new Set<String>();
        Set<String> caseTypes = new Set<String>();
        Set<String> brandingTypes = new Set<String>();
        Set<String> brandingStatus = new Set<String>();

        String pReasons = '';
        Boolean doNotUpdateOpp = false;

        if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
            Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(newList[0].RecordTypeId));
            if (mapBusinessRule != null && !mapBusinessRule .isEmpty()) {
                if (mapBusinessRule.get('CheckForTypes') != null) {
                    if (mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.contains(','))
                        caseTypes.addAll(mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c.split(','));
                    else
                        caseTypes.add(mapBusinessRule.get('CheckForTypes').Business_Rule_Value__c);
                }
                if (mapBusinessRule.get('brandingTypes') != null) {
                    if (mapBusinessRule.get('brandingTypes').Business_Rule_Value__c.contains(','))
                        brandingTypes.addAll(mapBusinessRule.get('brandingTypes').Business_Rule_Value__c.split(','));
                    else
                        brandingTypes.add(mapBusinessRule.get('brandingTypes').Business_Rule_Value__c);
                }

                if (mapBusinessRule.get('ClosedReason_' + newList[0].type) != null) {
                    String[] ClosedReason = new String[] {};
                    if ((mapBusinessRule.get('ClosedReason_' + newList[0].type).Business_Rule_Value__c).contains(';'))
                        ClosedReason = (mapBusinessRule.get('ClosedReason_' + newList[0].type).Business_Rule_Value__c).split(';');
                    else
                        ClosedReason = new String[] {mapBusinessRule.get('ClosedReason_' + newList[0].type).Business_Rule_Value__c};
                    //gets positive and negative reasons from the business rules
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
                }

                if (mapBusinessRule.get('BrandingStatusToExclude') != null && mapBusinessRule.get('BrandingStatusToExclude').business_rule_value__c != null ) {
                    brandingStatus.addall( mapBusinessRule.get('BrandingStatusToExclude').business_rule_value__c.split(','));
                }
                if (newList[0].isClosed && !oldmap.get(newList[0].id).isClosed) {
                    if (newList[0].Opportunity__c != null && positiveReason.contains(newList[0].Closed_Reason__c)) {
                        //caseTypes.remove(newList[0].type);
                        System.debug('caseTypes: ' + caseTypes);
                        List<Case> cs = [select id, isClosed, Closed_Reason__c from Case where opportunity__c = :newList[0].Opportunity__c and type in : caseTypes and id != :newList[0].Id];

                        if (cs != null && !cs.isEmpty()) {
                            for (Case c : cs) {
                                /*if(c.isClosed && (c.Closed_Reason__c=='Successful' || c.Closed_Reason__c=='Take Online')){
                                    //Opportunity opp = new Opportunity(Id=newList[0].Opportunity__c, stageName=mapBusinessRule.get('OppStageForPositiveIfBothClosed').Business_Rule_Value__c);
                                    //  updateOppList.add(opp);


                                        break;
                                }else*/ if (!c.isClosed || ( c.isClosed && (!positiveReason.contains(c.Closed_Reason__c)))) {
                                    donotUpdateOpp = true;


                                }
                            }
                        }
                        if (!donotUpdateOpp && mapBusinessRule.get('checkForOpenBranding') != null && Boolean.valueof(mapBusinessRule.get('checkForOpenBranding').Business_Rule_Value__c)) {
                            List<Branding_Content__c> brandingContentLst = [select id, opportunity__c, status__C from branding_content__c where opportunity__c = : newList[0].Opportunity__c and type__c in: brandingTypes and id != :newlist[0].branding__c];
                            for (Branding_Content__c bc : brandingContentLst) {
                                if (!brandingStatus.contains(bc.status__C)) {
                                    donotUpdateOpp = true;
                                    break;
                                }

                            }



                        }
                        if (!donotUpdateOpp) {
                            Opportunity opp = new Opportunity(Id = newList[0].Opportunity__c, stageName = mapBusinessRule.get('OppStageForPositive').Business_Rule_Value__c);
                            updateOppList.add(opp);

                        }
                        if (updateOppList != null && !updateOppList.isEmpty())
                            update updateOppList;
                    }
                }
            }


        }
    }

    public static void preventSalesTeamFromEditingQC(List<Case>newLst, Map<Id, Case>olMap) {
        if (!clsOpportunityProcessor.PreventQCValidation) {
            Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('QualityCheckInternalCaseClosingAction');
            for (Case cs : newLst) {

                if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
                    Map<String, Business_Config__c> mapBusinessRule = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(cs.RecordTypeId));
                    if (mapBusinessRule != null && !mapBusinessRule.isEmpty()) {

                        if (olMap.get(cs.id) != null && cs.status != olMap.get(cs.id).status && mapBusinessRule.get('QCProfileChk') != null && Boolean.valueof(mapBusinessRule.get('QCProfileChk').Business_Rule_Value__c) && mapBusinessRule.get('profileIDNotAllowed').business_rule_value__C.containsignorecase(userinfo.getprofileid()) && cs.type == mapBusinessRule.get('type').business_rule_value__c) {
                            cs.addError(Label.Quality_Check_Closure);
                        }


                    }
                }
            }
        }
    }
}