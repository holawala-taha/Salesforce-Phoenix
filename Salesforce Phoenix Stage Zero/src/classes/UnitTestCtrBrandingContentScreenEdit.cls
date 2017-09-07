@isTest
private class UnitTestCtrBrandingContentScreenEdit {

	@testSetup static void setup() {
		UnitTestDataFactory.getRecordtypeValues();

		Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
		insert c;

		Account a = UnitTestDataFactory.createAccount('test', c, 'CD_Account');
		insert a;

		Branding_Content__c bc = new Branding_Content__c(Restaurant_Name__c = a.id,
		        OwnerId = UserInfo.getUserId(),
		        RecordTypeId = [Select id from recordType where DeveloperName = 'CD_Branding_Content'].Id);

		insert bc;
	}

	@isTest static void CtrBrandingContentScreenOnEditSetCorrectlyrecordTypeDevName() {
		Branding_Content__c bc = [Select id, RecordTypeId from Branding_Content__c limit 1];

		PageReference pref = Page.BrandingContentScreenEdit;
		pref.getParameters().put('id', bc.Id);

		Test.startTest();
		Test.setCurrentPage(pref);

		ApexPages.StandardController std = new ApexPages.StandardController(bc);
		CtrBrandingContentScreenEdit ctr = new CtrBrandingContentScreenEdit(std);

		Test.stopTest();

		System.assertEquals('CD_Branding_Content', ctr.recordTypeDevName);
	}

	@isTest static void CtrBrandingContentScreenEditOnNewSetCorrectlyRecordTypeDevName() {
		Branding_Content__c bc = new Branding_Content__c();

		PageReference pref = Page.BrandingContentScreenEdit;

		Test.startTest();
		Test.setCurrentPage(pref);

		ApexPages.StandardController std = new ApexPages.StandardController(bc);
		CtrBrandingContentScreenEdit ctr = new CtrBrandingContentScreenEdit(std);

		Test.stopTest();

		System.assert(String.isNotBlank(ctr.recordTypeDevName));
	}

}