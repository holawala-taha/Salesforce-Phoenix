@isTest
private class UnitTestTrgOpportunityProcessor {
private static Map<String,RecordType> mapRecordTypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Case','Opportunity_Quote__c','Opportunity_Quote_Line_Item__c','Asset__C','Branding_Content__C','Additional_Charges__c'});
    static void testData(){

        
    }
    static{
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        List<Integration_Config__c> integrationSettings =new List<Integration_Config__c>(); 
        integrationSettings.add(new Integration_Config__c(name='United Kingdom',endpoint__c='http://staging-hungryhouse.com/api/salesforce/restaurant/', username__c='uksfuser', password__c='SFs3cr3tPw'));
        insert integrationSettings;
        List<MidasIntegration__c> midasIntg =new List<MidasIntegration__c>(); 
        midasIntg.add(new MidasIntegration__c(name='UK',EndPoint__c='http://midas.medusa-hero.com/backend/',AuthenticationToken__c='WyI0IiwiYzUwNjRkMmQ2MWUwNTE3YjVhNjRmMTk4Yjc2NmFiODgiXQ.CgtJbA.kFY4BLsKd3XXiXg7QtVxmLqZ7i0'));
        insert midasIntg;
        List<InterestedOppClosedLost__c> intOppClosedSetting =new List<InterestedOppClosedLost__c>(); 
        intOppClosedSetting.add(new InterestedOppClosedLost__c(name='Interested',Values__c='Not enough capacity'));
        insert intOppClosedSetting;
        UnitTestDataFactory.getRecordtypeValues();
    
    }
    
   
    
