/*
 * Controller per DERestaurantKPI page
 */
public with sharing class CtrRestaurantKPI {

    public Task callTask {
        get {
            if (callTask == null) {
                callTask = new Task(
                        RecordTypeId = LibRecordTypeHelper.getDefaultRecordTypeId(Task.SObjectType),
                        WhatId = acc.Id,
                        Status = 'Completed',
                        Type = 'Restaurant Quality call',
                        Subject = 'Call',
                        TaskSubtype = 'Call',
                        ActivityDate = Date.today());
            }
            return callTask;
        }
        set;
    }

    public Case followUpCase {
        get {
            if (followUpCase == null) {
                followUpCase = new Case(
                        Origin = 'Restaurant Quality call',
                        AccountId = acc.Id);
            }
            return followUpCase;
        }

        set;
    }

    // current account
    public Account acc { get; private set; }

    // restaurant owner name
    public String ownerName { get; private set; }

    @testVisible
    private String logCallRequestLabel;
    @testVisible
    private Id lastinsertedTask;

    private ApexPages.StandardController stdCtr;

    public CtrRestaurantKPI(ApexPages.StandardController stdCtr) {
        this.stdCtr = stdCtr;
        this.acc = (Account) stdCtr.getRecord();

        // set account owner
        for (Contact cnt : [
                Select Name
                From Contact
                Where Contact_Role__c = 'Owner'
                And AccountId = :acc.id
                Limit 1
        ]) {
            ownerName = cnt.Name;
        }
    }

    /* ********* ACTION METHODS ********* */

    public PageReference logCall() {
        System.debug('CtrRestaurantKPI.logCall: start');

        SavePoint svPnt = Database.setSavePoint();
        lastinsertedTask = null;

        try {
            System.debug('CtrRestaurantKPI.logCall: callTask is : ' + callTask);
            insert callTask;
            lastinsertedTask = callTask.id;
            System.debug('CtrRestaurantKPI.logCall: callTask id is: ' + lastinsertedTask);
        } catch (Exception e) {
            System.debug('CtrRestaurantKPI.logCall: exception occurred. Message is: ' + e.getMessage());
            Database.rollback(svPnt);
            ClsUtilsApexPages.addErrorMessage('Impossible to save call: ' + e.getMessage());
        }

        System.debug('CtrRestaurantKPI.logCall: done');
        return null;
    }

    /**
    * Called when user submit the log a call form
    * If an error occurs add an error message to current page.
    * @return always null
    */
    public Object logCallRequest() {
        System.debug('CtrRestaurantKPI.logCallRequest: start');

        // checks lastinsertedTask
        if (String.isBlank(lastinsertedTask)) {
            System.debug('CtrRestaurantKPI.logCallRequest: no call to post');
            return null;
        }
        // retrieves task to send the backend
        List<Task> phoneCalls = [
                SELECT
                        Activity_Subject__c,
                        Description,
                        ActivityDate,
                        Next_Call_Time__c,
                        Topis_Discussed__c,
                        CallDurationInSeconds
                FROM Task
                WHERE Id = :callTask.Id
        ];

        Continuation con = new Continuation(40);
        con.continuationMethod = 'logCallResponse';

        System.debug('CtrRestaurantKPI.logCallRequest: posting phone call to backend: ' + callTask);

        // post created task to the backend
        logCallRequestLabel = ClsRestaurantQualityApi.postPhoneCallsContinuation(
                con,
                getCountryBrandByCountryName(acc.Record_Country__c),
                String.valueOf(acc.Id).substring(0, 15),
                phoneCalls);

        System.debug('CtrRestaurantKPI.logCallRequest: sending request...');
        return con;
    }

    public Object logCallResponse() {
        System.debug('CtrRestaurantKPI.logCallResponse: start...');

        ClsRestaurantQualityApi.ResponseWrapper result;
        HttpResponse res = Test.isRunningTest() ? testResponse : Continuation.getResponse(logCallRequestLabel);

        System.debug('CtrRestaurantKPI.logCallResponse: response is: ' + res);
        System.debug('CtrRestaurantKPI.logCallResponse: response body is: ' + res.getBody());

        if (res.getStatusCode() == 200) {
            ClsUtilsApexPages.addConfirmMessage('Call saved successfully!');
        } else {
            ClsUtilsApexPages.addErrorMessage('Impossible to register call, error code is: ' + res.getStatusCode());
            try {
                System.debug('CtrRestaurantKPI.logCallResponse: deleting last task');
                delete [Select Id from Task where Id = :lastinsertedTask];
            } catch (Exception e) {
                System.debug('CtrRestaurantKPI.logCallResponse: exception occurred. Message is: ' + e.getMessage());
            }
        }

        // reset task
        callTask = null;

        System.debug('CtrRestaurantKPI.logCallResponse: done');
        return null;
    }

    /**
     * Called when user submit the follow up case form.
     * If an error occurs add an error message to current page.
     * @return always null
     */
    public PageReference createFollowUpCase() {
        System.debug('CtrRestaurantKPI.createFollowUpCase: start');

        SavePoint savePnt = Database.setSavePoint();

        try {

            System.debug('CtrRestaurantKPI.createFollowUpCase: case is: ' + followUpCase);

            // use assignment rules
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            followUpCase.setOptions(dmo);

            insert followUpCase;

            // reset case
            followUpCase = null;

            ClsUtilsApexPages.addConfirmMessage('Case saved correctly');

            System.debug('CtrRestaurantKPI.createFollowUpCase: case inserted correctly');
        } catch (Exception ex) {
            System.debug('CtrRestaurantKPI.createFollowUpCase: exception occurred. Message is: ' + ex.getMessage() + ' Stacktrace is: ' + ex.getStackTraceString());
            ClsUtilsApexPages.addErrorMessage('Impossible to save case: ' + ex.getMessage());
            Database.rollback(savePnt);
        }

        System.debug('CtrRestaurantKPI.createFollowUpCase: done');
        return null;
    }

    /* REMOTE ACTIONS */

    /**
    * Retrieves the list of failed Orders
    * @param accountId Salesforce account id
    * @param countryName Account's country
    * @return an instance of ResponseWrapper.
    */
    @RemoteAction
    public static ClsRestaurantQualityApi.ResponseWrapper getFailedOrders(String accountId, String countryName) {
        system.debug('getfailedOrders executing ');
        ClsRestaurantQualityApi.ResponseWrapper result;
        System.debug('CtrRestaurantKPI.getFailedOrders start... AccountId is: ' + accountId);

        if (String.isBlank(accountId)) {
            return null;
        }
        result = ClsRestaurantQualityApi.displayFailedOrdersList(
                getCountryBrandByCountryName(countryName),
                accountId.substring(0, 15)
        );
        System.debug('CtrRestaurantKPI.getFailedOrders done. Result is ' + result);
        return result;
    }


    /**
     * Retrieves the KPIs for the specified account
     * @param  accountId Sfdc account id
     * @param countryName Account's country name
     * @return           BigData system response body if no error occurs. Otherwise
     * an error description
     */
    @RemoteAction
    public static ClsRestaurantQualityApi.ResponseWrapper getRestaurantKPIs(String accountId, String countryName) {
        ClsRestaurantQualityApi.ResponseWrapper result;

        System.debug('CtrRestaurantKPI.getRestaurantKPIs: start. AccountId is: ' + accountId);

        if (String.isBlank(accountId)) {
            return null;
        }

        result = ClsRestaurantQualityApi.getRestaurantKPIs(
                getCountryBrandByCountryName(countryName),
                accountId.substring(0, 15)
        );

        System.debug('CtrRestaurantKPI.getRestaurants: done. Result is ' + result);
        return result;
    }

    /**
     * Unassign specified restaurant to current user
     * @param  accountId   Salesforce account id
     * @param  countryName Account's country name
     * @return             BigData system response body if no error occurs. Otherwise
     * an error description
     */
    @RemoteAction
    public static ClsRestaurantQualityApi.ResponseWrapper unassignRestaurant(String accountId, String countryName) {
        if (String.isBlank(accountId)) {
            return null;
        }

        return ClsRestaurantQualityApi.unassignRestaurant(
                getCountryBrandByCountryName(countryName),
                accountId.substring(0, 15)
        );
    }

    /* ********* HELPERS METHOD ********* */

    /**
     * Retrieves the restaurant quality's country brand code to send to API based
     * on country name
     * @param  countryName Country name
     * @return             Country brand or null
     */
    private static String getCountryBrandByCountryName(String countryName) {
        for (Country__c cnt : [
                SELECT Restaurant_Quality_Code__c
                FROM Country__c
                WHERE Name = :countryName
                AND Restaurant_Quality_Code__c != ''
        ]) {
            return cnt.Restaurant_Quality_Code__c;
        }
        return null;
    }

    // this is used only during Unit Test to mock the continuation response.
    // this is because a sfdc bug that do not allow to create mock during tests
    @testVisible
    private transient HttpResponse testResponse;
}