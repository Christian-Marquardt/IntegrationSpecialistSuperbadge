public class BillingCalloutService {
    // Getter Setter for Custom Metadata ServiceCredentials__c
    private static ServiceCredentials__c serviceCredentialsPriv = null;
    public static ServiceCredentials__c serviceCredentials {
        get {
            if (serviceCredentialsPriv == null) {
                serviceCredentialsPriv = [
                    SELECT Id, Username__c, Password__c
                    FROM ServiceCredentials__c
                    WHERE Name = :ApexConstants.BILLING_SERVICE_CREDENTIAL
                ];
            }
            return serviceCredentialsPriv;
        }
    }

    public static void callBillingService(List<Project__c> newList, Map<Id, Project__c> oldMap) {
        if (serviceCredentials != null && oldMap != null) {
            for (Project__c project : newList) {
                if (project.Status__c == ApexConstants.PROJECT_STATUS_BILLABLE && project.Status__c != oldMap.get(project.Id).Status__c) {
                    billingCallout(
                        project.ProjectRef__c,
                        project.Billable_Amount__c,
                        serviceCredentials.Username__c,
                        serviceCredentials.Password__c
                    );
                }
            }
        }
    }

    // Need to create invoice and pass in ProjectRef (External ID) and Amount to help with invoice creation
    @future(callout=true)
    private static void billingCallout(String projectRef, Decimal billableAmount, String user, String password) {
        try {
            BillingServiceProxy billingService = new BillingServiceProxy();
            BillingServiceProxy.project currentProject = new BillingServiceProxy.project();
            currentProject.projectid = projectRef;
            currentProject.billAmount = billableAmount;
            currentProject.username = user;
            currentProject.password = password;
            BillingServiceProxy.InvoicesPortSoap11 invoicePortSoap = new BillingServiceProxy.InvoicesPortSoap11();

            String response = invoicePortSoap.billProject(currentProject);

            // I do not like this at all, but without a race condition will happen
            // Could be refactored later on
            if (response != null && response.equalsIgnoreCase(ApexConstants.HTTP_RESPONSE_OK)) {
                Project__c project = [SELECT Id FROM Project__c WHERE ProjectRef__c = :projectRef LIMIT 1];
                project.Status__c = ApexConstants.PROJECT_STATUS_BILLED;
                update project;
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
        }
    }
}