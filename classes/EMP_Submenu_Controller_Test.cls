@isTest
public class EMP_Submenu_Controller_Test {
    testMethod static void test_PopulateData()
    {
        generateLinks();
        test.startTest();
        EMP_Submenu_Controller controller = new EMP_Submenu_Controller();
        test.stopTest();
        //check if  list variable has value
        system.assertEquals(3, controller.subMenuSource.size());
        
    }
    
    private static void generateLinks()
    {
        List<EMP_Sub_Menu__c> lstMenu = new List<EMP_Sub_Menu__c>();  
        
        List<EMP_Sub_Menu__c> lstHumanTop = new List<EMP_Sub_Menu__c>();
        EMP_Sub_Menu__c menu = new EMP_Sub_Menu__c();
        menu.Name = '1st Menu';
        menu.Submenu_Name__c = '1st Menu';
        menu.Submenu_URL__c = 'http://www.google.com';
        menu.Page_Target__c = 'New Page';
        lstMenu.add(menu);
        
        EMP_Sub_Menu__c menu2 = new EMP_Sub_Menu__c();
        menu2.Name = '2nd Menu';
        menu2.Submenu_Name__c = '2nd Menu';
        menu2.Submenu_URL__c = 'http://www.google.com';
        menu2.Page_Target__c = 'Self';
        lstMenu.add(menu2);
        
        EMP_Sub_Menu__c menu3 = new EMP_Sub_Menu__c();
        menu3.Name = '3rd Menu';
        menu3.Submenu_Name__c = '3rd Menu';
        menu3.Submenu_URL__c = 'http://www.yahoo.com';
        menu3.Page_Target__c = '';
        lstMenu.add(menu3);
        
        insert lstMenu;
    }
}