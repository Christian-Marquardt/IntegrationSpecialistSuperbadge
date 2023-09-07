@RestResource(urlMapping='/project/*')
global class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(
        String ProjectRef,
        String ProjectName,
        String OpportunityId,
        Date startDate,
        Date endDate,
        Double Amount,
        String Status
    ) {
        String returnMessage = '';
        System.debug('HELP');
        Savepoint objSavePoint = Database.setSavepoint();

        try {
            if (OpportunityId != null && OpportunityId.trim().length() > 0) {
                Opportunity opp = new Opportunity(Id = opportunityId);
                opp.DeliveryInstallationStatus__c = 'In progress';
                update opp;

                Project__c project = new Project__c(ProjectRef__c = ProjectRef);
                project.Name = ProjectName;
                project.Opportunity__c = OpportunityId;
                project.Start_Date__c = startDate;
                project.End_Date__c = endDate;
                project.Billable_Amount__c = Amount;
                upsert project;

                returnMessage = 'OK';
            } else {
                returnMessage = 'Invalid work';
            }
        } catch (Exception e) {
            Database.RollBack(objSavePoint);

            returnMessage = 'Exception is ' + e.getMessage();
        }

        return returnMessage;
    }
}