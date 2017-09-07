/**
 * Updates expired Contract, based on Business Config terminates the Contract
 * or renews it
 */
global class BatchContractRenewal implements Database.Batchable<sObject>, Database.Stateful {

   // business rules
   Map<String, Map<String, Business_Config__c>> mapBusinessLogic = LibBusinessConfig.motherOfAllBusinessMaps.get('BatchContractRenewal');

   global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator([
                                         SELECT
                                         End_Date__c,
                                         Status,
                                         recordtype.developername,
                                         Account.record_country__c,
                                         Renewal_version__c,
                                         Renewed_by__c,
                                         Last_renewal_date__c,
                                         Do_not_auto_renew__c
                                         FROM Contract
                                         WHERE end_date__c <= TODAY
                                         AND status = 'Activated'
                                      ]);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
      System.debug('BatchContractRenewal.execute: start');

      List<Contract> toUpdate = new List<Contract>();

      if (mapBusinessLogic == null || mapBusinessLogic.isEmpty()) {
         System.debug('BatchContractRenewal.execute: empty business rules');
         return; // nothing to do
      }

      System.debug('BatchContractRenewal.execute: scope list size is: ' + scope.size());

      for (Contract cont : (List<Contract>) scope) {

         System.debug('BatchContractRenewal.execute: processing contract: ' + cont.Id);

         Map<String, Business_Config__c> businessData = mapBusinessLogic.get(cont.RecordType.developername);

         if (businessData == null || businessData.isEmpty()) {
            System.debug('BatchContractRenewal.execute: nothing to do for this one');
            continue; // nothing to do for this contract
         }

         String countriesEnabledForAutoRenewal = businessData.get('CountriesEnabledForAutoRenewal') != null ? businessData.get('CountriesEnabledForAutoRenewal').Business_Rule_Value__c : '';

         // checks if has to renew the contract
         if (
            countriesEnabledForAutoRenewal.containsIgnoreCase(cont.Account.record_country__c)
            && businessData.get('RenewForNumberOfMonths') != null
            && cont.End_Date__c != null
            && !cont.Do_not_auto_renew__c
         ) {

            System.debug('BatchContractRenewal.execute: renewing contract: ' + cont.Id);

            cont.end_date__c = cont.end_date__c.addMonths(Integer.valueOf(businessData.get('RenewForNumberOfMonths').Business_Rule_Value__c)).addDays(-1);
            cont.Renewal_version__c = cont.Renewal_version__c != null ? cont.Renewal_version__c + 1 : 1;
            cont.Last_renewal_date__c = Date.today();
            cont.Renewed_by__c = UserInfo.getUserId();
            cont.Status = businessData.get('renewalContractStatus').Business_Rule_Value__c;

            toUpdate.add(cont);
         }
         // checks if has to terminate expired contracts
         else if (businessData.get('updateExpiredContracts') != null && Boolean.valueOf(businessData.get('updateExpiredContracts').Business_Rule_Value__c)) {

            System.debug('BatchContractRenewal.execute: terminating contract: ' + cont.Id);

            cont.status = businessData.get('expiredContractStatus').Business_Rule_Value__c;

            toUpdate.add(cont);
         }
      }

      System.debug('BatchContractRenewal.execute: toUpdate size is: ' + toUpdate.size());

      if (!toUpdate.isEmpty()) {
         update toUpdate;
      }

      System.debug('BatchContractRenewal.execute: done');
   }

   global void finish(Database.BatchableContext BC) {}
}