    @isTest static void test_contractProcess_positive() {
        // Implement test code
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Country__c c = [select id,iso__c,name from Country__c where name='Korea'];
        Opportunity opp = [select id,StageName,AccountId,Record_Country__c from Opportunity where name='TestOpp123'];
        
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='Yogiyo_Contract',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='Yogiyo_Additional_Charges',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='Yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='AddOnRecordType',Business_Rule_Value__c='Yogiyo_Add_On',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='BrandingContentRecordType',Business_Rule_Value__c='Yogiyo_Branding_Content',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='startDateIsOppCloseDate',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', c.Id, 'Yogiyo_Contract', true, true);
        insert new List<sObject>{b,b1,b2,b3,b4,b5,b6,b7};
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Contract> listContract = [Select id,name from Contract where Id_Opportunity__c=:opp.id];
        System.debug('listContract list: '+listContract);
        System.assertNotEquals(listContract,null);
    }

  
    @isTest static void test_contractProcess_positive_OppCloseDateOnAddChargeStartDate() {
        // Implement test code
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Country__c c = [select id,iso__c,name from Country__c where name='Korea'];
        Opportunity opp = [select id,StageName,CloseDate from Opportunity where name='AddChargeStartDateTest'];

        //Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='Yogiyo_Contract',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='Yogiyo_Additional_Charges',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='Yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        //Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='startDateIsOppCloseDate',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='Yogiyo_Contract',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='Yogiyo_Additional_Charges',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='Yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='AddOnRecordType',Business_Rule_Value__c='Yogiyo_Add_On',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='BrandingContentRecordType',Business_Rule_Value__c='Yogiyo_Branding_Content',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='startDateIsOppCloseDate',Business_Rule_Value__c='true',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', c.Id, 'Yogiyo_Contract', true, true);
        insert new List<sObject>{b,b1,b2,b3,b4,b5,b6,b7};
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Contract> listContract = [Select id,name from Contract where Id_Opportunity__c=:opp.id];
        List<Additional_Charges__c> listAddCharges = [SELECT Id, Id_Opportunity__c,Start_Date__c FROM Additional_Charges__c WHERE Id_Opportunity__c =: opp.Id ];
        System.debug('listContract list: '+listContract);
        System.assertNotEquals(listContract,null);
        System.assertNotEquals(listAddCharges,null);
    }

    @isTest static void test_contractProcess_negative() {
        // Implement test code
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Contract> listContract = [Select id,name from Contract where Id_Opportunity__c=:opp.id];
        System.debug('listContract list: '+listContract);
        System.assert(listContract.isEmpty());
    }

    @isTest static void test_assetProcess_positive() {
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Country__c c = [select id,iso__c,name from Country__c where name='Korea'];
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=c.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Asset Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='Yogiyo_Asset',Id_Country__c=c.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Asset Process',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        insert new List<sObject>{b,b1};
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Asset__c> listAsset = [select id from Asset__c where Opportunity__c=:opp.id];
        System.debug('listAsset list: '+listAsset);
        System.assertNotEquals(listAsset,null);


    }

    @isTest static void test_assetProcess_negative() {
        UnitTestDataFactory.testDataForYogiyoContractProcess();
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        
        Test.startTest();
            opp.StageName = 'Closed Won';
            update opp;
        Test.stopTest();
        
        List<Asset__c> listAsset = [select id from Asset__c where Opportunity__c=:opp.id];
        System.debug('listAsset list: '+listAsset);
        System.assert(listAsset.isEmpty());
    }
    
  

    @isTest static void test_NonContractedMenuProcessing(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='Non_Contracted__c',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Non Contracted',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='30',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('Yogiyo_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        insert new List<sObject>{b,b1,b2,b3};
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = true;
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> listCase = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        Opportunity result = [select id,stageName from Opportunity where id =:oppList[0].id];
        System.assertEquals(listCase.size(),1);
        System.assertEquals(result.stageName,'Non Contracted');
    }
    
    //Tests the nonContractedMenuProcessing Method Correctly
    @isTest static void test_NonContractedMenuProcessing_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = true;
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        Opportunity result = [select id,stageName from Opportunity where id =:oppList[0].id];
        System.assertEquals(caseList.size(),0);
        System.assertNotEquals(result.stageName,'Non Contracted');
    }

    @isTest static void test_NonContractedMenuChange(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='Non_Contracted__c',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='set StageName',Business_Rule_Value__c='Non Contracted',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='set Probability',Business_Rule_Value__c='30',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('Yogiyo_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='Non_Contracted__c',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='NonContractedMenuChange',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuChange',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Status',Business_Rule_Value__c='Closed',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuChange',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='Menu Change Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('Yogiyo_Entry_Case').id+',type=Convert to Contract,subject=Convert to Contract,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='NonContractedMenuChange',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        insert new List<sObject>{b,b1,b2,b3,b4,b5,b6,b7};
        Case menuProcessingCase = new Case(Type='Menu Processing',Subject='Menu Processing',RecordTypeId=mapRecordTypes.get('Yogiyo_Entry_Case').id ,status='closed');
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = true;
        oppList[0].StageName = 'Closed Won';
        
        Test.startTest();
            menuProcessingCase.Opportunity__c = oppList[0].id;
            menuProcessingCase.AccountId = accList[0].id;
            insert menuProcessingCase;
            update oppList[0]; 
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Convert to Contract'];
        System.assertEquals(caseList.size(),1);
    }
   
    @isTest static void test_NonContractedMenuChange_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        accList[0].Non_Contracted__c = true;
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].Non_Contracted__c = true;
        oppList[0].StageName = 'Closed Won';
        Test.startTest();
            update oppList[0];
        Test.stopTest();

        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Convert to Contract'];
        System.assertEquals(caseList.size(),0);
    }

    @isTest static void test_ContractedMenuProcessing(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        Business_Config__c b = new Business_Config__c(Business_Rule_Name__c='Non_Contracted__c',Business_Rule_Value__c='false',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('Yogiyo_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Take Online is not possible',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        insert new List<sObject>{b,b1,b2,b3,b4};
        
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].StageName = 'Closed Won';
        oppList[0].type = 'Contract Only';
        Test.startTest();
        update oppList[0];
        Test.stopTest();
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),1);
    }

    @isTest static void test_ContractedMenuProcessing_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].StageName = 'Closed Won';
        oppList[0].type = 'Contract Only';
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),0);
    }

    @isTest static void test_genericMenuProcessing_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('DH_AU_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Take Online is not possible',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2,b3,b4};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Editorial Queue';
        oppList[0].type = 'Contract Only';
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),1);

    }

    @isTest static void test_qualityCheckInternalCase_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Menu received',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='CheckOpenCaseType',Business_Rule_Value__c='Quality Check,Menu Processing,Terminal',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='QualityCheckCase',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('DH_AU_Internal_Case').id+',type=Quality Check,subject=Quality Check,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='UseBusinessTypeForCaseSubject',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2,b3,b4};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        oppList[0].type = 'Contract Only';
        oppList[0].Business_Type__c = 'New';
        oppList[0].StageName = 'Menu received';
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id, Subject from Case where Opportunity__c =:oppList[0].id and type='Quality Check'];
        System.assertEquals(caseList.size(),1);
        System.assert(caseList[0].Subject.contains(oppList[0].Business_Type__c));

    }

    @isTest static void test_qualityCheckInternalCase_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Menu received',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='CheckOpenCaseType',Business_Rule_Value__c='Quality Check,Menu Processing,Terminal',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='QualityCheckCase',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('DH_AU_Internal_Case').id+',type=Quality Check,subject=Quality Check,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='QualityCheckInternalCase',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='DH_AU_Contract',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='DH_AU_Additional_Charges',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.id, 'DH_AU_Contract', true, true);
        
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Editorial Queue';
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Quality Check'];
        System.assertEquals(caseList.size(),0);

    }

     @isTest static void test_validateOpportunityQuote_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Product Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='DH_AU_Contract',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='DH_AU_Additional_Charges',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.id, 'DH_AU_Contract', true, true);
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='AllowCheckForQCOpen',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='statusMap',Business_Rule_Value__c='{"Please Check":"Editorial Queue;Closed Won;Onboarding","Menu received":"Onboarding","Collecting documents":"Onboarding;Closed Won;Editorial Queue","Feedback Received":"Onboarding;Onboarding Failed;Closed Won","Prospecting":"Onboarding;Editorial Queue;Menu received;Feedback Received","Verbal Agreement":"Onboarding;Editorial Queue","Editorial Queue":"Closed Won","Onboarding Failed":"Editorial Queue;Closed Won;Collecting documents;Verbal Agreement;Menu received;Prospecting;Feedback Received"}',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='checkForAsset',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='checkForMP',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='CheckForBranding',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='checkForBEDataEntryCase',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b14 = new Business_Config__c(Business_Rule_Name__c='checkForSetupBackEndCase',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b15 = new Business_Config__c(Business_Rule_Name__c='checkForShipmentCase',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
        insert newQuote;
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        Case cs = new Case(Opportunity__c=oppList[0].id, accountid=accList[0].id,type='Quality Check', status='New');
        insert cs;
        Test.startTest();
            try{
                update oppList[0];
            }catch(Exception e){
               // System.assert(e.getMessage().contains(Label.Opportunity_Quote_Validation));
            }
        Test.stopTest();
        
        List<Opportunity> listOpp = [select id,StageName from Opportunity where id=:oppList[0].id];
        System.assertNotEquals('Closed Won',listOpp[0].StageName);
    }

    @isTest static void test_validateOpportunityQuote_Negative(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Product Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
        insert newQuote;
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        
        Test.startTest();
            try{
                update oppList[0];
            }catch(Exception e){
                System.assert(e.getMessage().contains(Label.Opportunity_Quote_Validation));
            }
            List<Opportunity> listOpp = [select id,StageName from Opportunity where id=:oppList[0].id];
            System.assertEquals('Closed Won',listOpp[0].StageName);
        Test.stopTest();
    }

     @isTest static void test_adSalesEntryCaseCreation(){
        Country__c testCountry = UnitTestDataFactory.createCountry('KR','Korea', 'KRW');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='AdSalesCaseProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='AdSales Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('Yogiyo_Internal_Case').id+',type=Ad Sales Entry,subject=Ad Sales Entry,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='AdSalesCaseProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='AdSales',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='AdSalesCaseProcessing',Record_Type_Id__c='Yogiyo_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2,b3};
                
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'Yogiyo_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'Yogiyo_Opportunity',Date.today());
        insert oppList;
        oppList[0].StageName = 'Closed Won';
        oppList[0].type = 'AdSales';
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Ad Sales Entry'];
        System.assertEquals(1,caseList.size());
     }
    
    @isTest static void test_genericMenuProcessingWithBusinessType_Positive(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('DH_AU_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Take Online is not possible',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Upgrade',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Upgrade',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Downgrade',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Downgrade',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Owner Change',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Owner Change',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Editorial Queue';
        oppList[0].type = 'Contract Only';
        oppList[0].Business_Type__c = 'Upgrade';
        
        Test.startTest();
            update oppList[0];
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing' and subject='Upgrade'];
        System.assertEquals(caseList.size(),1);
    }


   /* @isTest static void test_assetCreationProcess(){
        UnitTestDataFactory.testDataFor_DH_AU_ContractProcess();
        Country__c testCountry = [select id from Country__c where Name='Australia'];
        
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where name='TestOpp123'];
        List<Opportunity_Quote_Line_Item__c>  listOppServiceQuote = [select id from Opportunity_Quote_Line_Item__c where Id_Opportunity__c=:listOpp[0].id and Line_Item_Type__c='Service'];
        delete listOppServiceQuote;
        listOpp[0].StageName = 'Terminals Queue';
        listOpp[0].type = 'Product Only';
        
        Test.startTest();
            update listOpp[0];
        Test.stopTest();
        
        List<Asset__c> listAsset = [select id from Asset__c where Opportunity__c=:listOpp[0].id];
        System.assert(!listAsset.isEmpty());
        
    }*/
    
    @isTest static void test_genericMenuProcessingWithBusinessType_Positive2(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='Non_Contracted__c',Business_Rule_Value__c='false',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='ContractedMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Upgrade',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Upgrade',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Downgrade',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Downgrade',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='BusinessType-Owner Change',Business_Rule_Value__c='Case_Reason__c=Contract Update,subject=Owner Change',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='Menu Processing Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('DH_AU_Entry_Case').id+',type=Menu Processing,subject=Menu Processing,status=New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Take Online is not possible',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='GenericMenuProcessing',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10};

        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());

        insert oppList;
        oppList[0].StageName = 'Editorial Queue';
        oppList[0].type = 'Contract Only';
        oppList[0].Business_Type__c = 'Upgrade';
        
        Test.startTest();
            update oppList[0];
            TrgOpportunityProcessor.updateOpportunityCurrency(oppList);
        Test.stopTest();
        
        List<Case> caseList = [select id from Case where Opportunity__c =:oppList[0].id and type='Menu Processing'];
        System.assertEquals(caseList.size(),1);
    }
    
     @isTest static void test_validateOpportunityQuote(){
        Country__c testCountry = UnitTestDataFactory.createCountry('AU','Australia', 'AUD');
        insert testCountry;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='OpportunityType',Business_Rule_Value__c='Existing Business,New Business,Contract Only,Product Only,Contract & Product,Additional Contract,Administration',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='validateClosedOpportunity',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='DH_AU_Contract',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='DH_AU_Additional_Charges',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='DH_AU_Asset',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='BrandingContentRecordType',Business_Rule_Value__c='AU_Branding_Content',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='AddOnRecordType',Business_Rule_Value__c='DH_AU_Add_on',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
         Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='flexiblePremiumPlacementRuntime',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        Business_Config__c b10 = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.id, 'DH_AU_Contract', true, true);
        Business_Config__c b11 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='DH_AU_Additional_Charges',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='flexiblePremiumPlacement',Record_Type_Id__c='DH_AU_Opportunity_Quote_Line_Item',Type__c='Process');
        Business_Config__c b12 = new Business_Config__c(Business_Rule_Name__c='startDateIsOppCloseDate',Business_Rule_Value__c='false',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='flexiblePremiumPlacement',Record_Type_Id__c='DH_AU_Opportunity_Quote_Line_Item',Type__c='Process');
        Business_Config__c b13 = new Business_Config__c(Business_Rule_Name__c='AssetStatus',Business_Rule_Value__c='New',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13};
        company__c com = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', testCountry);
            insert com;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'DH_AU_Account');
        insert accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'DH_AU_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Draft');
        newQuote.recordtypeid=LibRecordTypeHelper.getRecordTypeValue('DH_AU_Opportunity_Quote');
        insert newQuote;
        
        
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','DH_AU_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','DH_AU_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'DH_AU_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'DH_AU_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Premium placement - 1 Month',lpg1.id,'DH_AU_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=true;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=true;
        lpp1.Requires_Additional_Charge__c=true;
        lpp1.Requires_Asset__c=false;
        lpp2.product_type__c='Premium placement - 1 Month';
        insert new List<sObject>{lpp,lpp1,lpp2};
        
        List<Opportunity_Quote_Line_Item__c> oqp=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp.id,lpg.id,4,true,'DH_AU_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        List<Opportunity_Quote_Line_Item__c> quoteLines=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,True,'DH_AU_Opportunity_Quote_Line_Item',20.0,0,true,1,system.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oqp2=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp1.id,lpg.id,4,true,'DH_AU_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        List<Opportunity_Quote_Line_Item__c> oqp3=UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,lpp2.id,lpg.id,4,true,'DH_AU_Opportunity_Quote_Line_Item',1,'20',200.0,2,300.0, 'Product');
        
        quoteLines[0].id_opportunity__c=oppList[0].id;
        oqp[0].id_opportunity__c=oppList[0].id;
        oqp2[0].id_opportunity__c=oppList[0].id;
        oqp3[0].id_opportunity__c=oppList[0].id;
        insert new List<sObject>{quoteLines[0],oqp[0],oqp2[0],oqp3[0]};
        
        oppList[0].type = 'Contract Only';
        oppList[0].StageName = 'Closed Won';
        
        Test.startTest();
            newQuote.Status__C='Accepted';
            update newQuote;
            //try{
                update oppList[0];
            //}catch(Exception e){
            //    System.assert(e.getMessage().contains(Label.Opportunity_Quote_Validation));
           // }
        Test.stopTest();
        
        List<Opportunity> listOpp = [select id,StageName from Opportunity where id=:oppList[0].id];
        //System.assertNotEquals('Closed Won',listOpp[0].StageName);
    }

    @isTest static void test_createBackendUK(){
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Hungry House', 'UK', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='stageName',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='BusinessType',Business_Rule_Value__c='New Business',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SendToBackendProcess',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'UK_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='United Kingdom';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','UK_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        insert lsp;
        Opportunity_Line_Item__c oppService = UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'UK_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        insert oppService;
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'UK_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        insert oppQuoteLine ;
        oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        newQuote.status__c='Accepted';
        update newQuote;
        update oppQuoteLine;
        List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        insert contacts;
        contacts[0].email='test@test.com';
        update contacts;   
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());    
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Editorial Queue';
            update oppList[0];
        Test.stopTest();
        
    } 
    
    @isTest static void test_CloseOppLostWithMidasAPI(){
        Test.setMock(HttpCalloutMock.class, new UnitTestMockWebservice());
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Hungry House', 'UK', testCountry);
        insert com;
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'UK_Account');
        insert accList;
        Tarif__c t = UnitTestDataFactory.createTarif(com,testCountry,'Premium Placement','UK_Tarif',false);
        insert t;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        oppList[0].Id_Tarif__c = t.Id;
        insert oppList;
        
        Test.startTest();
            oppList[0].StageName='Closed Lost';
            oppList[0].Lost_Reason__c = 'Not enough capacity';
            update oppList[0];
        Test.stopTest();
        
        Opportunity oppr = [select id,StageName,MidasAPIException__c from Opportunity where id=:oppList[0].id];
        //System.assertEquals(oppr.MidasAPIException__c,null);
        //System.assertEquals(oppr.StageName,'Closed Lost');
    }

    @isTest static void test_shippingbackendCase(){
        Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='StageName',Business_Rule_Value__c='Promo and Logistics Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='BackendShippingCase',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='ProductTypeForShipping',Business_Rule_Value__c='Packaging',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='BackendShippingCase',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='CheckOpenCaseType',Business_Rule_Value__c='Setup Backend,Shipment',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='BackendShippingCase',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='ShippingCase',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('CD_Internal_Case').id+',type=Shipment,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='BackendShippingCase',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='BackendCase',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('CD_Entry_Case').id+',type=Setup Backend,subject=Setup Backend,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='BackendShippingCase',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
       
        insert new List<sObject>{b1,b2,b3,b4,b5};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        //List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','CD_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        //insert lsp;
        //Opportunity_Line_Item__c oppService = //UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'CD_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        //insert oppService;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=false;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        //List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
       // insert oppQuoteLine ;
        //oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;
       // update oppQuoteLine;
        //List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        //insert contacts;
        //contacts[0].email='test@test.com';
        //update contacts;   
        
        Test.startTest();
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Promo and Logistics Queue';
            update oppList[0];
        Test.stopTest();
        
    }
    
    @isTest static void test_brandingOnQuoteAccept(){
        Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='opportunity stage',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='DefaultBrandingQtyProdType',Business_Rule_Value__c='Online Marketing,Packaging',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='createBrandingOnQuoteAccept',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='stageNameBranding',Business_Rule_Value__c='test',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='DesignQueueId',Business_Rule_Value__c=userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b6 = new Business_Config__c(Business_Rule_Name__c='TemplateType',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b7 = new Business_Config__c(Business_Rule_Name__c='BrandingContentRecordType',Business_Rule_Value__c='CD_Branding_Content',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b8 = new Business_Config__c(Business_Rule_Name__c='contract_RecordType',Business_Rule_Value__c='CD_Contract',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b9 = new Business_Config__c(Business_Rule_Name__c='AdditionalCharges RecordType',Business_Rule_Value__c='CD_Additional_Charges',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b10 = new Business_Config__c(Business_Rule_Name__c='Asset RecordType',Business_Rule_Value__c='CD_Asset',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='Opportunity Contract Process',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        
        insert new List<sObject>{b1,b2,b3,b4,b5,b6,b7,b8,b9,b10};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        //List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','CD_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        //insert lsp;
        //Opportunity_Line_Item__c oppService = //UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'CD_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        //insert oppService;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        //List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
       // insert oppQuoteLine ;
        //oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;
       // update oppQuoteLine;
        //List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        //insert contacts;
        //contacts[0].email='test@test.com';
        //update contacts;   
        
        Test.startTest();
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='test';
            update oppList[0];
        Test.stopTest();
        
    }

  @isTest static void test_RestaurantCare(){
        Country__c testCountry = UnitTestDataFactory.createCountry('CD','Colombia', 'COP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Clickdelivery', 'CD', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='stageName',Business_Rule_Value__c='Onboarding',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='RestaurantCare',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='chkForProdType',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='createBrandingOnQuoteAccept',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('CD_Entry_Case').id+',type=Onboarding,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Not Successful,Invalid,Duplicate',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='CD_Opportunity',Type__c='Process');
         
        insert new List<sObject>{b1,b2,b3,b4};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='Colombia';
        accList[0].BillingPostalCode='W1H 1DP';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'CD_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        //List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','CD_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        //insert lsp;
        //Opportunity_Line_Item__c oppService = //UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'CD_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        //insert oppService;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'CD_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'CD_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'CD_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        //List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
        //insert oppQuoteLine ;
        //oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;
        //update oppQuoteLine;
        //List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        //insert contacts;
        //contacts[0].email='test@test.com';
        //update contacts;   
         Case cs =new Case(type='Onboarding', status='New', recordtypeid=mapRecordTypes.get('CD_Entry_Case').id,accountid=acclist[0].id);
         insert cs;
         
         
        Test.startTest();
            cs.opportunity__c=opplist[0].id;
            cs.Status='Closed';
           cs.closed_reason__c='Successful';
            update cs;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Onboarding';
            update oppList[0];
            
        Test.stopTest();
        
    }
    
     @isTest static void test_RestaurantCareUK(){
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouyse', 'UK', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='stageName',Business_Rule_Value__c='Onboarding',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='chkForProdType',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
         Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='createBrandingOnQuoteAccept',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('UK_Entry_Case').id+',type=Onboarding,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Not Successful,Invalid,Duplicate',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('UK_Entry_Case').id+',type=Onboarding,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        
       
         
         insert new List<sObject>{b1,b2,b3,b4,b5};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='United Kingdom';
        accList[0].BillingPostalCode='W1H 1DP';
        accList[0].Delivery_ServicePicklist__c = 'Mixed';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        insert oppList;
        Opportunity_Quote__c newQuote = new Opportunity_Quote__c(Id_Opportunity__c=oppList[0].id,status__c='Approved',ID_Account__c=acclist[0].id);
        insert newQuote;

        //List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','CD_List_Service_Price',12,12,25,5,null,true,null,'Commission','ServiceType');
        //insert lsp;
        //Opportunity_Line_Item__c oppService = //UnitTestDataFactory.createOpportunityLineItemService('testService3',oppList[0],lsp.id,true,'CD_Opportunity_Line_Item',12,null,Date.today(),'Commission Fee',null);
        //insert oppService;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','CD_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','CD_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'UK_List_Product_Price',1,true,100,1,false,20); 
        List_Product_Price__c lpp2 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 2',lpg1.id,'UK_List_Product_Price',1,true,50,1,false,20);
        lpp.Requires_Asset__c=false;  
        lpp.Requires_Branding__c=true;
        lpp.Requires_Add_On__c=false;
        insert new List<sObject>{lpp,lpp1,lpp2};
        //List<Opportunity_Quote_Line_Item__c> oppQuoteLine =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'CD_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Commission Fee','Service');
        List<Opportunity_Quote_Line_Item__c> oppQuoteLine2 =  UnitTestDataFactory.createOpportunityQuoteLineItems(newQuote,1,False,'UK_Opportunity_Quote_Line_Item',12,1,True, 0, date.today(),'Packaging','Product');
       // insert oppQuoteLine ;
        //oppQuoteLine[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].id_opportunity__c=opplist[0].id;
        oppQuoteLine2[0].Id_List_Product_Price__c=lpp.id;
        insert oppQuoteLine2;
        newQuote.status__c='Accepted';
        update newQuote;
       // update oppQuoteLine;
        //List<Contact> contacts = UnitTestDataFactory.createContacts(accList, 'test Lastname', 'test FirstName', 'Mr', 'Owner', 1, 'testme', 'UK_Contact');
        //insert oppQuoteLine;
        //insert contacts;
        //contacts[0].email='test@test.com';
        //update contacts;   
        // Case cs =new Case(type='Onboarding', status='New', recordtypeid=mapRecordTypes.get('UK_Entry_Case').id,accountid=acclist[0].id);
       //  insert cs;
         
         
        Test.startTest();
           // cs.opportunity__c=opplist[0].id;
           // cs.Status='Closed';
         //  cs.closed_reason__c='Successful';
          //  update cs;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Onboarding';
            update oppList[0];
            
        Test.stopTest();
        
    }
    
 

 @isTest static void test_oppClosedLost(){
        Country__c testCountry = UnitTestDataFactory.createCountry('UK','United Kingdom', 'GBP');
        insert testCountry;
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouyse', 'UK', testCountry);
        insert com;
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='stageName',Business_Rule_Value__c='Onboarding',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='chkForProdType',Business_Rule_Value__c='true',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
         Business_Config__c b3 = new Business_Config__c(Business_Rule_Name__c='createBrandingOnQuoteAccept',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('UK_Entry_Case').id+',type=Onboarding,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b4 = new Business_Config__c(Business_Rule_Name__c='ClosedReason',Business_Rule_Value__c='Not Successful,Invalid,Duplicate',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        Business_Config__c b5 = new Business_Config__c(Business_Rule_Name__c='Case',Business_Rule_Value__c='RecordTypeId='+mapRecordTypes.get('UK_Entry_Case').id+',type=Onboarding,subject=Shipment,status=New,ownerid='+userinfo.getuserid(),Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='RestaurantCare',Record_Type_Id__c='UK_Opportunity',Type__c='Process');
        
       
         
         insert new List<sObject>{b1,b2,b3,b4,b5};
        List<Account> accList= UnitTestDataFactory.createAccounts(1,testCountry,'CD_Account');
        insert accList;
        accList[0].Restaurant_Name__c ='test';
        accList[0].record_country__c='United Kingdom';
        accList[0].BillingPostalCode='W1H 1DP';
        accList[0].Delivery_ServicePicklist__c = 'Mixed';
        update accList;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(accList,1,'UK_Opportunity',Date.today());
        insert oppList;
        
         
        Test.startTest();
           // cs.opportunity__c=opplist[0].id;
           // cs.Status='Closed';
         //  cs.closed_reason__c='Successful';
          //  update cs;
            Case cs =new Case(type='Onboarding', status='New', recordtypeid=mapRecordTypes.get('UK_Entry_Case').id,accountid=acclist[0].id,Opportunity__c=oppList[0].id);
            insert cs;
            Asset__C asset_new =new Asset__C( status__c='New', recordtypeid=mapRecordTypes.get('UK_Asset').id,account__c=acclist[0].id,Opportunity__c=oppList[0].id);
            insert asset_new;
            branding_content__c brand =new branding_content__c( status__c='New', recordtypeid=mapRecordTypes.get('UK_Branding_Content').id,Restaurant_Name__c=acclist[0].id,Opportunity__c=oppList[0].id);
            insert brand;
            oppList[0].Business_Type__c = 'New Business';
            oppList[0].stageName='Closed Lost';
            update oppList[0];
            
        Test.stopTest();
        
    }
    
 }
  /* @isTest static void test_updateSalesTargetRecords(){
         UnitTestDataFactory.testDataFor_DH_AU_OpportunityProcesses();
         Country__c testCountry = [select id from Country__c where Iso__c='AU' limit 1];
        Business_Config__c b1 = new Business_Config__c(Business_Rule_Name__c='Product_Stage',Business_Rule_Value__c='Closed Won',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=true,Process_Name__c='SalesTargetProcess',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        Business_Config__c b2 = new Business_Config__c(Business_Rule_Name__c='Service_Stage',Business_Rule_Value__c='Editorial Queue',Id_Country__c=testCountry.id,Is_Active__c=true,Parent__c=false,Process_Name__c='SalesTargetProcess',Record_Type_Id__c='DH_AU_Opportunity',Type__c='Process');
        insert new List<sObject>{b1,b2};
         List<List_Service_Price__c> listSer = [select id,name from List_Service_Price__c where name='testService3' limit 1];
        Sales_Target__c st = new Sales_Target__c(Business_Type__c=null,Product_Group__c=null,Commission_Target__c=listSer[0].Id,From__c=Date.today().addDays(-2),Product_Target__c=null,Sales_Rep__c=UserInfo.getUserId(),Target_Deals__c=5,Target_Revenue__c=null,Target_Units__c=null,To__c=Date.today().addDays(2),Type__c='Service',currencyIsoCode='AUD');
       system.debug('*st'+st);
        insert st;
        List<Opportunity> listOpp = [select id,RecordType.DeveloperName,Country__c,Record_Country__c,AccountId,recordtypeid,subtotal__c,vat__c,total__c,currencyIsoCode from Opportunity where name='TestOpp123'];
        System.debug('listOpp: '+listOpp);
        Opportunity_Quote__c oppQuote = new Opportunity_Quote__c(CurrencyIsoCode=listOpp[0].currencyIsoCode,Id_Account__c=listOpp[0].accountid,Id_Opportunity__c=listOpp[0].id,Description__c='test data',RecordTypeId=mapRecordtypes.get('DH_AU_Opportunity_Quote').id,Status__c='Accepted',Subtotal__c=19900,Total__c=19900);
        insert oppQuote;
        List<Opportunity_Line_Item__c> oppProductItem = [SELECT Commission_In_Percentage__c,Commission_Per_Order__c,Id_List_Service_Price__c,CurrencyIsoCode,Has_Related_Tarif__c,Id,Id_List_Price_Product__c,Id_Opportunity__c,Installments__c,Listed_Price__c,Name,Product_Group__c,Quantity__c,Discount__c,RecordTypeId,Total_Amount__c,Sub_Type__c,Line_Item_Type__c,Recurring_Fee__c,Start_Date__c,End_Date__c FROM Opportunity_Line_Item__c where  Id_Opportunity__c =:listOpp[0].id ];
        List<Opportunity_Quote_Line_Item__c> listOppQuotelines = new List<Opportunity_Quote_Line_Item__c>();
        for(Opportunity_Line_Item__c oppQP : oppProductItem){
            Opportunity_Quote_Line_Item__c oppQuoteLine = new Opportunity_Quote_Line_Item__c(Id_List_Service_Price__c=oppQP.Id_List_Service_Price__c,Commission_In_Percentage__c=oppQP.Commission_In_Percentage__c,Commission_Per_Order__c=oppQP.Commission_Per_Order__c,End_Date__c=oppQP.End_Date__c,Recurring_Fee__c=oppQP.Recurring_Fee__c,Start_Date__c=oppQP.Start_Date__c,CurrencyIsoCode=listOpp[0].currencyIsoCode,Has_Related_Tarif__c=true,Id_List_Product_Price__c=oppQP.Id_List_Price_Product__c,Id_Opportunity_Quote__c=oppQuote.id,Installments__c=oppQP.Installments__c,Listed_Price__c=oppQP.Listed_Price__c,Name=oppQP.name,Product_Group__c=oppQP.Product_Group__c,Quantity__c=oppQP.Quantity__c,Discount__c=oppQP.Discount__c,RecordTypeId=mapRecordtypes.get('DH_AU_Opportunity_Quote_Line_Item').id,Total_Amount__c=oppQp.Total_Amount__c,Sub_Type__c=oppQp.Sub_Type__c,Line_Item_Type__c=oppQp.Line_Item_Type__c,Id_Opportunity__c=oppQp.Id_Opportunity__c);
            listOppQuotelines.add(oppQuoteLine);

        }
        insert listOppQuotelines;
        Test.startTest();
        listOpp[0].StageName = 'Closed Won';
        Test.stopTest();
        Sales_Target__c stResult = [select id,Closed_Deals__c from Sales_Target__c where id=:st.id];
        System.debug('stResult: '+stResult);
    }
      @isTest static void test_sweden_createOpp_negative() {
       // UnitTestDataFactory.testDataForSwedenOpportunityProcesses();
        Opportunity opp = [select id,StageName from Opportunity where name='TestOpp123'];
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
        List<Asset__c> listAsset = [select id from Asset__c where Opportunity__c=:opp.id];
        System.debug('listAsset list: '+listAsset);
        System.assert(listAsset.isEmpty());
    }*/