/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Extension for Subproject_On_LAO Visual Force Page
Created on:    30 July 2015.
Test Class:    IMP_UpdateFormsOrder_Test
Code Coverage: 100%
------------------------------------------------------------
History
30 July 2015    Vishal Bandari              RQ-04982: Added getRecordDetails method
2015-11-06      vishal.bandari@cdk.com      RQ-05690: Added Estimated_Install_Date_EID__c and Business_Alignment_Workshop_Date__c fields from Subproject.
------------------------------------------------------------*/
public class Subproject_On_Laser_Extension
{
    private Id LAO_RecordId;
    
    public SubProject_External_Reference__c sperObj {get;set;}
    
    public Subproject_On_Laser_Extension(ApexPages.StandardController stdController)
    {
        LAO_RecordId = stdController.getId();
    }
    
    public void getRecordDetails()
    {
        try
        {            
            //2015-11-06 vishal.bandari@cdk.com RQ-05690 added Business_Alignment_Workshop_Date__c and Estimated_Install_Date_EID__c fields in SOQL
            
            sperObj = [
                SELECT SubProject__c, SubProject__r.Business_Alignment_Workshop_Date__c, 
                SubProject__r.Confidential__c,SubProject__r.Contract_Roll_Called__c,
                SubProject__r.Estimated_Install_Date_EID__c, SubProject__r.Impact_Project_Numbers__c,
                SubProject__r.Go_Live_Date__c, SubProject__r.Name, SubProject__r.Project_Manager__c       
                FROM SubProject_External_Reference__c 
                WHERE LAO_ID__c =: LAO_RecordId
                LIMIT 1
            ];  
        }
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());
        }
    }
}