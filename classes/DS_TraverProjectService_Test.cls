/*------------------------------------------------------------
Author: Hemanth Kesapragada
Description: This class is used to test  DS_TraverProject_Service
HTTP Method: POST only
Updates Traver Project object if all the params are passed.
History:
2015-06-23 Hemanth.kesapragada@cdk.com	Created
-------------------------------------------------------------*/
@isTest
public class DS_TraverProjectService_Test {

    public static String partyID;
    public static Decimal apptRatioService;
    public static Decimal apptRatioSales;
    public static Decimal scheduleRatio;
    public static Decimal confRatio;
    public static Decimal showRatio;
    public static Decimal closeRatio;
    public static RestRequest request;
    public static RestResponse response;
    public static Traver_Project__c traverObj = new Traver_Project__c();
    public static Account accountObj;
    static
    {
        request = new RestRequest()  ;  
        request.addHeader('httpMethod', 'POST');
        request.httpMethod = 'POST';
        request.requestURI = '/Traver';
        request.addParameter('Priority', 'High');
        RestContext.request = request;
        accountObj = DS_TestObjects.NewAccount_Inserted();
        accountObj.PartyID__c  = '11111';
        upsert accountObj;
        traverObj =  newTraverProject(accountObj);
    }    
    static testMethod void testSubmitTraverDetailsEmptyPartyID()
    {
        partyID = '';
        response = new RestResponse();
        RestContext.response = response ;
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        Blob b = response.responseBody;
        String actualMessage = b.toString();
        String expectedMessage = 'Party ID cannot be empty';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
    }
    static testMethod void testSubmitTraverDetailsEmptyRatioFields()
    {
        response = new RestResponse();
        RestContext.response = response ;
        partyID = '11111';
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        Blob b = response.responseBody;
        String actualMessage = b.toString();
        String expectedMessage = 'Atleast one ratio field must be specified';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
    }
    static testMethod void testSubmitTraverDetailsInvalidPartyID()
    {
        response = new RestResponse();
        RestContext.response = response ;
        partyID = '12345';
        apptRatioService=1.0;
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        Blob b = response.responseBody;
        String actualMessage = b.toString();
        String expectedMessage = 'Invalid PartyID';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
    }
    static testMethod void testSubmitTraverDetailsValidPartyID()
    {
        response = new RestResponse();
        RestContext.response = response ;
        partyID = '11111';
        apptRatioService = 2.0;
        apptRatioSales = 1.0;
        scheduleRatio=2.0;
        confRatio = 3.0;
        showRatio = 1.0;
        closeRatio = 1.1;
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        Blob b = response.responseBody;
        String actualMessage = b.toString();
        String expectedMessage = 'Traver Project updated';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
        
        Traver_Project__c expTraverObj = [select Appt_Ratio_Service__c,Appt_Ratio_Sales__c 
                                          from Traver_Project__c where id=:traverObj.Id];
        
        System.assertEquals(expTraverObj.Appt_Ratio_Service__c,apptRatioService);
        System.assertEquals(expTraverObj.Appt_Ratio_Sales__c,apptRatioSales);
        
        Traver_Project__c traverProjectObjNew =  newTraverProject(accountObj);
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        b = response.responseBody;
        actualMessage = b.toString();
        expectedMessage = 'Multiple Traver Projects found for this Party ID';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
        
        delete traverProjectObjNew;
        delete traverObj;
        
        DS_TraverProject_Service.submitTraverDetails(partyID, apptRatioService, apptRatioSales, scheduleRatio, confRatio, showRatio, closeRatio);
        b = response.responseBody;
        actualMessage = b.toString();
        expectedMessage = 'No Traver Projects found for this Party Id';
        System.assertEquals(expectedMessage.toUpperCase(),actualMessage.toUpperCase());
    }
    private static Traver_Project__c newTraverProject(Account accoubtObj)
    {
        Traver_Project__c traverProjectObj = new Traver_Project__c();
        traverProjectObj.Account__c = accountObj.Id;
        traverProjectObj.PartyID__c = accountObj.PartyID__c;
        traverProjectObj.Project_Status__c = 'Active';
        upsert traverProjectObj;
        return traverProjectObj;
    }
}