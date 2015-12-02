/*******************************************************
* Author: Sanjay.Ghanathey@cdk.com
* Description: Salesforce Datatypes replication in AngularJS
* Test Class: ALL_AngularInputFields_Test
* 
* History:
* 2015-07-28 	Sanjay Ghanathey		Created
* 2015-07-29 	Sanjay Ghanathey		Added Search
*                            		    using Rest
* 2015-08-06 	Sanjay Ghanathey		Fetch Picklist
*                            		    values
* *************************************************** */
@RestResource(urlMapping='/datatable/*')
global class ALL_AngularInputFields_Controller {
    
    //To Fetch Data for Lookup Fields    
    @RemoteAction
    global static String retrieveLookupData(string objectName,string columnNames,string searchString,string displayName) {        
        String query = 'SELECT '+columnNames+' FROM '+objectName +' WHERE '+displayName+' LIKE ' + '\'%'+ searchString + '%\''+'Limit 200';
        List<sObject> queryResult = Database.query(query);               
        return JSON.serialize(queryResult);
    }  
    
    //Fetch picklist data of given field
    @RemoteAction
    public static List<Picklist> getPicklistValues(String objectName, String fld){
        system.debug('Inside Get Pick list');
        List<Picklist> pickList = new List<Picklist>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        if (targetType == null) {
            // throw an exception
        }
        SObject obj =targetType.newSObject();
        Schema.sObjectType objType = obj.getSObjectType();         
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();               
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        
        list<Schema.PicklistEntry> values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : values)
        { 
            Picklist picklistObj = new Picklist();
            picklistObj.label = a.getLabel();
            picklistObj.value = a.getValue();
            pickList.add(picklistObj);            
        }
        system.debug('$$'+pickList);
        return pickList;
    }    
    
    public class Picklist
    {
        String label{get;set;}
        String value{get;set;}
    }
    
    //To Fetch Data for Lookup Fields 
    @HttpPost
    global static String doPost(String objectName,String columnNames,String searchString,String displayName) {        
        String query = 'SELECT '+columnNames+' FROM '+objectName +' WHERE '+displayName+' LIKE ' + '\'%'+ searchString + '%\'';
        List<sObject> queryResult = Database.query(query);               
        return JSON.serialize(queryResult);
    }
}