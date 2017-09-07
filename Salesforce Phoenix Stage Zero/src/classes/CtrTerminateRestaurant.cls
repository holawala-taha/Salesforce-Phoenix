public without sharing class CtrTerminateRestaurant {

  public Account acct { get; set; }

  public Map<Id, ContractWrapper> mapContracts { get; set; }
  public Map<Id, AdditionalWrapper> mapAddCharges {get; set;}
  public Map<Id, AdditionalWrapper> mapPPCharge {get; set;}
  public Map<Id, BrandingWrapper> mapBrandingCont {get; set;}
  public Map<Id, List<Contract>> mapOppContracts {get; set;}

  public Integer contractSize { get { return mapContracts.size( ); } }
  public Integer additionalSize { get { return mapAddCharges.size( ); } }
  public Integer premiumPlSize {get {return mapPPCharge.size();}}
  public Integer brandingSize {get { return mapBrandingCont.size();}}

  private Map<String, Business_Config__c> mapBusinessData { get; set; }
  private Set<String> doNotOverwriteStatusSet;

  private String assetStatus {get; set;}
  public Boolean showButtons {get; set;}

  public Boolean contractTerminationReasonMandatory {get; private set;}
  public Boolean addChargesTerminationReasonMandatory {get; private set;}
  public Boolean brandingTerminationReasonMandatory {get; private set;}

  public String brandingInactiveStatuses {
    get {
      if (mapBusinessData == null) {
        return '';
      }

      String res = '';

      if (mapBusinessData.containsKey('BrandingTerminateStatus')) {
        res += mapBusinessData.get('BrandingTerminateStatus').Business_Rule_Value__c;
      }

      if (mapBusinessData.containsKey('BrandingUninstalledStatus')) {
        res += ' ' + mapBusinessData.get('BrandingUninstalledStatus').Business_Rule_Value__c;
      }

      return res.trim();
    }
  }

  private static Map<String, Map<String, Map<String, Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;


  public CtrTerminateRestaurant(ApexPages.StandardController sdtController) {
    acct = (Account) sdtController.getRecord();
    this.showButtons = false;
    this.contractTerminationReasonMandatory = false;
    this.addChargesTerminationReasonMandatory = false;
    this.brandingTerminationReasonMandatory = false;

    this.mapContracts = new Map<Id, ContractWrapper>();
    this.mapAddCharges = new Map<Id, AdditionalWrapper>();
    this.mapPPCharge = new Map<Id, AdditionalWrapper>();
    this.mapBrandingCont = new Map<Id, BrandingWrapper>();
    this.doNotOverwriteStatusSet = new Set<String>();
    this.mapOppContracts = new Map<Id, List<Contract>>();
    Map<String, Map<String, Business_Config__c>> mapProcessData = moam.get('TerminateRestaurant');
    this.mapBusinessData = mapProcessData.get(LibRecordTypeHelper.getRecordTypeForIds(new Set<String> {'Account'}).get(acct.RecordTypeId).DeveloperName);

    if (this.mapBusinessData != null && !this.mapBusinessData.isEmpty()) {
      if (mapBusinessData.get('AssetTerminateStatus') != null) {
        this.assetStatus = mapBusinessData.get('AssetTerminateStatus').Business_Rule_Value__c;
        this.showButtons = true;
      } else {
        this.showButtons = false;
        ClsUtilsApexPages.addErrorMessage('Business rule AssetTerminateStatus is required');
        return;
      }

      if (mapBusinessData.containsKey('contractTerminationReasonMandatory')) {
        this.contractTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('contractTerminationReasonMandatory').Business_Rule_Value__c);
      }

      if (mapBusinessData.containsKey('addChargesTerminationReasonMandatory')) {
        this.addChargesTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('addChargesTerminationReasonMandatory').Business_Rule_Value__c);
      }

      if (mapBusinessData.containsKey('brandingTerminationReasonMandatory')) {
        this.brandingTerminationReasonMandatory = Boolean.valueOf(mapBusinessData.get('brandingTerminationReasonMandatory').Business_Rule_Value__c);
      }

      if (mapBusinessData.get('DoNotOverwriteStatus') != null) {
        if (mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c.indexOf(',') > -1) {
          this.doNotOverwriteStatusSet.addAll(mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c.split(','));
        } else {
          this.doNotOverwriteStatusSet.add(mapBusinessData.get('DoNotOverwriteStatus').Business_Rule_Value__c);
        }
      }

      refreshTables();
    } else {
      this.showButtons = false;
      ClsUtilsApexPages.addErrorMessage(Label.Terminate_process_required);
    }
  }

  public void refreshTables() {

    if (this.mapBusinessData == null || this.mapBusinessData.isEmpty()) {
      this.showButtons = false;
      ClsUtilsApexPages.addErrorMessage(Label.Terminate_process_required);
      return;
    }

    for (Contract c : [SELECT
                       ContractNumber,
                       Name__c,
                       StartDate,
                       recordtype.developername,
                       End_Date__c,
                       Status,
                       Commission__c,
                       Recurring_Fee__c,
                       online_payment_fee__c,
                       commission_per_order__C,
                       Termination_Reason__c,
                       Min__c,
                       Max__c,
                       index__c,
                       IsTiered__c,
                       Id_Opportunity__c
                       FROM Contract
                       WHERE AccountId = : this.acct.Id
                                         ORDER BY StartDate DESC]) {

      this.mapContracts.put(c.Id, new ContractWrapper(c));
      if (c.IsTiered__c) {
        if (!mapOppContracts.containsKey(c.Id_Opportunity__c)) {
          mapOppContracts.put(c.Id_Opportunity__c, new List<Contract>());
        }
        mapOppContracts.get(c.Id_Opportunity__c).add(c);
      }
    }

    for (Additional_Charges__c add : [SELECT
                                      Name,
                                      Start_Date__c,
                                      City_ZipCode__c,
                                      Position_fm__c,
                                      Booking_Api_Id__c,
                                      type__c,
                                      Id_Asset__r.status__c,
                                      Id_Asset__r.Returned_Reason__c,
                                      Id_Asset__r.Retour_Date__c,
                                      Id_Asset__c,
                                      Id_Asset__r.Name,
                                      Id_List_Product_Price__r.Product_Name__c,
                                      Product__c,
                                      Id_Opportunity__r.Name,
                                      Total_Amount__c,
                                      Termination_Date__c,
                                      Id_Asset__r.termination_date__c,
                                      Termination_Reason__c,
                                      status__c
                                      FROM Additional_Charges__c
                                      WHERE Id_Account__c = : this.acct.Id]) {
      if (add.type__c != null && add.type__c == 'Premium Placement') {
        this.mapPPCharge.put(add.Id, new AdditionalWrapper(add));
      } else {
        this.mapAddCharges.put(add.Id, new AdditionalWrapper(add));
      }
    }

    for (Branding_Content__c bc : [Select
                                   Name,
                                   Type__c,
                                   Quantity__c,
                                   Status__c,
                                   End_Date__c,
                                   Opportunity__c,
                                   Opportunity__r.StageName,
                                   Termination_Reason__c,
                                   Installation_Date__c
                                   From Branding_Content__c
                                   Where Restaurant_Name__c = : this.acct.id
                                       ORDER By End_Date__c DESC]) {
      System.debug(LoggingLevel.Error, 'm.zeuli - bc id is: ' + bc.id);
      this.mapBrandingCont.put(bc.Id, new BrandingWrapper(bc));
    }

    if ((contractSize + additionalSize + premiumPlSize + brandingSize) == 0) {
      this.showButtons = false;
      ClsUtilsApexPages.addInfoMessage(Label.No_contracts_available_for_termination);
    }
  }

  public void terminateRestaurant() {
    terminateEntities(false);
  }

  public void terminateSelected() {
    terminateEntities(true);
  }

  /**
   * Terminate entities related to current account.
   * If onlySelected is true then terminate only user selected entities, otherwise
   * will terminate all entities
   * @param onlySelected If true then consider only user selected entities
   */
  private void terminateEntities(Boolean onlySelected) {
    try {
      List<String> bookingIds = new List<String>();
      List<Additional_Charges__c> updateAdditional = new List<Additional_Charges__c>();
      List<Asset__c> updateAssets = new List<Asset__c>();
      List<Contract> updateContract = new List<Contract>();
      List<Branding_Content__c> brandingToUpdate = new List<Branding_Content__c>();
      Map<Id, Boolean> oppIdProcessed = new Map<Id, Boolean>();

      for (ContractWrapper cont : mapContracts.values()) {

        if ( (onlySelected && !cont.isSelected)
             || cont.con.Status == 'Terminated') {
          continue;
        }

        if (this.contractTerminationReasonMandatory
            && !(cont.con.IsTiered__c && cont.con.index__c > 1)
            && String.isBlank(cont.opp.Lost_Reason__c)) {
          ClsUtilsApexPages.addErrorMessage(Label.Terminate_Restaurant_Select_Reason);
          return;
        }

        Date endDate;

        if (cont.opp.Lost_Date__c == null) {
          endDate = Date.today();
        } else if (cont.con.StartDate <= cont.opp.Lost_Date__c) {
          endDate = cont.opp.Lost_Date__c;
        } else {
          // invalid lost date
          ClsUtilsApexPages.addErrorMessage(Label.Terminate_restaurant_enddate_validation);
          return;
        }

        if (cont.con.IsTiered__c) {
          if (!oppIdProcessed.containsKey(cont.con.Id_Opportunity__c)) {
            oppIdProcessed.put(cont.con.Id_Opportunity__c, true);
            for (Contract c : mapOppContracts.get(cont.con.Id_Opportunity__c)) {
              updateContract.add(new Contract(id = c.id, Status = 'Terminated', Termination_Reason__c = cont.opp.Lost_Reason__c, End_Date__c = endDate));
            }
          }
        } else {
          updateContract.add(new Contract(id = cont.con.id, Status = 'Terminated', Termination_Reason__c = cont.opp.Lost_Reason__c, End_Date__c = endDate));
        }
      }

      for (AdditionalWrapper addt : mapAddCharges.values()) {
        Asset__c updateAsset;

        if (onlySelected && !addt.isSelected) {
          continue;
        }

        if (this.addChargesTerminationReasonMandatory
            && String.isBlank(addt.opp.Lost_Reason__c)) {
          ClsUtilsApexPages.addErrorMessage(Label.Terminate_Restaurant_Select_Reason);
          return;
        }

        Date terminationDate;
        if (addt.opp.Lost_Date__c == null) {
          terminationDate = Date.today();
        } else {
          terminationDate = addt.opp.Lost_Date__c;
        }

        updateAdditional.add(new Additional_Charges__c(id = addt.add.Id, Termination_Reason__c = addt.opp.Lost_Reason__c, termination_date__c = terminationDate, status__c = 'Terminated'));

        if (addt.add.Id_Asset__c != null && addt.add.Id_Asset__r.termination_date__c == null) {
          if (this.doNotOverwriteStatusSet.contains(addt.add.Id_Asset__r.status__c)) {
            updateAsset = new Asset__c(id = addt.add.Id_Asset__c, termination_date__c = terminationDate);
          } else {
            updateAsset = new Asset__c(id = addt.add.Id_Asset__c, status__c = this.assetStatus, termination_date__c = terminationDate);
          }
          if (updateAsset != null) {
            if (addt.add.Id_Asset__r.Retour_Date__c == null) {
              updateAsset.Retour_Date__c = terminationDate;
            }
            if (addt.add.Id_Asset__r.Returned_Reason__c == null) {
              updateAsset.Returned_Reason__c = addt.opp.Lost_Reason__c;
            }
            updateAssets.add(updateAsset);
          }
        }
      }

      for (AdditionalWrapper addt : mapPPCharge.values()) {

        if (onlySelected && !addt.isSelected) {
          continue;
        }

        if (this.addChargesTerminationReasonMandatory
            && String.isBlank(addt.opp.Lost_Reason__c)) {
          ClsUtilsApexPages.addErrorMessage(Label.Terminate_Restaurant_Select_Reason);
          return;
        }

        Date terminationDate;
        if (addt.opp.Lost_Date__c == null) {
          terminationDate = Date.today();
        } else {
          terminationDate = addt.opp.Lost_Date__c;
        }
        if (addt.add.status__c == 'To be sent' && addt.add.type__c == 'Premium Placement' && addt.add.Booking_Api_Id__c != null) {
          bookingIds.add(addt.add.Booking_Api_Id__c);
        }
        updateAdditional.add(new Additional_Charges__c(id = addt.add.Id, Termination_Reason__c = addt.opp.Lost_Reason__c, termination_date__c = terminationDate, status__c = 'Terminated'));
      }

      for (BrandingWrapper bc : mapBrandingCont.values()) {

        if (onlySelected && !bc.isSelected) {
          continue;
        }

        String status;

        if (mapBusinessData.containsKey('checkForBrandingInstallationdate')
            && Boolean.valueOf(mapBusinessData.get('checkForBrandingInstallationdate').Business_Rule_Value__c)) {
          status = bc.branding.Installation_Date__c == null ? mapBusinessData.get('BrandingTerminateStatus').Business_Rule_Value__c : '';
        }
        // set status to default if blank
        status = String.isNotBlank(status) ? status : mapBusinessData.get('BrandingUninstalledStatus').Business_Rule_Value__c;

        bc.branding.Status__c = status;
        bc.branding.End_Date__c = bc.branding.End_Date__c == null ? Date.today() : bc.branding.End_Date__c;
        bc.branding.Termination_Reason__c = bc.opp.Lost_Reason__c;
        brandingToUpdate.add(bc.branding);
      }


      if (!bookingIds.isEmpty()) {
        String result = terminateMidasPP(bookingIds);
        if (result != 'success') {
          ClsUtilsApexPages.addErrorMessage(result);
          return;
        }
      }

      update updateContract;
      update updateAdditional;
      update updateAssets;
      update brandingToUpdate;

      refreshTables();

      ClsUtilsApexPages.addInfoMessage(Label.Terminate_Restaurant_Success);
    } catch (Exception e) {
      ClsUtilsApexPages.addErrorMessage(Label.Terminate_Restaurant_Error);
      System.debug('The following error occurred while terminating the restaurant: ' + e.getMessage());
    }
  }

  private String terminateMidasPP(List<String> bookingIds) {
    Id currentUserId = UserInfo.getUserId();
    User userData = [SELECT Id, Email, UserRole.Name FROM User where id = :currentUserId];

    List<Opportunity_Quote_Line_Item__c> oppQuotes = [select id, Booking_Api_Id__c from Opportunity_Quote_Line_Item__c where Booking_Api_Id__c in : bookingIds];
    List<Opportunity_line_item__c> oppLines = [select id, Booking_Api_Id__c, Id_Opportunity__c from Opportunity_line_item__c where Booking_Api_Id__c in: bookingIds];
    for (Opportunity_Quote_Line_Item__c opq : oppQuotes) {
      opq.Booking_Api_Id__c = opq.Booking_Api_Id__c + '_CANCELED';
    }
    for (Opportunity_line_item__c opq : oppLines) {
      opq.Booking_Api_Id__c = opq.Booking_Api_Id__c + '_CANCELED';
    }

    String bodyparam2 = ' {"meta": {"username": "' + userData.Email + '","sf_role": "' + userData.userRole.Name + '","sf_opportunity_id": "' + oppLines[0].Id_Opportunity__c + '"},"data": {"bookings": [';
    String arrays2 = '';

    for (String bk : bookingIds) {

      arrays2 += '{"type":"booking", "id":' + bk + '},';
    }

    bodyparam2 += arrays2.removeEnd(',');
    bodyparam2 += ']}}';

    //system.debug('post message is' + bodyparam2);

    //EndNew2
    //String bodyparam = '{"booking_ids":[';
    //String arrays = '';
    //for(String bk : bookingIds){
    // arrays += bk+',';
    // }
    //bodyparam += arrays.removeEnd(',');
    // bodyparam += ']}';
    // System.debug('bodyparam: '+bodyparam);
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    //HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK','cancelbooking/UKHH/','POST',bodyparam);
    HttpRequest req = LibWebserviceHelper.constructMidasHttpRequest('UK', '/v2/sites/UKHH/bookings/cancel', 'POST', bodyparam2);
    if (req != null) {
      //req.setHeader('user-info','{"user_email":"'+userData.Email+'", "user_role":"'+userData.userRole.Name+'"}');
      res = http.send(req);
      System.debug('response :' + res.getBody());
      system.debug('##status code' + res.getStatusCode());
      if (res.getStatusCode() == 204) {
        update oppQuotes;
        update oppLines;
        return 'success';
      } else {
        return 'Error: ' + res.getBody();
      }
    } else {
      return 'Error: MidasIntegration__c is not configured';
    }
  }

  public class ContractWrapper {
    public Boolean isSelected {get; set;}
    public Contract con {get; set;}
    public Opportunity opp {get; set;}
    ContractWrapper(Contract cont) {
      isSelected = false;
      con = cont;
      opp = new Opportunity();
      if (cont != null) {
        opp.Lost_Date__c = cont.End_Date__c;
        opp.Lost_Reason__c = cont.termination_Reason__c;
      }
    }
  }

  public class AdditionalWrapper {
    public Boolean isSelected {get; set;}
    public Additional_Charges__c add {get; set;}
    public Opportunity opp {get; set;}
    AdditionalWrapper(Additional_Charges__c addt) {
      isSelected = false;
      add = addt;
      opp = new Opportunity();
      if (addt != null) {
        opp.Lost_Date__c = addt.termination_date__c;
        opp.Lost_Reason__c = addt.termination_Reason__c;
      }

    }
  }

  public class BrandingWrapper {
    public Boolean isSelected {get; set;}
    public Branding_Content__c branding {get; set;}
    public Opportunity opp {get; set;}
    public BrandingWrapper(Branding_Content__c rec) {
      this.branding = rec;
      this.isSelected = false;
      opp = new Opportunity();
    }
  }
}