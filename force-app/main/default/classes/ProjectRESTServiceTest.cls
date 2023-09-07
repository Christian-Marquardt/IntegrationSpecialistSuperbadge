@isTest
private class ProjectRESTServiceTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        ServiceTokens__c serviceTokenSetting = new ServiceTokens__c();
        serviceTokenSetting.Name = 'ProjectServiceToken';
        serviceTokenSetting.Token__c = '3cf85446-9405-45ac-89b2-65d6dd204f11';
        insert serviceTokenSetting;

        ServiceCredentials__c serviceCredentials = new ServiceCredentials__c();
        serviceCredentials.Name = 'BillingServiceCredential';
        serviceCredentials.Username__c = 'bsUser1';
        serviceCredentials.Password__c = 'bsPass1';
        insert serviceCredentials;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Heavens Gate Inc.',
            AccountId = acc.Id,
            StageName = 'Open',
            CloseDate = System.today(),
            Amount = 100.00
        );
        insert opp;

        Test.stopTest();
    }

    @isTest
    static void postProjectDataTest() {
        Opportunity opp = [SELECT Id, CloseDate, Amount, StageName FROM Opportunity LIMIT 1];

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            '1234567',
            'Lets ride forever',
            String.valueOf(opp.Id),
            System.today(),
            opp.CloseDate,
            (Double) opp.Amount,
            opp.StageName
        );
        Test.stopTest();

        Assert.areEqual('OK', response);
    }

    @isTest
    static void postProjectDataFailTest1() {
        Opportunity opp = [SELECT Id, CloseDate, Amount, StageName FROM Opportunity LIMIT 1];

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            '1234567',
            'Lets ride forever',
            null,
            System.today(),
            System.today(),
            (Double) 12.00,
            'Prospecting'
        );
        Test.stopTest();

        Assert.areNotEqual('OK', response);
    }

    @isTest
    static void postProjectDataFailTest2() {
        Opportunity opp = [SELECT Id, CloseDate, Amount, StageName FROM Opportunity LIMIT 1];

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            '1234567',
            'Lets ride forever',
            '1111',
            System.today(),
            System.today(),
            (Double) 12.00,
            'Prospecting'
        );
        Test.stopTest();

        Assert.areNotEqual('OK', response);
    }
}