/***************************************************************************************
**	Name: ClsEmailReply
**  
**  Purpose: Global class used to create a task from inbounb email 
**           based on the reference id hidden in it's body.
**
**  Author: Rijad Halidovic
**
**  Date Created: 04.01.2016.
**
**  Modification History/Comments:
**     - Rijad Halidovic / 13.01.2016. / code refactoring + creating attachments
**
****************************************************************************************/

global class ClsEmailReply implements Messaging.InboundEmailHandler {
	public List<Task> listOfTasks = new List<Task>();
	public List<Attachment> listOfAttachments = new List<Attachment>();
	public Boolean isQuote = false;
// { MAIN METHODS } *********************************************************************/

	/// <name> handleInboundEmail </name>
	/// <summary> global class that handles Inbound Messages. Main purpose is to create
	///			  a task based on the reference id that is hidden in email's body </summary>
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    	String referenceId = getReferenceIdFromEmail(email.plainTextBody);
    	String ownerId = getOwnerIdFromEmail(email.plainTextBody);
    	//String quoteReference = '';

    	if(referenceId.length() == 0)
    		return result;

    	Task createdTask = createTaskFromEmail(email.plainTextBody, email.subject, referenceId, ownerId);  	
	   	result.success = true;

	   	if(listOfTasks.size() > 0)
	   		insert listOfTasks;

	   	if(email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
    		Id parent = isQuote ? referenceId : createdTask.Id;
    		createAttachmentsForTask(parent, email.binaryAttachments, ownerId);
	   	}
    		
	   	if(listOfAttachments.size() > 0) {
	   		insert listOfAttachments;
		   	
	   	}
	   	if(isQuote) {
		   		changeOpportuntiyStage(referenceId);
		}
		//createAFeedItem(referenceId, ownerId, email.plainTextBody, email.Subject);
	   	
	   	return result;
	}

// { HELPER METHODS } ********************************************************************/
	

	/// <name> getReferenceIdFromEmail </name>
	/// <summary> Filters out the hidden reference id from the email's body and 
	///           returns it as a String value. </summary>
	public String getReferenceIdFromEmail(String emailBody) {
    	String getRef = emailBody.substringBetween('(REF: #', '#)');
    	if(getRef == null) {
    		getRef = emailBody.substringBetween('(REFQ: #', '#)');
    		isQuote = true;
    	}
		if(getRef.length() <= 1)
    		return '';
  	
    	return getRef.subStringBefore('.');
	}

	/// <name> getOwnerIdFromEmail </name>
	/// <summary> Filters out the hidden owner id from the email's body and 
	///           returns it as a String value. </summary>
	public String getOwnerIdFromEmail(String emailBody) {
    	String getRef = emailBody.substringBetween('(REF: #', '#)');
    	if(getRef == null)
    		getRef = emailBody.substringBetween('(REFQ: #', '#)');
		if(getRef.length() <= 1)
    		return '';

    	return getRef.substringAfter('.');
	}

	/*public String getAccountIdFromOpportunity(String oppId) {
		List<Opportunity> opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppId];
		if(opp.size() > 0)
			return opp[0].AccountId;
		return '';
	}*/

	/// <name> createTaskFromEmail </name>
	/// <summary> Create a task from received inbound email. </summary>
	public Task createTaskFromEmail(String emailBody, String emailSubject, String referenceId, String ownerId) {
    	Task newTask = new Task(
	     	Description =  emailBody,
	      	ActivityDate = Date.today(),
	        Priority = 'Normal',
	        Status = 'Completed',
	        Subject = 'Email: ' + emailSubject,
	        WhatId =  referenceId,
	        //TaskSubtype = 'Email',
	        Type = 'Email'
	    );

    	if(ownerId.length() > 0)
	    	newTask.OwnerId = ownerId;
	    listOfTasks.add(newTask);

	   	return newTask;
	}

	/// <name> createAttachmentsForTask </name>
  	/// <summary> Creates attachment that will be added to the newly created Task </summary>
    public void createAttachmentsForTask(Id taskId, Messaging.InboundEmail.BinaryAttachment[] attachments, String ownerId){
    	//List<Attachment> insertAttachments = new List<Attachment>();
    	if(taskId != null || taskId != '') {
	       	for(Messaging.InboundEmail.BinaryAttachment binAtt : attachments){ 
	        	Attachment newAttachment = new Attachment();
	        	newAttachment.ParentId = taskId;
	            newAttachment.Name = binAtt.fileName;
	            newAttachment.Body = binAtt.body;
	            if(ownerId.length() > 0)
	    			newAttachment.OwnerId = ownerId;
	           	listOfAttachments.add(newAttachment);
	        }   
	    } 
    }

    /// <name> changeOpportuntiyStage </name>
  	/// <summary> Change opportunity stage when customer replies to an email </summary>
    public void changeOpportuntiyStage(String referenceId) {
    	// Check if referenceid is opportunity id
    	List<Opportunity> updateOpp = new List<Opportunity>();
    	List<Opportunity> getOpp = [SELECT AccountId, StageName, Probability, RecordType.DeveloperName FROM Opportunity WHERE Id = :referenceId];
    	if(getOpp.size() > 0) {
    		for(Opportunity opp : getOpp) {
				if(opp.Probability <= 60) {
	    			List<Business_Config__c> bc = [SELECT Id,Business_Rule_Value__c,Business_Rule_Name__c FROM Business_Config__c WHERE Process_Name__c = 'OppQuoteProcess' AND Record_Type_Id__c =: opp.RecordType.DeveloperName AND Business_Rule_Name__c = 'QuoteReplyStage' LIMIT 1];
		    		if(bc.size() > 0) {
			    		opp.StageName = bc[0].Business_Rule_Value__c;
			    		opp.Probability = 65;
			    		updateOpp.add(opp);
		    		}
		    	}
    		}
    	}
    	if(updateOpp.size() > 0)
    		update updateOpp;

    }

    /// <name> createAFeedItem </name>
    /// <summary> when replies comes without an attachment opportunity owner get notifies
    ///           via feed item that replies has come.
    /*public void createAFeedItem(String referenceId, String ownerId, String emailBody, String emailSubject) {
   		FeedItem post = new FeedItem();
   		//post.relatedRecordId = referenceId;
		post.ParentId =  referenceId;
		post.createdById = Label.Chatter_User_Post;
		post.Body = emailBody;
		post.type = 'TextPost';  // can be other type
		post.Title = emailSubject;
		insert post;
    }*/
}