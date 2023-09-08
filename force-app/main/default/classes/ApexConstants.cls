public with sharing class ApexConstants {
    // Custom Metadata Type Service Tokens
    public static final String PROJECT_SERVICE_TOKEN = 'ProjectServiceToken';

    // Custom Metadata Type Service Credentials
    public static final String BILLING_SERVICE_CREDENTIAL = 'BillingServiceCredential';
    public static final String BS_USERNAME_1 = 'bsUser1';
    public static final String BS_PASSWORD_1 = 'bsPass1';

    // Stage Names
    public static final String OPP_STAGE_NAME_PROSPECTING = 'Prospecting';
    public static final String OPP_STAGE_NAME_OPEN = 'Open';
    public static final String OPP_STAGE_NAME_SUBMITTED_PROJECT = 'Submitted Project';
    public static final String OPP_STAGE_NAME_RESUBMIT_PROJECT = 'Resubmit Project';

    // HTTP REST Responses
    public static final String HTTP_RESPONSE_OK = 'OK';

    // Opportunity Delivery Installation Statuses
    public static final String OPP_DELIVERY_INST_IN_PROGRESS = 'In progress';

    // HTTP Request Methods
    public static final String HTTP_REQUEST_POST = 'POST';

    // Project Status
    public static final String PROJECT_STATUS_RUNNING = 'Running';
    public static final String PROJECT_STATUS_BILLABLE = 'Billable';
    public static final String PROJECT_STATUS_BILLED = 'Billed';
}