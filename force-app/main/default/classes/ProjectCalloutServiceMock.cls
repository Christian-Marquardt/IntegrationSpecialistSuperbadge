@isTest
global class ProjectCalloutServiceMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('callout:ProjectService', req.getEndpoint(), 'Incorrect request endpoint');
        System.assertEquals(ApexConstants.HTTP_REQUEST_POST, req.getMethod(), 'Incorrect Request Method as it should be POST');

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(201);
        return res;
    }
}