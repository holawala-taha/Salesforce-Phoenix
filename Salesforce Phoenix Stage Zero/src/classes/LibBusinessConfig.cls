/*
@author : Magesh Mani Yadav
@Description: This library class is used to retrive businessRules for a specific trigger name or process name
@reviewer : KVE @ 7.9.2014
@creation : 02.09.2014
*/
public without sharing class LibBusinessConfig {

	public static final String MOAM_ORG_CACHE_PARTITION = 'local.BusinessConfigCache';
	public static final String MOAM_ORG_CACHE_KEY = 'moam';

	/*
	  implemented for ME approval flow v.5.5

	  @param:
	      country of approval item
	      level of approval
	  @return
	      custom setting entry

	*/
	public static TLB_Approval_Matrix__c determineApprover(String country, String role) {
		Map<String, TLB_Approval_Matrix__c> matrix = TLB_Approval_Matrix__c.getAll();
		TLB_Approval_Matrix__c approvalEntry;


		for (String key : matrix.keySet()) {
			//if(key.containsIgnoreCase(country)){
			if (matrix.get(key).CountryName__c == country) {
				if (matrix.get(key).Role__c == role) {
					approvalEntry =  matrix.get(key);
					break;
				}
			}

		}

		return approvalEntry;

	}

	/*
	    implemented for ME approval flow v.6.0

	    @param:
	        country of approval item
	        level of approval
	    @return
	        key: userid
	        value: custom setting entry

	*/
	/*public static Map<String, TLB_Approval_Matrix__c> determineApproverMap(String country, String  role) {
		Map<String, TLB_Approval_Matrix__c> mapResult = new Map<String, TLB_Approval_Matrix__c>();
		Map<String, TLB_Approval_Matrix__c> mapMatrix = TLB_Approval_Matrix__c.getAll();
        Map<String,Map<string,OpportunityTeamMember>> mapOppTeam = new Map<String,Map<string,OpportunityTeamMember>>();

		for (String key : mapMatrix.keySet()) {
			//if(key.containsIgnoreCase(country)){
			if (mapMatrix.get(key).CountryName__c == country) {
				if (mapMatrix.get(key).role__c == role){
					mapResult.put(mapMatrix.get(key).User_Id__c, mapMatrix.get(key));
				}
			}
		}

		return mapResult;





        

	}*/
    public static Map<String,Map<string,OpportunityTeamMember>> determineApproverMap(String oppid) {
       
        Map<String,Map<string,OpportunityTeamMember>> mapOppTeam = new Map<String,Map<string,OpportunityTeamMember>>();
        List<OpportunityTeamMember> oppTeam=[select id,UserId,User.name,user.email,TeamMemberRole from OpportunityTeamMember where OpportunityId =: oppid];
        for(OpportunityTeamMember ot:oppTeam){
            List<String> memRole = new List<String>();
            if(ot.TeamMemberRole.contains(',')){
                memRole.addAll(ot.TeamMemberRole.split(','));
            }else
                memRole.add(ot.TeamMemberRole);
            for(string mem:memRole)  {  
                if(mapOppTeam.get(mem)!=null){
                    mapOppTeam.get(mem).put(ot.UserId,ot);
                }else{
                    map<string,OpportunityTeamMember> userOppTeam = new Map<String,OpportunityTeamMember>();
                    userOppTeam.put(ot.UserId,ot);
                    mapOppTeam.put(mem,userOppTeam);
                }
            }
                
        }
        return mapOppTeam;
    }

	/*
	    implemented for SP-706

	    @param:
	        country of approval item
	    @return
	        email id of HOS of given country

	*/
	/*public static List<String> getCountryHOSEmailId(String countryName) {
		Map<String, TLB_Approval_Matrix__c> mapMatrix = TLB_Approval_Matrix__c.getAll();
		List<String> result = new List<String>();
		for (String key : mapMatrix.keyset()) {
			if (mapMatrix.get(key).CountryName__c == countryName) {
				if (mapMatrix.get(key).Role__c == 'Country HOS') {
					result.add(mapMatrix.get(key).User_Email__c);
				}
			}
		}

		return result;
	}*/



	public static void setSObjectCurrencyAndCompanyCode(List<SObject> records) {

		Map<String, String> companyCodeCurrencyMap = new Map<String, String>();
		Map<String, String> countryNameCurrencyMap = new Map<String, String>();
		String talabatPlatform;
		String focPlatform;
		if (Platform_Country__c.getValues('TalabatPlatform') != null) {
			talabatPlatform = Platform_Country__c.getValues('TalabatPlatform').Country__c;
		}
		if (Platform_Country__c.getValues('FOCPlatform') != null) {
			focPlatform = Platform_Country__c.getValues('FOCPlatform').Country__c;
		}
		Set<String> talabatSet = new Set<String>();
		Set<String> focSet = new Set<String>();
		if (talabatPlatform != null) {
			if (talabatPlatform.indexOf(',') > 1) {
				talabatSet.addAll(talabatPlatform.split(','));
			} else {
				talabatSet.add(talabatPlatform);
			}
		}
		if (focPlatform != null) {
			if (focPlatform.indexOf(',') > 1) {
				focSet.addAll(focPlatform.split(','));
			} else {
				focSet.add(focPlatform);
			}
		}
		//Map<Id, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForIds(new Set<String>{'Lead', 'Account', 'Contact', 'Opportunity'});
		//system.debug('@@@@ calling setSObjectCurrencyAndCompanyCode - objType : ' + objType);
		//system.debug('@@@@ calling setSObjectCurrencyAndCompanyCode - mapRecordtypes : ' + mapRecordtypes);
		//List<Company__c> companies = [SELECT Id, CurrencyIsoCode, Company_Code__c,Country__c,Country__r.Iso__c,Country__r.Name FROM Company__c];
		//system.debug('@@@@ calling setSObjectCurrencyAndCompanyCode - companies : ' + companies);
		for (Company__c comp :  [SELECT Id, CurrencyIsoCode, Company_Code__c, Country__c, Country__r.Iso__c, Country__r.Name FROM Company__c]) {
			companyCodeCurrencyMap.put(comp.Company_Code__c, comp.CurrencyIsoCode);
			countryNameCurrencyMap.put(comp.Country__r.Name, comp.CurrencyIsoCode);
		}
		system.debug('@@@@ calling setSObjectCurrencyAndCompanyCode - companyCodeCurrencyMap : ' + companyCodeCurrencyMap);
		for (SObject record : records) {
			String recordCountry = String.valueOf(record.get('Record_Country__c'));
			//sObject oldRec = recordOldmap.get(String.valueOf(record.get('id')));
			//if(recordOldmap==null || (recordOldmap!=null && record.get('Record_Country__c')!= (recordOldmap.get(String.valueOf(record.get('id'))).get('Record_Country__c')))){
			String objType = (String)record.getSObjectType().getDescribe().getName();
			system.debug('objType**' + objType);
			//String companyCode = LibBusinessConfig.determineCompany(mapRecordtypes.get((String)record.get('RecordTypeId')).DeveloperName);
			String companyCode = LibBusinessConfig.determineCompany(LibRecordTypeHelper.getRecordTypeValue(String.valueOf(record.get('RecordTypeId'))));
			record.put('CurrencyIsoCode', companyCodeCurrencyMap.get(companyCode));
			record.put('Company_Code__c', companyCode);
			system.debug('*record' + record);


			if (countryNameCurrencyMap.get(recordCountry) != null) {
				record.put('CurrencyIsoCode', countryNameCurrencyMap.get(recordCountry));
				system.debug('*record' + record);
			}
			if (objType.equalsIgnoreCase('Lead') || objType.equalsIgnoreCase('Account')) {
				String platforms;
				if (talabatSet.contains(recordCountry)) {
					platforms = 'Talabat';
				}
				if (focSet.contains(recordCountry)) {
					if (platforms != null) {
						platforms = platforms + ';FoodOnClick';
					} else {
						platforms = 'FoodOnClick';
					}
				}
				if (record.get('Platform__c') == null && Platform_Country__c.getValues(recordCountry) != null ) {
					platforms = Platform_Country__c.getValues(recordCountry).Country__c;
				}

				if (platforms != null) {
					record.put('Platform__c', platforms);
				}

			}
			// }
		}
		system.debug('@@@@ calling setSObjectCurrencyAndCompanyCode - records : ' + records);
	}
	public static void setCaseCurrencyAndCompanyCodeFromAccount(List<Case> cases) {
		Set<Id> accIds = new Set<Id>();
		Map<Id, Account> mapAccount = new Map<Id, Account>();
		for (Case cs : cases) {
			if (cs.AccountId != null) {
				accIds.add(cs.AccountId);
			}/*else{
                cases[0].addError('Case must be assigned with an account');
                return;
            }*/
		}
		for (Account acc : [select id, Company_Code__c, CurrencyIsoCode from Account where id in : accIds]) {
			mapAccount.put(acc.id, acc);
		}
		if (!mapAccount.isEmpty()) {
			for (Case cs : cases) {
				if (mapAccount.get(cs.AccountId) != null) {
					cs.CurrencyIsoCode = mapAccount.get(cs.AccountId).CurrencyIsoCode;
					cs.Company_Code__c = mapAccount.get(cs.AccountId).Company_Code__c;
				}
			}
		}
	}

	public static void setCountryLookUp(List<sObject> sObjects) {
		Map<Id, Country__c> sObjectIdCountryMap = new Map<Id, Country__c>();
		Map<Id, String> sObjectsMap = new Map<Id, String>();
		Set<String> sObjectCountryNames = new Set<String>();
		for (sObject sObj : sObjects) {
			sObjectCountryNames.add((String)sObj.get('Record_Country__c'));
			sObjectsMap.put((Id)sObj.get('Id'), (String)sObj.get('Record_Country__c'));
		}

		List<Country__c> countries = [SELECT Id, Name, Iso__c FROM Country__c WHERE Name IN : sObjectCountryNames];
		if (!countries.isEmpty()) {
			for (Id sObjId : sObjectsMap.keySet()) {
				for (Country__c country : countries) {
					if (country.Name.equals(sObjectsMap.get(sObjId))) {
						sObjectIdCountryMap.put(sObjId, country);
					}
				}
			}
		}

		if (!sObjectIdCountryMap.isEmpty()) {
			for (sObject sObj : sObjects) {
				sObj.put('Country__c', (Id)sObjectIdCountryMap.get(sObj.Id).Id);
			}
		}
	}

	//used to check the trigger is active or inactive
	public static Boolean isTriggerActive(String tgrName) {
		List<Business_Config__c> ListConfiguration = [SELECT Is_Active__c FROM Business_Config__c WHERE Process_Name__c = : tgrName AND Type__c = 'Trigger' Limit 1];
		if (!ListConfiguration.isEmpty()) {
			return ListConfiguration[0].Is_Active__c;
		}
		return null;
	}

	public static Map<String, Map<String, Map<String, Business_Config__c>>> motherOfAllBusinessMaps {
		get{
			if (motherOfAllBusinessMaps != null) {
				return motherOfAllBusinessMaps;
			}
			
			// get cache instance
			Cache.OrgPartition orgCache = Cache.Org.getPartition(MOAM_ORG_CACHE_PARTITION);

			// tries to retrieve value from cache
			motherOfAllBusinessMaps = (Map<String, Map<String, Map<String, Business_Config__c>>>) orgCache.get(MOAM_ORG_CACHE_KEY);

			// cache miss?
			if (motherOfAllBusinessMaps == null) {

				System.debug(LoggingLevel.Error, 'LibBusinessConfig.motherOfAllBusinessMaps: cache miss');

				// matrix is not cached, retrieves it
				motherOfAllBusinessMaps = createMotherOfAllBusinessMapsOptimized();

				try {
					// tries to cache matrix value
					orgCache.put(MOAM_ORG_CACHE_KEY, motherOfAllBusinessMaps, Cache.Org.MAX_TTL_SECS);

				} catch (Exception ignore) {
					// unable to cache value, just ignore this exception
					System.debug(LoggingLevel.Error, 'LibBusinessConfig.motherOfAllBusinessMaps: exception occurred while putting value in cache. Message is: ' + ignore.getMessage());
				}
			}

			return motherOfAllBusinessMaps;
		}
	}

	/*private static Map<String, Map<String, Map<String, Business_Config__c>> > createMotherOfAllBusinessMaps() {
		System.debug('$$$ MOTHER OF ALL BUSINESS CONFIGS IS HERE!');

		//1stKey=RecordType, 2ndKey=BusinessRuleName
		Map<String, Map<String, Business_Config__c>> mapGenericProcessData = LibBusinessConfig.getGenericProcessDataList();
		//1stKey=ProcessName, 2ndKey=RecordType, 3rdKey=businessRuleName
		Map<String, Map<String, Map<String, Business_Config__c>> > moam = new Map<String, Map<String, Map<String, Business_Config__c>> >();
		List<Business_Config__c> listBusinessConfigs = new List<Business_Config__c>();
		//System.debug('$$$ interating over recordTypes');

		for (String keyRecordType : mapGenericProcessData.keySet()) {

			//gets all businessRuleNames for this recordType

			for (String keyBusinessRuleName : mapGenericProcessData.get(keyRecordType).keySet()) {

				Business_Config__c config = mapGenericProcessData.get(keyRecordType).get(keyBusinessRuleName);

				Map<String, Map<String, Business_Config__c>> tempMap = new Map<String, Map<String, Business_Config__c>>();

				tempMap.put(keyRecordType, mapGenericProcessData.get(keyRecordType));

				if (moam.keySet().contains(config.Process_Name__c)) {

					if (moam.get(config.Process_Name__c).keySet().contains(keyRecordType)) {

						for (String key : mapGenericProcessData.get(keyRecordType).keySet()) {
							Business_Config__c brConfig = mapGenericProcessData.get(keyRecordType).get(key);

							if (brConfig.Process_Name__c == config.Process_Name__c) {
								if (moam.get(config.Process_Name__c).get(keyRecordType).get(brConfig.Business_Rule_Name__c) == null) {
									moam.get(config.Process_Name__c).get(keyRecordType).putAll(new Map<String, Business_Config__c> {brConfig.Business_Rule_Name__c => brConfig});
								}
							}
						}
					} else {
						Map<String, Map<String, Business_Config__c>> tempMapNRT = new Map<String, Map<String, Business_Config__c>>();

						for (String key : tempMap.get(keyRecordType).keySet()) {
							Business_Config__c brConfig = tempMap.get(keyRecordType).get(key);


							if (brConfig.Process_Name__c == config.Process_Name__c) {
								//System.debug('$$$ NEW RT putting brConfig with process name : ' + brConfig.Process_Name__c + ' Id: ' + brConfig.Id + 'RT: ' + keyRecordType + 'BR: ' + brConfig.Business_Rule_Name__c);
								if (tempMapNRT.get(keyRecordType) == null) {
									tempMapNRT.put(keyRecordType, new Map<String, Business_Config__c> {brConfig.Business_Rule_Name__c => brConfig});
								} else {
									tempMapNRT.get(keyRecordType).putAll(new Map<String, Business_Config__c> {brConfig.Business_Rule_Name__c => brConfig});
								}

							}
						}
						moam.get(config.Process_Name__c).putAll(tempMapNRT);
					}
				} else {
					Map<String, Map<String, Business_Config__c>> tempMapNP = new Map<String, Map<String, Business_Config__c>>();
					Integer counter = 0;

					for (String key : tempMap.get(keyRecordType).keySet()) {
						Business_Config__c brConfig = tempMap.get(keyRecordType).get(key);

						if (brConfig.Process_Name__c == config.Process_Name__c) {
							counter++;

							if (tempMapNP.get(keyRecordType) == null) {
								tempMapNP.put(keyRecordType, new Map<String, Business_Config__c> {brConfig.Business_Rule_Name__c => brConfig});
							} else {
								tempMapNP.get(keyRecordType).putAll(new Map<String, Business_Config__c> {brConfig.Business_Rule_Name__c => brConfig});
							}

						}
					}

					moam.put(config.Process_Name__c, tempMapNP);
				}
			}
		}
		return moam;
	}*/

//commented for huge CPU time
	private static Map<String, Map<String, Map<String, Business_Config__c>> > createMotherOfAllBusinessMapsOptimized() {
		Map<String, Map<String, Map<String, Business_Config__c>>> rootMap = new Map<String, Map<String, Map<String, Business_Config__c>>>();
		for (Business_Config__c b_config : [SELECT ID, Process_Name__c, Parent__c, Is_Active__c, Is_Json__c, Id_Country__c, Record_Type_Id__c, Business_Rule_Name__c, Business_Rule_Value__c, Type__c
		                                    FROM Business_Config__c
		                                    WHERE type__c = 'Process'
		                                            AND Business_Rule_Name__c != null
		                                            AND Record_Type_Id__c != null
		                                            AND Is_Active__c = true order by Process_Name__c ASC]) {
			List<string> recordTypeLst = new List<string>();
			//system.debug('@@rectype'+b_config.Record_Type_Id__c);
			if (b_config.Record_Type_Id__c.contains(',')) {
				//system.debug('@@if');
				recordTypeLst = b_config.Record_Type_Id__c.split(',');
			} else
				recordTypeLst.add(b_config.Record_Type_Id__c);
			//system.debug('@@recordTypeLst'+recordTypeLst);
			for (string rectype : recordTypeLst) {
				if (rootMap.isEmpty() || rootMap.get(b_config.Process_Name__c) == null) {
					Map<String, Business_Config__c> bruleMap = new Map<String, Business_Config__c> {b_config.Business_Rule_Name__c => b_config};
					rootMap.put(b_config.Process_Name__c, new Map<String, Map<String, Business_Config__c>> {rectype => bruleMap});
					//.debug('if ##bruleMap'+bruleMap+' ##rootmap'+rootMap);
				} else if (rootMap.get(b_config.Process_Name__c) != null && rootMap.get(b_config.Process_Name__c).get(rectype) == null) {
					Map<String, Map<String, Business_Config__c>> subMap = rootMap.get(b_config.Process_Name__c);
					subMap.put(rectype, new Map<String, Business_Config__c> {b_config.Business_Rule_Name__c => b_config});
					rootMap.put(b_config.Process_Name__c, subMap);
					// system.debug('else if 1##subMap'+subMap+' ##rootmap'+rootMap);
				} else if (rootMap.get(b_config.Process_Name__c) != null && rootMap.get(b_config.Process_Name__c).get(rectype) != null && rootMap.get(b_config.Process_Name__c).get(rectype).get(b_config.Business_Rule_Name__c) == null) {
					Map<String, Map<String, Business_Config__c>> subMap2 = rootMap.get(b_config.Process_Name__c);
					Map<String, Business_Config__c> bruleMap2 = subMap2.get(rectype);
					bruleMap2.put(b_config.Business_Rule_Name__c, b_config);
					subMap2.put(rectype, bruleMap2);
					rootMap.put(b_config.Process_Name__c, subMap2);
					//system.debug('else if2 ##subMap2'+subMap2+' ##rootmap'+rootMap);

				}
			}
		}
		//system.debug('@@root'+rootmap);
		return rootMap;
	}

	/*private static Map<String, Map<String,Map<String,Business_Config__c>> > createMotherOfAllBusinessMapsOptimized(){
	    Map<String,Map<String,Map<String,Business_Config__c>>> rootMap = new Map<String,Map<String,Map<String,Business_Config__c>>>();
	        for(Business_Config__c b_config: [SELECT ID, Process_Name__c,Parent__c, Is_Active__c,Is_Json__c, Id_Country__c,Record_Type_Id__c, Business_Rule_Name__c, Business_Rule_Value__c, Type__c
	            FROM Business_Config__c
	            WHERE type__c='Process'
	            AND Business_Rule_Name__c!=null
	            AND Record_Type_Id__c!=null
	            AND Is_Active__c=true order by Process_Name__c ASC]){
	            if(rootMap.isEmpty() || rootMap.get(b_config.Process_Name__c)==null){
	                Map<String,Business_Config__c> bruleMap= new Map<String,Business_Config__c>{b_config.Business_Rule_Name__c=>b_config};
	                rootMap.put(b_config.Process_Name__c,new Map<String,Map<String,Business_Config__c>>{b_config.Record_Type_Id__c=>bruleMap});
	            }else if(rootMap.get(b_config.Process_Name__c)!=null && rootMap.get(b_config.Process_Name__c).get(b_config.Record_Type_Id__c)==null){
	                Map<String,Map<String,Business_Config__c>> subMap = rootMap.get(b_config.Process_Name__c);
	                subMap.put(b_config.Record_Type_Id__c,new Map<String,Business_Config__c>{b_config.Business_Rule_Name__c=>b_config});
	                rootMap.put(b_config.Process_Name__c,subMap);
	            }else if(rootMap.get(b_config.Process_Name__c)!=null && rootMap.get(b_config.Process_Name__c).get(b_config.Record_Type_Id__c)!=null && rootMap.get(b_config.Process_Name__c).get(b_config.Record_Type_Id__c).get(b_config.Business_Rule_Name__c)==null){
	               Map<String,Map<String,Business_Config__c>> subMap2 = rootMap.get(b_config.Process_Name__c);
	               Map<String,Business_Config__c> bruleMap2 = subMap2.get(b_config.Record_Type_Id__c);
	               bruleMap2.put(b_config.Business_Rule_Name__c,b_config);
	               subMap2.put(b_config.Record_Type_Id__c,bruleMap2);
	               rootMap.put(b_config.Process_Name__c,subMap2);
	            }
	        }
	        return rootMap;
	}





	   /* public static Map<String, Map<String,Map<String,Business_Config__c>> > getMotherOfAllBusinessMaps(List<String> listProcesses){
	        System.debug('$$$ MOTHER OF ALL BUSINESS CONFIGS IS HERE!');

	        //1stKey=RecordType, 2ndKey=BusinessRuleName
	        Map<String,Map<String,Business_Config__c>> mapGenericProcessData = LibBusinessConfig.getGenericProcessDataList(listProcesses);
	        //1stKey=ProcessName, 2ndKey=RecordType, 3rdKey=businessRuleName
	        Map<String, Map<String,Map<String,Business_Config__c>> > moam = new Map<String, Map<String,Map<String,Business_Config__c>> >();
	        List<Business_Config__c> listBusinessConfigs = new List<Business_Config__c>();
	        //System.debug('$$$ interating over recordTypes');

	        for(String keyRecordType : mapGenericProcessData.keySet()){

	            //gets all businessRuleNames for this recordType

	            for(String keyBusinessRuleName : mapGenericProcessData.get(keyRecordType).keySet()){

	                Business_Config__c config = mapGenericProcessData.get(keyRecordType).get(keyBusinessRuleName);

	                Map<String,Map<String,Business_Config__c>> tempMap = new Map<String,Map<String,Business_Config__c>>();

	                tempMap.put(keyRecordType,mapGenericProcessData.get(keyRecordType));

	                if(moam.keySet().contains(config.Process_Name__c)){

	                    if(moam.get(config.Process_Name__c).keySet().contains(keyRecordType)){

	                        for(String key : mapGenericProcessData.get(keyRecordType).keySet()){
	                            Business_Config__c brConfig = mapGenericProcessData.get(keyRecordType).get(key);

	                            if(brConfig.Process_Name__c == config.Process_Name__c){
	                                if(moam.get(config.Process_Name__c).get(keyRecordType).get(brConfig.Business_Rule_Name__c) == null){
	                                    moam.get(config.Process_Name__c).get(keyRecordType).putAll(new Map<String, Business_Config__c>{brConfig.Business_Rule_Name__c => brConfig});
	                                }
	                            }
	                        }
	                    }else{
	                        Map<String,Map<String,Business_Config__c>> tempMapNRT = new Map<String,Map<String,Business_Config__c>>();

	                        for(String key : tempMap.get(keyRecordType).keySet()){
	                            Business_Config__c brConfig = tempMap.get(keyRecordType).get(key);


	                            if(brConfig.Process_Name__c == config.Process_Name__c){
	                                System.debug('$$$ NEW RT putting brConfig with process name : ' + brConfig.Process_Name__c + ' Id: ' + brConfig.Id + 'RT: ' + keyRecordType + 'BR: ' + brConfig.Business_Rule_Name__c);
	                                if(tempMapNRT.get(keyRecordType) == null){
	                                    tempMapNRT.put(keyRecordType, new Map<String,Business_Config__c>{brConfig.Business_Rule_Name__c => brConfig});
	                                }else{
	                                    tempMapNRT.get(keyRecordType).putAll(new Map<String,Business_Config__c>{brConfig.Business_Rule_Name__c => brConfig});
	                                }

	                            }
	                        }
	                        moam.get(config.Process_Name__c).putAll(tempMapNRT);
	                    }
	                }else{
	                    Map<String,Map<String,Business_Config__c>> tempMapNP = new Map<String,Map<String,Business_Config__c>>();
	                    Integer counter = 0;

	                    for(String key : tempMap.get(keyRecordType).keySet()){
	                        Business_Config__c brConfig = tempMap.get(keyRecordType).get(key);

	                        if(brConfig.Process_Name__c == config.Process_Name__c){
	                            counter++;

	                            if(tempMapNP.get(keyRecordType) == null){
	                                tempMapNP.put(keyRecordType, new Map<String,Business_Config__c>{brConfig.Business_Rule_Name__c => brConfig});
	                            }else{
	                                tempMapNP.get(keyRecordType).putAll(new Map<String,Business_Config__c>{brConfig.Business_Rule_Name__c => brConfig});
	                            }

	                        }
	                    }

	                    moam.put(config.Process_Name__c,tempMapNP);
	                }
	            }
	        }





	        return moam;
	    }*/



	//used to get all the process data
	/*
	use recordTypeId as Key
	*/
	public static Map<String, Map<String, Business_Config__c>> getGenericProcessDataList() {
		Map<Id, Business_Config__c> mapConfigurations = new Map<Id, Business_Config__c>(
		    [SELECT ID, Process_Name__c, Parent__c, Is_Active__c, Is_Json__c, Id_Country__c, Record_Type_Id__c, Business_Rule_Name__c, Business_Rule_Value__c, Type__c
		     FROM Business_Config__c
		     WHERE type__c = 'Process'
		                     AND Business_Rule_Name__c != null
		                     AND Record_Type_Id__c != null
		                     AND Is_Active__c = true]);
		System.debug('@@@@ calling getGenericProcessData - mapConfigurations : ' + mapConfigurations);

		Map<String, List<Id>> mapRecordtypes = new Map<String, List<Id>>();
		List<Id> listconfigId;
		if (!mapConfigurations.isEmpty()) {
			for (Business_Config__c Config : mapConfigurations.values()) {
				List<string> recTypeLst = new List<string>();
				if (Config.Record_Type_Id__c.contains(',')) {
					recTypeLst = (Config.Record_Type_Id__c).split(',');
				} else
					recTypeLst.add(Config.Record_Type_Id__c);
				for (string rectype : recTypeLst) {
					if (mapRecordtypes.get(rectype) == null) {
						listconfigId = new List<Id>();
						listconfigId.add(Config.id);
						mapRecordtypes.put(rectype, listconfigId);
					} else {
						List<ID> listTempConfigIds = mapRecordtypes.get(rectype);
						listTempConfigIds.add(Config.id);

						mapRecordtypes.remove(rectype);
						mapRecordtypes.put(rectype, listTempConfigIds);
					}

				}


			}
			Map<String, Map<String, Business_Config__c>> mapConfigurationRecordtype = new Map<String, Map<String, Business_Config__c>>();
			for (String recordTypeId : mapRecordtypes.keySet()) {
				Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
				Integer countTask = 0;
				for (Id gpcid : mapRecordtypes.get(recordTypeId)) {
					mapBusinessRules.put(mapConfigurations.get(gpcid).Process_Name__c + '-' + mapConfigurations.get(gpcid).Business_Rule_Name__c, mapConfigurations.get(gpcid));
				}
				mapConfigurationRecordtype.put(recordTypeId, mapBusinessRules);

			}
			System.debug('mapConfigurationRecordtype: ' + mapConfigurationRecordtype);
			return mapConfigurationRecordtype;
		}
		return new Map<String, Map<String, Business_Config__c>>();
	}

	//used to get all the process data for the given process name
	/*
	use recordTypeId as Key
	*/
	public static Map<String, Map<String, Business_Config__c>> getGenericProcessData(String processName) {
		Map<Id, Business_Config__c> mapConfigurations = new Map<Id, Business_Config__c>(
		    [SELECT ID, Process_Name__c, Parent__c, Is_Active__c, Is_Json__c, Id_Country__c, Record_Type_Id__c, Business_Rule_Name__c, Business_Rule_Value__c, Type__c
		     FROM Business_Config__c
		     WHERE Process_Name__c = : processName
		                             AND type__c = 'Process'
		                                     AND Business_Rule_Name__c != null
		                                     AND Record_Type_Id__c != null
		                                     AND Is_Active__c = true]);
		System.debug('@@@@ calling getGenericProcessData - mapConfigurations : ' + mapConfigurations);
		Map<String, List<Id>> mapRecordtypes = new Map<String, List<Id>>();
		List<Id> listconfigId;
		if (!mapConfigurations.isEmpty()) {
			for (Business_Config__c Config : mapConfigurations.values()) {
				List<string> recordTypeLst = new List<String>();
				if (Config.Record_Type_Id__c.contains(',')) {
					recordTypeLst = Config.Record_Type_Id__c.split(',');

				} else
					recordTypeLst.add(Config.Record_Type_Id__c);
				for (string recType : recordTypeLst) {

					if (mapRecordtypes.get(recType) == null) {
						listconfigId = new List<Id>();
						listconfigId.add(Config.id);
						mapRecordtypes.put(recType, listconfigId);
					} else {
						List<ID> listTempConfigIds = mapRecordtypes.get(recType);
						listTempConfigIds.add(Config.id);
						mapRecordtypes.remove(recType);
						mapRecordtypes.put(recType, listTempConfigIds);
					}
				}
			}
			System.debug('mapRecordtypes: ' + mapRecordtypes);
			Map<String, Map<String, Business_Config__c>> mapConfigurationRecordtype = new Map<String, Map<String, Business_Config__c>>();
			for (String recordTypeId : mapRecordtypes.keySet()) {
				Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
				Integer countTask = 0;
				for (Id gpcid : mapRecordtypes.get(recordTypeId)) {
					if (mapConfigurations.get(gpcid).Is_Json__c) {
						countTask++;
						mapConfigurations.get(gpcid).Business_Rule_Name__c = 'Task' + countTask;
					}
					mapBusinessRules.put(mapConfigurations.get(gpcid).Business_Rule_Name__c, mapConfigurations.get(gpcid));
				}
				if (countTask > 0) {
					Business_Config__c tempMap = mapBusinessRules.values()[0];
					mapBusinessRules.put('totalInternalTaskCount', new Business_Config__c(Process_Name__c = tempMap.Process_Name__c, Parent__c = false, Is_Active__c = true, Business_Rule_Name__c = 'totalInternalTaskCount', Business_Rule_Value__c = '' + countTask));
				}
				mapConfigurationRecordtype.put(recordTypeId, mapBusinessRules);

			}
			System.debug('mapConfigurationRecordtype: ' + mapConfigurationRecordtype);
			return mapConfigurationRecordtype;
		}
		return new Map<String, Map<String, Business_Config__c>>();
	}



	public static Map<String, String> getRecordTypeToRecordTypeAssignment(String processName) {
		Map<String, String> mapResult = new Map<String, String>();
		for (Business_Config__c bc : [SELECT Id, Business_Rule_Name__c, Business_Rule_Value__c
		                              FROM Business_Config__c
		                              WHERE Process_Name__c = : processName and type__c = 'Process' and Business_Rule_Name__c != null]) {
			mapResult.put(bc.Business_Rule_Name__c, bc.Business_Rule_Value__c);
		}
		return mapResult.isEmpty() ? null : mapResult;
		//return null;
	}
// Process_Name__c = 'Asset to Country Assignment'
	public static Map<String, Map<String, Business_Config__c>> getGerenericProcessDataWithCountry(String processName) {
		Map<Id, Business_Config__c> mapConfigurations = new Map<Id, Business_Config__c>(
		    [Select Id, Process_Name__c, Parent__c, Is_Json__c, Is_Active__c, Id_Country__c, Id_Country__r.iso__c, Record_Type_Id__c,
		     Business_Rule_Name__c, Business_Rule_Value__c, Type__c
		     from Business_Config__c
		     where Process_Name__c = : processName and type__c = 'Process' and Business_Rule_Name__c != null]);
		Map<String, List<Id>> mapCountrytypes = new Map<String, List<Id>>();
		List<Id> listconfigId;
		if (!mapConfigurations.isEmpty()) {
			for (Business_Config__c Config : mapConfigurations.values()) {
				if (mapCountrytypes.get(Config.Id_Country__r.iso__c) == null) {
					listconfigId = new List<Id>();
					listconfigId.add(Config.id);
					mapCountrytypes.put(Config.Id_Country__r.iso__c, listconfigId);
				} else {
					List<ID> listTempConfigIds = mapCountrytypes.get(Config.Id_Country__r.iso__c);
					listTempConfigIds.add(Config.id);
					mapCountrytypes.remove(Config.Id_Country__r.iso__c);
					mapCountrytypes.put(Config.Id_Country__r.iso__c, listTempConfigIds);
				}
			}
			System.debug('mapCountrytypes: ' + mapCountrytypes);
			Map<String, Map<String, Business_Config__c>> mapConfigurationWithCountry = new Map<String, Map<String, Business_Config__c>>();
			for (String countryCode : mapCountrytypes.keySet()) {
				Map<String, Business_Config__c> mapBusinessRules = new Map<String, Business_Config__c>();
				Integer countTask = 0;
				for (Id gpcid : mapCountrytypes.get(countryCode)) {
					if (mapConfigurations.get(gpcid).Is_Json__c) {
						countTask++;
					}
					mapBusinessRules.put(mapConfigurations.get(gpcid).Business_Rule_Name__c, mapConfigurations.get(gpcid));
				}
				if (countTask > 0) {
					Business_Config__c tempMap = mapBusinessRules.values()[0];
					mapBusinessRules.put('totalInternalTaskCount', new Business_Config__c(Process_Name__c = tempMap.Process_Name__c, Parent__c = false, Is_Active__c = true, Business_Rule_Name__c = 'totalInternalTaskCount', Business_Rule_Value__c = '' + countTask));
				}
				mapConfigurationWithCountry.put(countryCode, mapBusinessRules);
			}
			System.debug('mapConfigurationWithCountry: ' + mapConfigurationWithCountry);
			return mapConfigurationWithCountry;
		}
		return new Map<String, Map<String, Business_Config__c>>();
	}

	public static List<Company__c> getUserCompanies() {
		User usr = [select Company_Name__c From User Where Id = : UserInfo.getUserId() LIMIT 1];
		System.debug('@@@@ calling getUserCompanies - usr : ' + usr);
		List<String> companies = usr.Company_Name__c.split(';');
		Set<String> companyCodes = new Set<String>();
		for (String company : companies) {
			companyCodes.add(company);
		}
		System.debug('@@@@ calling - companyCodes : ' + companyCodes);
		List<Company__c> allUserCompanies = [SELECT Id, Name, Company_Code__c FROM Company__c WHERE Company_Code__c IN : companyCodes];
		System.debug('@@@@ calling getUserCompanies - allUserCompanies : ' + allUserCompanies);
		return allUserCompanies;
	}

	public static List<Country__c> getUserCountries() {
		User usr = [select CountryCode__c From User Where Id = : UserInfo.getUserId() LIMIT 1];
		List<String> countries = usr.CountryCode__c.split(';');
		Set<String> countriesCode = new Set<String>();
		for (String country : countries) {
			countriesCode.add(country);
		}
		List<Country__c> allUserCountries = [SELECT Id, Name, Iso__c FROM Country__c WHERE Iso__c IN : countriesCode];
		return allUserCountries;
	}

	public static String getRecordTypeDevName(sObject obj, String objectName) {
		String companyName;
		RecordType recordTypeDeveloperName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :(Id)obj.get('RecordTypeId')];
		List<String> rtParts = recordTypeDeveloperName.DeveloperName.split('_');
		if (rtParts.size() > 2 && rtParts[1].length() == 2) {
			companyName = rtParts[0] + '_' + rtParts[1];
		} else {
			companyName = rtParts[0];
		}
		return companyName + '_' + objectName;
	}

	public static String determineCompany(String rtDevName) {
		List<String> recordTypeParts = rtDevName.split('_');
		String opportunityCompany;
		if (recordTypeParts.size() > 2 && recordTypeParts[1].length() == 2) {
			opportunityCompany = recordTypeParts[0] + '_' + recordTypeParts[1];
		} else {
			opportunityCompany = recordTypeParts[0];
		}
		return opportunityCompany;
	}

	public static Map<String, String> recordCurrencyMap() {
		Map<String, String> currencyMap = new Map<String, String>();
		for (Company__c company : [SELECT Id, Name, CurrencyIsoCode, Country__r.Name FROM Company__c]) {
			currencyMap.put(company.Country__r.Name, company.CurrencyIsoCode);
		}
		return currencyMap;
	}



	/* public static String getRecordTypeNameByUserCountry(String objType){
	     System.debug('@@@@ getRecordTypeNameByUserCountry - ');
	     return getUserRecord().CountryCode__c + '_' + objType;
	 }*/

	/* public static String getRecordTypeNameByUserCompany(String objType){
	     System.debug('@@@@ getRecordTypeNameByUserCompany - ' + objType);
	     return getUserRecord().Company_Name__c + '_' + objType;
	 }*/

	/* public static String getUserCountryCode(){
	     System.debug('@@@@ getUserCountryCode - ');
	     return getUserRecord().CountryCode__c;
	 }*/
	/*private static User getUserRecord() {
	    System.debug('@@@@ getUserRecord - ');
	    User currentUser = [SELECT Id, Country, CountryCode__c, Company_Name__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
	    return currentUser;
	}*/

	/* public static Id getUserCountryId(){
	     System.debug('@@@@ getUserCountryId - ');
	     return getCountryRecord().Id;
	 }*/

	/*public static Id getEmailTemplateId(String templateName){
	    return getEmailTemplateRecord(templateName).Id;
	}*/

	/*public static EmailTemplate getEmailTemplate(String templateName){
	    return getEmailTemplateRecord(templateName);
	}*/

	/* private static User getUserRecord() {
	     System.debug('@@@@ getUserRecord - ');
	     User currentUser = [SELECT Id, Country, CountryCode__c, Company_Name__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
	     return currentUser;
	 }*/

	/*public static Country__c getCountryRecord(){
	    System.debug('@@@@ getCountryRecord - ' + getUserCountryCode());
	    Country__c country = [SELECT Id, Name, Iso__c FROM Country__c WHERE Iso__c =: getUserCountryCode()];
	    System.debug('@@@@ getCountryRecord - country' + country);
	    return country;
	}*/

	/*public static EmailTemplate getEmailTemplateRecord(String templateName){
	    return [SELECT id, Body, HtmlValue, Name FROM EmailTemplate WHERE DeveloperName =: getUserCountryCode() + '_' + templateName limit 1];
	}*/

	/*public static RecordType getRecordTypeId(String objType){
	    return [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: getRecordTypeNameByUserCountry(objType)];
	}*/

	/*public static RecordType getRecordTypeId(String objType){
	    return [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: getRecordTypeNameByUserCompany(objType)];
	}*/

	/*public static Country__c getCountryById(Id countryId){
	    return [SELECT Id, Name, CurrencyIsoCode, Iso__c FROM Country__c WHERE Id =: countryId];
	}*/
}