/**
 * Expose method to interact with Restaurant Quality API.
 */
public class ClsRestaurantQualityApi {


    // these are the api module endpoints
    private static final String  MIDAS_CONFIG = 'RestaurantQuality',                                    // midas configuration id
                                 RESTAURANTS_LIST = 'api/sites/{0}/restaurants',                        // poor restaurants list
                                 RESTAURANT_KPIS = 'api/sites/{0}/restaurants/sf:{1}',                  // restaurant kpis
                                 RESTAURANT_FAIL_ORDERS = 'api/sites/{0}/restaurants/sf:{1}/orders',
                                 POST_PHONE_CALLS = 'api/sites/{0}/restaurants/sf:{1}/phone_calls',     // post back phone call
                                 ASSIGN_RESTAURANT  = 'api/sites/{0}/restaurants/assign',               // assign restaurant to current agent
                                 UNASSIGN_RESTAURANT = 'api/sites/{0}/restaurants/unassign';            // unassign a restaurant to current user

    /* ********** API MODULE CALLS ********** */

    /**
     * Assign specified restaurant, or a random one, to current agent
     * @param  countryBrand Country brand code
     * @param  sfAccountId  Optional, specify which account user want to take ownership
     * @return              An instance of ResponseWrapper. If an error occurs set
     * inError flag to true
     */
    public static ResponseWrapper assignRestaurant(String countryBrand, String sfAccountId) {
        AssignRequestWrapper req = new AssignRequestWrapper(sfAccountId);
        return doSyncApiCallout(ASSIGN_RESTAURANT, new List<String> {countryBrand}, 'POST', JSON.serialize(req, true));
    }

    /**
     * unassign specified restaurant to current agent
     * @param  countryBrand Country brand code
     * @param  sfAccountId  Specify which account user want to take ownership
     * @return              An instance of ResponseWrapper. If an error occurs set
     * inError flag to true
     */
    public static ResponseWrapper unassignRestaurant(String countryBrand, String sfAccountId) {
        AssignRequestWrapper req = new AssignRequestWrapper(sfAccountId);
        return doSyncApiCallout(UNASSIGN_RESTAURANT, new List<String> {countryBrand}, 'POST', JSON.serialize(req, true));   
    }

    /**
     * Retrieves a list of poor restaurants but do NOT assign them to current
     * user.
     * @param  countryBrand Country brand code
     * @return              An instance of ResponseWrapper. If an error occurs
     * set inError field to true
     */
    public static ResponseWrapper displayRestaurantsList(String countryBrand) {
        return doSyncApiCallout(RESTAURANTS_LIST, new List<String> {countryBrand}, 'GET', null);
    }
    
    /**
     * Retrieves a list of failed Orders 
     * @param  countryBrand Country brand code
     * @return An instance of ResponseWrapper. If an error occurs
     * set inError field to true
     */
    public static ResponseWrapper displayFailedOrdersList(String countryBrand, String sfAccountId) {
    	system.debug('Start Executing displayFailedOrdersList');
        return doSyncApiCallout(RESTAURANT_FAIL_ORDERS, new List<String> {countryBrand,sfAccountId}, 'GET', null);
    }

    /**
     * Given a salesforce account id retrieves his Kpis detail
     * @param  countryBrand Country brand code
     * @param  sfAccountId  Salesforce account id
     * @return              An instance of ResponseWrapper. If an error occurred set the
     * inError field to true
     */
    public static ResponseWrapper getRestaurantKPIs(String countryBrand, String sfAccountId) {
        return doSyncApiCallout(RESTAURANT_KPIS, new List<String> {countryBrand, sfAccountId}, 'GET', null);
    }

    /**
     * Post to backend system a list of phone calls inserted in salesforce
     * @param con Continuation instance
     * @param  countryBrand Country brand code
     * @param  sfAccountId Salesforce account id
     * @param  phoneCalls   task records to send as phone calls
     * @return Continuation request id
     */
    public static String postPhoneCallsContinuation(Continuation con, String countryBrand, String sfAccountId, List<Task> phoneCalls) {
        System.debug('ClsRestaurantQualityApi.postPhoneCalls: start');

        System.debug('ClsRestaurantQualityApi.postPhoneCalls: countryBrand is: ' + countryBrand);
        System.debug('ClsRestaurantQualityApi.postPhoneCalls: sfAccountId is: ' + sfAccountId);
        System.debug('ClsRestaurantQualityApi.postPhoneCalls: phoneCalls are: ' + phoneCalls);

        // creates request body
        PhoneCallsRequestWrapper req = new PhoneCallsRequestWrapper(phoneCalls);

        System.debug('ClsRestaurantQualityApi.postPhoneCalls: building request...');

        // build http request
        HttpRequest httpreq = LibWebServiceHelper.constructMidasHttpRequest(
                                  MIDAS_CONFIG,
                                  String.format(POST_PHONE_CALLS, new List<String> {countryBrand, sfAccountId}),
                                  'POST',
                                  req.toJson());

        System.debug('ClsRestaurantQualityApi.postPhoneCalls: adding request to continuation. Request body is: ' + httpreq.getBody());

        return Test.isRunningTest() ? 'fake' : con.addHttprequest(httpreq); // this is because of a sfdc bug that doesn't allow to mock the continuation response
    }

