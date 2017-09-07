@isTest
private class UnitTestCtrRestaurantKPI {

    @testSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        c.Restaurant_Quality_Code__c = 'ABC';
        insert c;

        Account acc = UnitTestDataFactory.createAccount('acc 1', c, 'CD_Account');
        insert acc;

        insert new MidasIntegration__c(
            Name = 'RestaurantQuality',
            EndPoint__c = 'http://test.test',
            AuthenticationToken__c = 'Bearer token'
        );
    }

    @isTest static void CtrRestaurantKPIBuildCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);

        Test.stopTest();

        System.assertEquals(acc.Id, ctr.acc.Id);
    }

    @isTest static void getCallTaskReturnCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);

        Test.stopTest();

        System.assertNotEquals(null, ctr.callTask);
        System.assert(String.isBlank(ctr.callTask.Id));
    }

    @isTest static void getFollowUpCaseReturnCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);

        Test.stopTest();

        System.assertNotEquals(null, ctr.followUpCase);
        System.assert(String.isBlank(ctr.followUpCase.Id));
    }

    @isTest static void logCallCreateTaskCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        PageReference res;
        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);

        ctr.callTask.Subject = 'Test subject';

        res = ctr.logCall();

        Test.stopTest();

        Task[] calls = [
                           select id

                           from task

                           where WhatId = : acc.Id
                                          and IsClosed = true
                                                  and TaskSubtype = 'Call'
                                                          and Subject = 'Test subject'
                                                                  and Type = 'Restaurant Quality call'
                                                                          and ActivityDate = : Date.today()
                       ];

        // action function should return null
        System.assertEquals(null, res);
        System.assert(!calls.isEmpty());
        System.assertEquals(ctr.lastinsertedTask, calls[0].Id);
    }

    @isTest static void createFollowUpCaseReturnsCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        PageReference res;
        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);

        ctr.followUpCase.Type = 'test type';
        ctr.followUpCase.Reason = 'test reason';

        res = ctr.createFollowUpCase();

        Test.stopTest();

        Case[] followUpCases = [
                                   select id
                                   from Case
                                   where
                                   AccountId = :acc.Id
                                               and Type = 'test type'
                                                       and Reason = 'test reason'
                                                               and Origin = 'Restaurant Quality call'
                               ];

        // action function should return null
        System.assertEquals(null, res);
        System.assert(!followUpCases.isEmpty());
    }

    @isTest static void getRestaurantKPIsReturnsCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        ClsRestaurantQualityApi.ResponseWrapper result;

        Test.startTest();
        Test.setCurrentPage(pref);

        result = CtrRestaurantKPI.getRestaurantKPIs(acc.id, 'Ecuador');

        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest static void getRestaurantKPIsReturnsNullIfAccountIdIsBlank() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        ClsRestaurantQualityApi.ResponseWrapper result;

        Test.startTest();
        Test.setCurrentPage(pref);



        
        result = CtrRestaurantKPI.getRestaurantKPIs(null, 'Ecuador');

        Test.stopTest();

        System.assertEquals(null, result);
    }

    @isTest static void logCallRequestReturnsCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        Continuation con;
        Object response;
        CtrRestaurantKPI ctr;
        Boolean confMessage;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);
        ctr.callTask.Subject = 'ciao';
        ctr.logCall();
        con = (Continuation) ctr.logCallRequest();

        System.assert(String.isNotBlank(ctr.logCallRequestLabel));
        System.assertNotEquals(null, con);

        HttpResponse successRes = new HttpResponse();
        successRes.setStatusCode(200);
        successRes.setBody('whatever');

        ctr.testResponse = successRes;

        response = ctr.logCallResponse();
        confMessage = ApexPages.hasMessages(ApexPages.Severity.Confirm);

        Test.stopTest();

        System.assertEquals(null, response);
        System.assert(confMessage);
    }

    @isTest static void logCallRequestDeleteTaskIfResponseIsNotSuccessful() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        Continuation con;
        Object response;
        CtrRestaurantKPI ctr;
        Boolean errMessage;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);
        ctr.callTask.Subject = 'ciao';
        ctr.logCall();
        con = (Continuation) ctr.logCallRequest();

        System.assert(String.isNotBlank(ctr.logCallRequestLabel));
        System.assertNotEquals(null, con);

        HttpResponse errorRes = new HttpResponse();
        errorRes.setStatusCode(404);
        errorRes.setBody('whatever');

        ctr.testResponse = errorRes;

        response = ctr.logCallResponse();

        errMessage = ApexPages.hasMessages(ApexPages.Severity.Error);

        Test.stopTest();

        Task[] calls = [Select id from Task where id = :ctr.lastinsertedTask];

        System.assertEquals(null, response);
        System.assert(calls.isEmpty());
        System.assert(errMessage);
    }

    @isTest static void logCallRequestReturnsNullIfNoTaskCreated() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        Object res;
        CtrRestaurantKPI ctr;
        ApexPages.StandardController stdCtr;

        Test.startTest();

        Test.setCurrentPage(pref);

        stdCtr = new ApexPages.StandardController(acc);
        ctr = new CtrRestaurantKPI(stdCtr);
        res = ctr.logCallRequest();

        Test.stopTest();

        System.assertEquals(null, res);
    }

    @isTest static void unassignRestaurantReturnsCorrectly() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        ClsRestaurantQualityApi.ResponseWrapper result;

        Test.startTest();
        Test.setCurrentPage(pref);

        result = CtrRestaurantKPI.unassignRestaurant(acc.id, 'Ecuador');

        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest static void unassignRestaurantReturnsNullIfAccountIdIsBlank() {
        Account acc = [select id, Record_Country__c from Account limit 1];

        PageReference pref = Page.RestaurantKPI;
        pref.getParameters().put('id', acc.Id);

        ClsRestaurantQualityApi.ResponseWrapper result;

        Test.startTest();
        Test.setCurrentPage(pref);

        result = CtrRestaurantKPI.unassignRestaurant(null, 'Ecuador');

        Test.stopTest();

        System.assertEquals(null, result);
    }
}