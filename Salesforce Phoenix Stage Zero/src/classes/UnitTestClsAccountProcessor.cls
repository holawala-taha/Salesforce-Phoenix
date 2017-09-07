@isTest
private class UnitTestClsAccountProcessor {
    /* old code */
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc_au;
    private static Country__c c_au;

    static void postSetup() {
        acc_au = [select Name,
                  Record_Country__c,
                  RecordtypeId,
                  CurrencyIsoCode,
                  Relay_Method__c from Account Where Recordtype.DeveloperName = 'DH_AU_Account' limit 1];

        c_au = [select Iso__c, Name, CurrencyIsoCode From Country__c Where Iso__c = 'AU' limit 1];
    }

    @isTest static void menuProcessingClosingAction_Positive() {
        postSetup();
        Case menuProcessingCase;
        Opportunity opp_au;
        //try{
        opp_au = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
        opp_au.Type = 'Contract & Product';
        opp_au.StageName = 'Editorial Queue';
        opp_au.probability = 95;
        insert  new List<sObject> {opp_au};
        menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
        menuProcessingCase.Opportunity__c = opp_au.id;
        menuProcessingCase.AccountId = opp_au.AccountId;
        insert menuProcessingCase;

        menuProcessingCase.Status = 'Closed';
        menuProcessingCase.Closed_Reason__c = 'Take Online';
        System.debug('menuProcessingCase ' + menuProcessingCase);
        update menuProcessingCase;
        Account updateAccount = new Account(Id = opp_au.AccountId, Is_Tested__c = true);
        Test.startTest();
        update updateAccount;
        Test.stopTest();
        Opportunity result = [select id, stageName from Opportunity where id = :opp_au.id];
        System.assertEquals(result.stageName, 'Closed Won');
        /*}catch(Exception e){
            System.debug('Exception ' + e.getMessage());
            System.debug('Exception ' + e.getCause());
            System.debug('Exception ' + e.getStackTraceString());

        }*/
    }

    @isTest static void menuProcessingClosingAction_Negative() {
        //try{
        postSetup();
        Opportunity opp_au = UnitTestDataFactory.createOpportunity('TestOpp123', acc_au, 'DH_AU_Opportunity', Date.today());
        opp_au.Type = 'Contract & Product';
        opp_au.StageName = 'Editorial Queue';
        opp_au.probability = 95;
        insert  new List<sObject> {opp_au};
        Case menuProcessingCase = new Case(Type = 'Menu Processing', Subject = 'Menu Processing', RecordTypeId = mapRecordtypes.get('DH_AU_Entry_Case').id , Status = 'New');
        menuProcessingCase.Opportunity__c = opp_au.id;
        menuProcessingCase.AccountId = opp_au.AccountId;
        insert menuProcessingCase;
        menuProcessingCase.Status = 'Closed';
        menuProcessingCase.Closed_Reason__c = 'Take Online is not possible';

        update menuProcessingCase;
        Account updateAccount = new Account(Id = opp_au.AccountId, Is_Tested__c = false);
        Test.startTest();
        update updateAccount;
        Test.stopTest();
        Opportunity result = [select id, stageName from Opportunity where id = :opp_au.id];
        System.assertNotEquals(result.stageName, 'Closed Won');
        /*}catch(Exception e){
            System.debug('Exception ' + e.getMessage());
            System.debug('Exception ' + e.getCause());
            System.debug('Exception ' + e.getStackTraceString());
        }*/
    }
    /* old code end*/

    /* test restrict city values */

    @testSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        c_au = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        Company__c com_au = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', c_au);
        insert new List<sObject> {c, c_au, com, com_au};

        acc_au = UnitTestDataFactory.createAccount('TestAccount', c_au, 'DH_AU_Account');
        insert new List<sObject> {acc_au};

        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Positive', Business_Rule_Value__c = 'StageName=Closed Won,Probability=100', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Reason__c', Business_Rule_Value__c = 'Positive=Take Online;Negative=Take Online is not possible,Invalid,Duplicate', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'Check for Is_Tested__c', Business_Rule_Value__c = 'true', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c = 'Closed_Negative', Business_Rule_Value__c = 'StageName=Please Check,Probability=0', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c = 'StageName', Business_Rule_Value__c = 'Editorial Queue', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c = 'SkipForStage', Business_Rule_Value__c = 'Closed Won,Closed Lost', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c = 'ChildCaseTypes', Business_Rule_Value__c = 'Create Backend Id,Menu Typing', Id_Country__c = c_au.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'MenuProcessingClosingAction', Record_Type_Id__c = 'DH_AU_Entry_Case', Type__c = 'Process');

        insert new List<sObject> {b1, b2, b3, b4, b5, b6, b7};

        Country__c it = UnitTestDataFactory.createCountry('IT', 'Italia', 'EUR');
        insert it;

        Account cdAccount = UnitTestDataFactory.createAccount('CD Account', it, 'CD_Account');
        cdAccount.BillingCity = 'Napoli';
        insert cdAccount;

        List<Business_Config__c> configs = new List<Business_Config__c>();

        configs.add(
            UnitTestDataFactory.createBusinessConfig(
                'RestrictBillingAndMailingCityValues',
                'Process',
                'checkBillingAndMailingCity',
                'true',
                it.id,
                'CD_Account',
                true,
                true)
        );

        insert configs;

        BEIntegration_CountriesToCities__c cs = new BEIntegration_CountriesToCities__c(
            Name = 'Napoli', Country_Code__c = 'IT');
        insert cs;

        BEIntegration_CountriesToCities__c cs2 = new BEIntegration_CountriesToCities__c(
            Name = 'Roma', Country_Code__c = 'IT');
        insert cs2;
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBusinessConfigNotExists() {

        delete [select id from Business_Config__c];

        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'Not Exist';
        update acc;

        Test.stopTest();

    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBillingCityIsNotChanged() {
        Account acc = [Select BillingCity, Name From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.name = 'new name';
        update acc;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBillingCityIsBlank() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = '';
        update acc;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesFilterCorrectlyByRecordType() {
        Country__c c = [select name, iso__c , currencyIsoCode from country__c where name = 'Italia' limit 1];

        Account a = UnitTestDataFactory.createAccount('Test', c, 'UK_Account');
        a.BillingCity = 'not exist';

        Test.startTest();

        insert a;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfRuleIsNotActive() {
        Business_Config__c rule = [Select Business_Rule_Value__c From Business_Config__c Where Process_Name__c = 'RestrictBillingAndMailingCityValues' limit 1];
        rule.Business_Rule_Value__c = 'false';
        update rule;

        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'not exist';
        update acc;

        Test.stopTest();
    }


    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfCityIsValid() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'Roma';

        Test.stopTest();
    }


    @isTest static void checksBillingAndMailingCityValuesAddErrorToRecordIfCityIsNotValid() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        DataBase.SaveResult res;

        Test.startTest();

        acc.BillingCity = 'notexist';

        res = Database.update(acc, false);

        Test.stopTest();

        System.assert(!res.isSuccess());
    }
}