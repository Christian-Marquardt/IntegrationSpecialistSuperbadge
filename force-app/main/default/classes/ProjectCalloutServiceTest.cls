@isTest
private class ProjectCalloutServiceTest {
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
    static void testCalloutSuccess() {
        List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity LIMIT 1];

        List<Id> opportunityIds = new List<Id>();
        for (Opportunity opp : oppList) {
            opportunityIds.add(opp.Id);
        }

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
        Test.stopTest();

        oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN :opportunityIds];

        Assert.areEqual(
            ApexConstants.OPP_STAGE_NAME_SUBMITTED_PROJECT,
            oppList[0].StageName,
            'Opportunity did not update to Submitted Project with successful response'
        );
    }

    @isTest
    static void testCalloutFailure() {
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];

        List<Id> opportunityIds = new List<Id>();
        for (Opportunity opp : oppList) {
            opportunityIds.add(opp.Id);
        }

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
        Test.stopTest();

        oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN :opportunityIds];

        Assert.areEqual(
            ApexConstants.OPP_STAGE_NAME_RESUBMIT_PROJECT,
            oppList[0].StageName,
            'Opportunity and failed response did not get set to Resubmit Project'
        );
    }

    @isTest
    static void testExceptionWithEmptyOpp() {
        List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity LIMIT 1];

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        List<Id> opportunityIds = new List<Id>();

        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
        Test.stopTest();

        oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppList LIMIT 1];

        Assert.areEqual(ApexConstants.OPP_STAGE_NAME_OPEN, oppList[0].StageName, 'Opportunity did not remain Open');
    }
}