public class EMP_AssociatePortalHomeController {     
    public Boolean showDefault { get; set; }
    public Boolean showReadAll { get; set; }
    public EMP_AssociatePortalHomeController() {              
        String showRead = ApexPages.CurrentPage().getParameters().get('page');
        //check if the component for the read all will be loaded
        if ('ReadllBlog'.equals(showRead))
        {
            showDefault = false;
            showReadAll = true;
        }else
        {
            showDefault = true;
            showReadAll = false;
        }
    }
}