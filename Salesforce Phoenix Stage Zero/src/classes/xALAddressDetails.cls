public with sharing class xALAddressDetails {

	private class xALAddressDetailsException extends Exception {}

	private static final Integer MAX_DEPENDENT_LOCALITIES = 3;

	public xALCountry country 				{get; set;}
	public List<String> type 				{get; set;}
	public String addressLine				{get; set;}
	public String id 						{get; set;}
	public String account 					{get; set;}
	public Decimal latitude					{get; set;}
	public Decimal longitude				{get; set;}

	public xALAddressDetails() {}

	public xALAddressDetails(AddressDetail__c address) {
		this();

		if (address == null) {
			return;
		}

		type = String.isNotBlank(address.Type__c) ? address.Type__c.split(';') : new List<String>();
		addressLine = address.AddressLine__c;
		id = address.Id;
		account = address.Account__c;
		latitude = address.LatLng__latitude__s;
		longitude = address.LatLng__longitude__s;

		// checks country
		if (String.isBlank(address.CountryDevName__c)) {
			return;
		}

		country = xALCountry.byName(address.CountryDevName__c);

		// checks administrative area
		if (String.isBlank(address.AdministrativeAreaDevName__c)) {
			return;
		}

		country.adminArea = xALAdministrativeArea.byName(address.AdministrativeAreaDevName__c);

		if (String.isNotBlank(address.SubAdministratriveAreaDevName__c)) {
			// load sub administrative area
			country.adminArea.subAdministrativeArea = xALSubAdministrativeArea.byName(address.SubAdministratriveAreaDevName__c);

			if (String.isNotBlank(address.LocalityDevName__c)) {
				// load locality related to sub admin area
				country.adminArea.subAdministrativeArea.locality = loadLocalityTree(address);
			} else if (String.isNotBlank(address.PostalCodeDevName__c)) {
				// load postal code related to sub admin area
				country.adminArea.subAdministrativeArea.postalCode = xALPostalCode.byName(address.PostalCodeDevName__c);
			}
		} else if (String.isNotBlank(address.LocalityDevName__c)) {
			// load locality related to admin area
			country.adminArea.locality = loadLocalityTree(address);
		} else if (String.isNotBlank(address.PostalCodeDevName__c)) {
			// load postal code related to admin area
			country.adminArea.postalCode = xALPostalCode.byName(address.PostalCodeDevName__c);
		}
	}


	public xALAddressDetails(Id addressId) {
		this([
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
		         LocalityCode__c,
		         LocalityName__c,
		         LocalityType__c,
		         LocalityDevName__c,
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
		         WHERE Id = :addressId
		                    LIMIT 1
		     ]);
	}

	/**
	 * Persist this instance to an AddressDetail__c record and return its id
	 * @return [description]
	 */
	public Id save() {
		AddressDetail__c address = getAddressDetailRecord(this);

		try {
			upsert address;
		} catch (DmlException exc) {
			throw new xALAddressDetailsException(exc.getDmlMessage(0));
		}

		return address.Id;
	}

	/**
	 * Create a record of AddressDetail__c from an instance of xALAddressDetails
	 * @param  addressDetails Address detail instance
	 * @return                [description]
	 */
	private static AddressDetail__c getAddressDetailRecord(xALAddressDetails addressDetails) {
		AddressDetail__c address = new AddressDetail__c();

		if (String.isNotBlank(addressDetails.id)) {
			address.Id = addressDetails.id;
			// we have to clear this address
			address = clearAddressFields(address);
		} else {
			// new address, set also the account reference
			address.Account__c = addressDetails.account;
		}

		address.Type__c = '';
		for (String val : addressDetails.type) {
			address.Type__c += val + ';';
		}

		address.AddressLine__c = addressDetails.addressLine;

		// fill latitude and longitude
		address.LatLng__longitude__s = addressDetails.longitude;
		address.LatLng__latitude__s = addressDetails.latitude;

		if (addressDetails.country == null) {
			return address;
		}

		// fill country data
		xALCountry country = addressDetails.country;
		address.CountryDevName__c = country.developerName;
		address.CountryName__c = country.label;
		address.CountryCode__c = country.code;

		if (country.adminArea == null) {
			return address;
		}

		// fill admin area data
		xALAdministrativeArea adminArea = country.adminArea;
		address.AdministrativeAreaDevName__c = adminArea.developerName;
		address.AdministrativeAreaType__c = adminArea.type;
		address.AdministrativeAreaCode__c = adminArea.code;
		address.AdministrativeAreaName__c = adminArea.label;

		if (adminArea.subAdministrativeArea != null) {
			// fill sub admin data
			xALSubAdministrativeArea subArea = adminArea.subAdministrativeArea;
			address.SubAdministrativeAreaCode__c = subArea.code;
			address.SubAdministrativeAreaName__c = subArea.label;
			address.SubAdministrativeAreaType__c = subArea.type;
			address.SubAdministratriveAreaDevName__c = subArea.developerName;

			if (subArea.locality != null) {
				address = storeLocalityTree(address, subArea.locality);
			} else if (subArea.postalCode != null) {
				address = storePostalCode(address, subArea.postalCode);
			}
		} else if (adminArea.locality != null) {
			address = storeLocalityTree(address, adminArea.locality);
		} else if (adminArea.postalCode != null) {
			address = storePostalCode(address, adminArea.postalCode);
		}

		return address;
	}

	/**
	 * Stores postal code data to and AddressDetail__c record
	 * @param  address    AddressDetail__c record
	 * @param  postalCode Postal code
	 * @return            [description]
	 */
	private static AddressDetail__c storePostalCode(AddressDetail__c address, xALPostalCode postalCode) {
		address.PostalCodeDevName__c = postalCode.developerName;
		address.PostalCodeName__c = postalCode.value;
		return address;
	}

	/**
	 * Stores locality hierarchy information to AddressDetail__c record
	 * @param  address AddressDetail__c record
	 * @param  root    Root locality
	 * @return         [description]
	 */
	private static AddressDetail__c storeLocalityTree(AddressDetail__c address, xALLocality root) {
		// store root info
		address.LocalityDevName__c = root.developerName;
		address.LocalityName__c = root.label;
		address.LocalityCode__c = root.code;
		address.LocalityType__c = root.type;

		xALLocality curr = root;
		for (Integer i = 1; i <= MAX_DEPENDENT_LOCALITIES; i++) {

			if (curr.dependentLocality == null) {
				break;
			}

			curr = curr.dependentLocality;

			address.put('DependentlocalityCode_' + i + '__c', curr.code);
			address.put('DependentLocalityType_' + i + '__c', curr.type);
			address.put('DependentLocalityName_' + i + '__c', curr.label);
			address.put('DependentLocalityDevName_' + i + '__c', curr.developerName);
		}

		if (curr.postalCode != null) {
			address = storePostalCode(address, curr.postalCode);
		}

		return address;
	}

	/**
	 * Load all the hierarchy structure of a given root locality. If present load also
	 * the postal code related to the deepest locality level
	 * @param  address AddressDetail__c record
	 * @return         Root node
	 */
	private static xALLocality loadLocalityTree(AddressDetail__c address) {
		xALLocality root = xALLocality.byName(address.LocalityDevName__c);

		xALLocality curr = root;
		for (Integer i = 1; i <= MAX_DEPENDENT_LOCALITIES; i++) {
			String dependentLocality = String.valueOf(address.get('DependentLocalityDevName_' + i + '__c'));
			if (String.isNotBlank(dependentLocality)) {
				curr.dependentLocality = xALLocality.byName(dependentLocality);
				curr = curr.dependentLocality;
			}
		}

		// load postal code
		if (String.isNotBlank(address.PostalCodeDevName__c)) {
			curr.postalCode = xALPostalCode.byName(address.PostalCodeDevName__c);
		}

		return root;
	}

	/**
	 * Clear all address fields on specified addressDetails record. Used when updating
	 * an existing record
	 * @param  record Record to be cleared
	 * @return        cleared record
	 */
	private static AddressDetail__c clearAddressFields(AddressDetail__c record) {
		Map<String, Schema.SObjectField> fields = Schema.SObjectType.AddressDetail__c.fields.getMap();
		for (String fld : fields.keySet()) {
			Schema.DescribeFieldResult dfl = fields.get(fld).getDescribe();
			if (fld.endsWith('__c') && fld != 'Account__c' && dfl.isUpdateable()) {
				record.put(fld, '');
			}
		}
		return record;
	}
}