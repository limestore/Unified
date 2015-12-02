/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   To Update Forms_Order__c and Forms_Collection__c objects when Subproject__c is Updated
Test Class:    IMP_UpdateFormsOrder_Test
Created on:    15 July 2015.
Code Coverage: 100%
------------------------------------------------------------
History
15 July 2015    Vishal Bandari        -  RQ-04982: Added updateFormOrders method
28 July 2015    Siva.Pragada@cdk.com  -  added boolean check to see if the soql query is necessary. 
                                         we need to query only when the field values change. 
28 July 2015    Siva.Pragada@cdk.com  -  separeated the update dml into separate transaction using future update method in Utilities class.
                                         When we have cross object updates 
									     this would cause Recursive trigger error. We have cross object updates on FO to Task and Task to FO. 
28 July 2015    vishal.bandari@cdk.com - changed the update method to synchronous from future method
2015-11-04      vishal.bandari@cdk.com - RQ-05690: Added code to update Estimated_Install_Date__c field in Laser_Artwork_Order__c
------------------------------------------------------------*/
public class IMP_UpdateFormsOrder_Handler 
{
    public static void updateFormOrders(Map<Id,SubProject__c> newMap, Map<Id,SubProject__c> oldMap)
    {
        try
        {
            Boolean fieldValuesChanged = false;
            
            for(SubProject__c newSub: newMap.values())
            {
                SubProject__c oldSub = oldMap.get(newSub.ID);
                
                if(newSub.Go_Live_Date__c != oldSub.Go_Live_Date__c  || 
                   newSub.Project_Manager__c!= oldSub.Project_Manager__c ||  
                   newSub.Confidential__c!= oldSub.Confidential__c ||
                   newSub.Contract_Roll_Called__c != oldSub.Contract_Roll_Called__c ||
                   newSub.Impact_Project_Numbers__c != oldSub.Impact_Project_Numbers__c || 
                   newSub.Estimated_Install_Date_EID__c != oldSub.Estimated_Install_Date_EID__c)
                {
                    fieldValuesChanged = true; 
                    break;
                } 
            }
            // added boolean check to see if the soql query is necessary. we need to query only when the field values change. 
            // 2015-07-28 - Siva.Pragada@cdk.com
            if(fieldValuesChanged) 
            {
                Map<id,SubProject_External_Reference__c> sperMap = new Map<id,SubProject_External_Reference__c>([
                        SELECT Id, LAO_ID__c, SubProject__c,SubProject__r.Impact_Project_Numbers__c,
                               SubProject__r.Contract_Roll_Called__c, SubProject__r.Project_Manager__c, SubProject__r.Confidential__c, 
                               SubProject__r.Estimated_Install_Date_EID__c 
                        FROM SubProject_External_Reference__c
                        WHERE SubProject__c IN: newMap.keySet() 
                        AND LAO_ID__c != null
                    ]);
                
                List<Id> requiredFormsOrderIds = new List<Id>();
                
                for(SubProject_External_Reference__c sperObj: sperMap.values())
                {
                    requiredFormsOrderIds.add(sperObj.LAO_ID__c);
                }
                
                Map<Id,Laser_Artwork_Order__c> formsOrderMap = new Map<Id,Laser_Artwork_Order__c>([
                        SELECT Id, By_Pass_Forms_Validation_Rules__c, Confidential__c,Go_Live_Date__c,
                               Project_Manager__c, Roll_Call_Date__c, Impact_Project_Numbers__c, Estimated_Install_Date__c
                        FROM Laser_Artwork_Order__c
                        WHERE Id In: requiredFormsOrderIds
                    ]);
                
                Set<Laser_Artwork_Order__c> formsOrderSet = new Set<Laser_Artwork_Order__c>();
                
                for(SubProject_External_Reference__c sperObj : sperMap.values())
                {
                    SubProject__c newObj = newMap.get(sperObj.SubProject__c);
                    SubProject__c oldObj = oldMap.get(sperObj.SubProject__c);
                    Laser_Artwork_Order__c laoObj = formsOrderMap.get(sperObj.LAO_ID__c);
                    laoObj.By_Pass_Forms_Validation_Rules__c = !laoObj.By_Pass_Forms_Validation_Rules__c;
                    laoObj.Confidential__c = sperObj.SubProject__r.Confidential__c;
                    laoObj.Go_Live_Date__c = newObj.Go_Live_Date__c;
                    laoObj.Project_Manager__c = sperObj.SubProject__r.Project_Manager__c;
                    laoObj.Roll_Call_Date__c = sperObj.SubProject__r.Contract_Roll_Called__c;
                    laoObj.Impact_Project_Numbers__c = sperObj.SubProject__r.Impact_Project_Numbers__c;
                    
                    //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to update on Estimated_Install_Date__c
                    laoObj.Estimated_Install_Date__c = sperObj.SubProject__r.Estimated_Install_Date_EID__c;
                    
                    if(!formsOrderSet.contains(laoObj))
                    {
                        formsOrderSet.add(laoObj);
                    }
                }
                //Utilities.SerializesObjectList(new List<sobject>(formsOrderSet), 'Update');
                update new List<Laser_Artwork_Order__c>(formsOrderSet);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());
        }
    }
}