/**
 * extension controller per CtrBrandingContentScreenEdit screen, add the default
 * record type to the url if not specified
 */
public with sharing class CtrBrandingContentScreenEdit {

	public String recordTypeDevName {get; private set;}

	public CtrBrandingContentScreenEdit(ApexPages.StandardController std) {
		// this is because edit page override also the new page, and if current user has
		// a default record type the page is not able to render the proper fields component
		Id rtId;
		Branding_Content__c record = (Branding_Content__c) std.getRecord();

		rtId = String.isNotBlank(record.RecordTypeId)
		       ? record.RecordTypeId
		       : LibRecordTypeHelper.getDefaultRecordTypeId(Branding_Content__c.SobjectType);

		recordTypeDevName = [Select DeveloperName From RecordType Where Id = : rtId].DeveloperName;
	}
}