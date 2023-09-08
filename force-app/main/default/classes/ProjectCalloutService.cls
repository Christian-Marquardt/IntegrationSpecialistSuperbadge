public class ProjectCalloutService {
    // Complete the implementation for business and callout logic
    @InvocableMethod(label='Update Opportunity' description='Make HTTP Post Callout for Opportunity')
    public static void PostOpportunityToPMS(List<Id> opportunityIds) {
        try {
            String serviceToken = ServiceTokens__c.getValues(ApexConstants.PROJECT_SERVICE_TOKEN).Token__c;

            List<Opportunity> opportunityList = [
                SELECT Id, Name, Account.Name, closeDate, Amount
                FROM Opportunity
                WHERE Id IN :opportunityIds
            ];

            if (!opportunityList.isEmpty()) {
                Map<String, Object> oppJSONBuilderMap = new Map<String, Object>();
                oppJSONBuilderMap.put('amount', opportunityList[0].Amount);
                oppJSONBuilderMap.put('closeDate', opportunityList[0].CloseDate);
                oppJSONBuilderMap.put('accountName', opportunityList[0].Account?.Name);
                oppJSONBuilderMap.put('opportunityName', opportunityList[0].Name);
                oppJSONBuilderMap.put('opportunityId', opportunityList[0].Id);
                String jsonData = JSON.serialize(oppJSONBuilderMap);

                ID jobID = System.enqueueJob(new QueueablePMSCall(opportunityList[0].Id, jsonData, serviceToken));
            } else {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception!');
                throw e;
            }
        } catch (Exception ex) {
            System.debug('MASSIVE ERROR: ' + ex);
        }
    }

    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        private Id oppId;
        private String jSONInput;
        private String serviceToken;

        // Constructor
        public QueueablePMSCall(Id oppId, String jSONInput, String serviceToken) {
            this.oppId = oppId;
            this.jSONInput = jSONInput;
            this.serviceToken = serviceToken;
        }

        public void execute(QueueableContext context) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('token', this.serviceToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(this.jSONInput);

            HttpResponse response = http.send(request);
            Opportunity opp = new Opportunity(Id = this.oppId);

            if (response.getStatusCode() == 201) {
                opp.StageName = 'Submitted Project';
            } else {
                opp.StageName = 'Resubmit Project';
            }

            update opp;
        }
    }
}