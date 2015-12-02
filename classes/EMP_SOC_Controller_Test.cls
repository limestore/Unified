/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test class for EMP_SOC_Controller
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_SOC_Controller_Test {
	testMethod static void testLoad()
    {
        generateCustomSettings();
        generateContent('US','Test 1','2013');
        generateContent('US','Test 2','2014');
        generateContent('General Infor & FAQS','Test 2','');
        generateContent('General Infor & FAQS','Test 3','');
        test.startTest();
        EMP_SOC_Controller controller = new EMP_SOC_Controller();
        test.stopTest();
        system.assertEquals(1, controller.lstContent.size());
        system.assertEquals(1, controller.lstExternalSite.size());
    }
    
    private static void generateCustomSettings()
    {
        List<EMP_SOC_Config__c> lstConfig = new List<EMP_SOC_Config__c>();
    	EMP_SOC_Config__c config = new EMP_SOC_Config__c();
        config.Name = 'US';
        config.Image_URL__c = 'img/smile.png';
        config.isReportCategory__c = true;
        config.Description__c = 'test';
        config.Order__c = 1;
        lstConfig.add(config);
        
        EMP_SOC_Config__c config2 = new EMP_SOC_Config__c();
        config2.Name = 'General Infor & FAQS';
        config2.Image_URL__c = 'img/smile.png';
        config2.isReportCategory__c = false;
        config2.Description__c = 'test';
        config2.Order__c = 2;
        lstConfig.add(config2);
        
        insert lstConfig;
    }
    
    private static void generateContent(String name, String title, String subGroup) 
    {
        RecordType ContentRT = [select Id FROM RecordType WHERE Name = 'Report']; 
        
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL= 'www.google.com';
        testContentInsert.Title = 'Test Title ' + title;
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert;
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name  = 'Report'];
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;    
        
        testContent.Section_SubGroup__c = subGroup;      
        testContent.Expiration_Date__c = date.today().addDays(3); 
        testContent.Applicability__c = name;
        testContent.Version__c = '1.0';    
        testContent.Report_Category__c = 'SOC';
        update testContent;
    }
}