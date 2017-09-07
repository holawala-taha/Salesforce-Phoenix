public with sharing class ClsWebserviceCalloutsKR{
    
    private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;


    public static String createBackendAccount(String restaurantName, String salesforceId, String salesRep){
        Http theHttp = new Http();
        HttpRequest theRequest = new HttpRequest();
        HttpResponse theResponse = new HttpResponse();
        String baseURL;
        String apiKey;
        String secret;

        if(!test.isrunningtest()){
        Map<String,Business_Config__c> mapProcessData = moam.get('SendToBackendProcess').get('Yogiyo_Account');

        //String endpoint = 'https://www.yogiyo.co.kr/salesforce/restaurant/create/?api_key=salesforce&secret=23752ba30a8811e5a0b434363bd33456';

        baseURL = mapProcessData.get('calloutBaseURL').Business_Rule_Value__c;
        apiKey = mapProcessData.get('calloutAPIKey').Business_Rule_Value__c;
        secret = mapProcessData.get('calloutSecret').Business_Rule_Value__c;
        }else{
            baseURL = 'https://www.yogiyo.co.kr/salesforce/restaurant/create/';
            apiKey = 'salesforce';
            secret = '23752ba30a8811e5a0b434363bd33456';
        }


        String endpoint = baseURL;
        endpoint = endpoint + '?api_key=' + apiKey;
        endpoint = endpoint + '&secret=' + secret;

        System.debug('$$$ enpoint: ' + endpoint);

        String postParameters = 'salesforce_id=' + EncodingUtil.urlEncode(salesforceId, 'UTF-8');
        postParameters = postParameters + '&salesforce_user=' + EncodingUtil.urlEncode(salesRep, 'UTF-8');
        postParameters = postParameters + '&name=' + EncodingUtil.urlEncode(restaurantName, 'UTF-8');        

        theRequest.setEndpoint(endpoint);
        theRequest.setMethod('POST');
        theRequest.setBody(postParameters);

        try{

            theResponse = theHttp.send(theRequest);

            System.debug('$$$ the response: ' + theResponse);
            System.debug('$$$ the response message: ' + theResponse.getBody());

            if(theResponse.getStatusCode() == 200){

                String backendId = LibJSONHelper.parseResponseForKRBackendId(theResponse.getBody());

                /*Account theAccount = [SELECT Id, Backend_ID__c FROM Account WHERE Id =: salesforceId LIMIT 1];
                theAccount.Backend_ID__c = backendId;
                update theAccount;*/

                return backendId;    
            }else{
                return null;
            }

            

        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage() + '   ' + e.getStackTraceString());
            return null;
        }
    }

    public static FixedCommissionWrapper getFixAmountCommissionDistricts(String backendId){
        Http theHttp = new Http();
        HttpRequest theRequest = new HttpRequest();
        HttpResponse theResponse;
        FixedCommissionWrapper theWrapper;
        
        Map<String,Business_Config__c> mapBusinessRule = new Map<String,Business_Config__c>();
 		//Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('FixedAmountCommissionIntegration');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('FixedAmountCommissionIntegration');
        
        if(mapBusinessLogic != null){
            mapBusinessRule = mapBusinessLogic.get('Yogiyo_Opportunity');
            
            if(mapBusinessRule != null){
                String baseURL = mapBusinessRule.get('baseURL').Business_Rule_Value__c;
 				String endpointURL = mapBusinessRule.get('endpointURL').Business_Rule_Value__c;
 				String apiKey = mapBusinessRule.get('apiKey').Business_Rule_Value__c;
 				String secret = mapBusinessRule.get('secret').Business_Rule_Value__c;

 				String endpoint = baseURL + backendId + endpointURL + '?api_key=' + apiKey + '&secret=' + secret;
				System.debug('endpoint: ' + endpoint);
 				theRequest.setMethod('GET');
 				theRequest.setEndpoint(endpoint);
                
                try{
                    theResponse = theHTTP.send(theRequest);
                    //mocking the response
                    //String json = '{ 	"categories": [ 		{ 			"id": 1, "name": "category 1" 		} 	], 	"target_districts": [ 		 { 			"id": 1, 			"name": "target district 1", 			"district_id": 123, 			"start_date": "2015-08-01", 			"end_date": "2015-08-31", 			"monthly_fee": 39500 		} 	] }';
					String json = theResponse.getBody().replaceAll('targetdistrict__id','targetdistrict_id').replaceAll('district__name','district_name').replaceAll('district__id','district_id');
                    Integer statusCode = theResponse.getStatusCode();
                    
                    
                    System.debug('$$$ getFixAmountCommissionDistricts: theResponse status code: ' + statusCode);
					System.debug('$$$ getFixAmountCommissionDistricts: theResponse body: ' + json);
                    
                    
                    if(statusCode == 200){
                        theWrapper = (FixedCommissionWrapper) System.JSON.deserialize(json, FixedCommissionWrapper.class);
                        theWrapper.errorFlag = false;
                        theWrapper.errorMessage = '';
                    }else if(statusCode == 404){
                        theWrapper.errorFlag = true;
                        theWrapper.errorMessage = 'No results found';
                    }else {
                        theWrapper.errorFlag = true;
                        theWrapper.errorMessage = 'There was an error. Please contact your administrator.';
                    }
                    
                    /*theWrapper = (FixedCommissionWrapper) System.JSON.deserialize(json, FixedCommissionWrapper.class);
                    if(backendId == '0011'){
                    	theWrapper.errorFlag = false;
                        theWrapper.errorMessage = '';
                    }else if(backendId == '0022'){
                        theWrapper.errorFlag = true;
                        theWrapper.errorMessage = 'There was an error. Please contact your administrator.';
                    }*/
                    
                    
                }catch(Exception e){
                    System.debug('EXCEPTION: ' + e.getMessage());
                }
            }
        }
        
        return theWrapper;
    }

	public static DistrictPriceCategoryWrapper getAvailableDistrictsAndCategories(String backendId){
		Http theHTTP = new Http();
		HttpRequest theRequest = new HttpRequest();
		DistrictPriceCategoryWrapper theDistrictPriceWrapper;
		String districtsAndCategoriesJSON;
		Map<String,Business_Config__c> mapBusinessRule = new Map<String,Business_Config__c>();


 		//Map<String,Map<String,Business_Config__c>> mapBusinessLogic = LibBusinessConfig.getGenericProcessData('AdSalesIntegration');
        Map<String,Map<String,Business_Config__c>> mapBusinessLogic = moam.get('AdSalesIntegration');

 		if(mapBusinessLogic != null){
 			mapBusinessRule = mapBusinessLogic.get('Yogiyo_Opportunity');
 			
 			if(mapBusinessRule != null){

 				String baseURL = mapBusinessRule.get('baseURL').Business_Rule_Value__c;
 				String endpointURL = mapBusinessRule.get('endpointURL').Business_Rule_Value__c;
 				String apiKey = mapBusinessRule.get('apiKey').Business_Rule_Value__c;
 				String secret = mapBusinessRule.get('secret').Business_Rule_Value__c;

 				String endpoint = baseURL + backendId + endpointURL + '?api_key=' + apiKey + '&secret=' + secret;

 				theRequest.setMethod('GET');
 				theRequest.setEndpoint(endpoint);

 				try{
					HttpResponse theResponse = theHTTP.send(theRequest);

					System.debug('$$$ getAvailableDistrictsAndCategories: theResponse status code: ' + theResponse.getStatusCode());
					System.debug('$$$ getAvailableDistrictsAndCategories: theResponse body: ' + theResponse.getBody());

					if(theResponse.getStatusCode() == 200 && theResponse.getBody() != null && theResponse.getBody() != '' ){
						districtsAndCategoriesJSON = theResponse.getBody().replaceAll('district__id','district_id').replaceAll('district__name','district_name').replaceAll('super','typeSuper').replaceAll('basic','typeBasic');
						theDistrictPriceWrapper = (DistrictPriceCategoryWrapper)System.JSON.deserialize(districtsAndCategoriesJSON, DistrictPriceCategoryWrapper.class);
						theDistrictPriceWrapper.errorFlag = false;

						System.debug('$$$ districtWrapperObject: ' + theDistrictPriceWrapper.district_price);

					}else if(theResponse.getStatusCode() == 200 && (theResponse.getBody() == null || theResponse.getBody() == '') ){
						theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
						theDistrictPriceWrapper.errorFlag = true;
						theDistrictPriceWrapper.errorMessage = Label.AdSalesKRIncomplete;

					}else if(theResponse.getStatusCode() == 404){
						theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
						theDistrictPriceWrapper.errorFlag = true;
						theDistrictPriceWrapper.errorMessage = Label.AdSalesKR404;
					}

				}catch(Exception e){
					System.debug('$$$ Exception: ' + e.getMessage());
					theDistrictPriceWrapper = new DistrictPriceCategoryWrapper();
					theDistrictPriceWrapper.errorFlag = true;
					theDistrictPriceWrapper.errorMessage = Label.AdSalesKRException;
				}

 			}	
 		}


		return theDistrictPriceWrapper;

	}
}