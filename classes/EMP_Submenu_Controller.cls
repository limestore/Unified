public class EMP_Submenu_Controller {
    public List<EMP_Sub_Menu__c> subMenuSource { get; set; }
    public EMP_Submenu_Controller() {
        //load the data from the custom settings
        subMenuSource =  new List<EMP_Sub_Menu__c>();
        subMenuSource = EMP_Sub_Menu__c.getAll().values();
        //replace the value of the page_target__c
        for(EMP_Sub_Menu__c setting : subMenuSource){            
            if ('New Page'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_blank';
            }
            else if ('Self'.equals(setting.Page_Target__c))
            {
                setting.Page_Target__c = '_top';
            }
            else
            {
                setting.Page_Target__c = '_blank';
            }
            
        }        
        subMenuSource.sort();
    }
}