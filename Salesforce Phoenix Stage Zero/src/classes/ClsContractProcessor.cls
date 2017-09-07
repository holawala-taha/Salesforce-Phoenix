public with sharing class ClsContractProcessor {

    private static Map<String,Business_Config__c> mapBusinessData { get; set; }
    private static List<Contract> contractsToUpdate;
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    private static Contract con {get;set;}

    public static void preventDuplicateContracts(List<Contract> newContracts){
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('ContractCreation');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('ContractCreation');

        contractsToUpdate = new List<Contract>();
        Map<String, List<Contract>> contractsByServiceType = new Map<String, List<Contract>>();

        con=newContracts[0];
         List<Contract> allContracts = [
      SELECT Id, AccountId, StartDate, End_Date__c, Status, Service_Type__c,isTiered__C, RecordType.DeveloperName,Id_Opportunity__c  
      FROM Contract 
      WHERE Status != 'Terminated' 
      AND AccountId = : newContracts[0].AccountId /*and IsTiered__c = false*/];
    if(!allContracts.isEmpty()){  
      mapBusinessData = mapProcessData.get(allContracts[0].RecordType.DeveloperName);
      //Updated the condition for null pointer exception by Magesh on 22.04.15
      //if(mapBusinessData!=null && !mapBusinessData.isEmpty() && mapBusinessData.get('GroupBeforeSorting') != null && mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){
      //instead of the original code
      //if(mapBusinessData.get('GroupBeforeSorting') != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){ 
      if(mapBusinessData!=null && !mapBusinessData.isEmpty() && mapBusinessData.get('GroupBeforeSorting') != null && mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != null && (mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != '' || mapBusinessData.get('GroupBeforeSorting').Business_Rule_Value__c != 'false')){
                       
        if(!allContracts.isEmpty()){
          for(Contract ct : allContracts){
            if(contractsByServiceType.get(ct.Service_Type__c) != null){
                  contractsByServiceType.get(ct.Service_Type__c).add(ct);
                } else {
                  contractsByServiceType.put(ct.Service_Type__c, new List<Contract>{ct});
                }
        }
         for(String str : contractsByServiceType.keySet()){
          performSort(contractsByServiceType.get(str));
        }
      } else {
        performSort(allContracts);
      }
    
      try {
        update contractsToUpdate;
      } catch(Exception e) {
        newContracts[0].addError(Label.Account_Contract_Overlapping_Reorder_Error);
        system.debug('The following error occurred while reordering overlapping contracts on account : ' + e.getMessage());
      }
    }
  } 
}

    public static void performSort(List<Contract> contracts){
        if(contracts.size() > 1){
            LibOpportunityLineItemsHelper.sortList(contracts, 'StartDate', 'ASC');
            for(Integer i = 0; i < contracts.size() - 1; i++){
                if(!contracts[i].isTiered__C && contracts[i].Id_Opportunity__c!=contracts[i+1].id_opportunity__C){
                    contracts[i].End_Date__c = contracts[i+1].StartDate.addDays(-1);
                    contractsToUpdate.add(contracts[i]);
                }else if(contracts[i].isTiered__C && contracts[i].Id_Opportunity__c!=contracts[contracts.size()-1].id_opportunity__C){
                    contracts[i].End_Date__c =contracts[contracts.size()-1].startDate.addDays(-1);
                    contractsToUpdate.add(contracts[i]);
                }
            }
        }
    }
    
    

    /*public static void preventDuplicateContracts(List<Contract> newContracts){
        contractsToUpdate = new List<Contract>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        Map<Id, List<Contract>> newAcctIdContractMap = new Map<Id, List<Contract>>();
        Map<Id, List<Contract>> oldAcctIdContractMap = new Map<Id, List<Contract>>();
        for(Contract ct : newContracts){
            contractMap.put(ct.Id, ct);
            if(newAcctIdContractMap.get(ct.AccountId) != null){
                newAcctIdContractMap.get(ct.AccountId).add(ct);
            } else {
                List<Contract> singleAcctContracts = new List<Contract>();
                singleAcctContracts.add(ct);
                newAcctIdContractMap.put(ct.AccountId, singleAcctContracts);
            }
        }

        List<Contract> allContracts = [
            SELECT Id, AccountId, StartDate, End_Date__c, Status, Service_Type__c 
            FROM Contract 
            WHERE Status != 'Terminated' 
            AND Id NOT IN : contractMap.keySet() 
            AND AccountId IN : newAcctIdContractMap.keySet()
        ];
        if(!allContracts.isEmpty()){
            for(Contract ct : allContracts){
                if(oldAcctIdContractMap.get(ct.AccountId) != null){
                    oldAcctIdContractMap.get(ct.AccountId).add(ct);
                } else {
                    List<Contract> singleAcctContracts = new List<Contract>();
                    singleAcctContracts.add(ct);
                    oldAcctIdContractMap.put(ct.AccountId, singleAcctContracts);
                }
            }
        }

        //List<Contract> contractsToUpdate = new List<Contract>();
        if(!oldAcctIdContractMap.isEmpty()){
            System.debug('@@@@@ calling preventDuplicateContracts - oldAcctIdContractMap : ' + oldAcctIdContractMap);
            for(Id acctId : oldAcctIdContractMap.keySet()){
                Map<String, List<Contract>> contractsByServiceTypeNew = new Map<String, List<Contract>>();
                Map<String, List<Contract>> contractsByServiceTypeOld = new Map<String, List<Contract>>();

                List<Contract> newAcctContracts = newAcctIdContractMap.get(acctId);
                List<Contract> existingAcctContracts = oldAcctIdContractMap.get(acctId);
                
                for(Contract nc : newAcctContracts){
                    if(contractsByServiceTypeNew.get(nc.Service_Type__c) != null){
                        contractsByServiceTypeNew.get(nc.Service_Type__c).add(nc);
                    } else {
                        contractsByServiceTypeNew.put(nc.Service_Type__c, new List<Contract>{nc});
                    }
                }

                System.debug('@@@@@ calling preventDuplicateContracts - contractsByServiceTypeNew : ' + contractsByServiceTypeNew);

                if(existingAcctContracts != null && !existingAcctContracts.isEmpty()){
                    for(Contract oc : existingAcctContracts){
                        if(contractsByServiceTypeOld.get(oc.Service_Type__c) != null){
                            contractsByServiceTypeOld.get(oc.Service_Type__c).add(oc);
                        } else {
                            contractsByServiceTypeOld.put(oc.Service_Type__c, new List<Contract>{oc});
                        }
                    }
                }

                System.debug('@@@@@ calling preventDuplicateContracts - contractsByServiceTypeOld : ' + contractsByServiceTypeOld);

                if(!contractsByServiceTypeOld.isEmpty()){
                    for(String str : contractsByServiceTypeOld.keySet()){
                        sortContracts(contractsByServiceTypeNew.get(str), contractsByServiceTypeOld.get(str), contractMap);
                    }
                }
            }
        }
        try {
            update contractsToUpdate;
        } catch(Exception e) {
            newContracts[0].addError(Label.Account_Contract_Overlapping_Reorder_Error);
            system.debug('The following error occurred while reordering overlapping contracts on account : ' + e.getMessage());
        }
    }

    public static void sortContracts(List<Contract> newAcctContracts, List<Contract> existingAcctContracts, Map<Id, Contract> contractMap){
        existingAcctContracts.addAll(newAcctContracts);
        LibOpportunityLineItemsHelper.sortList(newAcctContracts, 'StartDate', 'ASC');
        LibOpportunityLineItemsHelper.sortList(existingAcctContracts, 'StartDate', 'ASC');
        System.debug('@@@@@ calling sortContracts - newAcctContracts : ' + newAcctContracts);
        System.debug('@@@@@ calling sortContracts - existingAcctContracts : ' + existingAcctContracts);

        for(Integer i = 0; i < existingAcctContracts.size(); i++){
            if(!contractMap.containsKey(existingAcctContracts[i].Id)){
                System.debug('@@@@@ calling sortContracts - existingAcctContracts[i].Id : ' + existingAcctContracts[i].Id);
                if(existingAcctContracts[i].StartDate < newAcctContracts[0].StartDate){
                    if(existingAcctContracts[i+1].Id == newAcctContracts[0].Id){
                        existingAcctContracts[i].End_Date__c = newAcctContracts[0].StartDate.addDays(-1);
                        contractsToUpdate.add(existingAcctContracts[i]);
                    }
                } else {
                    existingAcctContracts[i].Status = 'Terminated';
                    contractsToUpdate.add(existingAcctContracts[i]);
                }
            }
        }
    }*/
}