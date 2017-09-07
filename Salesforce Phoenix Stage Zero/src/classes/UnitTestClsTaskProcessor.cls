@isTest
private class UnitTestClsTaskProcessor {

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert c;

        Account a = UnitTestDataFactory.createAccount('test acc', c, 'CD_Account');
        insert a;

        Case cs = UnitTestDataFactory.createCase(a, 'New', 'CD Inbound', 'issue whatever', 'Phone', c, 'CD_Inbound', 'test');
        insert cs;

        Lead l = UnitTestDataFactory.createLeads(1, c, 'test', 'test', 'USD', 'test', 'CD_Lead')[0];
        insert l;
    }

    @isTest static void updateCaseLastCallDateWorksCorrectly() {
        Case c = [Select Id From Case Limit 1];

        Datetime res;

        Test.startTest();

        Task call = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert call;

        res = [select CreatedDate from Task where id =: call.Id].CreatedDate;

        Test.stopTest();

        c = [Select Last_Call_Date__c From Case where id =: c.Id];

        System.assertEquals(res, c.Last_Call_Date__c);
    }

    @isTest static void updateCaseLastCallDateDoesNothingIfTaskIsNotACallOrIsNotCompleted() {
        Case c = [Select Id From Case Limit 1];

        Test.startTest();

        // call not completed
        Task t1 = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'New',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        // not a call
        Task t2 = new Task(
            Type = 'Task',
            Subject = 'Test',
            WhatId = c.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert new List<Task>{t1, t2};

        Test.stopTest();

        c = [Select Last_Call_Date__c From Case where id =: c.Id];

        System.assertEquals(null, c.Last_Call_Date__c);
    }

    @isTest static void updateLeadLastCallDateWorksCorrectly() {
        Lead l = [select id from Lead limit 1];

        Datetime res;

        Test.startTest();

        Task call = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert call;

        res = [select CreatedDate from Task where id =: call.Id].CreatedDate;

        Test.stopTest();

        l = [Select Last_Call_Date__c From Lead Where Id =: l.Id];

        System.assertEquals(res, l.Last_Call_Date__c);
    }

    @isTest static void updateLeadLastCallDateDoesNothingIfTaskIsNotACallOrIsNotCompleted() {
        Lead l = [Select Id From Lead Limit 1];

        Test.startTest();

        // call not completed
        Task t1 = new Task(
            Type = 'Call',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'New',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        // not a call
        Task t2 = new Task(
            Type = 'Task',
            Subject = 'Test',
            WhoId = l.Id,
            Status = 'Completed',
            recordtypeId = LibRecordTypeHelper.getRecordTypeValue('CD_Task')
        );

        insert new List<Task>{t1, t2};

        Test.stopTest();

        l = [Select Last_Call_Date__c From Lead where id =: l.Id];

        System.assertEquals(null, l.Last_Call_Date__c);
    }



    @isTest static void legacyTestJustForCoverage() {
        List<Account> accounts;
        List<Account> accounts2;
        List<Opportunity> opportunities;
        List<Lead> ls;
        Case cs;


        Country__c testCountry = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        Country__c testCountry2 = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'GBP');
        insert testCountry;
        Company__c testCompany = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', testCountry);
        insert testCompany;
        accounts = UnitTestDataFactory.createAccounts(1, testCountry, 'Yogiyo_Account');
        accounts2 = UnitTestDataFactory.createAccounts(1, testCountry2, 'UK_Account');
        insert accounts;
        opportunities = UnitTestDataFactory.createOpportunities(accounts, 1, 'Yogiyo_Opportunity', Date.today().addMonths(2));
        insert opportunities;
        ls = UnitTestDataFactory.createLeads(2, testCountry, 'test', 'Yogiyo', 'KRW', 'test', 'Yogiyo_Lead');
        ls[0].Status = 'decision maker reached';
        ls[1].Status = 'employee reached';
        insert ls;
        cs = UnitTestDataFactory.createCase(accounts2[0], 'New', 'Restaurant Request', 'Transmission Issues', 'phone', testCountry2, 'UK_Inbound', 'Tablink Callback: Eve Richens');
        insert cs;

        ClsTaskProcessor ct = new ClsTaskProcessor();
        Task t1  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = opportunities[0].id, description = 'test it', ActivityDate = Date.today(), recordtypeId = LibRecordTypeHelper.getRecordTypeValue('Yogiyo_Task'));
        Task t2  = new Task(Subject = 'Email', Type = 'Call', status = 'New', whoid = ls[0].id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'decision maker reached');
        Task t3  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whoid = ls[0].id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'employee reached');
        Task t4  = new Task(Subject = 'Email', Type = 'Call', status = 'Completed', whatId = cs.Id, description = 'test it', ActivityDate = Date.today(), Activity_Subject__c = 'employee reached');
        insert new List<Task> {t1, t2, t3, t4};
    }
}