/**
 * Created by marco.zeuli on 25/8/2017.
 */

@IsTest
private class UnitTestCtrCreateNewAddress {
	static final String testPostCode = 'Test_Scenario_PostCode';
	static final String testAdminArea = 'Test_Scenario_AdminArea';
	static final String testAdminAreaLabel = 'Test Scenario AdminArea';
	static final String testLocality = 'Test_Scenario_Locality';
	static final String testSubArea = 'Test_Scenario_SubArea';
	static final String testCountry = 'Test_Scenario_Country';
	static final String testCountryLabel = 'Test Scenario Country';
	static final String testDependentLocality = 'Test_Scenario_DependentLocality';

	static final xAL_Country__mdt country = [
			SELECT DeveloperName, MasterLabel, Code__c
			FROM xAL_Country__mdt
			WHERE DeveloperName = :testCountry
	];

	static final xAL_AdministrativeArea__mdt area = [
			SELECT DeveloperName, MasterLabel, Type__c, Code__c
			FROM xAL_AdministrativeArea__mdt
			WHERE DeveloperName = :testAdminArea
	];

	static final xAL_SubAdministrativeAreas__mdt subArea = [
			SELECT DeveloperName, MasterLabel, Type__c, Code__c
			FROM xAL_SubAdministrativeAreas__mdt
			WHERE DeveloperName = :testSubArea
	];

	static final xAL_Locality__mdt locality = [
			SELECT DeveloperName, MasterLabel, Type__c, Code__c
			FROM xAL_Locality__mdt
			WHERE DeveloperName = :testLocality
	];

	static final xAL_Locality__mdt dependentLocality = [
			SELECT DeveloperName, MasterLabel, Type__c, Code__c
			FROM xAL_Locality__mdt
			WHERE DeveloperName = :testDependentLocality
	];

	static final xAL_PostalCode__mdt zipcode = [
			SELECT DeveloperName, MasterLabel, Number__c
			FROM xAL_PostalCode__mdt
			WHERE DeveloperName = :testPostCode
	];


	@TestSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c c = UnitTestDataFactory.createCountry('EC', testCountryLabel, 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		AddressDetail__c addr = new AddressDetail__c(
				Type__c = 'Restaurant Address;Billing Address',
				Account__c = a.Id,

				LatLng__Latitude__s = 10.0,
				LatLng__Longitude__s = 5.0,

				AddressLine__c = 'Go to **** yourself',

				CountryDevName__c = country.DeveloperName,
				CountryName__c = country.MasterLabel,
				CountryCode__c = country.Code__c,

				AdministrativeAreaDevName__c = area.DeveloperName,
				AdministrativeAreaName__c = area.MasterLabel,
				AdministrativeAreaCode__c = area.Code__c,
				AdministrativeAreaType__c = area.Type__c,

				SubAdministratriveAreaDevName__c = subArea.DeveloperName,
				SubAdministrativeAreaName__c = subArea.MasterLabel,
				SubAdministrativeAreaCode__c = subArea.Code__c,
				SubAdministrativeAreaType__c = subArea.Type__c,

				LocalityDevName__c = locality.DeveloperName,
				LocalityName__c = locality.MasterLabel,
				LocalityType__c = locality.Type__c,
				LocalityCode__c = locality.Code__c,

				DependentLocalityDevName_1__c = dependentLocality.DeveloperName,
				DependentLocalityName_1__c = dependentLocality.MasterLabel,
				DependentLocalityType_1__c = dependentLocality.Type__c,
				DependentlocalityCode_1__c = dependentLocality.Code__c,

				PostalCodeDevName__c = zipcode.DeveloperName,
				PostalCodeName__c = zipcode.Number__c
		);

		insert addr;
	}

	@IsTest static void CtrCreateNewAddressInstantiateCorrectly() {
		AddressDetail__c addr = [SELECT Id FROM AddressDetail__c LIMIT 1];
		PageReference pref = Page.CreateNewAddress;

		Test.startTest();
		Test.setCurrentPage(pref);

		ApexPages.StandardController stdCtr = new ApexPages.StandardController(addr);
		new CtrCreateNewAddress(stdCtr);
		new CtrCreateNewAddress();

		Test.stopTest();
	}

