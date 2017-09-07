/**
*  Controller per DERestaurantQuality page
 */
public with sharing class CtrRestaurantQuality {

    /**
     * Gets all country brands available for current user. Available country
     * brands depend on user CountryCode multi-select picklist and enabled
     * country to restaurant quality tool
     * @return Map where Key is Country name and value is country brand code
     */
    @RemoteAction
    public static Map<String, String> getCountryBrandCodesPerCurrentUser() {
        System.debug('CtrRestaurantQuality.getCountryBrandCodesPerCurrentUser: start');

        Map<String, String> res = new Map<String, String>();

        User current = [SELECT CountryCode__c FROM User WHERE Id = :UserInfo.getUserId()];

        System.debug('CtrRestaurantQuality.getCountryBrandCodesPerCurrentUser: country codes are: ' + current.CountryCode__c);

        if (String.isBlank(current.CountryCode__c)) {
            return res; // empty map
        }

        Set<String> isoCodes = new Set<String>(current.CountryCode__c.split(';'));

        // get available counties per current suer
        for (Country__c cnt : [
                    SELECT
                    Name,
                    Restaurant_Quality_Code__c
                    FROM Country__c
                    WHERE Iso__c IN :isoCodes
                    AND Restaurant_Quality_Code__c != ''
                ]) {
            res.put(cnt.Name, cnt.Restaurant_Quality_Code__c);
        }

        System.debug('CtrRestaurantQuality.getCountryBrandCodesPerCurrentUser: done, res is: ' + res);
        return res;
    }

    /**
    * Retrieves the list of poor restaurants
    * @param countryBrand Country brand
    * @return an instance of ResponseWrapper.
    */
    @RemoteAction
    public static ClsRestaurantQualityApi.ResponseWrapper getRestaurants(String countryBrand) {
        return  ClsRestaurantQualityApi.displayRestaurantsList(countryBrand);
    }

    /**
     * Assign a random restaurant to current user
     * @param countryBrand Country brand
     * @return [description]
     */
    @RemoteAction
    public static ClsRestaurantQualityApi.ResponseWrapper assignFirst(String countryBrand) {
        return ClsRestaurantQualityApi.assignRestaurant(countryBrand, null);
    }
}