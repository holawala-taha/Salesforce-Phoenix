@isTest
private class UnitTestTrgQuoteProcessor {

    static List<Opportunity> oppList;
    static Country__c testCountry;

    @testSetup static void setup() {
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
    }

    static void setupUserData(User u) {
        System.runAs(u) {

            testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert testCountry;
            Business_Config__c c =  UnitTestDataFactory.createBusinessConfig('Quote is won process', 'Trigger', null, null, testCountry.id, null, true, true);
            Business_Config__c b = UnitTestDataFactory.createBusinessConfig('Quote Accept Process', 'Process', 'set opportunity stage', '100% Closed', testCountry.id, 'Yogiyo_Opportunity', true, true);
            Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c = 'Status__c', Business_Rule_Value__c = 'Accepted', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = true, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');
            Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c = 'Product Only', Business_Rule_Value__c = 'stageName=Terminals Queue,Probability=95', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');
            Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c = 'Contract & Product', Business_Rule_Value__c = 'stageName=Menu Received,Probability=90', Id_Country__c = testCountry.id, Is_Active__c = true, Parent__c = false, Process_Name__c = 'OppTypeAndStageProcess', Record_Type_Id__c = 'Yogiyo_Opportunity_Quote', Type__c = 'Process');



            insert new List<sObject> {c, b, b1, b2, b3};
            List<Account> accList = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            insert accList;
            oppList = UnitTestDataFactory.createOpportunities(accList, 1, 'Yogiyo_Opportunity', Date.today());
            insert oppList;

        }
    }

    @isTest static void test_QuoteProcess_positive() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryherotest.com', 'Yogiyo', 'KR');
        List<Opportunity_Quote__c> oppQuoteList;

        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
            oppQuoteList.addAll(UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data1', 101.45, 101.45, '', '', 0));
            System.debug('oppQuoteList: ' + oppQuoteList);
            insert oppQuoteList;
            oppQuoteList[0].Status__c = 'Accepted';
            update oppQuoteList[0];
        }
        Test.stopTest();
        Opportunity_Quote__c result = [Select id, status__c from Opportunity_Quote__c where id = :oppQuoteList[1].id];
        System.assertEquals(result.status__c, 'Declined');

    }

    @isTest static void test_QuoteProcess_negative() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'testUser@deliveryherotest.com', 'Yogiyo', 'KR');
        List<Opportunity_Quote__c> oppQuoteList ;
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            oppQuoteList = UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data', 100.45, 100.45, '', '', 0);
            oppQuoteList.addAll(UnitTestDataFactory.createOpportunityQuotes(oppList[0], 1, 'Yogiyo_Opportunity_Quote', 'Draft', 'test data1', 101.45, 101.45, '', '', 0));

            System.debug('oppQuoteList: ' + oppQuoteList);
            insert oppQuoteList;
            oppQuoteList[0].Status__c = 'Declined';
            update oppQuoteList[0];
        }
        Test.stopTest();
        Opportunity_Quote__c result = [Select id, status__c from Opportunity_Quote__c where id = :oppQuoteList[1].id];
        System.assertEquals(result.status__c, 'Draft');
    }


}