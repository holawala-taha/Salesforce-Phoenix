trigger Business_Config_Trigger on Business_Config__c ( 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	// clear cache
	Cache.Org.getPartition(LibBusinessConfig.MOAM_ORG_CACHE_PARTITION).remove(LibBusinessConfig.MOAM_ORG_CACHE_KEY); 
}