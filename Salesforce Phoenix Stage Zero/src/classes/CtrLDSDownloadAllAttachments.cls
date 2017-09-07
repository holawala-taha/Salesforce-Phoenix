public with sharing class CtrLDSDownloadAllAttachments {

	/**
	 * Retrieves all Attachment records related to a given record id, without
	 * the Body content
	 * @param  recordId Parent record id
	 * @return          A list of Attachment records or an empty list
	 */
	@RemoteAction
	public static List<Attachment> getAttachments(String recordId) {
		System.debug('CtrLDSDownloadAllAttachments.getAttachments: start, recordId is: ' + recordId);

		if (String.isBlank(recordId)) {
			return new List<Attachment>();
		}

		System.debug('CtrLDSDownloadAllAttachments.getAttachments: getting attachment list...');

		return [SELECT
		        Name,
		        ContentType,
		        LastModifiedDate,
		        LastModifiedBy.Name
		        FROM Attachment
		        WHERE ParentId = : recordId];
	}

	/**
	 * Retrieves specified Attachment record along with his body content
	 * @param  attachmentId Attachment record id
	 * @return              Specified Attachment record or null
	 */
	@RemoteAction
	public static BodyWrapper getAttachmentBody(String attachmentId) {
		System.debug('CtrLDSDownloadAllAttachments.getAttachmentBody: start, attachmentId is: ' + attachmentId);

		if (String.isBlank(attachmentId)) {
			return null;
		}

		Attachment res = [SELECT Id, Body FROM Attachment WHERE Id = : attachmentId];

		System.debug('CtrLDSDownloadAllAttachments.getAttachmentBody: retrieved attachment is: ' + res);

		return new BodyWrapper(res);
	}

	public class BodyWrapper {
		public String Id {get; set;}
		public String Body {get; set;}
		public BodyWrapper(Attachment att) {
			this.Id = att.Id;
			this.Body = EncodingUtil.base64Encode(att.Body);
		}
	}
}