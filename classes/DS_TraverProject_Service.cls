/*------------------------------------------------------------
Author: Hemanth Kesapragada
Description: This class is a webservice to update Traver Project object. This is consumed using REST API. 
URL to access: 'baseURI' + '/services/apexrest/Traver'
Inputs: 
1) partyID				String
2) apptRatioService 	Decimal
3) apptRatioSales		Decimal
4) scheduleRatio		Decimal
5) confRatio			Decimal
6) showRatio			Decimal
7) closeRatio			Decimal
Response:
1) Response Message		String

History:
2015-06-18 Hemanth.kesapragada@cdk.com	Created
-----------------------------------------------------------*/
@RestResource(urlMapping='/Traver/*')
global class DS_TraverProject_Service 
{
    @HttpPost
    global static void submitTraverDetails(String partyID,Decimal apptRatioService, 
                                           Decimal apptRatioSales,Decimal scheduleRatio,
                                           Decimal confRatio,Decimal showRatio,
                                           Decimal closeRatio)
    {
        RestResponse resp = RestContext.response;
        resp.statusCode = 200;
        try
        {
            if(PartyID==null || PartyID=='')
            {
                resp.responseBody = Blob.valueOf('Party ID cannot be empty');
            }
            else if(apptRatioService==null && apptRatioSales==null && scheduleRatio==null && confRatio==null && showRatio==null && closeRatio==null)
            {
                resp.responseBody = Blob.valueOf('Atleast one ratio field must be specified');
            }
            else
            {
                Account accountObj;
                try
                { 
                    accountObj = [select Id,PartyID__c,Name from Account where PartyID__C=:partyID];
                }
                catch(Exception e)
                {
                    resp.responseBody = Blob.valueOf('Invalid PartyID');
                }
                if(accountObj==null)
                {
                    resp.responseBody = Blob.valueOf('Invalid PartyID');
                }
                else
                {
                    List<Traver_Project__c> traverProjectList = [select id,Project_Status__c,Appt_Ratio_Service__c,
                                                                 Appt_Ratio_Sales__c,Schedule_Ratio__c,
                                                                 Conf_Ratio__c,Show_Ratio__c,Close_Ratio__c 
                                                                 from Traver_Project__c 
                                                                 where Account__c = :accountObj.Id 
                                                                 and Project_Status__c='Active'];
                    if(traverProjectList.size()>1)
                    {
                        resp.responseBody = Blob.valueOf('Multiple Traver Projects found for this Party ID');
                    }
                    else if(traverProjectList.isEmpty())
                    {
                        resp.responseBody = Blob.valueOf('No Traver Projects found for this Party Id');
                    }
                    else
                    {
                        Traver_Project__c traverObj = traverProjectList.get(0);
                        boolean updateFlag = false;
                        if(apptRatioService!=null && apptRatioService!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Appt_Ratio_Service__c = apptRatioService;
                        }
                        if(apptRatioSales!=null&& apptRatioSales!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Appt_Ratio_Sales__c = apptRatioSales;
                        }
                        if(scheduleRatio!=null&& scheduleRatio!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Schedule_Ratio__c = scheduleRatio;
                        }
                        if(confRatio!=null&& confRatio!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Conf_Ratio__c = confRatio;
                        }
                        if(showRatio!=null&& showRatio!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Show_Ratio__c = showRatio;
                        }
                        if(closeRatio!=null&& closeRatio!=0.0)
                        {
                            updateFlag = true;
                            traverObj.Close_Ratio__c = closeRatio;
                        }
                        if(updateFlag)
                        {
                            upsert traverObj;
                        }
                        resp.responseBody = Blob.valueOf('Traver Project updated');
                    }
                }
            }
        }
        Catch(Exception e)
        {
            resp.responseBody = Blob.valueOf('Exception caused - '+e.getMessage());
        }
    }
    
}