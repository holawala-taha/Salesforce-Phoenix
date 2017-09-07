@isTest
/*
@author : Terence Viban - vibanterence@gmail.com
@reviewer : 
@creation : 12.01.2015

@notes: 
*/
private class UnitTestClsLeadProcessor {
    private static User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Team', 'yogiyotestuser@test.com', 'Yogiyo','KR');
     public static Map<String,RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String>{'Lead','Case','Contact','Opportunity','Account', 'Contact', 'Contract', 'List_Product_Group__c','List_Product_Price__c','List_Service_Price__c','Tarif__c','Tarif_Member__c','Opportunity_Tarif_Item__c','Opportunity_Product_Item__c','Opportunity_Service_Item__c','Opportunity_Quote__c',/* 'Opportunity_Quote_Product_Item__c', 'Opportunity_Quote_Service_Item__c',*/ 'Asset__c','Stock_Item__c', 'Additional_Charges__c', 'Opportunity_Line_Item__c', 'Opportunity_Quote_Line_Item__c'});
    
    private static Country__c testCountry;
    private static Company__c testCompany;
    private static List<Lead> leads;
    private static List<Territory__c> tr;
       

    static {
        UnitTestDataFactory.getRecordtypeValues();
        insert testUser;
        List<Platform_Country__c> platformCountry =new List<Platform_Country__c>(); 
        platformCountry.add(new Platform_Country__c(name='TalabatPlatform',country__c='Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name='FOCPlatform', country__c='Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;
        List<GlobalAPIProfile__c> globalAPiProfile=new List<GlobalAPIProfile__c>(); 
        globalAPiProfile.add(new GlobalAPIProfile__c(name='ProfileId',value__c=testUser.id));
        insert globalAPiProfile;
        System.runAs(testUser){
            testCountry = UnitTestDataFactory.createCountry('KR','Korea','KRW');
            insert testCountry;

            testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
            insert testCompany;

            List<Business_Config__c> listConfigs = new List<Business_Config__c>();
            Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'FieldsToQuery', 'Dong__c,GunGu__c,Subdistrict__c,Id,OwnerId,MobilePhone,Email,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,RecordTypeId,RecordType.DeveloperName,Street,City,PostalCode,Country,Fax,Phone,LeadSource,Status,State,Name,Company,Salutation,FirstName,LastName,Country__c,Record_Country__c,CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, true);
            Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'ContactInformationFieldsToDisplay', 'Salutation,FirstName,LastName,MobilePhone,Phone,Fax,Email', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'AccountInformationFieldsToDisplay', 'Street,Subdistrict__c,GunGu__c,Dong__c,City,PostalCode,State,Country', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadInformationFieldsToDisplay', 'OwnerId,LeadSource,Status,Country__c', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'MandatoryFields', 'OwnerId,Company,Country__c', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'true', testCountry.Id, 'Yogiyo_Lead', true, false);
            insert config6;
            
            Business_Config__c config7 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadToAccountMap', 'Record_Country__c=Record_Country__c,Account_Email__c=Email,Non_Contracted__c=Non_Contracted__c=ShippingStreet=Street,ShippingCity=City,ShippingPostalCode=PostalCode,ShippingCountry=Country,ShippingState=State,Shipping_Subdistrict__c=Subdistrict__c,CurrencyIsoCode=CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config8 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadFieldsToQueryAfterConversion', 'Record_Country__c,Email,Non_Contracted__c,Street,City,PostalCode,Country,State,Subdistrict__c,CurrencyIsoCode', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config9 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'TerritoryFieldToCompare', 'name', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config10 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'TerritoryType', 'Comma separated', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config11 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'EnableTerritory', 'true', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config12 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'nonContractedFlag', 'true', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config13 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'MandatoryFieldsNonContracted', 'name', testCountry.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config14 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'DefaultStageProbability', 'StageName=Prospecting,Probability=20', testCountry.Id, 'Yogiyo_Lead', true, false);
            
            insert new List<sObject>{config1, config2, config3, config4, config5, config7, config8, config9, config10, config11, config12, config13, config14};
            
            leads = UnitTestDataFactory.createLeads (1, testCountry, 'Mustermann', 'Yogiyo', 'KRW', 'Mustermann Food', 'Yogiyo_Lead');
            leads[0].order_date__c=system.today();
            leads[0].commission__c=12;
            leads[0].Tariff_Name__c='test';
            leads[0].non_standard_contract_components__c='BladeT&C';
            insert leads;
            leads[0].Non_Contracted__c=true;
            update leads[0];
            tr= new List<territory__c>();
            tr.add(new territory__c(type__C='Comma separated',account_record_type__C='yogiyo_Account', values__c='Yogiyo' ));
            insert tr;
            
        }
    }
    
    @isTest static void test_processLeadConversion_missingBusinessConfig() {
        Test.startTest();
            System.runAs(testUser){
                ClsLeadProcessor.processLeadConversion(leads[0].Id, testCompany.Company_Code__c,true);
            }
        Test.stopTest();

        //System.assertEquals(2, ClsLeadProcessor.results.size());
        //System.assertEquals('error', ClsLeadProcessor.results[0]);
        //System.assertEquals(true, ClsLeadProcessor.skipConversion);
        //System.assertEquals('', ClsLeadProcessor.skipConversionPage);   
    }
    
    @isTest static void test_processLeadConversion_skipConversion() {
        Test.startTest();
            System.runAs(testUser){
                Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'false', testCountry.Id, 'Yogiyo_Lead', true, false);
                insert config6;
                ClsLeadProcessor.processLeadConversion(leads[0].Id, testCompany.Company_Code__c,true);
            }
        Test.stopTest();

        System.assertEquals(2, ClsLeadProcessor.results.size());
        //System.assertEquals('success', ClsLeadProcessor.results[0]);
        //System.assertEquals('showConversionPage', ClsLeadProcessor.results[1]);
        System.assertEquals(true, ClsLeadProcessor.skipConversion);
        //System.assertEquals('false', ClsLeadProcessor.skipConversionPage);
    }
    
    @isTest static void test_processLeadConversion_convert() {
        Test.startTest();
            System.runAs(testUser){
               // Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'true', testCountry.Id, 'Yogiyo_Lead', true, false);
               // insert config6;
                ClsLeadProcessor.processLeadConversion(leads[0].Id, testCompany.Company_Code__c,true);
            }
        Test.stopTest();

        Lead convertedLead = [SELECT Id,isConverted,Company, LastName FROM Lead WHERE Id =: leads[0].Id];
        //System.assert(convertedLead.isConverted);

        Account createdAccount = [SELECT Id FROM Account WHERE Name=:convertedLead.Company];
        
        System.assertNotEquals(null, createdAccount);

        Opportunity createdOpp = [SELECT Id, Name FROM Opportunity WHERE AccountId =: createdAccount.Id];
        System.assertNotEquals(null, createdOpp);
        System.assertNotEquals(leads[0].Name, createdOpp.Name);

        Contact createdContact = [SELECT Id, Contact_Role__c, LastName FROM Contact Where AccountId =: createdAccount.Id];
        System.assertEquals(convertedLead.LastName, createdContact.LastName);
        System.assertEquals('Owner', createdContact.Contact_Role__c);

        System.assertEquals(2, ClsLeadProcessor.results.size());
        //System.assertEquals('success', ClsLeadProcessor.results[0]);
        //System.assertEquals(createdAccount.Id, ClsLeadProcessor.results[1]);
        //System.assertEquals(true, ClsLeadProcessor.skipConversion);
        //System.assertEquals('true', ClsLeadProcessor.skipConversionPage);
    }
     @isTest static void testLeadConvert() {
          Country__c con = UnitTestDataFactory.createCountry('UK','United Kingdom','GBP');
            insert con;

            Company__c com= UnitTestDataFactory.createCompany('Hungryhouse', 'uk', testCountry);
            insert com;

            List<Business_Config__c> listConfigs = new List<Business_Config__c>();
            Business_Config__c config1 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'FieldsToQuery', 'Dong__c,GunGu__c,Subdistrict__c,Id,OwnerId,MobilePhone,Email,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,RecordTypeId,RecordType.DeveloperName,Street,City,PostalCode,Country,Fax,Phone,LeadSource,Status,State,Name,Company,Salutation,FirstName,LastName,Country__c,Record_Country__c,CurrencyIsoCode', con.Id, 'UK_Lead', true, true);
            Business_Config__c config2 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'ContactInformationFieldsToDisplay', 'Salutation,FirstName,LastName,MobilePhone,Phone,Fax,Email', con.Id, 'UK_Lead', true, false);
            Business_Config__c config3 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'AccountInformationFieldsToDisplay', 'Street,Subdistrict__c,GunGu__c,Dong__c,City,PostalCode,State,Country', con.Id, 'UK_Lead', true, false);
            Business_Config__c config4 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadInformationFieldsToDisplay', 'OwnerId,LeadSource,Status,Country__c', con.Id, 'UK_Lead', true, false);
            Business_Config__c config5 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'MandatoryFields', 'OwnerId,Company,Country__c', testCountry.Id, 'UK_Lead', true, false);
            Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'true', con.Id, 'UK_Lead', true, false);
            insert config6;
            
            Business_Config__c config7 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadToAccountMap', 'Record_Country__c=Record_Country__c,Account_Email__c=Email,Non_Contracted__c=Non_Contracted__c=ShippingStreet=Street,ShippingCity=City,ShippingPostalCode=PostalCode,ShippingCountry=Country,ShippingState=State,Shipping_Subdistrict__c=Subdistrict__c,CurrencyIsoCode=CurrencyIsoCode', con.Id, 'UK_Lead', true, false);
            Business_Config__c config8 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'LeadFieldsToQueryAfterConversion', 'Record_Country__c,Email,Non_Contracted__c,Street,City,PostalCode,Country,State,Subdistrict__c,CurrencyIsoCode', con.Id, 'UK_Lead', true, false);
            Business_Config__c config9 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'TerritoryFieldToCompare', 'name', con.Id, 'Yogiyo_Lead', true, false);
            Business_Config__c config10 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'TerritoryType', 'Comma separated', con.Id, 'UK_Lead', true, false);
            Business_Config__c config11 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'EnableTerritory', 'true', con.Id, 'UK_Lead', true, false);
            Business_Config__c config12 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'nonContractedFlag', 'true', con.Id, 'UK_Lead', true, false);
            Business_Config__c config13 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'MandatoryFieldsNonContracted', 'name', con.Id, 'UK_Lead', true, false);
            Business_Config__c config14 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'DefaultStageProbability', 'StageName=Prospecting,Probability=20', con.Id, 'UK_Lead', true, false);
            
            insert new List<sObject>{config1, config2, config3, config4, config5, config7, config8, config9, config10, config11, config12, config13, config14};
            
            leads = UnitTestDataFactory.createLeads (1, con, 'Mustermann', 'UK', 'GBP', 'Mustermann Food', 'UK_Lead');
            leads[0].order_date__c=system.today();
            leads[0].commission__c=12;
            leads[0].Tariff_Name__c='test';
            leads[0].non_standard_contract_components__c='BladeT&C';
            insert leads;
            leads[0].Non_Contracted__c=true;
            leads[0].ownerid=userinfo.getuserid();
            update leads[0];
            
             Tarif__c tarifs= (new Tarif__c( Name = 'test' , Company__c = com.Id, 
                    Id_Country__c = con.Id,
                    Is_Active__c = false,
                    RecordtypeId = mapRecordtypes.get('UK_Tarif').Id));
           
        
        insert tarifs;
        tarifs.is_Active__c=true;
        update tarifs;
        List_Product_Group__c lpg = UnitTestDataFactory.createProductGroup(com,testCountry,'Apple','UK_List_Product_Group');
        List_Product_Group__c lpg1 = UnitTestDataFactory.createProductGroup(com,testCountry,'Setup Fee','UK_List_Product_Group');
        insert new List<SObject>{lpg,lpg1};

        List_Product_Price__c lpp = UnitTestDataFactory.createProduct(com,testCountry,'Ipad 4 Gen. 16GB',lpg.id,'UK_List_Product_Price',1,true,100,1,false,20);
        List_Product_Price__c lpp1 = UnitTestDataFactory.createProduct(com,testCountry,'Super Hero Setup 1',lpg1.id,'UK_List_Product_Price',1,true,100,1,false,20);
        List_Service_Price__c lsp = UnitTestDataFactory.createService(com,testCountry,'testService1','UK_List_Service_Price',12,12,25,5,null,true,null,'Commission Fee','Commission Fee');
        //insert lsp;
        insert new List<sObject>{lpp,lpp1,lsp};
        Tarif_Member__c tr1= new Tarif_Member__c(Id_Tarif_Item__c=lpp1.id,Tarif_Name__c=tarifs.id,type__c='Product');
        Tarif_Member__c tr2= new Tarif_Member__c(Id_Tarif_Item__c=lsp.id,Tarif_Name__c=tarifs.id,type__c='Service');
        insert new List<sObject>{tr1,tr2};
        Test.startTest();
          //  System.runAs(testUser){
               // Business_Config__c config6 = UnitTestDataFactory.createBusinessConfig('Lead Conversion', 'Process', 'SkipConversionPage', 'true', testCountry.Id, 'Yogiyo_Lead', true, false);
               // insert config6;
                ClsLeadProcessor.processLeadConversion(leads[0].Id, testCompany.Company_Code__c,true);
          //  }
        Test.stopTest();

        Lead convertedLead = [SELECT Id,isConverted,Company, LastName FROM Lead WHERE Id =: leads[0].Id];
        //System.assert(convertedLead.isConverted);

        Account createdAccount = [SELECT Id FROM Account WHERE Name=:convertedLead.Company];
        
        System.assertNotEquals(null, createdAccount);

        Opportunity createdOpp = [SELECT Id, Name FROM Opportunity WHERE AccountId =: createdAccount.Id];
        System.assertNotEquals(null, createdOpp);
        //System.assertNotEquals(leads[0].Name, createdOpp.Name);
        clsLEadPRocessor.leadToQuoteProcess(createdOpp.id);

        Contact createdContact = [SELECT Id, Contact_Role__c, LastName FROM Contact Where AccountId =: createdAccount.Id];
        System.assertEquals(convertedLead.LastName, createdContact.LastName);
        System.assertEquals('Owner', createdContact.Contact_Role__c);

        System.assertEquals(2, ClsLeadProcessor.results.size());
        //System.assertEquals('success', ClsLeadProcessor.results[0]);
        //System.assertEquals(createdAccount.Id, ClsLeadProcessor.results[1]);
        //System.assertEquals(true, ClsLeadProcessor.skipConversion);
        //System.assertEquals('true', ClsLeadProcessor.skipConversionPage);
    }
    
}