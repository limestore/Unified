@isTest
private class EMP_Chatter_Controller_Test
{
    @isTest
    static void testDataTable_Test1(){
        Test.startTest();
             CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
             insert cg;
                    
             // Create Chatter Post
             FeedItem testFeed1 = new FeedItem(Body='Test Feed 1 Post', ParentId = cg.Id, Type='TextPost');
             insert testFeed1;
                    
             // Create Chatter Comment
             FeedComment testFeed1Comment = new FeedComment(CommentBody='Test Feed 1 Comment', FeedItemId=testFeed1.Id, CommentType='TextComment');
             insert testFeed1Comment;
                    
             // Create Chatter Post
             FeedItem testFeed2 = new FeedItem(Body='Test Feed 2 Post', ParentId = cg.Id, Type='TextPost');
             insert testFeed2;
                    
             // Create Chatter Comment
             FeedComment testFeed2Comment = new FeedComment(CommentBody='#answer Test Feed 2 Comment', FeedItemId=testFeed2.Id, CommentType='TextComment');
             insert testFeed2Comment;
                    
             List<CollaborationGroupFeed> feeds = [Select Body from CollaborationGroupFeed];
             system.debug('-------------- ' + feeds);
        
        Test.setCurrentPage(Page.EMP_NoPage);
        EMP_Chatter_Controller objempc = new EMP_Chatter_Controller();
         objempc.ChatterGroupIdvalue=cg.id;
        String strVal = objempc.ChatterGroupIdvalue;
        
        String UserStatus = objempc.UserStatus;
        String profileImageUrl = objempc.profileImageUrl;
        String CurrPageName = objempc.CurrPageName;
        String post = objempc.post;
        String ChatterGroupId = objempc.ChatterGroupId;
        objempc.AddPost();
        objempc.ShowMore();
        objempc.getGroupNames();
        Test.stopTest();
    }
}