global class BatchAdditionalChargeStartDate implements Database.Batchable<sObject> {
	
	String query = 'select id,Start_Date__c,Id_Opportunity__r.closeDate,createdDate  from Additional_Charges__c where Start_Date__c = null';
	
	global BatchAdditionalChargeStartDate() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<Additional_Charges__c> updateAddtCharges = new List<Additional_Charges__c>();
   		for(Additional_Charges__c addt : (List<Additional_Charges__c>)scope){
   			if(addt.Id_Opportunity__r.closeDate!=null){
   				addt.Start_Date__c = addt.Id_Opportunity__r.closeDate;
   			}else{
   				addt.Start_Date__c = addt.createdDate.date(); 
   			}
   			updateAddtCharges.add(addt);
   		}
   		update updateAddtCharges;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}