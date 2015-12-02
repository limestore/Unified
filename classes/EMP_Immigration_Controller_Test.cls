/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test class for EMP_Immigration_Controller
History
12/19/2014   Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_Immigration_Controller_Test {
	testMethod static void test_LoadData()
    {
         //test if the immigration record will load
        contentParam param = new contentParam();
        param.url = 'http://www.google.com/';
        param.title = 'Google.com';
        param.libraryName = 'Immigration Postings';
        param.geographic = 'North America'; 
        param.postingDate = date.today();
        param.expirationDate = date.today() + 1;
        generateImmigrationContent(param);
        param.geographic = 'International';
        param.expirationDate = date.today() + 1;
        generateImmigrationContent(param);        

        test.startTest();  
        EMP_Immigration_Controller controller = new EMP_Immigration_Controller();
        test.stopTest();
        
        system.assertEquals(2, controller.content.size());
    }
    
    private static void generateImmigrationContent(contentParam con)
    {
        RecordType ContentRT = [select Id FROM RecordType WHERE Name =: con.libraryName]; 
        
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.ContentURL= con.url;
        testContentInsert.Title = con.title;
        testContentInsert.RecordTypeId = ContentRT.Id; 
        
        insert testContentInsert;
        
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testContentInsert.Id];        
        ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name  =: con.libraryName];
        
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;
        testContent.Immigration_Geographic_Applicability__c = con.geographic;
        testContent.Posting_Date__c = con.postingDate;   
        testContent.Expiration_Date__c = con.expirationDate;
        update testContent;         
    }    
    
     public class contentParam {
        public String url { get; set; }
        public String title { get; set; }
        public String libraryName { get; set; }
        public String geographic { get; set; }      
        public Date postingDate { get; set; }
        public Date expirationDate { get; set; }      
    }
}