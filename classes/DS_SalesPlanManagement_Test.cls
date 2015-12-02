public class DS_SalesPlanManagement_Test
{
    public static testmethod void TestSeasonalRates()
    {
        Seasonal_Rate__c sr1 = new Seasonal_Rate__c();
        sr1.Name = 'Test - Five Ten Ten';
        sr1.January__c = 5;
        sr1.February__c = 10;
        sr1.March__c = 10;
        sr1.April__c = 5;
        sr1.May__c = 10;
        sr1.June__c = 10;
        sr1.July__c = 5;
        sr1.August__c = 10;
        sr1.September__c = 10;
        sr1.October__c = 5;
        sr1.November__c = 10;
        sr1.December__c = 10;
        
        DS_SalesPlanManagement.Result r1 = DS_SalesPlanManagement.SaveSeasonalRate(sr1);
        
        Seasonal_Rate__c sr2 = new Seasonal_Rate__c();
        sr2.Name = 'This name is too long and will cause the upsert to fail, '
            + 'which will then cause the try/catch block to fail and test the catch code.';
        sr2.January__c = 5;
        sr2.February__c = 10;
        sr2.March__c = 10;
        sr2.April__c = 5;
        sr2.May__c = 10;
        sr2.June__c = 10;
        sr2.July__c = 5;
        sr2.August__c = 10;
        sr2.September__c = 10;
        sr2.October__c = 5;
        sr2.November__c = 10;
        sr2.December__c = 10;
        
        DS_SalesPlanManagement.Result r2 = DS_SalesPlanManagement.SaveSeasonalRate(sr2);
        
        List<Seasonal_Rate__c> srs = DS_SalesPlanManagement.GetAllSeasonalRates();
    }
    
    public static testmethod void TestUserPerformances()
    {
        List<String> ForecastingChannels = DS_SalesPlanManagement.GetAllUserForecastingChannels();
        List<String> Titles = DS_SalesPlanManagement.GetAllUserTitles();
        
        User TestUser = DS_TestObjects.NewUser();
        TestUser.Forecasting_Channel__c = (ForecastingChannels!=null?(ForecastingChannels.size()>0?ForecastingChannels[0]:null):null);
        insert TestUser;
        
        List<String> UserIds = new List<String>();
        UserIds.add(TestUser.Id);
        
        // test user methods
        DS_SalesPlanManagement.GetAllForecastingUsers();
        DS_SalesPlanManagement.GetAllActiveForecastingUsers();
        DS_SalesPlanManagement.GetAllInactiveForecastingUsers();
        DS_SalesPlanManagement.GetAllUserManagers();
        
        // successful update
        List<President_s_Club_Performance__c> Performances1 = DS_SalesPlanManagement.GetPCPerformance(UserIds);
        DS_SalesPlanManagement.Result r1 = DS_SalesPlanManagement.SetPCPerformance(Performances1);
        
        // this second update will fail because there is no ID set for the Performance record
        List<President_s_Club_Performance__c> Performances2 = new List<President_s_Club_Performance__c>();
        Performances2.add(new President_s_Club_Performance__c(Forecasting_Channel__c='My fake forecasting channel'));
        DS_SalesPlanManagement.Result r2 = DS_SalesPlanManagement.SetPCPerformance(Performances2);
    }
    
    public static testmethod void TestAssignQC()
    {
        List<String> ForecastingChannels = DS_SalesPlanManagement.GetAllUserForecastingChannels();
        
        User TestUser = DS_TestObjects.NewUser();
        TestUser.Forecasting_Channel__c = (ForecastingChannels!=null?(ForecastingChannels.size()>0?ForecastingChannels[0]:null):null);
        insert TestUser;
        
        Employee_Information__c UserEmployeeInformation = new Employee_Information__c(User__c=TestUser.Id,Name='Test Employee Information');
        insert UserEmployeeInformation;
        
        DS_SalesPlanManagement.UserWithCredit uwqc = new DS_SalesPlanManagement.UserWithCredit();
        uwqc.EmployeeInformationId = UserEmployeeInformation.Id;
        uwqc.ClubInformations = new List<Employee_Club_Information__c>();
        uwqc.Performances = new List<President_s_Club_Performance__c>();
        uwqc.UserId = TestUser.Id;
        uwqc.ForecastingChannel = TestUser.Forecasting_Channel__c;
        uwqc.TotalQC = '100000';
        uwqc.PCNumber = '105000';
        uwqc.Updated = false;
        uwqc.Message = 'Error';
        
        List<DS_SalesPlanManagement.UserWithCredit> uwqcs = new List<DS_SalesPlanManagement.UserWithCredit>();
        uwqcs.add(uwqc);
        
        Seasonal_Rate__c sr1 = new Seasonal_Rate__c();
        sr1.Name = 'Test - Five Ten Ten';
        sr1.January__c = 5;
        sr1.February__c = 10;
        sr1.March__c = 10;
        sr1.April__c = 5;
        sr1.May__c = 10;
        sr1.June__c = 10;
        sr1.July__c = 5;
        sr1.August__c = 10;
        sr1.September__c = 10;
        sr1.October__c = 5;
        sr1.November__c = 10;
        sr1.December__c = 10;
        DS_SalesPlanManagement.Result r1 = DS_SalesPlanManagement.SaveSeasonalRate(sr1);
        
        List<Seasonal_Rate__c> srs = DS_SalesPlanManagement.GetAllSeasonalRates();
        Seasonal_Rate__c sr2 = (srs!=null?(srs.size()>0?srs[0]:null):null);
        
        List<String> years = DS_SalesPlanManagement.getYears();
        String year = (years!=null?(years.size()>0?years[0]:null):null);
        
        // failure cases
        DS_SalesPlanManagement.Result r2 = DS_SalesPlanManagement.Assign('QC',null,sr2.Id,year);
        DS_SalesPlanManagement.Result r3 = DS_SalesPlanManagement.Assign('QC',new List<DS_SalesPlanManagement.UserWithCredit>(),sr2.Id,year);
        DS_SalesPlanManagement.Result r4 = DS_SalesPlanManagement.Assign('QC',uwqcs,null,year);
        DS_SalesPlanManagement.Result r5 = DS_SalesPlanManagement.Assign('QC',uwqcs,sr2.Id,null);
        DS_SalesPlanManagement.Result r6 = DS_SalesPlanManagement.Assign('QC',uwqcs,'123000000abc456',year);
        
        // success case
        DS_SalesPlanManagement.Result r7 = DS_SalesPlanManagement.Assign('QC',uwqcs,sr2.Id,year);
        
        // 1 more error cases
        DS_SalesPlanManagement.Result r8 = DS_SalesPlanManagement.Assign('QC',uwqcs,sr2.Id,year); // duplicate id error
        
        // 1 more success case
        uwqcs[0].ClubInformations = null;
        uwqcs[0].Performances = null;
        DS_SalesPlanManagement.Result r9 = DS_SalesPlanManagement.Assign('QC',uwqcs,sr2.Id,year); // updating pre-existing values from successful insert
    }
}