    /**
     * Send the request to specified API module.
     * @param  module     API module to invoke
     * @param  fillers    module path's fillers to build rest url resource
     * @param  httpMethod Http method to be used when invoking the api
     * @param  body       Request body
     * @return            An instance of ResponseWrapper. If an error occurs the field
     * inError will be set to true and the response will contain an error description
     */
    private static ResponseWrapper doSyncApiCallout(String module, List<String> fillers, String httpMethod, String body) {
        System.debug('ClsRestaurantQualityApi.doSyncApiCallout: start');

        ResponseWrapper result;

        try {

            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: module is: ' + module);
            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: fillers are: ' + fillers);

            // build http request
            HttpRequest req = LibWebServiceHelper.constructMidasHttpRequest(
                                  MIDAS_CONFIG,
                                  String.format(module, fillers),
                                  httpMethod,
                                  body);

            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: request is: ' + req);

            if (req == null) {
                System.debug('ClsRestaurantQualityApi.doSyncApiCallout: midas not configured!');
                return new ResponseWrapper(true, 'Error: MidasIntegration__c is not configured. Please contact a System Administrator');
            }

            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: sending request. Request body is: ' + req.getBody());

            // send request to backend
            HttpResponse res = new Http().send(req);

            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: response is ' + res);
            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: response body is ' + res.getBody());

            // checks response code
            result = (res.getStatusCode() == 200)
                     ? new ResponseWrapper(res.getBody())
                     : new ResponseWrapper(true, 'Error: please contact a System Administrator. \nSystem response status is: ' + res.getStatus());
        } catch (Exception ex) {
            System.debug('ClsRestaurantQualityApi.doSyncApiCallout: exception occurred. Message is ' + ex.getMessage() + ' Stacktrace is ' + ex.getStackTraceString());
            result = new ResponseWrapper(true, 'Error: please contact a System Administrator. \nDetails: ' + ex.getMessage());
        }

        return result;
    }


    /* ********** REQUEST WRAPPERS ********** */

    /**
     * wrap a phone call to be sent to backend system
     * Note: do not use directly this class, use PhoneCallsRequestWrapper instead
     */
    class TaskWrapper {
        String comment;
        String call_begin;
        String next_call_time;
        String subject;
        List<String> topics;
        Integer duration;

        TaskWrapper(Task call) {
            comment = call.Description;
            call_begin = call.ActivityDate != null ? Datetime.newInstance(call.ActivityDate, System.now().time()).format('yyyy-MM-dd HH:mm:ss', 'UTC') : '';
            next_call_time = call.Next_Call_Time__c != null ? call.Next_Call_Time__c.format('yyyy-MM-dd HH:mm:ss', 'UTC') : '';
            subject = call.Activity_Subject__c;
            topics = String.isNotBlank(call.Topis_Discussed__c) ? call.Topis_Discussed__c.split(';') : new List<String>();
            duration = call.CallDurationInSeconds != null ? call.CallDurationInSeconds : 0;
        }
    }

    /**
     * wrap the information regarding a restaurant
     */
    class RestaurantWrapper {
        String restaurant_id;
        String sf_restaurant_id;
        RestaurantWrapper(String sfId, String restId) {
            sf_restaurant_id = sfId;
            restaurant_id = restId;
        }
    }

    /**
     * wrap the list of phone call
     * Note: do not use directly this class, use PhoneCallsRequestWrapper instead
     */
    class CallsDataWrapper {
        List<TaskWrapper> phone_calls;
        CallsDataWrapper(List<Task> calls) {
            phone_calls = new List<TaskWrapper>();
            for (Task t : calls) {
                phone_calls.add(new TaskWrapper(t));
            }
        }
    }

    /**
     * Wrap the request for assign restaurant call
     */
    class AssignRequestWrapper {
        MetaRequestWrapper meta;
        RestaurantWrapper data;
        AssignRequestWrapper(String sfId) {
            meta = new MetaRequestWrapper();
            if (String.isNotBlank(sfId)) {
                data = new RestaurantWrapper(sfId, null);
            }
        }
    }

    /**
     * wrap the list of phone class to post
     */
    class PhoneCallsRequestWrapper {

        MetaRequestWrapper meta;
        CallsDataWrapper data;

        public PhoneCallsRequestWrapper(List<Task> calls) {
            meta = new MetaRequestWrapper();
            data = new CallsDataWrapper(calls);
        }

        public String toJson() {
            return JSON.serialize(this, true);
        }
    }


    /**
    * wrap the request to send to backend
    */
    class MetaRequestWrapper {
        public String username {get; set;}
        public String sf_role {get; set;}

        public MetaRequestWrapper() {
            username = UserInfo.getUserName();
            sf_role = [ Select DeveloperName From UserRole Where Id = : UserInfo.getUserRoleId() ].DeveloperName;
        }
    }

    /* ********** RESPONSE WRAPPERS ********** */

    /**
    * wrap the response to send back to the page. If inError is true then response
    * will contain an error description to be displayed on the page. Otherwise
    * response will contain the backend response. Usually it would be a JSON string
    */
    public class ResponseWrapper {
        public Boolean inError {get; set;}
        public String response {get; set;}

        public ResponseWrapper(Boolean inError, String response) {
            this.inError = inError;
            this.response = response;
        }

        public ResponseWrapper(String response) {
            this(false, response);
        }
    }
}