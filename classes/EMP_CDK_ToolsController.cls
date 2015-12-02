public class EMP_CDK_ToolsController {    
    
    public List<EMP_CDK_Tools__c> dataCol1 { get; set; }
    public List<EMP_CDK_Tools__c> dataCol2 { get; set; }
    public List<EMP_CDK_Tools__c> dataCol3 { get; set; }
    
    public EMP_CDK_ToolsController() {
        Map<String,String> mapCategory = new Map<String,String>();
        //load data from custom settings
        List<EMP_CDK_Tools__c> lstContent = EMP_CDK_Tools__c.getAll().values();
        //compute the number of items per column
        Integer seperateCount = lstContent.size() / 3;
        List<ToolsWrapper> sortedList = sortManual(lstContent);

        dataCol1 = new List<EMP_CDK_Tools__c>();
        dataCol2 = new List<EMP_CDK_Tools__c>();
        dataCol3 = new List<EMP_CDK_Tools__c>();
        
        Integer ctr = 1;
        Integer cnt = 1;
        //seperate the content into 3 column
        for(ToolsWrapper toolWrap : sortedList){    
            EMP_CDK_Tools__c setting = toolWrap.content;
            //ctr represent the column number
            //cnt represent the count of records
            if (ctr == 1)
            {
                dataCol1.add(setting);                
            }
            else if(ctr == 2)
            {
                dataCol2.add(setting);
            }              
            else
            {
                dataCol3.add(setting);
            }
            //increment cnt when number of record match the number of the seperateCount
            //reset the cnt
            if (cnt == seperateCount)
            {
                ctr++;
                cnt = 1;
            }else
            {
                cnt++;
            }
        }
    }
    
    public List<ToolsWrapper> sortManual(List<EMP_CDK_Tools__c> lstTools)
    {
        //sort by Tool_Name__c
        List<ToolsWrapper> sortedList = new List<ToolsWrapper>();
        for(EMP_CDK_Tools__c setting : lstTools){
            ToolsWrapper tool = new ToolsWrapper();
            tool.toolName = setting.Tool_Name__c;
            tool.content = setting;
            sortedList.add(tool);
        }
        sortedList.sort();
        return sortedList;
    }
    
    public class ToolsWrapper implements Comparable
    {
        public String toolName { get; set; }
        public EMP_CDK_Tools__c content { get; set; }
        public Integer compareTo(Object compareTo)
        {
            ToolsWrapper jobsWrapper = (ToolsWrapper) compareTo;
            if (toolName == jobsWrapper.toolName) return 0;
            if (toolName > jobsWrapper.toolName) return 1;
            return -1;  
        }
    }
}