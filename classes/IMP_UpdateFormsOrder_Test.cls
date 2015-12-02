/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test IMP_UpdateFormsOrder_Handler Class and Subproject_On_Laser_Extension Class
Created on:    16 July 2015.
Code Coverage: 100%
------------------------------------------------------------
History
16 July 2015    Vishal Bandari          RQ-04982: Added setupTestData Method
16 July 2015    Vishal Bandari          RQ-04982: Added validateHandlerAndExtension Method
16 July 2015    Vishal Bandari          RQ-04982: Added negitiveTest Method
30 July 2015    Vishal Bandari          RQ-04982: Added code to test Subproject_On_Laser_Extension Class in validateHandlerAndExtension Method
2015-11-04      vishal.bandari@cdk.com  RQ-05690: Added code to test update on Estimated_Install_Date__c field in Laser_Artwork_Order__c
------------------------------------------------------------*/
@IsTest
public class IMP_UpdateFormsOrder_Test
{
    
    //to Setup Test Data
    @testSetup
    public static void setUpTestData()
    {
        //Inserting Sample Project__c
        Project__c projectObj = new Project__c();
        projectObj.Project_Region__c = 'CANADA-EAST';
        insert projectObj;
        
        //Inserting Sample SubProject__c
        Subproject__c subprojectObj = new Subproject__c();
        subprojectObj.SubProject_Name__c = 'Sample Subproject';
        subprojectObj.Project__c = projectObj.Id;
        subprojectObj.SubProject_Region__c = 'CANADA-EAST';
        subprojectObj.Number_of_Rooftops__c = 12.0;
        subprojectObj.Project_Type__c = 'Unhook';
        subprojectObj.Number_of_User_Connections__c = 12.0;
        subprojectObj.Market__c = 'LightSpeed-Powersports';
        subprojectObj.Confidential__c = false;
        subprojectObj.Contract_Roll_Called__c = null;
        insert subprojectObj;
        
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        CMF_Info__c cmf = new CMF_Info__c();
        cmf.Name = 'Sample CMF';
        cmf.Account__c = acc.Id;
        insert cmf;
        
        List<Laser_Artwork_Order__c> laoList = new List<Laser_Artwork_Order__c>();
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj = new Laser_artwork_order__C();
        laoObj.Ship_CMF_Info__c = cmf.id;
        laoList.add(laoObj);
        
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj2 = new Laser_artwork_order__C();
        laoObj.Ship_CMF_Info__c = cmf.id;
        laoList.add(laoObj2);
        
        insert laoList;
        
        //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
        SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
        sperObj.LAO_ID__c = laoObj.id;
        sperObj.Project__c = projectObj.Id;
        sperObj.SubProject__c = subprojectObj.Id;
        insert sperObj;
        
    }
    
    //to Test Confidential__c, Go_Live_Date__c, Project_Manager__c update on Subproject__c reflects on Forms_Order__c and Forms_Collection_c object
    public static testmethod void validateHandlerAndExtension()
    {
        test.startTest(); 
        Subproject__c subprojectObj = [
            SELECT ID, Go_Live_Date__c, Project_Manager__c, Confidential__c, Contract_Roll_Called__c, Impact_Project_Numbers__c,Estimated_Install_Date_EID__c
            FROM Subproject__c
            WHERE SubProject_Name__c = 'Sample Subproject'
        ];
        
        //Initially values are not initialised when Subproject__c is inserted
        System.assertEquals(subprojectObj.Go_Live_Date__c,null, 'Go Live Date got initialized');
        System.assertEquals(subprojectobj.Project_Manager__c,null, 'Project Manager got initialized');
        System.assertEquals(subprojectobj.Confidential__c,false, 'Confidential got changed without update');
        System.assertEquals(subprojectObj.Contract_Roll_Called__c,null, 'Contract Roll Called Date got changed without update');
        System.assertEquals(subprojectObj.Impact_Project_Numbers__c,null, 'Impact Project Numbers got changed without update');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        System.assertEquals(subprojectObj.Estimated_Install_Date_EID__c,null, 'Estimated Install Date got changed without update');
        
        //Update the values of Subproject Object field
        subprojectObj.Go_Live_Date__c = System.Date.today();
        subprojectobj.Project_Manager__c = Userinfo.getUserId();
        subprojectobj.Confidential__c = !subprojectobj.Confidential__c;
        subprojectobj.Contract_Roll_Called__c = System.Date.today();
        subprojectobj.Impact_Project_Numbers__c = '5';
        subprojectObj.Estimated_Install_Date_EID__c = Date.Today().addDays(2);
        update subprojectObj;
        
        SubProject_External_Reference__c sperObj = [
            SELECT Id,  LAO_ID__c
            FROM SubProject_External_Reference__c
            WHERE SubProject__c =: subprojectObj.Id
        ];
        
        Laser_Artwork_Order__c laoObj = [
            SELECT ID, Go_Live_Date__c, Project_Manager__c, Confidential__C, Roll_Call_Date__c, Impact_Project_Numbers__c, Estimated_Install_Date__c
            FROM Laser_Artwork_Order__c
            WHERE Id =: sperObj.LAO_ID__c
        ];
        
        //Check for update of Laser_Artwork_Order__c or Forms_Order__c object
        System.assertEquals(subprojectObj.Go_Live_Date__c,laoObj.Go_Live_Date__c, 'Go Live Date not updated in Forms Order');
        System.assertEquals(subprojectObj.Project_Manager__c,laoObj.Project_Manager__c, 'Project Manager not updated in Forms Order');
        System.assertEquals(subprojectobj.Confidential__c,laoObj.Confidential__c, 'Confidential not updated in Forms Order');
        System.assertEquals(subprojectobj.Contract_Roll_Called__c,laoObj.Roll_Call_Date__c, 'Confidential not updated in Forms Order');
        System.assertEquals('5',laoObj.Impact_Project_Numbers__c, 'Impact Project numbers not updated in Forms Order');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        System.assertEquals(subprojectObj.Estimated_Install_Date_EID__c,laoObj.Estimated_Install_Date__c, 'Estimated Install Date not updated in Forms Order');
        
        //Testing Standard Layout of Laser_Artwork_Object__c SubprojectInfo Section
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(laoObj);
        Subproject_On_Laser_Extension sole = new Subproject_On_Laser_Extension(stdCtrl);
        sole.getRecordDetails();
        System.assertNotEquals(null, sole.sperObj, 'Subproject External Reference Object Not Found');
        
        laoObj = [SELECT ID  FROM Laser_Artwork_Order__c WHERE Id != :sperObj.LAO_ID__c order by CreatedDate desc Limit 1];
        stdCtrl = new ApexPages.StandardController(laoObj);
        sole = new Subproject_On_Laser_Extension(stdCtrl);
        sole.getRecordDetails();
        System.assertEquals(null, sole.sperObj, 'Unexpected value for Subproject External Reference Object');
        test.stopTest();
    }
    
    //to perform negitive test
    public static testmethod void negitiveTest()
    {
        IMP_UpdateFormsOrder_Handler.updateFormOrders(null,null);
    }
}