@isTest
private class UnitTestLibBusinessConfig {
    private static User testUser;
    private static Country__c country;
    private static Company__c company;
    private static List<Account> accts;
    private static List<Lead> leads;
    private static Business_Config__c configTrigger;
    private static Business_Config__c configProcess;

    static {
        testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'yogiyouser@test.com', 'Yogiyo', 'KR');
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        UnitTestDataFactory.getRecordtypeValues();
        System.runAs(testUser){
            country = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            insert country;

            company = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', country);
            company.CurrencyIsoCode = country.CurrencyIsoCode;
            insert company;

            leads = UnitTestDataFactory.createLeads(201, country, 'Test Lead','Test Company', 'KRW', 'Test Burgers - Not for eating', 'Yogiyo_Lead');
            //insert leads;
            /*accts = UnitTestDataFactory.createAccounts(201, country, 'Yogiyo_Account');
            insert accts;*/
            configTrigger = UnitTestDataFactory.createBusinessConfig('Test Trigger', 'Trigger', 'Test Rule', 'Test Value', country.Id, 'Yogiyo_Account', true, true);
            configProcess = UnitTestDataFactory.createBusinessConfig('Test Process', 'Process', 'Test Rule', 'Test Value', country.Id, 'Yogiyo_Account', true, true);

            TLB_Approval_Matrix__c approvalSetting_level1 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'Level1',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    
                                                                                    Notification__c = true,
                                                                                    Role__c = 'HOS'
                                                                                    
                                                                                    );

            TLB_Approval_Matrix__c approvalSetting_level2 = new TLB_Approval_Matrix__c(
                                                                                    Name = 'Level2',
                                                                                    CountryName__c = 'Arab Emirates',
                                                                                    
                                                                                    Notification__c = true,
                                                                                    Role__c = 'Legal'
                                                                                    
                                                                                    );

            insert new List<sObject>{approvalSetting_level2,approvalSetting_level1};

            //RecortType rt = new RecortType(DeveloperName = 'Yogiyo_Lead');
        }
    }

    @isTest static void test_determineApproverMap(){
        Map<String,TLB_Approval_Matrix__c> mapApprovalEntry;
        Test.startTest();

        System.runas(testUser){
           // mapApprovalEntry = LibBusinessConfig.determineApproverMap('Arab Emirates', 1);
           //List<string> email=LibBusinessConfig.getCountryHOSEmailId('Arab Emirates');
           LibBusinessConfig.getGenericProcessDataList();
            

        }

        Test.stopTest();

        //System.assert(!mapApprovalEntry.isEmpty());
    }

    @isTest static void test_determineApprover(){
        TLB_Approval_Matrix__c approvalEntry;
        Test.startTest();

        System.runas(testUser){
           // approvalEntry = LibBusinessConfig.determineApprover('Arab Emirates', 1);
        }

        Test.stopTest();

       // System.assertNotEquals(null,approvalEntry);
    }


    @isTest static void test_setCountryLookUp() {
        
        Test.startTest();

        System.assertEquals(null, leads[0].Country__c);

        System.runAs(testUser){
            insert leads;
        }

        Test.stopTest();

        Lead testLead = [SELECT Id, Name, Country__c FROM Lead WHERE id = :leads[0].Id];
        System.assertEquals(country.Id, testLead.Country__c);
    }
    
    @isTest static void test_isTriggerActive() {
        Test.startTest();

        System.assertEquals(null, LibBusinessConfig.isTriggerActive('Test Trigger'));

        System.runAs(testUser){
            insert configTrigger;
        }

        Test.stopTest();
        System.assertEquals(true, LibBusinessConfig.isTriggerActive('Test Trigger'));
    }
    
    @isTest static void test_getGenericProcessData(){
        Test.startTest();

        System.runAs(testUser){
            insert configTrigger;
            System.assertEquals(new Map<String,Map<String,Business_Config__c>>(), LibBusinessConfig.getGenericProcessData('Test Process'));

            insert configProcess;
            System.assertEquals('Test Value', LibBusinessConfig.getGenericProcessData('Test Process').get('Yogiyo_Account').get('Test Rule').Business_Rule_Value__c);

            Map<String, Map<String,Map<String,Business_Config__c>> > result = LibBusinessConfig.motherOfAllBusinessMaps;
        }

        Test.stopTest();
    }

    @isTest static void test_getRecordTypeToRecordTypeAssignment(){
        Test.startTest();

        System.runAs(testUser){
            insert configProcess;
            System.assertEquals('Test Value', LibBusinessConfig.getRecordTypeToRecordTypeAssignment('Test Process').get('Test Rule'));
        }

        Test.stopTest();
    }

    @isTest static void test_getGerenericProcessDataWithCountry(){
        Test.startTest();

        System.runAs(testUser){
            insert configProcess;
            System.assertEquals('Test Value', LibBusinessConfig.getGerenericProcessDataWithCountry('Test Process').get('KR').get('Test Rule').Business_Rule_Value__c);
        }

        Test.stopTest();
    }

    @isTest static void test_getUserCompanies(){
        Test.startTest();

        System.runAs(testUser){
            System.debug('@@@@ calling test_getUserCompanies : ' + LibBusinessConfig.getUserCompanies());
            System.assertEquals(1, LibBusinessConfig.getUserCompanies().size());
            System.assertEquals('Yogiyo', LibBusinessConfig.getUserCompanies()[0].Name);
        }

        Test.stopTest();
    }

    @isTest static void test_getUserCountries(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals(1, LibBusinessConfig.getUserCountries().size());
            System.assertEquals('Korea', LibBusinessConfig.getUserCountries()[0].Name);
        }

        Test.stopTest();
    }

    @isTest static void test_getRecordTypeDevName(){
        Test.startTest();

        System.runAs(testUser){
            insert leads;
            System.assertEquals('Yogiyo_Lead', LibBusinessConfig.getRecordTypeDevName(leads[0], 'Lead'));
        }

        Test.stopTest();
    }

    @isTest static void test_determineCompany(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals('Yogiyo', LibBusinessConfig.determineCompany('Yogiyo_Account'));
            System.assertEquals('DH_AU', LibBusinessConfig.determineCompany('DH_AU_Account'));
        }

        Test.stopTest();
    }

    @isTest static void test_recordCurrencyMap(){
        Test.startTest();

        System.runAs(testUser){
            System.assertEquals('KRW', LibBusinessConfig.recordCurrencyMap().get('Korea'));
        }

        Test.stopTest();
    }
}