public class ProjectCalloutService {
    public static Opportunity mainOpp;

    //Complete the implementation for business and callout logic
    @InvocableMethod(label='Update Opportunity' description='Make HTTP Post Callout for Opportunity')
    public static void PostOpportunityToPMS(List<Id> opportunityIds) {
        try {
            System.debug('OPPIDS: ' + opportunityIds);
            String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;

            List<Opportunity> opportunityList = [
                SELECT Id, Name, Account.Name, closeDate, Amount
                FROM Opportunity
                WHERE Id IN :opportunityIds
            ];
            System.debug('OPPLIST: ' + opportunityList);

            if (!opportunityList.isEmpty()) {
                Map<String, Object> oppJSONBuilderMap = new Map<String, Object>();
                oppJSONBuilderMap.put('amount', opportunityList[0].Amount);
                oppJSONBuilderMap.put('closeDate', opportunityList[0].CloseDate);
                oppJSONBuilderMap.put('accountName', opportunityList[0].Account?.Name);
                oppJSONBuilderMap.put('opportunityName', opportunityList[0].Name);
                oppJSONBuilderMap.put('opportunityId', opportunityList[0].Id);
                String jsonData = JSON.serialize(oppJSONBuilderMap);

                System.debug('Json Data - ' + jsonData);
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

        public QueueablePMSCall(Id oppId, String jSONInput, String serviceToken) {
            this.oppId = oppId;
            this.jSONInput = jSONInput;
            this.serviceToken = serviceToken;
            System.debug('oppId: ' + oppId);
            System.debug('jSONInput: ' + jSONInput);
            System.debug('serviceToken: ' + serviceToken);
        }

        public void execute(QueueableContext context) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('token', this.serviceToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(this.jSONInput);
            System.debug('request: ' + request.getBody());
            HttpResponse response = http.send(request);
            System.debug('REQUEST: ' + request);
            System.debug('response: ' + response);
            // Parse the JSON response

            Opportunity opp = new Opportunity(Id = this.oppId);
            if (response.getStatusCode() == 201) {
                opp.StageName = 'Submitted Project';
                System.debug('RESPONSE SUCCESS: ' + response.getBody());
            } else {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                opp.StageName = 'Resubmit Project';
            }

            update opp;
        }
    }
}