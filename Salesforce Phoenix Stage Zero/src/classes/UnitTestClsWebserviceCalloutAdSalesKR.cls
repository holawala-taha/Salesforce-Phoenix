@isTest
private class UnitTestClsWebserviceCalloutAdSalesKR {

	private static User testUser_kr = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyotestuser@test.com', 'Yogiyo','KR');
	private static Country__c testCountry_kr;
	private static Company__c testCompany_kr;


	//KR testdata
    static {
    	insert testUser_kr;
    	System.runAs(testUser_kr){
    		testCountry_kr = UnitTestDataFactory.createCountry('KR','Korea','KRW');
			insert testCountry_kr;

			testCompany_kr = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry_kr);
			insert testCompany_kr;

			testUser_kr.CountryCode__c = 'KR';
			testUser_kr.Company_Name__c = 'Yogiyo';
			update testUser_kr;

			Business_Config__c b1_kr = new Business_Config__c(Business_Rule_Name__c='baseURL',Business_Rule_Value__c='https://www.yogiyo.co.kr/salesforce/restaurant/',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c b2_kr = new Business_Config__c(Business_Rule_Name__c='endpointURL',Business_Rule_Value__c='/available_districts_and_categories/',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c b3_kr = new Business_Config__c(Business_Rule_Name__c='apiKey',Business_Rule_Value__c='salesforce',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c b4_kr = new Business_Config__c(Business_Rule_Name__c='secret',Business_Rule_Value__c='23752ba30a8811e5a0b434363bd33456',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='AdSalesIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');

			Business_Config__c c1_kr = new Business_Config__c(Business_Rule_Name__c='baseURL',Business_Rule_Value__c='https://www.yogiyo.co.kr/salesforce/restaurant/',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=true,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c c2_kr = new Business_Config__c(Business_Rule_Name__c='endpointURL',Business_Rule_Value__c='/zero_commission/',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c c3_kr = new Business_Config__c(Business_Rule_Name__c='apiKey',Business_Rule_Value__c='salesforce',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
			Business_Config__c c4_kr = new Business_Config__c(Business_Rule_Name__c='secret',Business_Rule_Value__c='23752ba30a8811e5a0b434363bd33456',Id_Country__c=testCountry_kr.Id,Is_Active__c=true,Parent__c=false,Process_Name__c='FixedAmountCommissionIntegration',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');

			insert new List<sObject>{b1_kr,b2_kr,b3_kr,b4_kr,c1_kr,c2_kr,c3_kr,c4_kr};

    	}
    }
    @isTest static void getFixAmountCommissionDistricts_Pass(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());
        
        FixedCommissionWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getFixAmountCommissionDistricts('4712');
        
        Test.stopTest();
        
        System.assertNotEquals(null, wrapper.mapCategories);
        System.assertNotEquals(null, wrapper.mapDistricts);
        System.assertNotEquals(null, wrapper.mapDistrictPrices);
    }
	
	@isTest static void getAvailableDistrictsAndCategories_Pass() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0815');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.debug('wrapper.mapCategories: '+wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);


	}

	@isTest static void getAvailableDistrictsAndCategories_Pass_Decimal_Amounts() {

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0816');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.debug('wrapper.mapCategories: '+wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(50000.00, wrapper.mapDistrictPrices.get('Super-4006'));


	}
	
	@isTest static void getAvailableDistrictsAndCategories_Fail() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('4711');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKR404,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_Incomplete() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0021');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKRIncomplete,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_Incomplete_null() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0022');

		Test.stopTest();

		System.assertEquals(true,wrapper.errorFlag);
		System.assertEquals(Label.AdSalesKRException,wrapper.errorMessage);
		
	}

	@isTest static void getAvailableDistrictsAndCategories_no_basic_category() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0023');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(null, wrapper.mapDistrictPrices.get('Basic-4006'));
		System.assertEquals(50000,wrapper.mapDistrictPrices.get('Super-4006'));
		
	}

	@isTest static void getAvailableDistrictsAndCategories_no_super_category() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new UnitTestMockWebserviceAdSalesKR());

		DistrictPriceCategoryWrapper wrapper = ClsWebserviceCalloutAdSalesKR.getAvailableDistrictsAndCategories('0024');

		Test.stopTest();

		System.assertEquals(false,wrapper.errorFlag);
		System.assertNotEquals(null, wrapper.mapCategories);
		System.assertNotEquals(null, wrapper.mapDistricts);
		System.assertNotEquals(null, wrapper.mapDistrictPrices);
		System.assertNotEquals(null, wrapper.mapTypeDistricts);

		System.assertEquals(30000, wrapper.mapDistrictPrices.get('Basic-4006'));
		System.assertEquals(null,wrapper.mapDistrictPrices.get('Super-4006'));
		
	}
	
}