@isTest
private class UnitTestClsCaseProcessor {
    private static User runningUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryherotest.com', 'Yogiyo', 'KR');
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc;
    private static Account acc_uk;
    private static Account acc_cd;
    private static Country__c c;
    private static Country__c c_au;
    private static Country__c c_uk;
    private static country__c c_cd;
    private static Opportunity opp;
    private static Opportunity opp_au;
    private static Opportunity opp_uk;
    private static Opportunity opp_cd;
    private static Account acc_au;
    private static List<Asset__c> assetsUK;
    private static List<Stock_Item__c> stockListUK;
    private static Company__c com_uk;
    private static company__c com_cd;

    private static User runningAdminUser = UnitTestDataFactory.createUser('System Administrator', 'testAdmin@deliveryherotest.com', 'Yogiyo;UK', 'KR,UK');

    static {

        insert runningAdminUser;
        insert runningUser;
        System.runAs(runningAdminUser) {
            UnitTestDataFactory.getRecordtypeValues();
            Platform_Country__c pt1 = new Platform_Country__c(name = 'FOCPlatform', Country__c = 'Lebanon,Qatar,United Arab Emirates');
            Platform_Country__c pt2 = new Platform_Country__c(name = 'TalabatPlatform', Country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates');
            List<MidasIntegration__c> midasIntg = new List<MidasIntegration__c>();
            midasIntg.add(new MidasIntegration__c(name = 'UK', EndPoint__c = 'http://midas.medusa-hero.com/backend/', AuthenticationToken__c = 'WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
            insert midasIntg;
            List<InterestedOppClosedLost__c> intOppClosedSetting = new List<InterestedOppClosedLost__c>();
            intOppClosedSetting.add(new InterestedOppClosedLost__c(name = 'Interested', Values__c = 'Not enough capacity', CaseClosingReason__c = 'Successful'));
            insert intOppClosedSetting;
            c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            c_au = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
            c_uk = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
            c_cd = UnitTestDataFactory.createCountry('CD', 'Colombia', 'COP');
            Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
            Company__c com_au = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', c_au);
            com_cd = UnitTestDataFactory.createCompany('ClickDelivery', 'CD', c_cd);
            com_uk = UnitTestDataFactory.createCompany('Hungryhouse', 'HH', c_uk);
            insert new List<sObject> {c, c_au, c_uk, com, com_au, com_uk, pt1, pt2, c_cd, com_cd};

            Business_Config__c v1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Closed', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'MenuEntryCaseValidation', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c v2 = new Business_Config__c(Business_Rule_Name__c = 'FieldsToValidate', Business_Rule_Value__c = 'Person_In_Charge__c,Menu_Typed_Date__c,Person_in_Charge_Final_Check__c,Final_Check_Date__c,Person_In_Charge_Take_Online__c,Take_Online_Date__c', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuEntryCaseValidation', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c greeting_OppQuoteProcess = UnitTestDataFactory.createBusinessConfig('OppQuoteProcess', 'Process', 'Greeting', 'Salutation,Lastname', c.Id, 'Yogiyo_Opportunity', true, false);

            Business_Config__c terminationCaseFlow = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'Type', 'Termination', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow2 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'createRetentionCaseClosingReason', 'Retention', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow3 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'RetentionCaseType', 'Retention', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow4 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'createRetentionCase', 'true', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow5 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'RetentionCaseRecordType', 'DH_AU_Inbound', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow6 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'RetentionCaseStatus', 'New', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow7 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'RetentionCaseOrigin', 'Web', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow8 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'RetentionCaseSubject', 'Retention', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow9 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'createTakeOfflineCaseClosingReason', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow10 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseType', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow11 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseTypeOrigin', 'Web', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow12 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseTypeSubject', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow15 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseReason', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow13 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseTypeRecordType', 'DH_AU_Inbound', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c terminationCaseFlow14 = UnitTestDataFactory.createBusinessConfig('TerminationCaseFlow', 'Process', 'TakeOfflineCaseStatus', 'New', c_au.Id, 'DH_AU_Inbound', true, false);


            Business_Config__c retentionCaseFlow = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'closingReasonUnsuccesful', 'Not Successful', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow2 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'closingReasonSuccessfulCloseParentCaseStatus', 'Retention', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow3 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'closingReasonSuccessful', 'Successful', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow4 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseStatus', 'New', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow5 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseOrigin', 'Web', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow6 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseSubject', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow7 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseType', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow10 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseReason', 'Take Offline', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow8 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'closingReasonSuccessfulCloseParentCase', 'true', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c retentionCaseFlow9 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOfflineCaseRecordType', 'DH_AU_Inbound', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c r11 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOnlineCaseStatus', 'Test', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c r12 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOnlineCaseOrigin', 'Test', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c r13 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOnlineCaseSubject', 'Successful', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c r14 = UnitTestDataFactory.createBusinessConfig('RetentionCaseFlow', 'Process', 'takeOnlineCaseType', 'Termination', c_au.Id, 'DH_AU_Inbound', true, false);

            Business_Config__c takeOfflineCaseFlow = UnitTestDataFactory.createBusinessConfig('TakeOfflineCaseFlow', 'Process', 'closeReasonSuccessful', 'Successful', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c takeOfflineCaseFlow2 = UnitTestDataFactory.createBusinessConfig('TakeOfflineCaseFlow', 'Process', 'closeParentCaseOnSuccessful', 'true', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c takeOfflineCaseFlow3 = UnitTestDataFactory.createBusinessConfig('TakeOfflineCaseFlow', 'Process', 'closeReasonUnsuccessful', 'Not Successful', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c takeOfflineCaseFlow4 = UnitTestDataFactory.createBusinessConfig('TakeOfflineCaseFlow', 'Process', 'closingReasonSuccessfulCloseParentCaseStatus', 'Closed', c_au.Id, 'DH_AU_Inbound', true, false);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Positive', Business_Rule_Value__c = 'StageName=Call - Reached,Probability=25', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Take Online;Negative=Take Online is not possible,Invalid,Duplicate', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'Non_Contracted__c', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Negative', Business_Rule_Value__c = 'StageName=Closed Lost,Probability=0', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'StageName', Business_Rule_Value__c = 'Non Contracted', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c = 'LostReasonIfOppClosedLost', Business_Rule_Value__c = 'Other', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');
            Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c = 'SkipForStage', Business_Rule_Value__c = 'Closed Won,Closed Lost', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMPClosingAction', Record_Type_Id__c = 'Yogiyo_Entry_Case', Type__c = 'Process');

            Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c = 'Non_Contracted__c', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'NonContractedMenuProcessing', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c = 'set StageName', Business_Rule_Value__c = 'Non Contracted', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuProcessing', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c = 'set Probability', Business_Rule_Value__c = '30', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuProcessing', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c = 'Menu Processing Case', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordTypes.get('Yogiyo_Entry_Case').id + ',type=Menu Processing,subject=Menu Processing,status=New', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuProcessing', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');

            Business_Config__c q1 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Successful,Negative=Not Successful', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q2 = new Business_Config__c(Business_Rule_Name__c = 'CreateAsset', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q3 = new Business_Config__c(Business_Rule_Name__c = 'AssetRecordType', Business_Rule_Value__c = 'Yogiyo_Asset', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q4 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'New - Awaiting Shipping', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q5 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Negative', Business_Rule_Value__c = 'StageName=Please correct errors,Probability=90', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q6 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Positive', Business_Rule_Value__c = 'StageName=Closed Won,Probability=100', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');
            Business_Config__c q7 = new Business_Config__c(Business_Rule_Name__c = 'SkipForStage', Business_Rule_Value__c = 'Closed Won,Closed Lost', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'Yogiyo_Internal_Case', Type__c = 'Process');

            Business_Config__c a1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Final Check', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'MenuProcessingStatusUpdateValidation', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c a2 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Menu Processing', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingStatusUpdateValidation', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c a3 = new Business_Config__c(Business_Rule_Name__c = 'OpenChildCaseType', Business_Rule_Value__c = 'Create Backend Id,Menu Typing', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingStatusUpdateValidation', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c a4 = new Business_Config__c(Business_Rule_Name__c = 'LastChildType', Business_Rule_Value__c = 'Menu Typing', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingStatusUpdateValidation', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c a5 = new Business_Config__c(Business_Rule_Name__c = 'LastChildClosedReason', Business_Rule_Value__c = 'Successful', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingStatusUpdateValidation', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');

            Business_Config__c w1 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Create Backend Id', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'MenuTypingCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c w2 = new Business_Config__c(Business_Rule_Name__c = 'IsClosed', Business_Rule_Value__c = 'true', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuTypingCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c w3 = new Business_Config__c(Business_Rule_Name__c = 'ClosedReason', Business_Rule_Value__c = 'Successful', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuTypingCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c w4 = new Business_Config__c(Business_Rule_Name__c = 'MenuTypingCase', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordTypes.get('DH_AU_Entry_Case').id + ',type=Menu Typing,subject=Menu Typing,status=New', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuTypingCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c w5 = new Business_Config__c(Business_Rule_Name__c = 'OpportunityBusinessType', Business_Rule_Value__c = 'New', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuTypingCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');

            Business_Config__c e1 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'New', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'BEAccountCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c e2 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Menu Processing', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BEAccountCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c e3 = new Business_Config__c(Business_Rule_Name__c = 'BEAccountCase', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordTypes.get('DH_AU_Entry_Case').id + ',type=Create Backend Id,subject=BE Account Creation,status=New', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BEAccountCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c e4 = new Business_Config__c(Business_Rule_Name__c = 'OpportunityBusinessType', Business_Rule_Value__c = 'New', Id_Country__c = c_au.Id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BEAccountCaseProcess', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');

            Business_Config__c ba1 = new Business_Config__c(Business_Rule_Name__c = 'Non_Contracted__c', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'NonContractedMenuChange', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c ba2 = new Business_Config__c(Business_Rule_Name__c = 'StageName', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuChange', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c ba3 = new Business_Config__c(Business_Rule_Name__c = 'Menu Processing Status', Business_Rule_Value__c = 'Closed', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuChange', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c ba4 = new Business_Config__c(Business_Rule_Name__c = 'Menu Change Case', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordtypes.get('Yogiyo_Entry_Case').id + ',type=Convert to Contract,subject=Convert to Contract,status=New', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'NonContractedMenuChange', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');

            Business_Config__c bv1 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Positive', Business_Rule_Value__c = 'StageName=Closed Won,Probability=100', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv2 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Take Online;Negative=Take Online is not possible,Invalid,Duplicate', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv3 = new Business_Config__c(Business_Rule_Name__c = 'Check for Is_Tested__c', Business_Rule_Value__c = 'true', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv4 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Negative', Business_Rule_Value__c = 'StageName=Please Check,Probability=0', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv5 = new Business_Config__c(Business_Rule_Name__c = 'StageName', Business_Rule_Value__c = 'Editorial Queue', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv6 = new Business_Config__c(Business_Rule_Name__c = 'SkipForStage', Business_Rule_Value__c = 'Closed Won,Closed Lost', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv7 = new Business_Config__c(Business_Rule_Name__c = 'NotificationAfterClosing', Business_Rule_Value__c = 'false', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv8 = new Business_Config__c(Business_Rule_Name__c = 'AllowChildCaseCloseValidation', Business_Rule_Value__c = 'false', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv9 = new Business_Config__c(Business_Rule_Name__c = 'ChildCaseTypes', Business_Rule_Value__c = 'Create Backend Id,Menu Typing', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv10 = new Business_Config__c(Business_Rule_Name__c = 'statusValues', Business_Rule_Value__c = 'Final Check,Approval Pending,Take Online', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingAccountUpdate', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv11 = new Business_Config__c(Business_Rule_Name__c = 'orderMap', Business_Rule_Value__c = '{"Approval Pending":2,"Final Check":1}', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingAccountUpdate', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv12 = new Business_Config__c(Business_Rule_Name__c = 'closingStatus', Business_Rule_Value__c = 'Take Online', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingAccountUpdate', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv13 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Menu Processing', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingAccountUpdate', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv14 = new Business_Config__c(Business_Rule_Name__c = 'newStatus', Business_Rule_Value__c = 'MP - Initiated', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingAccountUpdate', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv15 = new Business_Config__c(Business_Rule_Name__c = 'Status', Business_Rule_Value__c = 'Closed', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'ParentCaseClosure', Record_Type_Id__c = 'DH_AU_Inbound', Type__c = 'Process');

            Business_Config__c bv16 = new Business_Config__c(Business_Rule_Name__c = 'ownerId', Business_Rule_Value__c = runningUser.id, Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'BackToQueueBtn', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv17 = new Business_Config__c(Business_Rule_Name__c = 'MPStatus', Business_Rule_Value__c = 'Please correct Errors', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackToQueueBtn', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
            Business_Config__c bv18 = new Business_Config__c(Business_Rule_Name__c = 'MPRecType', Business_Rule_Value__c = 'DH_AU_Entry_Case', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackToQueueBtn', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');

            Business_Config__c c1 = new Business_Config__c(Business_Rule_Name__c = 'PositiveStageName', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c2 = new Business_Config__c(Business_Rule_Name__c = 'NegativeStageProbability', Business_Rule_Value__c = 'Onboarding Failed;0', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c3 = new Business_Config__c(Business_Rule_Name__c = 'Type', Business_Rule_Value__c = 'Onboarding', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c4 = new Business_Config__c(Business_Rule_Name__c = 'closingReasonPositive', Business_Rule_Value__c = 'Successful,Take Online', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c5 = new Business_Config__c(Business_Rule_Name__c = 'chkAssetStatus', Business_Rule_Value__c = 'true', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c6 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'Activated Successfully', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c7 = new Business_Config__c(Business_Rule_Name__c = 'closingReason', Business_Rule_Value__c = '{"Positive":"Successful,Take Online","Negative":"Invalid,Not Successful"}', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c8 = new Business_Config__c(Business_Rule_Name__c = 'chkBrandingStatus', Business_Rule_Value__c = 'true', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');
            Business_Config__c c9 = new Business_Config__c(Business_Rule_Name__c = 'BrandingStatus', Business_Rule_Value__c = 'Activated Successfully', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'RestaurantCareClosingAction', Record_Type_Id__c = 'UK_Restaurant_Operations', Type__c = 'Process');

            Business_Config__c d1 = new Business_Config__c(Business_Rule_Name__c = 'recordtypesOnCreate', Business_Rule_Value__c = 'UK_Entry_Case', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'updateDueDateForCase', Record_Type_Id__c = 'UK_Entry_Case', Type__c = 'Process');
            Business_Config__c d2 = new Business_Config__c(Business_Rule_Name__c = 'CaseStatus', Business_Rule_Value__c = 'Menu Typing', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'updateDueDateForCase', Record_Type_Id__c = 'UK_Entry_Case', Type__c = 'Process');
            Business_Config__c d3 = new Business_Config__c(Business_Rule_Name__c = 'casetypeOnUpd', Business_Rule_Value__c = 'Menu Change', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'updateDueDateForCase', Record_Type_Id__c = 'UK_Entry_Case', Type__c = 'Process');
            Business_Config__c d4 = new Business_Config__c(Business_Rule_Name__c = 'casetypeOnCreate', Business_Rule_Value__c = 'Menu Processing', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'updateDueDateForCase', Record_Type_Id__c = 'UK_Entry_Case', Type__c = 'Process');
            Business_Config__c d5 = new Business_Config__c(Business_Rule_Name__c = 'inboundCaseRecordType', Business_Rule_Value__c = 'UK_Inbound', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'updateDueDateForCase', Record_Type_Id__c = 'UK_Entry_Case', Type__c = 'Process');

            Business_Config__c d6 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Successful,Negative=Not Successful', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'QCReplacementClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d7 = new Business_Config__c(Business_Rule_Name__c = 'PositiveRepStatus', Business_Rule_Value__c = 'BackOffice-Approved', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QCReplacementClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d8 = new Business_Config__c(Business_Rule_Name__c = 'NegativeRepStatus', Business_Rule_Value__c = 'BackOffice-Rejected', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QCReplacementClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d9 = new Business_Config__c(Business_Rule_Name__c = 'OnboardingCase', Business_Rule_Value__c = 'RecordTypeId=' + mapRecordtypes.get('UK_Restaurant_Operations').id + ',type=Onboarding,subject=Onboard Restaurant,status=New', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QCReplacementClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');

            Business_Config__c d10 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d11 = new Business_Config__c(Business_Rule_Name__c = 'BrandingContentRecordType', Business_Rule_Value__c = 'UK_Branding_Content', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d12 = new Business_Config__c(Business_Rule_Name__c = 'Asset RecordType', Business_Rule_Value__c = 'UK_Asset', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d13 = new Business_Config__c(Business_Rule_Name__c = 'TemplateType', Business_Rule_Value__c = 'true', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d14 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'UK_Additional_Charges', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d15 = new Business_Config__c(Business_Rule_Name__c = 'contract_RecordType', Business_Rule_Value__c = 'UK_Contract', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d16 = new Business_Config__c(Business_Rule_Name__c = 'AddOnRecordType', Business_Rule_Value__c = 'UK_Add_On', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');
            Business_Config__c d117 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'New', Id_Country__c = c_uk.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'UK_Opportunity', Type__c = 'Process');

            Business_Config__c d17 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d18 = new Business_Config__c(Business_Rule_Name__c = 'BrandingContentRecordType', Business_Rule_Value__c = 'DH_AU_Branding_Content', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d19 = new Business_Config__c(Business_Rule_Name__c = 'Asset RecordType', Business_Rule_Value__c = 'DH_AU_Asset', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d20 = new Business_Config__c(Business_Rule_Name__c = 'TemplateType', Business_Rule_Value__c = 'false', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d21 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'DH_AU_Additional_Charges', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d22 = new Business_Config__c(Business_Rule_Name__c = 'contract_RecordType', Business_Rule_Value__c = 'DH_Contract', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');
            Business_Config__c d23 = new Business_Config__c(Business_Rule_Name__c = 'AddOnRecordType', Business_Rule_Value__c = 'DH_AU_Add_On', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'DH_AU_Opportunity', Type__c = 'Process');

            Business_Config__c d24 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d25 = new Business_Config__c(Business_Rule_Name__c = 'BrandingContentRecordType', Business_Rule_Value__c = 'Yogiyo_Branding_Content', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d26 = new Business_Config__c(Business_Rule_Name__c = 'Asset RecordType', Business_Rule_Value__c = 'Yogiyo_Asset', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d27 = new Business_Config__c(Business_Rule_Name__c = 'TemplateType', Business_Rule_Value__c = 'false', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d28 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'Yogiyo_Additional_Charges', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d29 = new Business_Config__c(Business_Rule_Name__c = 'contract_RecordType', Business_Rule_Value__c = 'Yogiyo_Contract', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');
            Business_Config__c d30 = new Business_Config__c(Business_Rule_Name__c = 'AddOnRecordType', Business_Rule_Value__c = 'Yogiyo_Add_On', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'Yogiyo_Opportunity', Type__c = 'Process');


            Business_Config__c d31 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Successful,Negative=Not Successful', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d32 = new Business_Config__c(Business_Rule_Name__c = 'CreateAsset', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d33 = new Business_Config__c(Business_Rule_Name__c = 'AssetRecordType', Business_Rule_Value__c = 'Yogiyo_Asset', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d34 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'New - Awaiting Shipping', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d35 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Negative', Business_Rule_Value__c = 'StageName=Please correct errors,Probability=90', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d36 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Positive', Business_Rule_Value__c = 'StageName=Closed Won,Probability=100', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d37 = new Business_Config__c(Business_Rule_Name__c = 'SkipForStage', Business_Rule_Value__c = 'Closed Won,Closed Lost', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');
            Business_Config__c d38 = new Business_Config__c(Business_Rule_Name__c = 'CreateBranding', Business_Rule_Value__c = 'true', Id_Country__c = c.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'QualityCheckInternalCaseClosingAction', Record_Type_Id__c = 'UK_Internal_Case', Type__c = 'Process');

            Business_Config__c d39 = new Business_Config__c(Business_Rule_Name__c = 'ClosedReason_Shipment', Business_Rule_Value__c = 'Positive=Successful;Negative=Not Successful', Id_Country__c = c.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'BackendShippingCaseClosure', Record_Type_Id__c = 'CD_Internal_Case,CD_Entry_Case', Type__c = 'Process');
            Business_Config__c d40 = new Business_Config__c(Business_Rule_Name__c = 'ClosedReason_Setup Backend', Business_Rule_Value__c = 'Positive=Take Online;Negative=Not Successful', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackendShippingCaseClosure', Record_Type_Id__c = 'CD_Internal_Case,CD_Entry_Case', Type__c = 'Process');
            Business_Config__c d41 = new Business_Config__c(Business_Rule_Name__c = 'OppStageForPositiveIfBothClosed', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackendShippingCaseClosure', Record_Type_Id__c = 'CD_Internal_Case,CD_Entry_Case', Type__c = 'Process');
            Business_Config__c d42 = new Business_Config__c(Business_Rule_Name__c = 'OppStageForNegative', Business_Rule_Value__c = 'Please Check', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackendShippingCaseClosure', Record_Type_Id__c = 'CD_Internal_Case,CD_Entry_Case', Type__c = 'Process');
            Business_Config__c d43 = new Business_Config__c(Business_Rule_Name__c = 'CheckForTypes', Business_Rule_Value__c = 'Shipment,Setup Backend', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'BackendShippingCaseClosure', Record_Type_Id__c = 'CD_Internal_Case,CD_Entry_Case', Type__c = 'Process');


            Business_Config__c e10 = new Business_Config__c(Business_Rule_Name__c = 'opportunity stage', Business_Rule_Value__c = 'Closed Won', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e11 = new Business_Config__c(Business_Rule_Name__c = 'BrandingContentRecordType', Business_Rule_Value__c = 'CD_Branding_Content', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e12 = new Business_Config__c(Business_Rule_Name__c = 'Asset RecordType', Business_Rule_Value__c = 'CD_Asset', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e13 = new Business_Config__c(Business_Rule_Name__c = 'TemplateType', Business_Rule_Value__c = 'true', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e14 = new Business_Config__c(Business_Rule_Name__c = 'AdditionalCharges RecordType', Business_Rule_Value__c = 'CD_Additional_Charges', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e15 = new Business_Config__c(Business_Rule_Name__c = 'contract_RecordType', Business_Rule_Value__c = 'CD_Contract', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e16 = new Business_Config__c(Business_Rule_Name__c = 'AddOnRecordType', Business_Rule_Value__c = 'CD_Add_On', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');
            Business_Config__c e23 = new Business_Config__c(Business_Rule_Name__c = 'AssetStatus', Business_Rule_Value__c = 'New - Awaiting Shipping', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'Opportunity Contract Process', Record_Type_Id__c = 'CD_Opportunity', Type__c = 'Process');

            Business_Config__c e17 = new Business_Config__c(Business_Rule_Name__c = 'CheckForTypes', Business_Rule_Value__c = 'BE Data Entry', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');
            Business_Config__c e18 = new Business_Config__c(Business_Rule_Name__c = 'OppStageForPositive', Business_Rule_Value__c = 'Closed won', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');
            Business_Config__c e19 = new Business_Config__c(Business_Rule_Name__c = 'brandingTypes', Business_Rule_Value__c = 'Exclusive Special Offer', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');
            Business_Config__c e20 = new Business_Config__c(Business_Rule_Name__c = 'BrandingStatusToExclude', Business_Rule_Value__c = 'Approved,Rejected', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');
            Business_Config__c e21 = new Business_Config__c(Business_Rule_Name__c = 'ClosedReason_BE Data Entry', Business_Rule_Value__c = 'Positive=Take Online', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');
            Business_Config__c e22 = new Business_Config__c(Business_Rule_Name__c = 'checkForOpenBranding', Business_Rule_Value__c = 'true', Id_Country__c = c_cd.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'brandingCaseClosure', Record_Type_Id__c = 'CD_Entry_Case', Type__c = 'Process');


            insert new List<sObject> {v1, v2, greeting_OppQuoteProcess, terminationCaseFlow, terminationCaseFlow2, terminationCaseFlow3, terminationCaseFlow4, terminationCaseFlow5,
                                      terminationCaseFlow6, terminationCaseFlow7, terminationCaseFlow8, terminationCaseFlow9, terminationCaseFlow10, terminationCaseFlow11, terminationCaseFlow12, terminationCaseFlow13, terminationCaseFlow14, terminationCaseFlow15, retentionCaseFlow, retentionCaseFlow2, retentionCaseFlow3, retentionCaseFlow4, retentionCaseFlow5,
                                      retentionCaseFlow6, retentionCaseFlow7, retentionCaseFlow8, retentionCaseFlow9, retentionCaseFlow10, takeOfflineCaseFlow, takeOfflineCaseFlow2, takeOfflineCaseFlow3, takeOfflineCaseFlow4, b1, b2, b3, b4, b5, b6, b7, b11, b12, b13, b14, q1, q2, q3, q4, q5, q6, q7, a1, a2, a3, a4, a5, w1, w2, w3, w4, w5, e1, e2, e3, e4, ba1, ba2, ba3, ba4, bv1, bv2, bv3, bv4,
                                      bv5, bv6, bv7, bv8, bv9, bv10, bv11, bv12, bv13, bv14, bv15, bv16, bv17, bv18, c1, c2, c3, c4, c5, c6, c7, c8, c9, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, d32, d33, d34, d35, d36, d37, d38, d39, d40, d41, d42, d43, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, r11, r12, r13, r14, e23, d117
                                     };
            System.runAs(runningUser) {
                runningUser.CountryCode__c = 'KR;AU;UK';
                runningUser.Company_Name__c = 'Yogiyo;DH_AU;HH';
                update runningUser;
                acc = UnitTestDataFactory.createAccount('TestAccount', c, 'Yogiyo_Account');
                acc_au = UnitTestDataFactory.createAccount('TestAccount', c_au, 'DH_AU_Account');
                acc_uk = UnitTestDataFactory.createAccount('TestAccount', c_uk, 'UK_Account');
                acc_cd = UnitTestDataFactory.createAccount('TestAccount', c_cd, 'CD_Account');
                acc_au.Relay_Method__c = 'Email';
                insert new List<sObject> {acc, acc_au, acc_uk, acc_cd};
                List<Contact> contactList = UnitTestDataFactory.createContacts(new List<Account> {acc}, 'testContact', 'firstname', null, 'owner', 1, 'testCt', 'Yogiyo_Contact');
                insert contactList;
                opp = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
                opp_au = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
                opp_au.type = 'Contract Only';
                insert  new List<sObject> {opp, opp_au};
                opp_uk = UnitTestDataFactory.createOpportunity('TestOpp123', acc_uk, 'UK_Opportunity', Date.today());
                opp_cd = UnitTestDataFactory.createOpportunity('TestOpp123', acc_cd, 'CD_Opportunity', Date.today());

                /* stockListUK= UnitTestDataFactory.createStockItems(4,'UK_Stock_Item',acc_uk,null,'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'UK Telekom', 'In Stock', 'Other');
                  insert stockListUK;
                  assetsUK = UnitTestDataFactory.createAssets(10, acc_uk, opp_uk, Date.today().addDays(-10), true, stockListUK[0], stockListUK[1], 'UK_Asset', '12345674',
                      '1', '1', Date.today(), Date.today(), 'En Route', true, 'New', 'Shared Information', 'Take over Information', 'Activated Successfully',
                      Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
                  insert assetsUK;*/
                insert opp_cd;
                insert opp_uk;



                Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c = opp_uk.id, status__c = 'Draft');
                newQuote.recordtypeid = LibRecordTypeHelper.getRecordTypeValue('UK_Opportunity_Quote');
                newQuote.status__c = 'Accepted';
                insert newQuote;
                Tarif__c t = UnitTestDataFactory.createTarif(com_uk, c_uk , 'Menu Printing', 'UK_Tarif', false);
                insert t;


                List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com_uk, c_uk , 'Apple', 'UK_List_Product_Group');
                List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com_uk, c_uk , 'Menu Printing', 'UK_List_Product_Group');
                insert new List<SObject> {lpg, lpg1};

                List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com_uk, c_uk , 'Menu Printing with website', lpg.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
                List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com_uk, c_uk , 'Menu Printing without website', lpg1.id, 'UK_List_Product_Price', 1, true, 100, 1, false, 20);
                lpp1.product_type__c = 'Menu Printing';
                lpp.product_type__c = 'Menu Printing';
                lpp.Requires_Branding__c = true;
                lpp.Requires_Asset__c = true;
                insert new List<sobject> {lpp1, lpp};
                List<Opportunity_Quote_Line_Item__c> oqp = UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote, lpp.id, lpg.id, 4, true, 'UK_Opportunity_Quote_Line_Item', 1, '20', 200.0, 2, 300.0, 'Product');
                oqp[0].Id_Opportunity__c = opp_uk.id;
                insert oqp;


            }


        }


    }



    @isTest static void nonContractedMenuChange_positive() {
        System.runAs(runningUser) {

            acc.Non_Contracted__c = true;
            update acc;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp.id;
            menuProcessingCase.AccountId = opp.AccountId;
            insert menuProcessingCase;
            menuProcessingCase.status = 'Closed';
            menuProcessingCase.Person_In_Charge__c = 'testUser';
            menuProcessingCase.Menu_Typed_Date__c = Datetime.now();
            menuProcessingCase.Person_in_Charge_Final_Check__c = 'testUser';
            menuProcessingCase.Final_Check_Date__c = Datetime.now();
            menuProcessingCase.Person_In_Charge_Take_Online__c = 'testUser';
            menuProcessingCase.Take_Online_Date__c = Datetime.now();

            opp.Non_Contracted__c = true;
            opp.stageName = 'Closed Won';
            update opp;
            Test.startTest();
            update menuProcessingCase;
            Test.stopTest();
        }
        List<Case> listCase = [select id from case where Opportunity__c = :opp.id and type = 'Convert to Contract'];
        System.assertEquals(listCase.size(), 1);
    }

    @isTest static void terminationCaseFlow_retention_successful() {
        System.runAs(runningUser) {
            Case terminationCase = new Case(
                Type = 'Termination',
                RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id,
                Status = 'New'
            );
            insert terminationCase;

            //terminationCase.Status = 'In retention';
            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Retention';

            Test.startTest();
            update terminationCase;
            Case retentionCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Retention', retentionCase.Type);
            retentionCase.Status = 'Closed';
            retentionCase.Closed_Reason__c = 'Successful';
            update retentionCase;
            Test.stopTest();
            terminationCase = [SELECT Id, IsClosed FROM Case WHERE Id = : terminationCase.Id];
            System.assertEquals(true, terminationCase.IsClosed);

        }
    }

    //also tests takeoffline flow
    @isTest static void terminationCaseFlow_retention_unsuccessful() {
        System.runAs(runningUser) {
            Case terminationCase = new Case(
                Type = 'Termination',
                RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id,
                Status = 'New'
            );
            insert terminationCase;

            //terminationCase.Status = 'In retention';
            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Retention';

            Test.startTest();
            update terminationCase;
            Case retentionCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Retention', retentionCase.Type);
            retentionCase.Status = 'Closed';
            retentionCase.Closed_Reason__c = 'Not Successful';
            update retentionCase;
            Case takeOfflineCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id AND Type = 'Take Offline'];
            takeOfflineCase.Status = 'Closed';
            takeOfflineCase.Closed_Reason__c = 'Successful';
            update takeOfflineCase;
            Test.stopTest();

            terminationCase = [SELECT Id, IsClosed FROM Case WHERE Id = : terminationCase.Id];
            System.assertEquals(true, terminationCase.IsClosed);


        }
    }

    @isTest static void terminationCaseFlow_takeOffline_successful() {
        System.runAs(runningUser) {
            Case terminationCase = new Case(
                Type = 'Termination',
                RecordTypeId = mapRecordtypes.get('DH_AU_Inbound').id,
                Status = 'New'
            );
            insert terminationCase;

            terminationCase.Status = 'Closed';
            terminationCase.Closed_Reason__c = 'Take Offline';

            Test.startTest();
            update terminationCase;
            Case takeOfflineCase = [SELECT Id, ParentId, Type, Status, Closed_Reason__c FROM Case WHERE ParentId = : terminationCase.Id];
            System.assertEquals('Take Offline', takeOfflineCase.Type);
            takeOfflineCase.Status = 'Closed';
            takeOfflineCase.Closed_Reason__c = 'Successful';
            update takeOfflineCase;
            Test.stopTest();
        }
    }

    @isTest static void MenuProcessingClosingAction_Positive() {
        System.runAs(runningUser) {
            //try{
            //insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            insert opp_au1;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online';
            Test.startTest();
            System.debug('$$$ menuProcessingCase ' + menuProcessingCase);
            update menuProcessingCase;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            // System.assertEquals(result.stageName,'Closed Won');
            /*}catch(Exception e){
                System.debug('Exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            }*/


        }

    }


    @isTest static void MenuProcessingClosingAction_Positive2() {

        System.runAs(runningUser) {
            //try{
            //insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            insert opp_au1;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online is not possible';
            Test.startTest();
            update menuProcessingCase;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertEquals(result.stageName, 'Please Check');


            /*}catch(Exception e){
                System.debug('Exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            }*/
        }
    }

    @isTest static void MenuProcessingClosingAction_Negative() {


        System.runAs(runningUser) {
            //try{
            //insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            insert opp_au1;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online is not possible';
            Test.startTest();
            update menuProcessingCase;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp_au1.id];
            System.assertNotEquals(result.stageName, 'Closed Won');
            /*}catch(Exception e){
                System.debug('Exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            }*/
        }
    }

    @isTest static void NonContractedMPClosingAction_Positive() {

        System.runAs(runningUser) {
            //insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            //try{
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            opp1.Non_Contracted__c = true;
            Test.startTest();
            insert opp1;
            //Case menuProcessingCase = [select id,Status,Closed_Reason__c from Case where Opportunity__c=:opp1.id and type='Menu Processing' limit 1];
            Case menuProcessingCase = new Case(Opportunity__c = opp1.id, type = 'Menu Processing', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id);
            insert menuProcessingCase ;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online';
            menuProcessingCase.Person_In_Charge__c = 'A';
            menuProcessingCase.Menu_Typed_Date__c = Date.today();
            menuProcessingCase.Person_in_Charge_Final_Check__c = 'B';
            menuProcessingCase.Final_Check_Date__c = Date.today();
            menuProcessingCase.Person_In_Charge_Take_Online__c = 'C';
            menuProcessingCase.Take_Online_Date__c = Date.today();
            update menuProcessingCase;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Call - Reached');
            /*}catch(Exception e){
                System.debug('Exception ' + e.getMessage() + ' ' + e.getStackTraceString());
            }*/
        }
    }

    @isTest static void NonContractedMPClosingAction_Negative() {
        //Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='Closed_Positive',Business_Rule_Value__c='StageName=Closed Won,Probability=100',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=true,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        //Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Closed_Reason__c',Business_Rule_Value__c='Positive=Take Online,Negative=Take Online is not possible',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        //Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Check for Is_Tested__c',Business_Rule_Value__c='true',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        //Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Closed_Negative',Business_Rule_Value__c='StageName=Please Check,Probability=0',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        //Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');
        //Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='SkipForStage',Business_Rule_Value__c='Closed Won,Closed Lost',Id_Country__c=c_au.id,Is_Active__c=true,Parent__c=false,Process_Name__c='MenuProcessingClosingAction',Record_Type_Id__c='DH_AU_Entry_Case',Type__c='Process');


        System.runAs(runningUser) {
            //insert new List<sObject>{b1,b2,b3,b4,b5,b6};
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            opp1.Non_Contracted__c = true;
            opp1.StageName = 'Non Contracted';
            opp1.probability = 30;
            insert opp1;
            //Case menuProcessingCase = [select id,Status,Closed_Reason__c from Case where Opportunity__c=:opp1.id and type='Menu Processing' limit 1];
            Case menuProcessingCase = new Case(Opportunity__c = opp1.id, type = 'Menu Processing', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Entry_Case').id);
            insert menuProcessingCase ;
            menuProcessingCase.Status = 'Closed';
            menuProcessingCase.Closed_Reason__c = 'Take Online is not possible';
            menuProcessingCase.root_cause__c = 'other';
            Test.startTest();
            update menuProcessingCase;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Closed Lost');
        }
    }

    @isTest static void QualityCheckClosingAction_Positive() {
        System.runAs(runningUser) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';
            update cs;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Closed Won');
        }
    }
    @isTest static void QualityCheckClosingAction_Negative() {
        System.runAs(runningUser) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'Yogiyo_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('Yogiyo_Internal_Case').id);
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Not Successful';
            update cs;
            Test.stopTest();
            Opportunity result = [select id, stageName from Opportunity where id = :opp1.id];
            System.assertEquals(result.stageName, 'Please correct errors');
        }
    }

    @isTest static void BEAccountCreation_Positive() {
        System.runAs(runningUser) {
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            opp_au1.Business_Type__c = 'New';
            insert opp_au1;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            //menuProcessingCase.status = 'In Progress';

            Test.startTest();
            insert menuProcessingCase;
            Test.stopTest();
            List<Case> caseList = [select id from Case where type = 'Create Backend Id' and subject = 'BE Account Creation'];
            System.assertEquals(caseList.size(), 1);
        }
    }


    @isTest static void BEAccountCreation_Positive2() {
        System.runAs(runningUser) {
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.probability = 95;
            opp_au1.Business_Type__c = 'Upgrade';
            insert opp_au1;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            Test.startTest();
            insert menuProcessingCase;
            Test.stopTest();
            List<Case> caseList = [select id from Case where type = 'Create Backend Id' and subject = 'BE Account Creation'];
            System.assertEquals(caseList.size(), 0);
        }
    }


    @isTest static void MenuTyping_Positive() {
        System.runAs(runningUser) {
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.Type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.Probability = 95;
            opp_au1.Business_Type__c = 'New';
            insert opp_au1;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;
            List<Case> caseList = [select id, status, Closed_Reason__c from Case where type = 'Create Backend Id' and subject = 'BE Account Creation'];
            caseList[0].status = 'Closed';
            caseList[0].Closed_Reason__c = 'Successful';
            Test.startTest();
            update caseList[0];
            Test.stopTest();
            List<Case> caseList1 = [select id from Case where type = 'Menu Typing' and subject = 'Menu Typing'];
            System.assertEquals(caseList1.size(), 1);
        }
    }


    @isTest static void menuTypingCaseClosingAction_Positive() {
        System.runAs(runningUser) {
            //try{
            Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
            opp_au1.Type = 'Contract Only';
            opp_au1.StageName = 'Editorial Queue';
            opp_au1.Probability = 95;
            opp_au1.Business_Type__c = 'New';
            insert opp_au1;
            Account updateAccount = new Account(Id = opp_au1.AccountId, Is_Tested__c = true);
            update updateAccount;
            Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
            menuProcessingCase.Opportunity__c = opp_au1.id;
            menuProcessingCase.AccountId = opp_au1.AccountId;
            insert menuProcessingCase;
            List<Case> caseList = [select id, status, Closed_Reason__c from Case where type = 'Create Backend Id' and subject = 'BE Account Creation'];
            caseList[0].status = 'Closed';
            caseList[0].Closed_Reason__c = 'Successful';
            update caseList[0];
            List<Case> caseList1 = [select id, status, Closed_Reason__c from Case where type = 'Menu Typing' and subject = 'Menu Typing'];
            caseList1[0].status = 'Closed';
            caseList1[0].Closed_Reason__c = 'Successful';
            Test.startTest();
            update caseList1[0];
            Test.stopTest();
            List<Case> caseList2 = [select id, status from Case where type = 'Menu Processing' and id = :menuProcessingCase.id];
            //System.assertEquals(caseList2[0].status,'Final Check');
            /*}catch(Exception e){
                System.debug('Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
            } */
        }
    }

    //@isTest static void menuProcessingStatusUpdateValidation_Positive(){
    //    System.runAs(runningUser){
    //        Opportunity opp_au1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc_au,'DH_AU_Opportunity',Date.today());
    //        opp_au1.Type='Contract Only';
    //        opp_au1.StageName = 'Editorial Queue';
    //        opp_au1.Probability = 95;
    //        opp_au1.Business_Type__c = 'New';
    //        insert opp_au1;
    //        Account updateAccount = new Account(Id=opp_au1.AccountId, Is_Tested__c=true);
    //        update updateAccount;
    //        Case menuProcessingCase = new Case(Type='Menu Processing',Subject='Menu Processing',RecordTypeId=mapRecordtypes.get('DH_AU_Entry_Case').id ,Status='New');
    //        menuProcessingCase.Opportunity__c = opp_au1.id;
    //        menuProcessingCase.AccountId = opp_au1.AccountId;
    //        insert menuProcessingCase;

    //        List<Case> caseList = [select id,status,Closed_Reason__c from Case where type='Create Backend Id' and subject='BE Account Creation'];
    //        caseList[0].status='Please correct Errors';
    //        update caseList[0];
    //        caseList[0].status = 'Closed';
    //        caseList[0].Closed_Reason__c = 'Successful';
    //        update caseList[0];
    //        Test.startTest();
    //        menuProcessingCase.status = 'Closed';
    //        menuProcessingCase.closed_reason__c = 'Take Online';
    //        try{
    //            update menuProcessingCase;
    //        }catch(Exception e){
    //            System.assert(e.getMessage().contains(Label.menu_processing_status_update_validation));
    //        }
    //        Test.stopTest();

    //    }
    //}

    @isTest static void restaurantCareClosingAction_Positive() {
        System.runAs(runningAdminUser ) {


            Case resCare = new Case(Type = 'Onboarding', Subject = 'Onboarding', RecordTypeId = mapRecordtypes.get('UK_Restaurant_Operations').id , Status = 'New');
            resCare.Opportunity__c = opp_uk.id;
            resCare.AccountId = opp_uk.AccountId;
            insert resCare;
            opp_uk.stagename = 'Onboarding';
            update opp_uk;
            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            resCare.status = 'Closed';
            resCare.Closed_Reason__c = 'Successful';
            Test.startTest();
            update resCare;
            Test.stopTest();


            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }

    @isTest static void menutypeage() {
        System.runAs(runningAdminUser ) {


            Case cs = new Case(Type = 'Menu Processing', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Entry_Case').id , Status = 'Menu Typing');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;

            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Final Check';
            cs.menu_typed_date__C = system.now();
            cs.First_Check_Date__c = system.now();

            update cs;
            Test.startTest();

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }

    @isTest static void menutypeageMenuChange() {
        System.runAs(runningAdminUser ) {


            Case cs = new Case(Type = 'Menu Change', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Entry_Case').id , Status = 'Menu Typing');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;
            cs.menu_change_date__C = system.now();
            update cs;
            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Final Check';
            cs.menu_typed_date__C = system.now();

            update cs;
            Test.startTest();

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }
    @isTest static void premiumPlacementCaseUK() {
        System.runAs(runningAdminUser ) {

            Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
            Case cs = new Case(Type = 'Sales Task', Subject = 'test', RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id , Status = 'New' , case_reason__c = 'Premium Placement');
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            Test.startTest();
            insert cs;

            // assetsUK[0].status__c='Activated Successfully';
            //assetsUK[0].opportunity__C=opp_uk.id;
            cs.status = 'Closed';
            cs.closed_reason__c = 'Successful';
            cs.menu_typed_date__C = system.now();
            cs.Root_Cause__c = 'test';

            update cs;
            Test.stopTest();
            //

            //List<Opportunity> result = [select id, stageName from Opportunity where id =: resCare.Opportunity__c];
            //System.assertEquals(result[0].stageName,'Closed Won');

        }
    }
    @isTest static void qualityCheckReplacementClosingAction_positive() {
        System.runAs(runningAdminUser ) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'UK_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check Replacement', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);

            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';

            update cs;
            Test.stopTest();

        }
    }
    @isTest static void qualityCheckReplacementClosingAction_negative() {
        System.runAs(runningAdminUser ) {
            Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123', acc, 'UK_Opportunity', Date.today());
            opp1.type = 'Contract Only';
            Test.startTest();
            insert opp1;
            Case cs = new Case(Opportunity__c = opp1.id, type = 'Quality Check Replacement', AccountId = acc.id, RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);

            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Not Successful';
            update cs;
            Test.stopTest();

        }
    }
    @isTest static void qualityCheckCreateBranding_positive() {
        System.runAs(runningAdminUser ) {
            // Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
            // opp1.type='Contract Only';

            Test.startTest();
            //insert opp1;
            opp_uk.Business_Type__c = 'New Business';
            update opp_uk;
            Case cs = new Case(type = 'Quality Check', RecordTypeId = mapRecordtypes.get('UK_Internal_Case').id);
            cs.Opportunity__c = opp_uk.id;
            cs.AccountId = opp_uk.AccountId;
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';
            update cs;
            Test.stopTest();

        }
    }
    @isTest static void marketingShipping_positive() {
        System.runAs(runningAdminUser ) {
            // Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
            // opp1.type='Contract Only';
            opp_cd.business_type__C = 'New Business';
            update opp_cd;

            Test.startTest();

            //insert opp1;
            Case cs = new Case(type = 'Shipment', RecordTypeId = mapRecordtypes.get('CD_Internal_Case').id);
            cs.Opportunity__c = opp_cd.id;
            cs.AccountId = opp_cd.AccountId;
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Successful';
            update cs;
            Test.stopTest();

        }
    }

    @isTest static void brandingCase_positive() {
        System.runAs(runningAdminUser ) {
            // Opportunity opp1 = UnitTestDataFactory.createOpportunity('TestOpp123',acc,'UK_Opportunity',Date.today());
            // opp1.type='Contract Only';
            opp_cd.business_type__C = 'New Business';
            update opp_cd;

            Test.startTest();
            //insert opp1;
            Case cs = new Case(type = 'BE Data Entry', RecordTypeId = mapRecordtypes.get('CD_Entry_Case').id);
            cs.Opportunity__c = opp_cd.id;
            cs.AccountId = opp_cd.AccountId;
            insert cs;
            cs.Status = 'Closed';
            cs.Closed_Reason__c = 'Take Online';
            update cs;
            Test.stopTest();

        }
    }





}