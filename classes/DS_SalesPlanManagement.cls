/* ADP Dealer Services - Sales Automation
 * Programmer: Matt Keefe (matt_keefe@adp.com, 847.485.4849)
 * Project: Sales Crediting Plan Management
 * 
 * Short Description: An interface for entering and calculating NNC (Net New Credit), RC (Renewal Credit),
 *   QC (Quota Credit) and PC (Presidents Club) Number.
 * 
 * Project Description: Entering Credit amounts in Salesforce is tedious when done through the default
 *   interface. This interface enables selection of a Sales Plan (a set of percentages per month) which
 *   can be applied (upon button click) to a yearly total for a given Credit Type (NNC, RC, QC). When QC 
 *   is entered, the PC Number is automatically set to 105% of the total QC. 
 *   
 * Project Components:
 *   DS_SalesPlanManagement.cls
 *   DS_SalesPlanManagement.page
 *   DS_SalesPlanManagement_CSS.resource
 *   DS_SalesPlanManagement_JS.resource
 *   DS_SalesPlanManagement_Test.cls
 *   jQuery.resource
 *   
 */

global class DS_SalesPlanManagement
{
    global class Result
    {
        // constructors
        global Result(){Success=false;}
        global Result(boolean s){Success=s;}
        
        // variables
        global string Message;
        global boolean Success;
        
        global List<UserWithCredit> Users;
    }
    
    global class UserWithCredit
    {
        global UserWithCredit() { Updated = false; } // default Updated status to false
        
        global boolean Updated;
        global string Message;
        
        global string UserId;
        global string EmployeeInformationId;
        global string ForecastingChannel;
        global string TotalNNC;
        global string TotalRC;
        global string TotalQC;
        global string PCNumber;
        
        global List<President_s_Club_Performance__c> Performances;
        global List<Employee_Club_Information__c> ClubInformations;
        
        global string getByName(string creditType)
        {
            if(creditType == 'TotalNNC') { return TotalNNC; }
            if(creditType == 'TotalRC') { return TotalRC; }
            if(creditType == 'TotalQC') { return TotalQC; }
            if(creditType == 'PCNumber') { return PCNumber; }
            return null;
        }
        
        global void setByName(string creditType, string value)
        {
            if(creditType == 'TotalNNC') { TotalNNC=value; }
            if(creditType == 'TotalRC') { TotalRC=value; }
            if(creditType == 'TotalQC') { TotalQC=value; }
            if(creditType == 'PCNumber') { PCNumber=value; }
        }
    }
    
    global static String UserQueryBase = ''
    	+ 'Select '
    		+ 'Id, Name, FirstName, LastName, Title, Region__c, Forecasting_Channel__c, '
        	+ 'ManagerId, Manager.Name, Manager.FirstName, Manager.LastName, IsActive, ' 
        	+ '(Select Id, Name From Employee_Information__r) '
        + 'From User ' 
        + 'Where Forecasting_Channel__c != null '
    	+ '';
    
    global static String UserQueryEnd = ' '
    	+ 'ORDER BY LastName, FirstName ASC '
    	+ '';
    
    @RemoteAction
    global static List<String> GetYears()
    {
        List<String> Years = new List<String>();
        for(Integer i=0; i<5; i++)
        {
            Years.add(String.valueOf(Date.Today().Year()-i));
        }
        return Years;
    }
    
    @RemoteAction
    global static List<Seasonal_Rate__c> GetAllSeasonalRates()
    {
        List<Seasonal_Rate__c> AllSeasonalRates = [Select Id, Name, 
            January__c, February__c, March__c, April__c, May__c, June__c, 
            July__c, August__c, September__c, October__c, November__c, December__c 
            From Seasonal_Rate__c Order By Name Asc];
        
        return AllSeasonalRates;
    } 
    
    @RemoteAction
    global static Result SaveSeasonalRate(Seasonal_Rate__c sr)
    {
        Result r = new Result(true);
        
        try { upsert sr; }
        catch(Exception ex) { r.Message = ex.getMessage(); r.Success = false; }
        
        return r;
    }
    
    @RemoteAction
    global static List<User> GetAllForecastingUsers()
    {
        return Database.query(UserQueryBase + UserQueryEnd);
    }
    
    @RemoteAction
    global static List<User> GetAllActiveForecastingUsers()
    {
        return Database.query(UserQueryBase + ' '
            + 'And IsActive = true ' 
            + UserQueryEnd);
    }
    
    @RemoteAction
    global static List<User> GetAllInactiveForecastingUsers()
    {
        return Database.query(UserQueryBase + ' '
            + 'And IsActive = false ' 
            + UserQueryEnd);
    }
    
    @RemoteAction
    global static List<User> GetAllUserManagers()
    {
    	Map<Id,String> Managers = new Map<Id,String>();
    	List<User> UsersWithManagers = [Select Id, Name, ManagerId, Manager.Name From User Where ManagerId != null ORDER BY Manager.Name];
    	for(User u : UsersWithManagers) { Managers.put(u.ManagerId,u.Manager.Name); }
    	
    	String ManagerIds = '(';
		for(String ManagerId : Managers.keyset()) { ManagerIds += '\'' + ManagerId + '\'' + ',';  } 
		ManagerIds = ManagerIds.substring(0,ManagerIds.lastIndexOf(',')) + ') ';
    	
        return Database.query(UserQueryBase + ' '
            + 'And IsActive = true ' 
            + 'And Id IN ' + ManagerIds
            + UserQueryEnd);
    }
    
    @RemoteAction
    global static List<String> GetAllUserTitles()
    {
        List<User> Users = DS_SalesPlanManagement.GetAllForecastingUsers();
        
        Set<String> Titles = new Set<String>(); // all items added to a set are unique
        List<String> SortedTitles = new List<String>(); // lists are sortable
        
        for(User u : Users){
            if(u.Title != null){
                Titles.add(u.Title);}} // assign to a Set to remove duplicates
        
        SortedTitles.addAll(Titles);
        SortedTitles.sort();
        
        system.debug(SortedTitles);
        return SortedTitles;
    }
    
    @RemoteAction
    global static List<String> GetAllUserForecastingChannels()
    {
        List<String> PickListStrings = new List<String>();
        Schema.DescribeFieldResult FieldResult = User.Forecasting_Channel__c.getDescribe();
        List<Schema.Picklistentry> PickListEntries = FieldResult.getPicklistValues();
        
        for(Schema.Picklistentry p : PickListEntries)
        {
            if(p.getValue() != 'All' && p.getValue() != '--None--') {
                PickListStrings.add(p.getValue()); }
        }
        
        PickListStrings.sort();
        return PickListStrings;
    }
    
    @RemoteAction
    global static List<President_s_Club_Performance__c> GetPCPerformance(List<String> UserIdStrings)
    {
        Set<Id> UserIds = new Set<Id>();
        for(String s : UserIdStrings) { 
            try { Id i = s; UserIds.add(i); } catch(Exception ex) { } } 
        
        List<President_s_Club_Performance__c> Performances = [Select Id, Name, 
            Employee_Name__c, Employee_Name__r.User__r.Name, Employee_Name__r.User__r.LastName, Employee_Name__r.User__r.FirstName, 
            Fiscal_Year__c, Forecasting_Channel__c, Month__c, MonthNumber__c, Planned_NNC__c, Planned_RC__c, Planned_QC_Month__c, 
            Actual_NNC__c, Actual_RC__c, Actual_QC_Month__c 
            From President_s_Club_Performance__c Where Employee_Name__r.User__c IN :UserIds 
            Order BY MonthNumber__c, Employee_Name__r.User__r.LastName ASC];
        
        return (Performances != null ? 
            (Performances.size() > 0 ? Performances : new List<President_s_Club_Performance__c>()) : 
            new List<President_s_Club_Performance__c>()
        );
    }
    
    @RemoteAction
    global static Result SetPCPerformance(List<President_s_Club_Performance__c> Performances)
    {
        Result r = new Result();
        
        try 
        {
            update Performances;
            r.Success = true;
            r.Message = 'Success';
        }
        catch(Exception ex)
        {
            r.Message = ex.getMessage();
            return r;
        }
        
        return r;
    }
    
    @RemoteAction
    global static Result Assign(string AssignType, List<UserWithCredit> Users, string SeasonalRateId, string Year)
    {
        system.debug(AssignType);
        system.debug(Users);
        system.debug(SeasonalRateId);
        
        string CreditType = null;
        string CreditTypeField = null;
        
        Result AssignCreditResult = new Result(false);
        
        if(AssignType == 'NNC') { CreditType = 'TotalNNC'; CreditTypeField = 'Planned_NNC__c'; }
        else if(AssignType == 'RC') { CreditType = 'TotalRC'; CreditTypeField = 'Planned_RC__c'; }
        else if(AssignType == 'QC') { CreditType = 'TotalQC'; CreditTypeField = 'Planned_QC_Month__c'; }
        else { AssignCreditResult.message = 'Error: The type of credit to assign is invalid.'; return AssignCreditResult; }
        
        if(Users == null) {
            AssignCreditResult.message = 'Error: The list of Users provided is blank.'; return AssignCreditResult; }
        
        if(Users.size() < 1) {
            AssignCreditResult.message = 'Error: The list of Users provided is empty.'; return AssignCreditResult; }
        
        if(SeasonalRateId == null) {
            AssignCreditResult.message = 'Error: The Seasonal Rate selected is not valid.'; return AssignCreditResult; }
        
        if(Year == null) {
            AssignCreditResult.message = 'Error: The Year selected is not valid.'; return AssignCreditResult; }
        
        Map<Id,UserWithCredit> UsersByEmployeeInformation = new Map<Id,UserWithCredit>();
        List<President_s_Club_Performance__c> PerformancesToUpdate = new List<President_s_Club_Performance__c>();
        List<Employee_Club_Information__c> ClubInformationsToUpdate = new List<Employee_Club_Information__c>();
        Seasonal_Rate__c Rate = null;
        
        List<Seasonal_Rate__c> Rates = [Select Id, Name, 
            January__c, February__c, March__c, April__c, May__c, June__c, 
            July__c, August__c, September__c, October__c, November__c, December__c 
            From Seasonal_Rate__c Where Id = :SeasonalRateId];
        
        Rate = (Rates != null) ? ((Rates.size() > 0) ? Rates[0] : null) : null;
        
        if(Rate == null) { 
            AssignCreditResult.message = 'Error: The Seasonal Rate selected is not valid.'; return AssignCreditResult; }
        
        for(UserWithCredit u : Users) {
            UsersByEmployeeInformation.put(u.EmployeeInformationId,u); }
        
        List<President_s_Club_Performance__c> Performances = [Select Id, Name, 
            Month__c, MonthNumber__c, Fiscal_Year__c, Employee_Name__c, 
            Planned_NNC__c, Planned_RC__c, Planned_QC_Month__c, Forecasting_Channel__c 
            From President_s_Club_Performance__c 
            Where Employee_Name__c IN :UsersByEmployeeInformation.keyset()
            And Fiscal_Year__c = :Year];
        
        for(President_s_Club_Performance__c p : Performances) 
        {
            // get the User and initialize Performances variable (if not yet initialized)
            UserWithCredit u = UsersByEmployeeInformation.get(p.Employee_Name__c);
            if(u.Performances == null){ u.Performances = new List<President_s_Club_Performance__c>(); }
            
            // only Performances matching User forecasting channel should be updated
            if(p.Forecasting_Channel__c == u.ForecastingChannel) { u.Performances.add(p); } 
        }
        
        List<Employee_Club_Information__c> ClubInformation = [Select Id, Name, Employee_Name__c, 
            Assigned_Plan_QC__c, Board_of_Directors__c, Eagle_Award__c, Fiscal_Year__c, Hall_of_Fame__c, 
            Pace_Setters__c, Pewter_Award__c, Pewter_Award_Reason__c, Qualified_for_Club__c, 
            SPX_ClubInfo_CreateDate__c, SPX_ClubInfo_ID__c 
            From Employee_Club_Information__c 
            Where Employee_Name__c IN :UsersByEmployeeInformation.keyset()
            And Fiscal_Year__c = :Year];
        
        for(Employee_Club_Information__c ci : ClubInformation)
        {
            UserWithCredit u = UsersByEmployeeInformation.get(ci.Employee_Name__c);
            if(u.ClubInformations == null){ u.ClubInformations = new List<Employee_Club_Information__c>(); }
            u.ClubInformations.add(ci);
        }
        
        for(UserWithCredit u : UsersByEmployeeInformation.values())
        {
            system.debug(u);
            
            Set<String> uPerformanceMonths = new Set<String>();
            
            if(u.Performances != null) { 
            	for(President_s_Club_Performance__c p : u.Performances) { uPerformanceMonths.add(p.Month__c); } }
            
            Integer uPerformancesSize = (u.Performances==null?0:u.Performances.size());
            
            if(uPerformancesSize < 12)
            {
                List<President_s_Club_Performance__c> NewPerformances = new List<President_s_Club_Performance__c>();
                
                if(!uPerformanceMonths.contains('July')) { 
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=1,Month__c='July')); }
                if(!uPerformanceMonths.contains('August')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=2,Month__c='August')); }
                if(!uPerformanceMonths.contains('September')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=3,Month__c='September')); }
                if(!uPerformanceMonths.contains('October')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=4,Month__c='October')); }
                if(!uPerformanceMonths.contains('November')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=5,Month__c='November')); }
                if(!uPerformanceMonths.contains('December')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=6,Month__c='December')); }
                if(!uPerformanceMonths.contains('January')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=7,Month__c='January')); }
                if(!uPerformanceMonths.contains('February')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=8,Month__c='February')); }
                if(!uPerformanceMonths.contains('March')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=9,Month__c='March')); }
                if(!uPerformanceMonths.contains('April')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=10,Month__c='April')); }
                if(!uPerformanceMonths.contains('May')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=11,Month__c='May')); }
                if(!uPerformanceMonths.contains('June')) {
                	NewPerformances.add(new President_s_Club_Performance__c(MonthNumber__c=12,Month__c='June')); }
                
                for(President_s_Club_Performance__c p : NewPerformances) 
                { 
                    p.Employee_Name__c = u.EmployeeInformationId;
                    p.Forecasting_Channel__c = u.ForecastingChannel;
                    p.Fiscal_Year__c = Year;
                }
                
                u.Performances = NewPerformances;
            }
            
            if(u.Performances.size() > 0)
            {
            	Decimal TotalRemainders = 0; // total remainders
            	
                for(President_s_Club_Performance__c p : u.Performances) 
                {
                    Double OldCredit = (Double)p.get(CreditTypeField);
                    
                    system.debug('Total Credit (before): '+u.getByName(CreditType));
                    
                    // get rid of all non digits (dollar sign, commas, etc) and convert to double
                    // for every non digit matched, in the TotalQC field, replace with blank 
                    u.setByName(CreditType,Pattern.compile('\\D+\\.+').matcher(u.getByName(CreditType)).replaceAll('')); 
                    
                    system.debug('Total Credit (after): '+u.getByName(CreditType));
                    
                    Double TotalCredit = null;
                    try {
                        TotalCredit = Double.valueOf(u.getByName(CreditType)); // convert to double
                    }
                    catch(Exception ex) {}
                    
                    if(TotalCredit != null)
                    {
                    	Decimal MonthValue = 0, MonthRemainder = 0;
                    	
                    	// if the month is between 1 and 12 inclusive
                    	if(p.MonthNumber__c >= 1 && p.MonthNumber__c <= 12)
                    	{
	                        system.debug('Total Credit: '+TotalCredit);
	                        system.debug('Month Number: '+p.MonthNumber__c);
	                        
	                        if(Rate.Name.toLowerCase() == 'even distribution')
	                        {
	                        	MonthValue = TotalCredit/12;
	                        	p.put(CreditTypeField,MonthValue);
	                        }
	                        else
	                        {
		                        if(p.MonthNumber__c == 1) { MonthValue = (Rate.July__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 2) { MonthValue = (Rate.August__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 3) { MonthValue = (Rate.September__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 4) { MonthValue = (Rate.October__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 5) { MonthValue = (Rate.November__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 6) { MonthValue = (Rate.December__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 7) { MonthValue = (Rate.January__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 8) { MonthValue = (Rate.February__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 9) { MonthValue = (Rate.March__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 10) { MonthValue = (Rate.April__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 11) { MonthValue = (Rate.May__c/100) * TotalCredit; }
		                        if(p.MonthNumber__c == 12) { MonthValue = (Rate.June__c/100) * TotalCredit; }
	                        }
	                        
	                        // add the numbers after the decimal to the TotalRemainders
	                        MonthRemainder = (MonthValue - math.floor(MonthValue)); 
	                        TotalRemainders += MonthRemainder; 
	                        system.debug('-----------------------------'+TotalRemainders+','+MonthRemainder);
	                        
	                        if(p.MonthNumber__c == 12) { // if last month, add remainders to month value
	                        	p.put(CreditTypeField,Math.round(Double.valueOf(MonthValue+TotalRemainders))); }
                        	else { // otherwise, put only the month value without month remainder
                        		p.put(CreditTypeField,Double.valueOf(MonthValue-MonthRemainder)); }
                    	}
                        
                        if(p.get(CreditTypeField) != oldCredit) { PerformancesToUpdate.add(p); u.Updated = true; }
                    }
                } // end for Presidents Club Record
            }
            
            if(AssignType == 'QC')
            {
                Integer ClubInformationsSize = (u.ClubInformations==null?0:u.ClubInformations.size());
                if(ClubInformationsSize < 1)
                {
                    List<Employee_Club_Information__c> NewClubInformations = new List<Employee_Club_Information__c>();
                    
                    u.setByName('PCNumber',Pattern.compile('\\D+\\.+').matcher(u.getByName('PCNumber')).replaceAll('')); 
                    
                    Double PCNumber = null;
                    Id EmployeeInformationId = null;
                    
                    try {
                        PCNumber = Double.valueOf(u.getByName('PCNumber'));
                        system.debug('PC Number: '+PCNumber);
                        EmployeeInformationId = Id.valueOf(u.EmployeeInformationId);
                    }
                    catch(Exception ex) {}
                    
                    if(PCNumber != null && EmployeeInformationId != null)
                    {
                        NewClubInformations.add(new Employee_Club_Information__c(
                            Fiscal_Year__c = Year,
                            Assigned_Plan_QC__c = PCNumber,
                            Employee_Name__c = EmployeeInformationId));
                    }
                    
                    u.ClubInformations = NewClubInformations;
                }
                
                if(u.ClubInformations.size() > 0)
                {
                    for(Employee_Club_Information__c ci : u.ClubInformations)
                    {
                        // get rid of all non digits (dollar sign, commas, etc) and convert to double
                        // for every non digit matched, in the TotalQC field, replace with blank 
                        u.setByName('PCNumber',Pattern.compile('\\D+\\.+').matcher(u.getByName('PCNumber')).replaceAll('')); 
                        
                        Double PCNumber = null;
                        try { PCNumber = Double.valueOf(u.getByName('PCNumber')); } catch(Exception ex) {}
                        
                        if(PCNumber != null) 
                        {
                            ci.Assigned_Plan_QC__c = PCNumber;
                            ClubInformationsToUpdate.add(ci); 
                        }
                    }
                }
            } // end if AssignType is QC
            
        } // end for User
        
        try
        {
            if(!PerformancesToUpdate.IsEmpty()){ upsert PerformancesToUpdate; }
            if(!ClubInformationsToUpdate.IsEmpty()){ upsert ClubInformationsToUpdate; }
        } 
        catch (Exception ex) 
        { 
            AssignCreditResult.Message = 'Error: An unexpected error occurred when updating '
                + 'President\'s Club Performances or Employee Club Informations. Error Message: '+ex.getMessage(); 
            return AssignCreditResult; 
        }
        
        AssignCreditResult.Users = UsersByEmployeeInformation.values();
        AssignCreditResult.Success = true;
        AssignCreditResult.Message = 'Success!';
        
        return AssignCreditResult;
    }
}