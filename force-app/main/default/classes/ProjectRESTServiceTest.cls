@isTest
private class ProjectRESTServiceTest {
    @testSetup
    static void testSetup() {
        Test.startTest();
        ServiceTokens__c serviceTokenSetting = new ServiceTokens__c();
        serviceTokenSetting.Name = ApexConstants.PROJECT_SERVICE_TOKEN;
        serviceTokenSetting.Token__c = '3cf85446-9405-45ac-89b2-65d6dd204f11';
        insert serviceTokenSetting;

        ServiceCredentials__c serviceCredentials = new ServiceCredentials__c();
        serviceCredentials.Name = ApexConstants.BILLING_SERVICE_CREDENTIAL;
        serviceCredentials.Username__c = ApexConstants.BS_USERNAME_1;
        serviceCredentials.Password__c = ApexConstants.BS_PASSWORD_1;
        insert serviceCredentials;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Heavens Gate Inc.',
            AccountId = acc.Id,
            StageName = ApexConstants.OPP_STAGE_NAME_OPEN,
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

        Assert.areEqual(ApexConstants.HTTP_RESPONSE_OK, response, 'Response did not result in OK');
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
            ApexConstants.OPP_STAGE_NAME_PROSPECTING
        );
        Test.stopTest();

        Assert.areNotEqual(ApexConstants.HTTP_RESPONSE_OK, response, 'Response should have not been set OK');
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
            ApexConstants.OPP_STAGE_NAME_PROSPECTING
        );
        Test.stopTest();

        Assert.areNotEqual(ApexConstants.HTTP_RESPONSE_OK, response, 'Response should have not been set OK');
    }
}