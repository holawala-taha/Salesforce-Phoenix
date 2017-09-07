/*
@author : Alexander Faust
@reviewer : 
@creation : 05.12.2014
*/
public with sharing class LibWebserviceHelper {
    public static string createBillingAuthenticationHeader(String requestMethod,String URI,String JSONMessage){
        String username = 'qa-test';
        String secret = 'u2i7l94apfrrkzjo2lq990u74lp896rk5cgvwd7zdq';
        
        String requestHash = String.valueOf(System.now().getTime() / 1000) + requestMethod + URI + EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(JSONMessage)));
        Blob signatureBlob =Crypto.generateMAC('hmacSHA1',Blob.valueOf(requestHash),Blob.valueOf(secret));
        String signatureString = username+'.'+String.valueOf(System.now().getTime() / 1000)+'.'+EncodingUtil.convertToHex(signatureBlob);
        
        return signatureString;
    }
    
    public static String extractIdFromURI(String param, String param2){
    
    //placeholder for the sake of deployment
        return '';
    }

    public static List<string> createBackendCalloutHeader(string country, string module){
        Integration_Config__c integrationConfigs = Integration_Config__c.getValues(country);            
        String sEndPoint =  integrationConfigs.endpoint__c+module; //'http://staging-hungryhouse.com/api/salesforce/restaurant/add-contact ';
        String sUsername = integrationConfigs.username__c; //'uksfuser';
        String sSecret = integrationConfigs.password__c; //'SFs3cr3tPw';
        Blob headerValue = Blob.valueOf(sUsername + ':' + sSecret );
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        List<string> reqStringLst = new List<string>();
        reqStringLst.add(sEndPoint);
        reqStringLst.add(authorizationHeader);
        return reqStringLst;
        
    }

    public static HttpRequest constructMidasHttpRequest(String countryCode, String module,String httpMethod,String body){
        MidasIntegration__c integrationConfigs = MidasIntegration__c.getValues(countryCode);
        if(integrationConfigs!=null){
            String endPoint = integrationConfigs.EndPoint__c + module;
            System.debug('The endpointurl is' + endpoint);
            String authToken = integrationConfigs.AuthenticationToken__c;
            String UserId = integrationConfigs.UserId__c;
            HttpRequest req = new HttpRequest();
            if(countryCode == 'Peru' || countryCode == 'Colombia' || countryCode =='Ecuador'){
                endpoint+= '?id='+UserId + '&token=' + authToken; 
            }else{
            	req.setHeader('Authorization',authToken);
                 }
            req.setEndpoint(endPoint);
            req.setMethod(httpMethod);
            if(body!=null){
                req.setBody(body);
                req.setHeader('Content-Type','application/json');
            }
            return req;
        }else{
            return null;
        }
    }


    public static HttpRequest createBackendCalloutHeaderTalabat(String tokenContent, String ep){
         HttpRequest req = new HttpRequest();
       // req.setEndpoint('https://sfi-qa.talabat.com/token?client_Id='+EncodingUtil.urlEncode(clientID, 'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret, 'UTF-8')+'&username=mafzal@talabat.com&password='+EncodingUtil.urlEncode('459yAhRTmnxfBE8C', 'UTF-8')+'&grant_type='+EncodingUtil.urlEncode('password', 'UTF-8'));
        req.setEndpoint(ep+'token');
        req.setMethod('POST');
        req.setBody(tokenContent);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        system.debug(req); 
        return req;
        
    }

}