public class ClsOpportunityProcessor{
  public static boolean PreventQCValidation=false;

    public static void terminateOpportunityChildRecordsOnLost(List<opportunity> newOppLst, Map<id, Opportunity> oldMap){
           // Map<String, Map<String, Business_Config__c>> mapBusinessLogic = moam.get('OpportunityLostProcess');
            List<string> oppIds = new List<String>();
            //if (mapBusinessLogic != null && !mapBusinessLogic.isEmpty()) {
               for (Opportunity opp : newOppLst) {
                   // Map<String,Map<String,Business_Config__c>> oppBConfigMap = new Map<String, Map<String,Business_Config__c>>();
                   // Map<String, Business_Config__c> mapBusinessRules = mapBusinessLogic.get(LibRecordTypeHelper.getRecordTypeValue(opp.RecordTypeId));
                    if (/*mapBusinessRules != null && !mapBusinessRules.isEmpty() &&*/ opp.stageName != oldMap.get(opp.id).stagename && opp.stageName == 'Closed Lost'/*mapBusinessRules.get('stageName').Business_Rule_Value__c*/) {
                        oppIds.add(opp.id);
                        //oppBConfigMap.put(opp.id,mapBusinessRules);
                       // oppQueueId.put(opp.id, mapBusinessRules.get('DesignQueueId').Business_Rule_Value__c);
                    }
                }
    
                List<Case> csOpenLst = [select id, status, closed_reason__c from case where opportunity__c in : oppIds and isClosed =false] ;
                List<Branding_content__c> brandingContentLst = [select id, status__C,Installation_Date__c from branding_content__c where opportunity__C in : oppIds];
                List<Asset__C> assetLst =[select id, status__C from asset__c where opportunity__c in :oppIds];
    
                if(!csOpenLst.isEmpty()){
                   for(Case c:csOpenLst) {
                    c.status='Closed';
                    c.closed_reason__C='Opportunity Lost';
                   }
                   PreventQCValidation=true;
                   update csOpenLst;
                   PreventQCValidation=false;
    
                }
                if(!brandingContentLst.isEmpty()){
                    for(branding_content__c b:brandingContentLst){
                        b.status__c='Canceled';
                        if(b.Installation_Date__c!=null)
                            b.status__c='Uninstalled';
    
                    }
                    update brandingContentLst;
                }
                if(!assetLst.isEmpty()){
                    for(Asset__C a:assetLst){
                        a.status__c='Canceled';
                    }
                    update assetLst;
                }
    
            }
   }