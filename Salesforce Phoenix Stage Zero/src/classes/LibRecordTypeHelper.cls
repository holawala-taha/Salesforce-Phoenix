/**
 * RecordType records helper class
 */
public with sharing class LibRecordTypeHelper {

	/**
	 * Given a Sobject returns the default record type per current suer
	 * @param  obj sObject
	 * @return     Default record type id or null
	 */
	public static Id getDefaultRecordTypeId(SObjectType obj) {
		System.debug('LibRecordTypeHelper.getDefaultRecordTypeId: start, obj is: ' + obj);
		
		Id res;
		for (Schema.RecordTypeInfo info : obj.getDescribe().getRecordTypeInfos()) {
			if (info.isDefaultRecordTypeMapping()) {
				res = info.getRecordTypeId();
			}
		}
		
		System.debug('LibRecordTypeHelper.getDefaultRecordTypeId: done, res is: ' + res);
		return res;
	}

	/**
	 * Retrieve record type id or developer name according to key
	 * @param  key Key could be either the record type id or record type dev name
	 * @return     Record type id if key is the developer name, developer name if
	 * the key is record type id
	 *
	 */
	public static String getRecordTypeValue(String key) {
		System.debug('LibRecordTypeHelper.getRecordTypeValue: start, key is: ' + key);
		return RecordType__c.getValues(key).value__c;
	}

	/**
	 * Retrieves record type record by developer name and Object
	 * @param  devName Record type developer name
	 * @param  sObjectName     Object name
	 * @return                 RecordType record or null
	 */
	public static RecordType getRecordType(String devName, String sObjectName) {

		System.debug('LibRecordTypeHelper.getRecordType: start, devName is: ' + devName + ', objectName is: ' + sObjectName);

		Map<Id, RecordType> res = new Map<Id, RecordType>(
		    [
		        SELECT Id
		        FROM RecordType
		        WHERE DeveloperName = :devName
		                              AND SobjectType = :sObjectName
		                                      LIMIT 1
		    ]
		);

		System.debug('LibRecordTypeHelper.getRecordType: done, res is: ' + res);

		return res.isEmpty() ? null : res.values()[0];
	}

	/**
	 * Returns all record type related to specified Objects
	 * @param  sObjectNames Objects list
	 * @return             Map where key is record type developer name and value
	 * record type record
	 */
	public static Map<String, RecordType> getRecordTypeForObjects(Set<String> sObjectNames) {
		Map<String, RecordType> res =  new Map<String, RecordType>();

		System.debug('LibRecordTypeHelper.getRecordTypeForObjects: start, objectNames are: ' + sObjectNames);

		for (RecordType r : getRecordTypesBysObjectName(sObjectNames)) {
			res.put(r.DeveloperName, r);
		}

		System.debug('LibRecordTypeHelper.getRecordTypeForObjects: done, res is: ' + res);

		return res;
	}

	/**
	 * Retrieves record type related to specified Objects
	 * @param  sObjectNames Objects list
	 * @return             Map where key is record type id and value record type record
	 */
	public static Map<Id, RecordType> getRecordTypeForIds(Set<String> sObjectNames) {
		System.debug('LibRecordTypeHelper.getRecordTypeForIds: start, objectNames are: ' + sObjectNames);
		return new Map<Id, RecordType>(getRecordTypesBysObjectName(sObjectNames));
	}

	private static List<RecordType> getRecordTypesBysObjectName(Set<String> sObjectNames) {
		return [Select Id, DeveloperName from RecordType where SobjectType in: sObjectNames];
	}
}