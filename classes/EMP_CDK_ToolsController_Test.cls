@isTest
public class EMP_CDK_ToolsController_Test {
    testMethod static void test_PopulateData()
    {
        generateLinks();
        test.startTest();
        EMP_CDK_ToolsController controller = new EMP_CDK_ToolsController();
        test.stopTest();
        //check if all list variable has value
        system.assertEquals(5, controller.dataCol1.size());
        system.assertEquals(5, controller.dataCol2.size());
        system.assertEquals(6, controller.dataCol3.size());
    }
    
    private static void generateLinks()
    {
        List<EMP_CDK_Tools__c> lstTools = new List<EMP_CDK_Tools__c>();
        
        for (Integer ctr = 0; ctr< 16; ctr++)
        {
            EMP_CDK_Tools__c top = new EMP_CDK_Tools__c();
            top.Name = String.valueOf(ctr);
            top.Tool_Name__c = String.valueOf(ctr);
            top.Tool_URL__c = 'http://www.google.com';
            lstTools.add(top);
        }
        insert lstTools;
    }
    
}