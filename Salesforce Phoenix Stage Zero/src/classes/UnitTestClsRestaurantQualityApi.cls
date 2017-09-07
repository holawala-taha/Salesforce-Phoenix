@isTest
private class UnitTestClsRestaurantQualityApi {

    static Boolean RESPONSE_OK;
    static final String RESPONSE_BODY_OK = '{"foo":"bar"}';
    static final String RESPONSE_BODY_ERROR = 'Error';

    // used to check if postPhoneCallsFuture makes the callout
    static Boolean postPhoneCallCalled;

    public class MockHttpPostPhoneCalls implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            postPhoneCallCalled = true;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (RESPONSE_OK) {
                res.setBody(RESPONSE_BODY_OK);
                res.setStatusCode(200);
            } else {
                res.setBody(RESPONSE_BODY_ERROR);
                res.setStatusCode(400);
            }
            return res;
        }
    }

    @testSetup
    static void setup() {
        insert new MidasIntegration__c(
            Name = 'RestaurantQuality',
            EndPoint__c = 'http://test.test',
            AuthenticationToken__c = 'Bearer token'
        );
    }

    @isTest
    static void displayRestaurantsListReturnsorrectlyIfStatusCodeIs200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = true;

        res = ClsRestaurantQualityApi.displayRestaurantsList('test');

        Test.stopTest();

        System.assert(!res.inError);
        System.assertEquals(res.response, RESPONSE_BODY_OK);
    }

    @isTest
    static void getRestaurantKpisReturnsErrorResponseIfMidasNotConfigured() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        delete [select id from MidasIntegration__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        res = ClsRestaurantQualityApi.getRestaurantKPIs('test', 'test');

        Test.stopTest();

        System.assert(res.inError);
    }

    @isTest
    static void getRestaurantKpisReturnsErrorResponseIfStatusCodeDifferentFrom200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = false;

        res = ClsRestaurantQualityApi.getRestaurantKPIs('test', 'test');

        Test.stopTest();

        System.assert(res.inError);
    }

    @isTest
    static void getRestaurantKpisReturnsorrectlyIfStatusCodeIs200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = true;

        res = ClsRestaurantQualityApi.getRestaurantKPIs('test', 'test');

        Test.stopTest();

        System.assert(!res.inError);
        System.assertEquals(res.response, RESPONSE_BODY_OK);
    }

    @isTest static void postPhoneCallMakesCalloutToBackEnd() {
        Task t = new Task(
            Activity_Subject__c = 'Call - Decision maker reached',
            ActivityDate = Date.today(),
            Description = 'Test',
            Topis_Discussed__c = 'New Sign up;Premium Placement'
        );
        insert t;

        String label;

        Test.startTest();

        label = ClsRestaurantQualityApi.postPhoneCallsContinuation(new Continuation(10), 'test', 'test', new List<Task> {t});

        Test.stopTest();

        System.assert(String.isNotBlank(label));
    }

    // start new test
    @isTest
    static void assignRestaurantReturnsErrorResponseIfMidasNotConfigured() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        delete [select id from MidasIntegration__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        res = ClsRestaurantQualityApi.assignRestaurant('test', 'test');

        Test.stopTest();

        System.assert(res.inError);
    }

    @isTest
    static void assignRestaurantReturnsErrorResponseIfStatusCodeDifferentFrom200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = false;

        res = ClsRestaurantQualityApi.assignRestaurant('test', 'test');

        Test.stopTest();

        System.assert(res.inError);
    }

    @isTest
    static void assignRestaurantReturnsorrectlyIfStatusCodeIs200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = true;

        res = ClsRestaurantQualityApi.assignRestaurant('test', 'test');

        Test.stopTest();

        System.assert(!res.inError);
        System.assertEquals(res.response, RESPONSE_BODY_OK);
    }

    @isTest
    static void unassignRestaurantReturnsorrectlyIfStatusCodeIs200() {
        ClsRestaurantQualityApi.ResponseWrapper res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RESPONSE_OK = true;

        res = ClsRestaurantQualityApi.unassignRestaurant('test', 'test');

        Test.stopTest();

        System.assert(!res.inError);
        System.assertEquals(res.response, RESPONSE_BODY_OK);
    }
}