public class TrgAddressDetailProcessor {
	/**
	 * Called on before insert or update checks that there aren't two addresses of same
	 * type related to same account. In case of duplicates add an error message to the record
	 * @param newAddresses
	 */
	public static void checksDuplicateAddressTypesPerAccount(List<AddressDetail__c> newAddresses) {
		Set<Id> accountIds = new Set<Id>();
		Map<Id, Map<String, Integer>> accountIdToTypesOccurrence = new Map<Id, Map<String, Integer>>();

		// gets account ids
		for (AddressDetail__c addr : newAddresses) {
			accountIds.add(addr.Account__c);
			addTypesOccurrencesToMap(accountIdToTypesOccurrence, addr);
		}

		// get address detail records
		for (AddressDetail__c addr : [
		            SELECT
		            Type__c,
		            Account__c
		            FROM AddressDetail__c
		            WHERE Account__c in :accountIds
		            AND Id not in: newAddresses
		        ]) {

			addTypesOccurrencesToMap(accountIdToTypesOccurrence, addr);
		}

		for (AddressDetail__c addr : newAddresses) {
			for (String type : accountIdToTypesOccurrence.get(addr.Account__c).keySet()) {
				if (accountIdToTypesOccurrence.get(addr.Account__c).get(type) > 1) {
					addr.addError(Label.AddressDetail_DuplicateAddressType + ' ' + type);
				}
			}
		}
	}

	private static void addTypesOccurrencesToMap(Map<Id, Map<String, Integer>> typesOccurrences, AddressDetail__c addr) {
		if (!typesOccurrences.containsKey(addr.Account__c)) {
			typesOccurrences.put(addr.Account__c, new Map<String, Integer>());
		}

		Map<String, Integer> typeOccurrence = typesOccurrences.get(addr.Account__c);

		for(String type : addr.Type__c.split(';')) {
			Integer occ = typeOccurrence.containsKey(type) ? typeOccurrence.get(type) + 1 : 1;
			typeOccurrence.put(type, occ);
		}
	}
}