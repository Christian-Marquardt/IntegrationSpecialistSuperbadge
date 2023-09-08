@isTest
private class BillingCalloutServiceTest {
    //Implement mock callout tests here
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

        Project__c project = new Project__c(
            ProjectRef__c = '12345_abcd',
            Billable_Amount__c = 10.00,
            Status__c = ApexConstants.PROJECT_STATUS_RUNNING,
            Opportunity__c = opp.Id
        );
        insert project;
        Test.stopTest();
    }

    @isTest
    static void billingCalloutSuccessTest() {
        List<Project__c> projectList = [SELECT Id, ProjectRef__c, Billable_Amount__c, Status__c, Opportunity__c FROM Project__c LIMIT 1];

        projectList[0].Status__c = ApexConstants.PROJECT_STATUS_BILLABLE;

        // Set mock callout class
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());

        Test.startTest();
        update projectList;
        Test.stopTest();

        projectList = [SELECT Id, ProjectRef__c, Billable_Amount__c, Status__c, Opportunity__c FROM Project__c WHERE Status__c = 'Billed'];

        Assert.isFalse(projectList.isEmpty(), 'Project List should not be empty');
    }

    @isTest
    static void billingCalloutFailureTest() {
        List<Project__c> projectList = [SELECT Id, ProjectRef__c, Billable_Amount__c, Status__c, Opportunity__c FROM Project__c LIMIT 1];

        projectList[0].Status__c = ApexConstants.PROJECT_STATUS_BILLABLE;

        // Set mock callout class
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());

        Test.startTest();
        update projectList;
        Test.stopTest();

        projectList = [SELECT Id, ProjectRef__c, Billable_Amount__c, Status__c, Opportunity__c FROM Project__c WHERE Status__c = 'Billed'];

        Assert.isTrue(projectList.isEmpty(), 'Project List should be empty');
    }
}