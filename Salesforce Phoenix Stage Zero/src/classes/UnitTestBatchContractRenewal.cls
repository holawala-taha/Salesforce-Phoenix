@isTest
private class UnitTestBatchContractRenewal {

    @testSetup static void setup() {
        Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Opportunity', 'Contract'});
        UnitTestDataFactory.getRecordtypeValues();

        Country__c bh = UnitTestDataFactory.createCountry('BH', 'Bahrain', 'BHD');
        Country__c ec = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert new List<Country__c> {ec, bh};

        Business_Config__c b1 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'CountriesEnabledForAutoRenewal', 'Bahrain', bh.id, 'Talabat_Contract', true, true);
        Business_Config__c b2 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'RenewForNumberOfMonths', '12', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b3 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'expiredContractStatus', 'Expired', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b4 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'renewalContractStatus', 'Activated', bh.id, 'Talabat_Contract', true, false);
        Business_Config__c b5 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'updateExpiredContracts', 'true', bh.id, 'Talabat_Contract', true, false);

        Business_Config__c b6 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'expiredContractStatus', 'Expired', ec.id, 'CD_Contract', true, true);
        Business_Config__c b7 = UnitTestDataFactory.createBusinessConfig('BatchContractRenewal', 'Process', 'updateExpiredContracts', 'true', ec.id, 'CD_Contract', true, false);
        insert new List<sObject> {b1, b2, b3, b4, b5, b6, b7};

        Account acc1 = UnitTestDataFactory.createAccount('BatchTestClassAccount1', bh, 'Talabat_Account');
        Account acc2 = UnitTestDataFactory.createAccount('cd account', ec, 'CD_Account');
        insert new List<Account> {acc1, acc2};

        Opportunity opp1 = new Opportunity(
            Setup_Fee_AU__c = 155,
            Start_Date_uk__c = Date.newInstance(2014, 12, 21),
            name = 'BatchTestOpp1',
            recordtypeid = mapRecordTypes.get('Talabat_Opportunity').id,
            AccountId = acc1.id,
            CloseDate = Date.newInstance(2014, 12, 21),
            StageName = 'Prospecting',
            TarrifName_AU__c = 'testTarif1',
            Is_DataLoaded__c = true,
            Migration_Notes_AU__c = 'Migration');

        Opportunity opp2 = new Opportunity(
            Setup_Fee_AU__c = 155,
            Start_Date_uk__c = Date.newInstance(2014, 12, 21),
            name = 'BatchTestOpp2',
            recordtypeid = mapRecordTypes.get('CD_Opportunity').id,
            AccountId = acc2.id,
            CloseDate = Date.newInstance(2014, 12, 21),
            StageName = 'Prospecting',
            TarrifName_AU__c = 'testTarif1',
            Is_DataLoaded__c = true,
            Migration_Notes_AU__c = 'Migration');
        insert new List<Opportunity> {opp1, opp2};

        Contract con1 = new Contract(name = 'test1',
                                     AccountId = acc1.id,
                                     Id_Opportunity__c = opp1.id,
                                     status = 'Draft',
                                     StartDate = Date.Today().addYears(-1),
                                     end_date__c = Date.Today(),
                                     recordtypeid = mapRecordTypes.get('Talabat_Contract').id);
        Contract con2 = new Contract(name = 'test2',
                                     AccountId = acc2.id,
                                     Id_Opportunity__c = opp2.id,
                                     status = 'Draft',
                                     StartDate = Date.Today().addYears(-1),
                                     end_date__c = Date.Today(),
                                     recordtypeid = mapRecordTypes.get('CD_Contract').id);
        insert new List<Contract> {con1, con2};

        con1.Status = 'Activated';
        con2.Status = 'Activated';
        update new List<Contract> {con1, con2};
    }

    @isTest static void batchContractRenewalDoesNothingIfNoBusinessConfig() {
        delete [select id from Business_Config__c];

        Contract c = [Select Status From Contract limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        c = [Select Status, End_Date__c From Contract where id = : c.Id];

        System.assertEquals('Activated', c.Status);
        System.assert(c.End_Date__c <= Date.today());
    }

    @isTest static void batchContractRenewalDoesNothingIfNoBusinessLogic() {
        delete [Select Id from Business_Config__c Where Record_Type_Id__c like 'Tal%'];

        Contract talabatC = [Select Id from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status From Contract Where Id = : talabatC.Id];

        System.assertEquals('Activated', talabatC.Status);
        System.assert(talabatC.End_Date__c <= Date.today());
    }

    @isTest static void batchContractRenewalRenewContractCorrectly() {
        Contract talabatC = [Select Id from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status, Last_renewal_date__c, Renewal_version__c From Contract WHere id = : talabatC.Id];

        System.assertEquals('Activated', talabatC.Status);
        System.assert(talabatC.End_Date__c > Date.today());
        System.assertEquals(1, talabatC.Renewal_version__c);
        System.assert(talabatC.Last_renewal_date__c >= Date.today());
    }

    @isTest static void batchContractRenewalDoesNotRenewContractIfAutoRenewIsDisabled() {
        Contract talabatC = [Select Do_not_auto_renew__c from Contract Where RecordType.DeveloperName = 'Talabat_Contract' limit 1];
        talabatC.Do_not_auto_renew__c = true;
        update talabatC;

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        talabatC = [Select End_Date__c, Status From Contract WHere id = : talabatC.Id];

        System.assertEquals('Expired', talabatC.Status);
        System.assert(talabatC.End_Date__c <= Date.today());
    }

    @isTest static void batchContractRenewalDoesNotRenewContractIfCountryIsNotEnabledForAutoRenewal() {
        Contract cdC = [Select Id From Contract Where RecordType.DeveloperName like 'CD%' limit 1];

        Test.startTest();

        Database.executeBatch(new BatchContractRenewal());

        Test.stopTest();

        cdC = [Select Status, End_Date__c From Contract WHere Id =: cdC.Id];

        System.assertEquals('Expired', cdC.Status);
        System.assert(cdC.End_Date__c <= Date.today());
    }
}