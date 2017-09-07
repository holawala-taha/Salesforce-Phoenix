/**
 * Created by marco.zeuli on 25/8/2017.
 */

@IsTest
private class UnitTestTrgAddressDetailProcessor {
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

	// without admin area
	@IsTest static void checksDuplicateAddressTypesPerAccountThrowExceptionIfNewAddressIsDuplicate() {
		AddressDetail__c addr = [
				SELECT
						Account__c,
						AddressLine__c,
						AdministrativeAreaCode__c,
						AdministrativeAreaType__c,
						AdministrativeAreaName__c,
						AdministrativeAreaDevName__c,
						CountryName__c,
						CountryDevName__c,
						CountryCode__c,
						LocalityCode__c,
						LocalityName__c,
						LocalityType__c,
						LocalityDevName__c,
						DependentlocalityCode_1__c,
						DependentLocalityDevName_1__c,
						DependentLocalityName_1__c,
						DependentLocalityType_1__c,
						DependentlocalityCode_2__c,
						DependentLocalityDevName_2__c,
						DependentLocalityName_2__c,
						DependentLocalityType_2__c,
						DependentlocalityCode_3__c,
						DependentLocalityDevName_3__c,
						DependentLocalityName_3__c,
						DependentLocalityType_3__c,
						PostalCodeName__c,
						PostalCodeDevName__c,
						SubAdministrativeAreaCode__c,
						SubAdministrativeAreaName__c,
						SubAdministrativeAreaType__c,
						SubAdministratriveAreaDevName__c,
						Type__c,
						LatLng__longitude__s,
						LatLng__latitude__s
				FROM AddressDetail__c
				LIMIT 1
		];

		AddressDetail__c newAddr = addr.clone();

		Boolean throwed = false;

		Test.startTest();

		try {
			insert newAddr;
		} catch (DmlException exc) {
			throwed = true;
		}

		Test.stopTest();

		System.assert(throwed);
	}

	@IsTest static void checksDuplicateAddressTypesPerAccountThrowExceptionIfAddressIsDuplicateDuringBulkLoad() {
		AddressDetail__c addr = [
				SELECT
						Account__c,
						AddressLine__c,
						AdministrativeAreaCode__c,
						AdministrativeAreaType__c,
						AdministrativeAreaName__c,
						AdministrativeAreaDevName__c,
						CountryName__c,
						CountryDevName__c,
						CountryCode__c,
						LocalityCode__c,
						LocalityName__c,
						LocalityType__c,
						LocalityDevName__c,
						DependentlocalityCode_1__c,
						DependentLocalityDevName_1__c,
						DependentLocalityName_1__c,
						DependentLocalityType_1__c,
						DependentlocalityCode_2__c,
						DependentLocalityDevName_2__c,
						DependentLocalityName_2__c,
						DependentLocalityType_2__c,
						DependentlocalityCode_3__c,
						DependentLocalityDevName_3__c,
						DependentLocalityName_3__c,
						DependentLocalityType_3__c,
						PostalCodeName__c,
						PostalCodeDevName__c,
						SubAdministrativeAreaCode__c,
						SubAdministrativeAreaName__c,
						SubAdministrativeAreaType__c,
						SubAdministratriveAreaDevName__c,
						Type__c,
						LatLng__longitude__s,
						LatLng__latitude__s
				FROM AddressDetail__c
				LIMIT 1
		];

		AddressDetail__c newAddr = addr.clone();
		AddressDetail__c newAddr2 = addr.clone();

		delete addr;

		Boolean throwed = false;

		Test.startTest();

		System.debug(LoggingLevel.ERROR, 'add1 acc:' + newAddr.Account__c);
		System.debug(LoggingLevel.ERROR, 'add2 acc:' + newAddr2.Account__c);

		try {
			insert new List<AddressDetail__c>{
					newAddr, newAddr2
			};
		} catch (DmlException exc) {
			throwed = true;
		}

		Test.stopTest();

		System.assert(throwed);
	}
}