	@IsTest static void getAdminAreaByNameReturnsCorrectly() {
		xALAdministrativeArea res;
		Test.startTest();
		res = CtrCreateNewAddress.getAdminAreaByName(testAdminArea);
		Test.stopTest();
		System.assertNotEquals(null, res);

	}
	@IsTest static void getAdminAreaByLabelReturnsCorrectly() {
		xALAdministrativeArea res;
		Test.startTest();
		res = CtrCreateNewAddress.getAdminAreaByLabel(testAdminAreaLabel);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}
	@IsTest static void getSubAdminAreaByNameReturnsCorrectly() {
		xALSubAdministrativeArea res;
		Test.startTest();
		res = CtrCreateNewAddress.getSubAdminAreaByName(testSubArea);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}
	@IsTest static void getLocalityByNameReturnsCorrectly() {
		xALLocality res;
		Test.startTest();
		res = CtrCreateNewAddress.getLocalityByName(testLocality);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}
	@IsTest static void getCountryByNameReturnsCorrectly() {
		xALCountry res;
		Test.startTest();
		res = CtrCreateNewAddress.getCountryByName(testCountry);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}

	@IsTest static void getCountryByLabelReturnsCorrectly() {
		xALCountry res;
		Test.startTest();
		res = CtrCreateNewAddress.getCountryByLabel(testCountryLabel);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}
	@IsTest static void getCountryByAccountCountryLabelReturnsCorrectly() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALCountry res;
		Test.startTest();
		res = CtrCreateNewAddress.getCountryByAccountCountryLabel(a.Id);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}
	@IsTest static void getAddressDetailsReturnsCorrectly() {
		AddressDetail__c addr = [SELECT Id FROM AddressDetail__c LIMIT 1];
		xALAddressDetails res;
		Test.startTest();
		res = CtrCreateNewAddress.getAddressDetails(addr.Id);
		Test.stopTest();
		System.assertNotEquals(null, res);
	}

	@IsTest static void getAddressDetailsPerAccountReturnsCorrectly() {
		AddressDetail__c addr = [SELECT Id FROM AddressDetail__c LIMIT 1];
		List<xALAddressDetails> res;

		Test.startTest();

		res = CtrCreateNewAddress.getAddressDetailsPerAccount([SELECT Id FROM Account LIMIT 1].Id);

		Test.stopTest();

		System.assertEquals(1, res.size());
		System.assertEquals(addr.Id, res[0].id);
	}

	@IsTest static void saveAddressReturnsCorrectly() {
		Account a = [SELECT Id FROM Account LIMIT 1];
		xALAddressDetails newAddr = new xALAddressDetails();

		newAddr.type = new List<String>{
				'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		CtrCreateNewAddress.saveAddress(newAddr);

		Test.stopTest();

		List<AddressDetail__c> res = [SELECT Id FROM AddressDetail__c];

		System.assertEquals(2, res.size());
	}

	@IsTest static void saveAddressesReturnsCorrectly() {
		Account a = [SELECT Id FROM Account LIMIT 1];

		xALAddressDetails addr = new xALAddressDetails([SELECT Id FROM AddressDetail__c LIMIT 1].Id);
		xALAddressDetails newAddr = new xALAddressDetails();

		newAddr.type = new List<String>{
				'Shipping Address'
		};
		newAddr.addressLine = 'Go to hell!! :D';
		newAddr.account = a.Id;
		newAddr.latitude = 15.0;
		newAddr.longitude = 10.0;

		newAddr.country = xALCountry.byName(testCountry);
		newAddr.country.adminArea = xALAdministrativeArea.byName(testAdminArea);
		newAddr.country.adminArea.postalCode = xALPostalCode.byName(testPostCode);

		Test.startTest();

		CtrCreateNewAddress.saveAddresses(new List<xALAddressDetails>{addr, newAddr});

		Test.stopTest();

		List<AddressDetail__c> res = [SELECT Id FROM AddressDetail__c];

		System.assertEquals(2, res.size());
	}
}