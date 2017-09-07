@isTest
private class UnitTestCtrAccountHierarchy {

    @testSetup static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Country__c c = UnitTestDataFactory.createCountry('EC', 'Ecuador', 'USD');
        insert c;

        insert new Business_Config__c(
            Record_Type_Id__c = 'CD_Account',
            Id_Country__c = c.Id,
            Is_Active__c = true,
            Parent__c = true,
            Type__c = 'Process',
            Process_Name__c = 'Account Hierarchy',
            Business_Rule_Name__c = 'FieldsToQuery',
            Business_Rule_Value__c = '[{"apiName": "Name", "isHeaderField":true, "relationshipField": "", "isLookup": false, "isPicklist": false }, {"apiName": "Type", "relationshipField": "", "isLookup": false, "isPicklist": true }, {"apiName": "Brand__c", "relationshipField": "Brand__r.Name", "isLookup": true, "isPicklist": false }, {"apiName": "Backend_ID__c", "relationshipField": "", "isLookup": false, "isPicklist": false }]'
        );

        Account client = UnitTestDataFactory.createAccount('client', c, 'CD_Account');
        client.Type = 'Client';
        insert client;

        Account franchise1 = UnitTestDataFactory.createAccount('franchise1', c, 'CD_Account');
        franchise1.ParentId = client.Id;
        franchise1.Type = 'Franchise';

        Account franchise2 = UnitTestDataFactory.createAccount('franchise2', c, 'CD_Account');
        franchise2.ParentId = client.Id;
        franchise2.Type = 'Franchise';

        insert new List<Account>{franchise1, franchise2};

        List<Account> branches = new List<Account>();

        for (Integer i = 0; i < 10; i++) {
            Account branch = UnitTestDataFactory.createAccount('branch ' + i, c, 'CD_Account');
            branch.ParentId = Math.mod(i, 2) == 0 ? franchise1.Id : franchise2.Id;
            branch.Type = 'Branch';
            branches.add(branch);
        }

        insert branches;
    }

    @isTest static void constructorsInstantiateCorrectly() {

        Account a = [select id from account limit 1];

        Test.startTest();

        Test.setCurrentPage(Page.AccountHierarchy);

        ApexPages.StandardController stdCtr = new ApexPages.StandardController(a);

        CtrAccountHierarchy ctr1 = new CtrAccountHierarchy();
        CtrAccountHierarchy ctr2 = new CtrAccountHierarchy(stdCtr);

        Test.stopTest();
    }

    @isTest static void getHeadersReturnsEmptyListIfNoBCForRecordType() {

        List<String> res;

        Test.startTest();

        res = CtrAccountHierarchy.getHeaders('RecordType that do not exist');

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assert(res.isEmpty());
    }

    @isTest static void getHeadersReturnsCorrectly() {
        List<String> res;

        Test.startTest();

        res = CtrAccountHierarchy.getHeaders('CD_Account');

        Test.stopTest();

        System.assert(!res.isEmpty());
    }

    @isTest static void getTreeReturnsCorrectlyWithRootAccount() {

        Account root = [Select Id from Account Where Type = 'Client' limit 1];

        List<CtrAccountHierarchy.TreeNode> res;

        Test.startTest();

        res = CtrAccountHierarchy.getTree(root.Id);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(root.Id, res[0].Id);
    }

    @isTest static void getTreeReturnsCorrectlyWithFranchiseAccount() {

        Account root = [Select Id from Account Where Type = 'Client' limit 1];
        Account franc = [Select Id from Account Where Type = 'Franchise' limit 1];

        List<CtrAccountHierarchy.TreeNode> res;

        Test.startTest();

        res = CtrAccountHierarchy.getTree(franc.Id);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(root.Id, res[0].Id);
    }

    @isTest static void getTreeReturnsCorrectlyWithBranchAccount() {

        Account root = [Select Id from Account Where Type = 'Client' limit 1];
        Account branch = [Select Id from Account Where Type = 'Branch' limit 1];

        List<CtrAccountHierarchy.TreeNode> res;

        Test.startTest();

        res = CtrAccountHierarchy.getTree(branch.Id);

        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals(1, res.size());
        System.assertEquals(root.Id, res[0].Id);
    }
}