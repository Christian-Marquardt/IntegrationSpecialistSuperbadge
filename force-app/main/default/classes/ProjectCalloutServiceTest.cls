@isTest
private class ProjectCalloutServiceTest {
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

        Opportunity opp = new Opportunity(Name = 'Heavens Gate Inc.', AccountId = acc.Id, StageName = 'Open', CloseDate = System.today());
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

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        //HttpResponse res = CalloutClass.getInfoFromExternalService();
        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(opportunityIds);
        Test.stopTest();

        oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN :opportunityIds];

        Assert.areEqual('Submitted Project', oppList[0].StageName, 'Response was invalid');
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

        Assert.areEqual('Resubmit Project', oppList[0].StageName, 'Response was invalid');
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

        Assert.areEqual('Open', oppList[0].StageName, 'Response was invalid');
    }
}