public with sharing class CtrCreateNewAddress {

	public CtrCreateNewAddress() {}

	public CtrCreateNewAddress(ApexPages.StandardController ctr) {}

	@RemoteAction
	public static xALAdministrativeArea getAdminAreaByName(String name) {
		return xALAdministrativeArea.byName(name);
	}

	@RemoteAction
	public static xALAdministrativeArea getAdminAreaByLabel(String label) {
		return xALAdministrativeArea.byLabel(label);
	}

	@RemoteAction
	public static xALSubAdministrativeArea getSubAdminAreaByName(String name) {
		return xALSubAdministrativeArea.byName(name);
	}

	@RemoteAction
	public static xALLocality getLocalityByName(String name) {
		return xALLocality.byName(name);
	}

	@RemoteAction
	public static xALCountry getCountryByName(String name) {
		return xALCountry.byName(name);
	}

	@RemoteAction
	public static String getAccountRecordType(String accountId) {
		return LibRecordTypeHelper.getRecordTypeValue([SELECT RecordTypeId FROM Account WHERE Id = :accountId].RecordTypeId);
	}

	@RemoteAction
	public static xALCountry getCountryByLabel(String label) {
		xALCountry res = null;
		try {
			res = xALCountry.byLabel(label);
		} catch (Exception e) {
			System.debug('CtrCreateNewAddress.getCountryByLabel: exception occurred. Message is: ' + e.getMessage());
		}
		return res;
	}

	@RemoteAction
	public static xALCountry getCountryByAccountCountryLabel(String accountId) {
		return getCountryByLabel([SELECT Record_Country__c FROM Account WHERE Id = :accountId].Record_Country__c);
	}

	@RemoteAction
	public static xALAddressDetails getAddressDetails(String id) {
		return new xALAddressDetails(id);
	}

	@RemoteAction
	public static List<xALAddressDetails> getAddressDetailsPerAccount(String accountId) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (AddressDetail__c addr : [SELECT Id FROM AddressDetail__c WHERE Account__c = : accountId]) {
			res.add(new xALAddressDetails(addr.Id));
		}
		return res;
	}

	@RemoteAction
	public static xALAddressDetails saveAddress(xALAddressDetails address) {
		return new xALAddressDetails(address.save());
	}

	@RemoteAction
	public static List<xALAddressDetails> saveAddresses(List<xALAddressDetails> addresses) {
		List<xALAddressDetails> res = new List<xALAddressDetails>();
		for (xALAddressDetails addr : addresses) {
			res.add(new xALAddressDetails(addr.save()));
		}
		return res;
	}
}