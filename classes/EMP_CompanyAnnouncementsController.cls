public class EMP_CompanyAnnouncementsController 
{
    public String ContentTag {get;set;}
    public Integer NumColumns {get;set;}
    public Boolean showAll {get;set;}   
    
    public list<ContentVersion> RecentUpdates {get;set;}
    
    public static final String ContentLibraryName = System.Label.EMP_Library_Name;
    
    public EMP_CompanyAnnouncementsController()
    {
        // declare variables
        RecentUpdates = new List<ContentVersion>();
        
        // set defaults
        if(NumColumns == null) { NumColumns = 1; }
        if(ContentTag == null) { ContentTag = 'Company Announcement'; }
        
        // query all contentDocument Ids and add to the ContentDocumentIdSet
        EMP_ContentDocumentHelper cdhelper = new EMP_ContentDocumentHelper(ContentLibraryName);
        set<Id> ContentDocumentIdSet = cdHelper.ContentDocumentIds;
        set<Id> latestVersion = cdHelper.LatestVersionIds;  
        
        // validates that set(ContentDocumentIdSet) contains value
        if(!ContentDocumentIdSet.isEmpty() || ContentDocumentIdSet.size() > 0)
        {
            // query all ContentVersion 
            list<ContentVersion> ContentVersions = [
                Select ContentDocumentId, Title, Publish_Date__c, 
                       TagCsv, Document_Type__c, Video_File_Location__c 
                From ContentVersion 
                WHERE Id IN: latestVersion
                AND ContentDocumentId IN: ContentDocumentIdSet
                AND Expiration_Date__c >: system.Today()
                AND Content_Start_Date__c <=: system.Today()
                ORDER BY Publish_Date__c DESC 
            ];            
           
           	if(ContentVersions != null && !ContentVersions.isEmpty())
           	{
                Set<String> subHeaderTitle = new Set<String>(); // for de-duplicating
                
            	for (ContentVersion objContentVersion :ContentVersions)
            	{
                    // checks that there are no duplicate titles
                    if (!subHeaderTitle.contains(objContentVersion.Title))
                    {
                        // add value to set for duplicate checking
                        subHeaderTitle.add(objContentVersion.Title);
                        // below condition removed because content visibility 
                        //   is now controlled by a Visualforce component
                        //if (objContentVersion.TagCsv != null && 
                        //    objContentVersion.TagCsv.contains(ContentTag)) { 
                        //    RecentUpdates.add(objContentVersion); }
                         
                        // add all documents instead of filtering
                        RecentUpdates.add(objContentVersion);
                    }
        		}
                //}
            }
        } // end of if condition
    } // end of contstructor
}