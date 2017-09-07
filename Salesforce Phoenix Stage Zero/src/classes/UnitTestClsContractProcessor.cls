@isTest
private class UnitTestClsContractProcessor {

    private static List<Contract> newContracts = new List<Contract>();
    private static List<Contract> oldContracts = new List<Contract>();
    private static List<Account> accounts;
    private static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Contract'});


    @testsetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();
        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;

        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        insert testCountry;

        Business_Config__c config = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.Id, 'Yogiyo_Contract', true, true);
        insert config;
    }

    static void setupUserData(User u) {
        System.runAs(u) {
            //Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
            //insert testCountry;
            Country__c testCountry = [Select Iso__c,
                                      Name,
                                      CurrencyIsoCode
                                      From Country__c
                                      Where Iso__c = 'KR' ];

            accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
            insert accounts;

            for (Integer i = 1; i < 11; i++) {
                oldContracts.add(new Contract(
                                     AccountId = accounts[0].Id,
                                     StartDate = Date.today().addDays(i + 1),
                                     End_Date__c = Date.today().addDays(i + 2),
                                     Status = 'Draft',
                                     RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id
                                 )
                                );
            }
            oldContracts.add(new Contract(AccountId = accounts[0].Id, StartDate = Date.today(), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

            for (Integer i = 12; i < 212; i++) {
                newContracts.add(new Contract(
                                     AccountId = accounts[0].Id,
                                     StartDate = Date.today().addDays(i + 1),
                                     End_Date__c = Date.today().addDays(i + 2),
                                     Status = 'Draft',
                                     RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id
                                 )
                                );
            }
            newContracts.add(new Contract(AccountId = accounts[0].Id, StartDate = Date.today().addDays(1), Status = 'Draft', RecordTypeId = mapRecordtypes.get('Yogiyo_Contract').Id));

            //Business_Config__c config = UnitTestDataFactory.createBusinessConfig('ContractCreation', 'Process', 'GroupBeforeSorting', 'false', testCountry.Id, 'Yogiyo_Contract', true, true);

            //insert config;
        }
    }

    @isTest static void test_noContractsAvailableOnAccountYet() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryherotest.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            insert newContracts;
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        // Nothing happens
        System.assertEquals(null, newContracts[newContracts.size() - 1].End_Date__c);
    }

    @isTest static void test_contractsOnAccountPreventDuplicates() {
        User testUser = UnitTestDataFactory.createUser('Yogiyo Sales Management', 'testUser@deliveryherotest.com', 'Yogiyo', 'KR');
        Test.startTest();
        System.runAs(testUser) {
            setupUserData(testUser);
            insert oldContracts;
            insert newContracts;
            ClsContractProcessor.preventDuplicateContracts(newContracts);
        }
        Test.stopTest();

        Set<Id> conIds = new Set<Id>();
        for (Contract cont : oldContracts) {
            conIds.add(cont.Id);
        }

        Boolean allTerminated = true;
        List<Contract> contracts = [SELECT Id, status, StartDate, End_Date__c FROM Contract WHERE Id IN :conIds];
        Contract con = [SELECT Id, status, End_Date__c FROM Contract WHERE Id = : oldContracts[oldContracts.size() - 1].Id];

        // Check to make sure that all previous contacts with a start date greated than the start date of the earliest new contract are terminated.
        /*for(Contract cont : contracts){
            if((cont.Id != con.Id) && (cont.Status != 'Terminated')){
                allTerminated = false;
            }
        }*/

        // System.assertEquals(Date.today(), con.End_Date__c);
        System.assertEquals('Draft', con.Status);
        //System.assertEquals(true, allTerminated);
    }
}