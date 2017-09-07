/* SP-495 / SP-501 */
public with sharing class CtrAssetScreen {
    //start copy from CtrAssetController
   
   private static Map<String, Map<String,Map<String,Business_Config__c>> > moam = LibBusinessConfig.motherOfAllBusinessMaps;
    public Asset__c assetObj;
    private final Asset__c oldAssetValues;
    public List<Asset_Cancellation__c> listAssetCanceled {get;set;}
    public Boolean showRelatedSection {
        get { 
            if(this.listAssetCanceled.isEmpty()){
                return false;
            }else{
                return true;    
            }
        }
    }

    public String products {get;set;}
    
    
    //end copy from CtrAssetController
    public Asset__c theAsset {get;set;}
    //switches for different modes of the screen
    public boolean viewMode {get;set;}
    public boolean editMode {get;set;}
    public boolean showReplacementBtn {get;set;}
    //public boolean lockMode {get;set;}
    //fieldset lists for the different sections of the page
    public List<Schema.FieldSetMember> fields_detail {get;set;}
    public List<Schema.FieldSetMember> fields_deposit {get;set;}
    public List<Schema.FieldSetMember> fields_stockItemInfo {get;set;}
    public List<Schema.FieldSetMember> fields_deliveryStockItem {get;set;}
    //public List<Schema.FieldSetMember> fields_return {get;set;}
    public List<Schema.FieldSetMember> fields_other {get;set;}
    public List<Schema.FieldSetMember> fields_system {get;set;}
    public List<Schema.FieldSetMember> fields_Asset_Can_KR {get;set;}
    public List<Schema.FieldSetMember> fields_Asset_Can_AU {get;set;}
    public List<Schema.FieldSetMember> fields_Asset_Can {get;set;}
    private List<String> listFieldNames;

    public Boolean seAsset { get; set; }
    public Boolean ukAsset { get; set; }
    private Map<Id,List_Product_Price__c> productItemsMap {get;set;}
    private Map<String,Business_Config__c> mapBusinessData {get;set;}

    private String replacementStatus {get;set;}



    public String productItems { get{
        if(productItems==null){
            productItemsMap  = new Map<Id,List_Product_Price__c>();
            if(this.theAsset.Opportunity__c!=null){
                List<List_Product_Price__c> lpps = [SELECT Id, Name,Requires_Additional_Charge__c, Product_Name__c,Requires_Replacement__c,List_Price__c from List_Product_Price__c where RecordTypeId =: LibRecordTypeHelper.getRecordTypeValue(this.theAsset.Opportunity__r.Company_Code__c + '_List_Product_Price') and Requires_Replacement__c=true and Is_Active__c = true];
                for(List_Product_Price__c lpp : lpps){
                    productItemsMap.put(lpp.Id,lpp);
                }
                productItems = JSON.serialize(lpps);
            }
        }
        return  productItems; 
        } set;}
    
    public CtrAssetScreen(ApexPages.StandardController stdCtrl){
        //stdCtrl.addFields(new List<String>{'RecordTypeId'});
        this.viewMode = true;
        this.editMode = false;
        this.seAsset = false;
        this.ukAsset = false;
        this.showReplacementBtn=false;
        //this.lockMode = false;
        //Map<String,Map<String,Business_Config__c>> mapProcessData= LibBusinessConfig.getGenericProcessData('AssetScreenProcess');
        Map<String,Map<String,Business_Config__c>> mapProcessData= moam.get('AssetScreenProcess');
        //read all fieldsets...
        Asset__c asset = [SELECT RecordType.DeveloperName FROM Asset__c WHERE Id = :stdCtrl.getId()];
        //String recordType = LibRecordTypeHelper.getRecordTypeValue(this.theAsset.RecordTypeId);
        if(asset.RecordType.DeveloperName == 'UK_Asset' || asset.RecordType.DeveloperName=='SE_Asset' || asset.Recordtype.developername =='Talabat_Asset') {
            string[] recCompName = asset.RecordType.DeveloperName.split('_');
            this.ukAsset = true;
            this.fields_detail = readFieldSet('AssetScreen_Detail_'+recCompName[0], 'Asset__c');
            this.fields_other = readFieldSet('AssetScreen_Other_'+recCompName[0], 'Asset__c');
            this.fields_stockItemInfo = readFieldSet('AssetScreen_StockItemInfo_'+recCompName[0], 'Asset__c');
        }
        else {
            this.fields_detail = readFieldSet('AssetScreen_Detail', 'Asset__c');
            this.fields_other = readFieldSet('AssetScreen_Other', 'Asset__c');
             this.fields_stockItemInfo = readFieldSet('AssetScreen_StockItemInfo', 'Asset__c');
            this.fields_deposit = readFieldSet('AssetScreen_Deposit', 'Asset__c');

        }
        
        //this.fields_stockItemInfo = readFieldSet('AssetScreen_StockItemInfo', 'Asset__c');
        this.fields_deliveryStockItem = readFieldSet('AssetScreen_DeliveryStockItems', 'Asset__c');
        //this.fields_return = readFieldSet('AssetScreen_Return', 'Asset__c');
        
        this.fields_system = readFieldSet('AssetScreen_System', 'Asset__c');
        
        //...get the api names of the fieldset members...
        listFieldNames = new List<String>();
        for(Schema.FieldSetMember fsm : this.fields_detail){
            listFieldNames.add(fsm.getFieldPath());
        }
        if(this.fields_deposit!=null){
            for(Schema.FieldSetMember fsm : this.fields_deposit){
                listFieldNames.add(fsm.getFieldPath());
            }
        }
        
        for(Schema.FieldSetMember fsm : this.fields_stockItemInfo){
            listFieldNames.add(fsm.getFieldPath());
        }
        for(Schema.FieldSetMember fsm : this.fields_deliveryStockItem){
            listFieldNames.add(fsm.getFieldPath());
        }
        /*for(Schema.FieldSetMember fsm : this.fields_return){
            listFieldNames.add(fsm.getFieldPath());
        }*/
        for(Schema.FieldSetMember fsm : this.fields_other){
            listFieldNames.add(fsm.getFieldPath());
        }
        for(Schema.FieldSetMember fsm : this.fields_system){
            listFieldNames.add(fsm.getFieldPath());
        }
        listFieldNames.add('RecordType.developername');
        listFieldNames.add('Opportunity__r.Company_Code__c');
        listFieldNames.add('Opportunity__r.StageName');
        listFieldNames.add('Opportunity__r.CurrencyIsoCode');
        listFieldNames.add('Opportunity__c');
        listFieldNames.add('Id_Opportunity_Quote_Line_Item__r.Id_Opportunity_Quote__c');
        listFieldNames.add('Id_Opportunity_Quote_Line_Item__c');
        listFieldNames.add('Id_Opportunity_Quote_Line_Item__r.Id_List_Product_Price__c');

        //...and feed them to the standardcontroller
        if(!Test.isRunningTest()){
            stdCtrl.addFields(listFieldNames);    
        }
        
        this.theAsset = (Asset__c)stdCtrl.getRecord();
        
        /*if(this.theAsset.Status__c == 'Canceled'){
           switchToLockMode();
        }*/


        if(this.theAsset != null) {
            if(this.theAsset.RecordType != null) {
                if(this.theAsset.RecordType.DeveloperName != null) {
                    this.seAsset = this.theAsset.RecordType.DeveloperName.contains('SE');
                }
            }
        }
        
        
        
        if(mapProcessData!=null && !mapProcessData.isEmpty()){
            mapBusinessData = mapProcessData.get(this.theAsset.RecordType.DeveloperName);
            if(mapBusinessData!=null && !mapBusinessData.isEmpty()){
                if(mapBusinessData.get('AssetCancellationFieldSet')!=null){
                    this.fields_Asset_Can_KR = readFieldSet(mapBusinessData.get('AssetCancellationFieldSet').Business_Rule_Value__c,'Asset_Cancellation__c');
                    this.fields_Asset_Can = this.fields_Asset_Can_KR ;
                }if(mapBusinessData.get('displayReplacementBtn')!=null){
                    this.showReplacementBtn=Boolean.valueOf(mapBusinessData.get('displayReplacementBtn').Business_Rule_Value__c);
                }if(mapBusinessData.get('replacementStatus')!=null){
                    this.replacementStatus=mapBusinessData.get('replacementStatus').Business_Rule_Value__c;
                }

            } 

        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,Label.BusinessProcessNotActive));
        }


        retriveAssetCancelations();
    }
    
    public void switchToLockMode(){
        //this.lockMode = true;
        this.viewMode = true;
        this.editMode = false;
    }
    
    public void switchToEditMode(){
        this.viewMode = false;
        this.editMode = true;
    }
    
    /*public void switchToViewMode(){
        this.viewMode = true;
        this.editMode = false;
        String queryString = 'select id'; 
        for(String fsm : this.listFieldNames){
           queryString += ', ' + fsm;
        }
        queryString += ' from Asset__c where Id=\''+this.theAsset.id+'\'';
        system.debug('query: '+queryString);
        this.theAsset = Database.query(queryString);
        retriveAssetCancelations();
    }*/

    public PageReference switchToViewMode(){
        return new PageReference('/'+theAsset.Id);
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);  
        return fieldSetObj.getFields();
    }
    
    
    //start copy from CtrAssetController
    private void retriveAssetCancelations(){
        /*this.listAssetCanceled = [Select Id,Asset__c,Return_Age__c,Return_Comments__c,Return_Due_Date__c,Returned_Reason__c,Returning_Stock_Item__r.name,
                                                        Returning_Stock_Item__c,Returning_Stock_Item_Serial_No__c,Return_Request_Date__c,Warehouse_Return_Date__c,
                                                        Return_Shipping_Company__c,Return_Status__c,Return_Tracking_Number__c,CreatedDate,LastModifiedDate
                                                        from Asset_Cancellation__c 
                                                        where Asset__c=:this.theAsset.id Order By CreatedDate DESC];*/

        String queryString = 'select id, name, Returning_Stock_Item__r.name';
        if(this.fields_Asset_Can!=null){
            for(Schema.FieldSetMember fsm : this.fields_Asset_Can){
                queryString += ', ' + fsm.getFieldPath();
            }
        } 
        
        queryString += ' from Asset_Cancellation__c where Asset__c=\''+this.theAsset.id+'\' Order By CreatedDate DESC';
        this.listAssetCanceled = Database.query(queryString);
    }
    
    public PageReference saveDetails(){
        
        try{
            System.debug('theAsset: '+theAsset);
            update theAsset;
            update this.listAssetCanceled;
            
            retriveAssetCancelations();
        }catch(Exception e){
            System.debug('Error at Save Detail: '+e.getMessage());
            System.debug(LoggingLevel.Error, 'm.zeuli - stack trace: ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error occured contact Admins.'));
            return null;
        }
        return new PageReference('/'+theAsset.Id);

    }

    public PageReference refreshPage(){
        return new PageReference('/'+this.assetObj);
    }
    
    
    //end copy from CtrAssetController

    public void assetReplacement(){
        String products = System.currentPageReference().getParameters().get('products').remove('\'');
        List<String> splited  = products.split('#::#');
        String prods = splited[0];
        String reason = splited[1];
        String notesData=null;
        if(splited.size()==3){
            notesData = splited[2];
        }
        System.debug('notesData: '+notesData);
        List<Replacement_Order__c> replacements = new List<Replacement_Order__c>();
        System.debug('prods: '+prods);
        if(prods!=null){
            if(prods.indexOf(',') > 1){
                for(String ch : prods.split(',')){
                    replacements.add(new Replacement_Order__c(Amount__c=productItemsMap.get(ch).List_Price__c,Status__c=this.replacementStatus,CurrencyIsoCode=this.theAsset.Opportunity__r.CurrencyIsoCode,Id_List_Product_Price__c=ch,Id_Asset__c=this.theAsset.id,Id_Opportunity__c=this.theAsset.Opportunity__c,Id_Account__c=this.theAsset.Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(this.theAsset.Opportunity__r.Company_Code__c+'_Replacement_Order'),reason__c=reason,Replacement_Notes__c=notesData));
                }
            }else{
                String ch = prods;
                replacements.add(new Replacement_Order__c(Amount__c=productItemsMap.get(ch).List_Price__c,Status__c=this.replacementStatus,CurrencyIsoCode=this.theAsset.Opportunity__r.CurrencyIsoCode,Id_List_Product_Price__c=ch,Id_Asset__c=this.theAsset.id,Id_Opportunity__c=this.theAsset.Opportunity__c,Id_Account__c=this.theAsset.Account__c,RecordTypeId=LibRecordTypeHelper.getRecordTypeValue(this.theAsset.Opportunity__r.Company_Code__c+'_Replacement_Order'),reason__c=reason,Replacement_Notes__c=notesData));
            }
        }
        if(!replacements.isEmpty()){
        insert replacements;
        this.theAsset.status__c = mapBusinessData.get('UpdateAssetStatusForRP').Business_Rule_Value__c;
        update this.theAsset;
        }
    }
}