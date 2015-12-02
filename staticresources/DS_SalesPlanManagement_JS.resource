/* Project:     Sales Plan Management
 * Description: Facilitiates the management of Sales Plans which involves managing Seasonal Rates, 
 *                which are then used to assign QC (Quota Credit) to (Forecasting) Sales Users.
 * Programmer:  Matt Keefe (matt.keefe@adp.com, 847.845.4849)
 */

// -- Variables --

var j$ = jQuery.noConflict();

var SeasonalRates = []; // new Array();
var AllForecastingUsers = {}; // new Object();
var SelectedUsers = {}; // new Object();

var dialog;

// -- Initialization --

j$(document).ready(function(){init();});

function init()
{
	// set up tabs (then display)
	j$("#UserSelectionOptions").tabs({
		create: function(event,ui){
			j$(this).css("display","");
		}
	});
	
	// set up the page dialog
	dialog = j$("<div>").dialog({
		modal:true,
		height:"auto",
		autoOpen:false,
		show:"fade", hide:"fade",
		close:function(){dialog.removeClass("DialogMessage");}
	});
	
	// populate data
	GetAllForecastingUsers(); // put together an Array of all Users
	GetAllSeasonalRates(); // retrieve all Seasonal Rates
	
	// set years
	var years = getYearOptions();
	for(var i=0; i<years.length; i++) { j$("#SelectYear").append(years[i]); }
	
	var today = new Date();
	j$("#SelectYear").val(today.getFullYear());
	
	// bind buttons
	j$("#ViewSeasonalRate").bind("click",function(){CreateSeasonalRateTable(SeasonalRates[j$("#SeasonalRate").val()]);});
	j$("#DefaultQC").bind("keyup",function(){
		if (!isNaN(this.value)) { var dpc = Math.round(105 * this.value) / 100; j$("#DefaultPCNumber").val(dpc); } });
	
	j$("#ApplyDefaultNNC").bind("click",function(){
		var dqc = j$("#DefaultNNC").val();
		for(var i=0;i<AllForecastingUsers.users.length;i++) {
			if(AllForecastingUsers.users[i].selected && AllForecastingUsers.users[i].selected == true) {
				AllForecastingUsers.users[i].TotalNNC = dqc;
			}
		}
		j$("#SelectedUsersTable [id$='nnc']").val(dqc);
	});
	
	j$("#ApplyDefaultRC").bind("click",function(){
		var dqc = j$("#DefaultRC").val();
		for(var i=0;i<AllForecastingUsers.users.length;i++) {
			if(AllForecastingUsers.users[i].selected && AllForecastingUsers.users[i].selected == true) {
				AllForecastingUsers.users[i].TotalRC = dqc;
			}
		}
		j$("#SelectedUsersTable [id$='rc']").val(dqc);
	});
	
	j$("#ApplyDefaultQC").bind("click",function(){
		var dqc = j$("#DefaultQC").val();
		for(var i=0;i<AllForecastingUsers.users.length;i++) {
			if(AllForecastingUsers.users[i].selected && AllForecastingUsers.users[i].selected == true) {
				AllForecastingUsers.users[i].TotalQC = dqc;
			}
		}
		j$("#SelectedUsersTable [id$='qc']").val(dqc);
	});
	
	j$("#ApplyDefaultPCNumber").bind("click",function(){
		var dpc = j$("#DefaultPCNumber").val();
		for(var i=0;i<AllForecastingUsers.users.length;i++) {
			if(AllForecastingUsers.users[i].selected && AllForecastingUsers.users[i].selected == true) {
				AllForecastingUsers.users[i].PCNumber = dpc;
			}
		}
		j$("#SelectedUsersTable [id$='pc']").val(dpc);
	});
	
	j$("#AddSeasonalRate").bind("click",function(){CreateSeasonalRateTable(new Seasonal_Rate__c());});
	
	j$("#AddUsersByTitle").bind("click",function(){AddUsers("Title",j$("#UserTitles").val(),true);});
	j$("#AddUsersByForecastingChannel").bind("click",function(){AddUsers("Forecasting_Channel__c",j$("#UserForecastingChannels").val(),true);});
	j$("#AddUsersByManagerId").bind("click",function(){AddUsers("ManagerId",j$("#UserManagerNames").val(),true);});
	j$("#AddActiveUserById").bind("click",function(){AddUsers("Id",j$("#ActiveUserNames").val(),true);});
	j$("#AddInactiveUserById").bind("click",function(){AddUsers("Id",j$("#InactiveUserNames").val());});
	
	j$("#AssignNNC").bind("click",function(event){event.preventDefault();AssignNNC();})
		.button();
	
	j$("#AssignRC").bind("click",function(event){event.preventDefault();AssignRC();})
		.button();
	
	j$("#AssignQC").bind("click",function(event){event.preventDefault();AssignQC();})
		.button();
	
	j$("#AssignButtons").css("display","");
	
	j$(".TableIcon").live("mouseenter", function(){j$(this).addClass("ui-state-hover");});
	j$(".TableIcon").live("mouseleave", function(){j$(this).removeClass("ui-state-hover");});
}

// -- Objects --

function Seasonal_Rate__c()
{
	this.Name = null;
	this.January__c = null;
	this.February__c = null;
	this.March__c = null;
	this.April__c = null;
	this.May__c = null;
	this.June__c = null;
	this.July__c = null;
	this.August__c = null;
	this.September__c = null;
	this.October__c = null;
	this.November__c = null;
	this.December__c = null;
}

function Users(AllUsers)
{
	for(var i=0; i<AllUsers.length; i++) { AllUsers[i].selected = false; AllUsers[i].index = null; }
	
	// save the input to the Users object
	this.users = AllUsers;
	
	// create a method for finding users
	//  - key: the property to search
	//  - value: the value to find within the key (property)
	this.find = function(key,value,active){
		return j$.grep(this.users,function(obj){
			return obj[key] == value 
				// and if active parameter is supplied, and active is true, return all active
				// otherwise (no active parameter, or active not true), return all regardless
				&& ((active && active == true) ? obj["IsActive"] == true : true); 
		});
	}
	
	// create a new object maps
	//this.idMap = {}; 
	//this.titleMap = {};
	//this.forecastingChannelMap = {};
	
	// set object maps
	//for(var i=0; i<AllUsers.length; i++) 
	//{
		// if this.idMap[user.Id] is null or 0, assign an empty array
		// null or 0 casts to false, and the true value is assigned.
		//this.idMap[AllUsers[i].Id] = this.idMap[AllUsers[i].Id] || []; 
		//this.idMap[AllUsers[i].Id].push(AllUsers[i]);
		//this.titleMap[AllUsers[i].Title] = this.titleMap[AllUsers[i].Title] || [];
		//this.titleMap[AllUsers[i].Title].push(AllUsers[i]);
		//this.forecastingChannelMap[AllUsers[i].Forecasting_Channel__c] = this.forecastingChannelMap[AllUsers[i].Forecasting_Channel__c] || [];
		//this.forecastingChannelMap[AllUsers[i].Forecasting_Channel__c].push(AllUsers[i]);
	//}
}

// -- Functions --

function GetAllForecastingUsers()
{
	AllForecastingUsers = {}; // set to a new object
	
	var results = [];
	
	DS_SalesPlanManagement.GetAllForecastingUsers(function(r1,event) {
		if(r1) {
			j$(r1).each(function(i,r){results.push(r);});
			
			j$("#SelectedUsersTable thead").append(
				j$("<tr>").removeClass("pBody").addClass("ui-state-default a").append(""
					,j$("<td>").css("width","20px").html(
						j$("<div>").addClass("ui-state-default ui-corner-all TableIcon")
							.html(j$("<span>").addClass("ui-icon ui-icon-circle-close"))
							.bind("click",function(){
								j$("#SelectedUsersTable tbody tr").remove();
								for(var i=0; i<AllForecastingUsers.users.length; i++) {  
									AllForecastingUsers.users[i].selected = false;
									AllForecastingUsers.users[i].index = null;
									AllForecastingUsers.users[i].TotalQC = null;
									AllForecastingUsers.users[i].PCNumber = null;
								}
							})
					)
					,j$("<td>").css("width","20px").append(
						j$("<div>").addClass("ui-state-default ui-corner-all TableIcon")
							.append(j$("<span>").addClass("ui-icon ui-icon-newwin"))
							.bind("click",function(event) { ViewAllUserDetails(event); })
					)
					,j$("<td>").html("Name")
					,j$("<td>").html("Title")
					,j$("<td>").html("Forecasting Channel")
					,j$("<td>").html("Manager Name")
					,j$("<td>").addClass("InputHeader").html("Total NNC")
					,j$("<td>").addClass("InputHeader").html("Total RC")
					,j$("<td>").addClass("InputHeader").html("Total QC")
					,j$("<td>").addClass("InputHeader").html("PC Number")
				)
			);
			
			AllForecastingUsers = new Users(results);
		}
	});
}

function AddUsers(type, mapkey, active)
{
	AddDataToSelectedUserTable(
		AllForecastingUsers.find(type,mapkey,active)
	); 
}

function AddDataToSelectedUserTable(data)
{
	if(!data) { return; }
	
	var TableBody = j$("#SelectedUsersTable tbody");
	var DefaultQC = j$("#DefaultQC").val();
	var DefaultPCNumber = j$("#DefaultPCNumber").val();
	
	for(var i=0; i<data.length; i++)
	{
		var default_qc = j$("#DefaultQC").val();
		var default_pc = j$("#DefaultPCNumber").val();
		
		if (data[i] && !data[i].selected) {
			TableBody.append(""
				,j$("<tr>").append(""
					,j$("<td>").html(
						j$("<div>").addClass("ui-state-default ui-corner-all TableIcon")
							.html(j$("<span>").addClass("ui-icon ui-icon-circle-close"))
							.bind("click",{userid:data[i].Id},function(event){
								j$(this).parent().parent().remove();
								var UserToRemove = AllForecastingUsers.find("Id",event.data.userid)[0];
								UserToRemove.selected = false; UserToRemove.index = null; UserToRemove.TotalQC = null; UserToRemove.PCNumber = null;
								j$("#SelectedUsersTable tbody tr").each(function(i,item){
									j$(item).removeClass("even odd").addClass(i%2==0?"even":"odd");
								});
							})
					)
					,j$("<td>").html(
						j$("<div>").addClass("ui-state-default ui-corner-all TableIcon")
							.html(j$("<span>").addClass("ui-icon ui-icon-newwin"))
							.bind("click", {userid:data[i].Id}, function(event){ ViewUserDetail(event); })
					)
					,j$("<td>").html(
						(data[i].Employee_Information__r)?
							(j$("<a>")
								.attr("href","/"+data[i].Employee_Information__r[0].Id)
								.attr("target","_blank")
								.focus(function(){ j$(this).parent().parent().children().addClass("RowHighlight"); })
								.blur(function(){ j$(this).parent().parent().children().removeClass("RowHighlight"); })
								.html(data[i].LastName + ', ' + data[i].FirstName)):
							(data[i].LastName + ', ' + data[i].FirstName))
					,j$("<td>").html(data[i].Title)
					,j$("<td>").html(data[i].Forecasting_Channel__c)
					,j$("<td>").html(data[i].Manager.LastName+", "+data[i].Manager.FirstName)
					,j$("<td>").html(j$("<input>")
						.attr("id",data[i].Id+"_nnc")
						.focus(function(){ j$(this).parent().parent().children().addClass("RowHighlight"); })
						.blur(function(){ j$(this).parent().parent().children().removeClass("RowHighlight"); })
						//.val(data[i].TotalNNC?data[i].TotalNNC:default_nnc) // uncomment to remember prev entered values
						.bind("keyup",{userid:data[i].Id},function(event){
							AllForecastingUsers.find("Id",event.data.userid)[0].TotalNNC = this.value; 
						})
					)
					,j$("<td>").html(j$("<input>")
						.attr("id",data[i].Id+"_rc")
						.focus(function(){ j$(this).parent().parent().children().addClass("RowHighlight"); })
						.blur(function(){ j$(this).parent().parent().children().removeClass("RowHighlight"); })
						//.val(data[i].TotalRC?data[i].TotalRC:default_rc) // uncomment to remember prev entered values
						.bind("keyup",{userid:data[i].Id},function(event){
							AllForecastingUsers.find("Id",event.data.userid)[0].TotalRC = this.value; 
						})
					)
					,j$("<td>").html(j$("<input>")
						.attr("id",data[i].Id+"_qc")
						.focus(function(){ j$(this).parent().parent().children().addClass("RowHighlight"); })
						.blur(function(){ j$(this).parent().parent().children().removeClass("RowHighlight"); })
						//.val(data[i].TotalQC?data[i].TotalQC:default_qc) // uncomment to remember prev entered values
						.bind("keyup",{userid:data[i].Id},function(event){
							AllForecastingUsers.find("Id",event.data.userid)[0].TotalQC = this.value; 
							var tqc = j$(this).val().replace(/[^0-9\.]*/g,"");
							if (!isNaN(tqc)) {
								var DefaultPCNumber = Math.round(105 * tqc)/100;
								j$("#" + event.data.userid + "_pc").val(DefaultPCNumber+''); 
								AllForecastingUsers.find("Id",event.data.userid)[0].PCNumber = DefaultPCNumber; 
							}
						})
					)
					,j$("<td>").html(j$("<input>")
						.attr("id",data[i].Id+"_pc")
						.focus(function(){ j$(this).parent().parent().children().addClass("RowHighlight"); })
						.blur(function(){ j$(this).parent().parent().children().removeClass("RowHighlight"); })
						//.val(data[i].PCNumber?data[i].PCNumber:default_pc) // uncomment to remember prev entered values
						.bind("keyup",{userid:data[i].Id},function(event){
							AllForecastingUsers.find("Id",event.data.userid)[0].PCNumber = this.value; 
						})
					)
				)
				.mouseenter(function(){ j$(this).children().addClass("RowHighlight"); }) // #C5D4E2
				.mouseleave(function(){ j$(this).children().removeClass("RowHighlight"); })
			);
			
			// set default values
			data[i].TotalQC = (data[i].TotalQC?data[i].TotalQC:default_qc);
			data[i].PCNumber = (data[i].PCNumber?data[i].PCNumber:default_pc);
			data[i].selected = true;
			data[i].index = j$("#SelectedUsersTable tr").length-1; // number of rows minus one for header row
		}
	}

	j$("#SelectedUsersTable tbody tr").each(function(i,item){
		j$(item).removeClass("even odd").addClass(i%2==0?"even":"odd");
	});
}

function ViewAllUserDetails(e0) // e0 is event zero
{
	var pcps = [];
	
	var SelectMonth = j$("<select>").attr("id","ViewAllSelectMonth")
		.append(j$("<option>").val("July").html("July"))
		.append(j$("<option>").val("August").html("August"))
		.append(j$("<option>").val("September").html("September"))
		.append(j$("<option>").val("October").html("October"))
		.append(j$("<option>").val("November").html("November"))
		.append(j$("<option>").val("December").html("December"))
		.append(j$("<option>").val("January").html("January"))
		.append(j$("<option>").val("February").html("February"))
		.append(j$("<option>").val("March").html("March"))
		.append(j$("<option>").val("April").html("April"))
		.append(j$("<option>").val("May").html("May"))
		.append(j$("<option>").val("June").html("June"));
	
	var SelectYear = j$("<select>").attr("id","ViewAllSelectYear");
	var years = getYearOptions();
	for(var i=0; i<years.length; i++) { SelectYear.append(years[i]); }
	
	var today = new Date();
	SelectYear.val(today.getFullYear());
	
	var loading = j$("<div>")
		.css("text-align","center")
		.append("User details can only be viewed one month at a time; please select a month.").append("<br/><br/>")
		.append(SelectMonth)
		.append(SelectYear)
		.dialog({
			"modal": true,
			"show": "fade", "hide": "fade",
			"title": "Details for Selected Users",
			"buttons": {
				"View" : function(ViewEvent) {
					var ViewButton = j$(ViewEvent.currentTarget);
					
					ViewButton.attr("disabled","disabled").addClass("ui-state-disabled"); // Disable View button
					var ViewButtonText = j$(ViewButton.children()[0]).html("Loading..."); // Change to Loading...
					
					var actualsdialog = j$("<div>")
						.dialog({
							"modal": true,
							"width": 720,
							"autoOpen": false,
							"show": "fade", "hide": "fade",
							"title": "Actuals for Selected Users",
							"buttons": {
								"Save": function(SaveEvent) {
									var SaveButton = j$(SaveEvent.currentTarget);
									
									SaveButton.attr("disabled","disabled").addClass("ui-state-disabled"); // Disable Save
									var SaveButtonText = j$(SaveButton.children()[0]).html("Saving..."); // Change to Saving...
									
									function President_s_Club_Performance__c() {
										this.Id = null,
										this.Planned_NNC__c = null;
										this.Actual_NNC__c = null; 
										this.Planned_RC__c = null;
										this.Actual_RC__c = null; 
										this.Planned_QC_Month__c = null;
										this.Actual_QC_Month__c = null; 
									}
									
									var PCPerformanceToUpdate = [];
									
									j$.each(pcps, function(index,pcp) {
										var pnnc = pcp.PlannedNNCInput.val().replace(/[^0-9\.\-]*/g,"");
										var annc = pcp.ActualNNCInput.val().replace(/[^0-9\.\-]*/g,"");
										var prc = pcp.PlannedRCInput.val().replace(/[^0-9\.\-]*/g,"");
										var arc = pcp.ActualRCInput.val().replace(/[^0-9\.\-]*/g,"");
										var pqc = pcp.PlannedQCInput.val().replace(/[^0-9\.\-]*/g,"");
										var aqc = pcp.ActualQCInput.val().replace(/[^0-9\.\-]*/g,"");
										
										if (pcp.Fiscal_Year__c == SelectYear.val()
										&&  !isNaN(pnnc)
										&&  !isNaN(annc)
										&&  !isNaN(prc)
										&&  !isNaN(arc)
										&&  !isNaN(pqc)
										&&  !isNaN(aqc)) {
											var pc2update = new President_s_Club_Performance__c();
											pc2update.Id = pcp.Id;
											pc2update.Planned_NNC__c = pnnc;
											pc2update.Actual_NNC__c = annc;
											pc2update.Planned_RC__c = prc;
											pc2update.Actual_RC__c = arc;
											pc2update.Planned_QC_Month__c = pqc;
											pc2update.Actual_QC_Month__c = aqc;
											PCPerformanceToUpdate.push(pc2update);
										}
									});
									
									DS_SalesPlanManagement.SetPCPerformance(PCPerformanceToUpdate, 
										function(r2,e2) { // result 2, event 2; r2e2.. lol
											if(r2 && r2.Success) {
												SaveButtonText.html("Saved");
												setTimeout(function(){actualsdialog.dialog("destory").remove();}, 1000); // close the dialog after 2 seconds
											}
											else {
												actualsdialog.dialog("destory").remove();
												loading.html("An error occurred while Saving. Please try again.");
												loading.dialog("open");
											}
										});
								},
								"Close": function() { j$(this).dialog("destory").remove(); }
							}
						});
					
					var actualstablebody = j$("<tbody>");
					var actualstable = j$("<table>")
						.addClass("DialogTable")
						.append(
							j$("<thead>").append(
								j$("<tr>").append(
									j$("<td>").html("Name"),
									j$("<td>").html("Year"),
									j$("<td>").html("Month"),
									j$("<td>").html("Planned<br/>NNC"),
									j$("<td>").html("Planned<br/>RC"),
									j$("<td>").html("Planned<br/>QC"),
									j$("<td>").html("Actual<br/>NNC"),
									j$("<td>").html("Actual<br/>RC"),
									j$("<td>").html("Actual<br/>QC")
								)
							),
							actualstablebody
						);
					
					var UserIds = [];
					if (AllForecastingUsers.users.length && AllForecastingUsers.users.length > 0) {
						for (var i = 0; i < AllForecastingUsers.users.length; i++) { 
							if (AllForecastingUsers.users[i].selected) { 
								UserIds.push(AllForecastingUsers.users[i].Id);
							}
						}
					}
					
					DS_SalesPlanManagement.GetPCPerformance(UserIds,function(r1,e1){
						if(r1) {
							j$(r1).each(function(index,pcp){
								if(pcp.Fiscal_Year__c == SelectYear.val()
								&& pcp.Month__c == SelectMonth.val()) { 
									var b = j$.browser.mozilla?"keypress":"keydown"; // IE is stupid
									pcp.PlannedNNCInput = j$("<input>").val(pcp.Planned_NNC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,0);});
									pcp.PlannedRCInput = j$("<input>").val(pcp.Planned_RC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,1);});
									pcp.PlannedQCInput = j$("<input>").val(pcp.Planned_QC_Month__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,2);});
									pcp.ActualNNCInput = j$("<input>").val(pcp.Actual_NNC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,3);});
									pcp.ActualRCInput = j$("<input>").val(pcp.Actual_RC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,4);});
									pcp.ActualQCInput = j$("<input>").val(pcp.Actual_QC_Month__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,5);});
									pcps.push(pcp);
									actualstablebody.append(
										j$("<tr>").append(
											j$("<td>").html(pcp.Employee_Name__r.User__r.LastName + ", " + pcp.Employee_Name__r.User__r.FirstName),
											j$("<td>").html(pcp.Fiscal_Year__c),
											j$("<td>").html(pcp.Month__c),
											j$("<td>").append(pcp.PlannedNNCInput),
											j$("<td>").append(pcp.PlannedRCInput),
											j$("<td>").append(pcp.PlannedQCInput),
											j$("<td>").append(pcp.ActualNNCInput),
											j$("<td>").append(pcp.ActualRCInput),
											j$("<td>").append(pcp.ActualQCInput)
										) // end append tr
									); // end tb append
								}
							});
							
							actualstable.append(actualstablebody);
							actualsdialog.append(actualstable);
							loading.dialog("destory").remove();
							actualsdialog.dialog("open");
						}
						else {
							loading.html("An error occurred while retrieving data. Please try again.");
						}
					});
				}
			}
		});
}

function ViewUserDetail(e0) // e0 is event zero
{
	var CurrentUser, NextUser, PreviousUser;
	var SelectedUsers = AllForecastingUsers.find("selected",true).sort(function(a,b){return a.index - b.index}); 
	
	for(var i=0;i<SelectedUsers.length;i++) {
		if(SelectedUsers[i] && SelectedUsers[i].Id && SelectedUsers[i].Id == e0.data.userid) { 
			CurrentUser = SelectedUsers[i];
			if(SelectedUsers[i-1]) { PreviousUser = SelectedUsers[i-1]; }
			if(SelectedUsers[i+1]) { NextUser = SelectedUsers[i+1]; }
		}
	}
	
	var pcps = []; // new array
	
	var loading = j$("<div>")
		.html("<br/>"
			+ "<div style='text-align:center;width:100%;'>Loading...</div><br/>"
			+ "<div style='text-align:center;width:100%;'><img src='"+j$("#blue-bar-loading").attr("src")+"' /></div>")
		.dialog({
			"modal": true,
			"show": "fade", "hide": "fade",
			"title": CurrentUser.index + "/" + SelectedUsers.length + " - " + CurrentUser.LastName + ", " + CurrentUser.FirstName,
		});
	
	var UserIds = []; UserIds.push(e0.data.userid);
	DS_SalesPlanManagement.GetPCPerformance(UserIds,
		function(r1,e1) { // result 1, event 1
			if(r1 && r1.length > 0) {
				var pcdata = j$("<div>")
					.html("")
					.dialog({
						"modal": true,
						"width": 720,
						"autoOpen": false,
						"title": CurrentUser.index + "/" + SelectedUsers.length + " - " + CurrentUser.LastName + ", " + CurrentUser.FirstName,
						"show": "fade", "hide": "fade",
						"buttons": {
							"Previous": {
								text: "« Previous",
								disabled: !(PreviousUser && PreviousUser.Id != null),
								click: function(PreviousEvent) {
									if (PreviousUser != null && PreviousUser.Id != null) {
										var PreviousButton = j$(PreviousEvent.currentTarget);
										
										PreviousButton.attr("disabled", "disabled").addClass("ui-state-disabled"); // Disable Save
										var PCPerformancesToUpdate = GetPCPerformancesToUpdate(pcps);
										
										DS_SalesPlanManagement.SetPCPerformance(PCPerformancesToUpdate, function(r2, e2){ // r2e2.. lol
											if (r2 && r2.Success) {
												pcdata.dialog("destory").remove();
												var prev = {}; prev.data = {};
												prev.data.userid = PreviousUser.Id
												ViewUserDetail(prev);
											}
											else {
												pcdata.dialog("destory").remove();
												loading.html("An error occurred while Saving. Please try again.");
												loading.dialog("open");
											}
										});
									}
								}
							},
							"Next": {
								text: "» Next",
								disabled: !(NextUser && NextUser.Id != null),
								click: function(NextEvent) {
									if (NextUser != null && NextUser.Id != null) {
										var NextButton = j$(NextEvent.currentTarget);
										
										NextButton.attr("disabled", "disabled").addClass("ui-state-disabled"); // Disable Save
										var PCPerformancesToUpdate = GetPCPerformancesToUpdate(pcps);
										
										DS_SalesPlanManagement.SetPCPerformance(PCPerformancesToUpdate, function(r3, e3){ 
											if (r3 && r3.Success) {
												pcdata.dialog("destory").remove();
												var next = {}; next.data = {};
												next.data.userid = NextUser.Id
												ViewUserDetail(next);
											}
											else {
												pcdata.dialog("destory").remove();
												loading.html("An error occurred while Saving. Please try again.");
												loading.dialog("open");
											}
										});
									}
								}
							},
							"Save": {
								text: "Save & Close", 
								click: function(SaveEvent){
									var SaveButton = j$(SaveEvent.currentTarget);
									
									SaveButton.attr("disabled", "disabled").addClass("ui-state-disabled"); // Disable Save
									var SaveButtonText = j$(SaveButton.children()[0]).html("Saving..."); // Change to Saving...
									var PCPerformancesToUpdate = GetPCPerformancesToUpdate(pcps);
									
									DS_SalesPlanManagement.SetPCPerformance(PCPerformancesToUpdate, function(r4, e4){ 
										if (r4 && r4.Success) {
											SaveButtonText.html("Saved");
											setTimeout(function(){
												pcdata.dialog("destory").remove();
											}, 1000); // close the dialog after 2 seconds
										}
										else {
											pcdata.dialog("destory").remove();
											loading.html("An error occurred while Saving. Please try again.");
											loading.dialog("open");
										}
									});
								}
							},
							"Close": function(CloseEvent){ j$(this).dialog("destory").remove(); }
						}
					});
				
				pcdata.append(
					j$("<table>").addClass("DialogTable").append(
						j$("<thead>").append(
							j$("<tr>").append(
								j$("<td>").html("Year"),
								j$("<td>").html("Month"),
								j$("<td>").html("Planned<br/>NNC"),
								j$("<td>").html("Planned<br/>RC"),
								j$("<td>").html("Planned<br/>QC"),
								j$("<td>").html("Actual<br/>NNC"),
								j$("<td>").html("Actual<br/>RC"),
								j$("<td>").html("Actual<br/>QC")
							)
						),
						j$("<tbody>")
					)
				);
				
				var tb = j$("tbody",pcdata);
				
				j$(r1).each(function(index,pcp){
					if(pcp.Fiscal_Year__c == j$("#SelectYear").val()) {
						var b = j$.browser.mozilla?"keypress":"keydown"; // IE is stupid
						pcp.PlannedNNCInput = j$("<input>").val(pcp.Planned_NNC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,0);});
						pcp.PlannedRCInput = j$("<input>").val(pcp.Planned_RC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,1);});
						pcp.PlannedQCInput = j$("<input>").val(pcp.Planned_QC_Month__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,2);});
						pcp.ActualNNCInput = j$("<input>").val(pcp.Actual_NNC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,3);});
						pcp.ActualRCInput = j$("<input>").val(pcp.Actual_RC__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,4);});
						pcp.ActualQCInput = j$("<input>").val(pcp.Actual_QC_Month__c).bind(b,function(pcp_ev){TableInputNavigation(pcp_ev,5);});
						pcps.push(pcp);
						tb.append(
							j$("<tr>").append(
								j$("<td>").html(pcp.Fiscal_Year__c),
								j$("<td>").html(pcp.Month__c),
								j$("<td>").append(pcp.PlannedNNCInput),
								j$("<td>").append(pcp.PlannedRCInput),
								j$("<td>").append(pcp.PlannedQCInput),
								j$("<td>").append(pcp.ActualNNCInput),
								j$("<td>").append(pcp.ActualRCInput),
								j$("<td>").append(pcp.ActualQCInput)
							) // end append tr
						); // end tb append
					} // end if year
				}); // end each row
				loading.dialog("destroy").remove();
				pcdata.dialog("open"); // with all of the data added, open the dialog
			} // end if result
			else {
				loading.html("Details for the selected User are not available.");
				loading.dialog("option", "buttons", [
					{
						text: "« Previous",
						disabled: !(PreviousUser && PreviousUser.Id != null),
						click: function() {
							if (PreviousUser != null && PreviousUser.Id != null) {
								j$(this).dialog("destory").remove();
								var prev = {};
								prev.data = {};
								prev.data.userid = PreviousUser.Id
								ViewUserDetail(prev);
							}
						}
					},
					{
						text: "» Next",
						disabled: !(NextUser && NextUser.Id != null),
						click: function() {
							if (NextUser != null && NextUser.Id != null) {
								j$(this).dialog("destory").remove();
								var next = {};
								next.data = {};
								next.data.userid = NextUser.Id
								ViewUserDetail(next);
							}
						}
					}
				]);
			}
		}); // end JS Remoting callback
} // end function

function GetPCPerformancesToUpdate(pcps)
{
	function President_s_Club_Performance__c() {
		this.Id = null,
		this.Planned_NNC__c = null;
		this.Planned_RC__c = null;
		this.Planned_QC_Month__c = null;
		this.Actual_NNC__c = null; 
		this.Actual_RC__c = null; 
		this.Actual_QC_Month__c = null; 
	}
	
	var PCPerformancesToUpdate = [];
	
	j$.each(pcps, function(index,pcp) {
		var pnnc = pcp.PlannedNNCInput.val().replace(/[^0-9\.\-]*/g,"");
		var prc = pcp.PlannedRCInput.val().replace(/[^0-9\.\-]*/g,"");
		var pqc = pcp.PlannedQCInput.val().replace(/[^0-9\.\-]*/g,"");
		var annc = pcp.ActualNNCInput.val().replace(/[^0-9\.\-]*/g,"");
		var arc = pcp.ActualRCInput.val().replace(/[^0-9\.\-]*/g,"");
		var aqc = pcp.ActualQCInput.val().replace(/[^0-9\.\-]*/g,"");
		
		if (pcp.Fiscal_Year__c == j$("#SelectYear").val()
		&&  !isNaN(pnnc)
		&&  !isNaN(prc)
		&&  !isNaN(pqc)
		&&  !isNaN(annc)
		&&  !isNaN(arc)
		&&  !isNaN(aqc)) {
			var pc2update = new President_s_Club_Performance__c();
			pc2update.Id = pcp.Id;
			pc2update.Planned_NNC__c = pnnc;
			pc2update.Planned_RC__c = prc;
			pc2update.Planned_QC_Month__c = pqc;
			pc2update.Actual_NNC__c = annc;
			pc2update.Actual_RC__c = arc;
			pc2update.Actual_QC_Month__c = aqc;
			PCPerformancesToUpdate.push(pc2update);
		}
	});
	
	return PCPerformancesToUpdate;
}

function AssignNNC() { ValidateAndAssign("NNC"); }
function AssignRC() { ValidateAndAssign("RC"); }
function AssignQC() { ValidateAndAssign("QC"); }
function ValidateAndAssign(AssignType)
{
	AssignType = AssignType.toUpperCase();
	
	var DataToSend = []; // new array for the data to send
	var SelectedSeasonalRate = j$("#SeasonalRate").val();
	var SelectedYear = j$("#SelectYear").val();
	
	var pass = 0;
	var fail = 0;
	
	for(var i=0;i<AllForecastingUsers.users.length;i++)
	{
		if(AllForecastingUsers.users[i].selected && AllForecastingUsers.users[i].selected == true)
		{
			var PassConditions = false;
			
			// if there is an employee information record,
			// and there is a TotalNNC variable or the TotalNNC variable equals zero 
			// (checking the variable would return false if the value was zero, so an or statement is necessary) 
			if(AssignType == "NNC") {
				PassConditions = (AllForecastingUsers.users[i].Employee_Information__r
				&& (AllForecastingUsers.users[i].TotalNNC || AllForecastingUsers.users[i].TotalNNC == 0));
			}
			
			// if there is an employee information record,
			// and there is a TotalRC variable or the TotalRC variable equals zero
			if(AssignType == "RC") {
				PassConditions = (AllForecastingUsers.users[i].Employee_Information__r
				&& (AllForecastingUsers.users[i].TotalRC || AllForecastingUsers.users[i].TotalRC == 0));
			}
			
			// if there is an employee information record,
			// and there is a TotalQC variable or the TotalQC variable equals zero
			// and there is a PCNumber variable or the PCNumber variable equals zero
			if(AssignType == "QC") {
				PassConditions = (AllForecastingUsers.users[i].Employee_Information__r
				&& (AllForecastingUsers.users[i].TotalQC || AllForecastingUsers.users[i].TotalQC == 0)
				&& (AllForecastingUsers.users[i].PCNumber || AllForecastingUsers.users[i].PCNumber == 0));
			}
			
			if(PassConditions) {
				var user = {};
				user.UserId = AllForecastingUsers.users[i].Id;
				user.EmployeeInformationId = AllForecastingUsers.users[i].Employee_Information__r[0].Id;
				user.ForecastingChannel = AllForecastingUsers.users[i].Forecasting_Channel__c;
				if (AssignType == "NNC") { user.TotalNNC = AllForecastingUsers.users[i].TotalNNC + ''.replace(/\D+/g, ''); } // remove extra characters and assign
				if (AssignType == "RC") { user.TotalRC = AllForecastingUsers.users[i].TotalRC + ''.replace(/\D+/g, ''); } // remove extra characters and assign
				if (AssignType == "QC") { user.TotalQC = AllForecastingUsers.users[i].TotalQC + ''.replace(/\D+/g, ''); } // remove extra characters and assign
				if (AssignType == "QC") { user.PCNumber = AllForecastingUsers.users[i].PCNumber + ''.replace(/\D+/g, ''); } // remove extra characters and assign
				DataToSend.push(user); pass++;
			} else { fail++; }
		}
	}
	
	var failmessage = "<span class='emphasis'>"+fail+"</span> " 
		+ "user"+(fail>1?"s":"")+" did not have either an Employee Information record"
		+ (AssignType=="NNC"? " or Total NNC value; " : "")
		+ (AssignType=="RC"? " or Total RC value; " : "")
		+ (AssignType=="QC"? ", Total QC value, or PC Number value; " : "")
		+ "these will not be processed.<br/><br/>";
	
	var passmessage = "<span class='emphasis'>" + DataToSend.length + "</span>&nbsp;"
		+ "user"+(DataToSend.length>1?"s":"")+" will be assigned "+AssignType.toUpperCase()+" using the"
		+ "<br/><br/>"
		+ "<span class='emphasis'>\"" + j$("#SeasonalRate option:selected").text() + "\"</span><br/><br/>"
		+ "Seasonal Rate to calculate the correct amount for each month of the year using the Total "+AssignType.toUpperCase()+" number provided."
		+ "<br/><br/>"
		+ "<span class='emphasis'>Are you sure?</span>";
	
	var nonemessage = "There are no selected users. Please select users by Title, Forecasting Channel, or Lookup before assigning "+AssignType.toUpperCase()+".";
	
	j$("<div>")
		.html("<div class='DialogMessage'>"
			+ ((fail>0&&pass<1)?failmessage:"") // some fail, no pass
			+ ((fail>0&&pass>0)?failmessage+"<hr/>"+passmessage:"") // some fail, some pass
			+ ((fail<1&&pass>0)?passmessage:"") // no fail, some pass
			+ ((fail<1&&pass<1)?nonemessage:"") // no fail, no pass
			+ "</div>")
		.dialog({
			"modal": true,
			"show":"fade",
			"hide":"fade",
			"title": ((pass>0)?"Are you sure?":"Invalid Data"),
			"minWidth": 400,
			"buttons": (pass>0)?{
				"Confirm":function() {
					j$(this).dialog("destory").remove();
					var d = j$("<div>")
						.html("<br/>"
							+ "<div style='text-align:center;width:100%;'>Assigning "+(AssignType=="QC"?"QC and PC Number":AssignType)+"...</div><br/>"
							+ "<div style='text-align:center;width:100%;'><img src='"+j$("#blue-bar-loading").attr("src")+"' /></div>")
						.dialog({
							"modal":true,
							"show":"fade",
							"hide":"fade",
							"title":"Assign",
							"buttons": {
								"Close":function(){j$(this).dialog("destory").remove();}
							}
						});
					//log(AssignType); log(DataToSend); log(SelectedSeasonalRate); log(SelectedYear);
					DS_SalesPlanManagement.Assign(AssignType,DataToSend,SelectedSeasonalRate,SelectedYear,function(result,event){
						if (result) { 
							d.html("<br/><div style='text-align:center;width:100%;'>"+result.Message+"</div><br/>"); 
							setTimeout(function(){d.dialog("destory").remove();}, 2000); 
						} //log(result);
					});
				},
				"View Seasonal Rate":function(){
					j$(this).dialog("destory").remove();
					CreateSeasonalRateTable(SeasonalRates[j$("#SeasonalRate").val()]);
				},
				"Cancel":function(){
					j$(this).dialog("destory").remove();
				}
			}:{
				"Close":function(){j$(this).dialog("destory").remove();}
			}
		});
}

function GetAllSeasonalRates()
{
	var SeasonalRateSelect = j$("#SeasonalRate");
	
	DS_SalesPlanManagement.GetAllSeasonalRates(function(result,event)
	{
		//log(result); 
		if (result && result.length > 0) 
		{
			// save the selected value for sorting
			var val = SeasonalRateSelect.val();
			
			// delete all options
			SeasonalRateSelect.empty();
			
			// for each result, add the result to the rate array, and add a select option
			j$(result).each(function(index,item)
			{
				SeasonalRates[item.Id] = item;
				
				// no need to append the options, this is done through Visualforce for efficiency/performance
				var SelectOption = j$("<option></option>").attr("value", item.Id).text(item.Name); 
				SeasonalRateSelect.append(SelectOption);
			});
			
			// sort the options and select the value that was saved
			SeasonalRateSelect
				.html(j$("#SeasonalRate option").sort(function(a1,b1){
					var a = (''+a1).toLowerCase();
					var b = (''+b1).toLowerCase();
					return a.text == b.text ? 0 : a.text < b.text ? -1 : 1;}))
				.val(val);
		}
	});
}

function CreateSeasonalRateTable(sr)
{
	dialog.empty(); // clear any previous data

	dialog.dialog({
		title:"Modify Seasonal Rate", // set the selected Seasonal Rate name as the dialog name
		width:j$(window).width()/3, // set the width of the dialog to 1/3 the browser window size
		buttons:{
			"Save":function(){SaveSeasonalRate(sr);},
			"Cancel":function(){j$(this).dialog("close");}
		}
	});
	
	// add an input for the name
	dialog.append(
		j$("<div>").addClass("SeasonalRateName")
			.append(j$("<label>").html("Name").attr("for","SeasonalRateName"))
			.append(j$("<input>").attr("id","SeasonalRateName").val(sr.Name).bind("keyup",function(){
				sr.Name = this.value;
			}))
	);
	
	// add an informational message
	dialog.append(
		j$("<div>")
			.html("The total value (sum) of all percentages entered must be equal to 100%.")
			.css("padding","4px 0 10px 0")
			.css("text-align","center"));
	
	// create the table
	var srTable = j$("<table>").attr("id","SeasonalRateTable").addClass("DialogTable");
	
	// create the table header
	var srTableHead = j$("<thead>").append(
		j$("<tr>")
			.append(j$("<td>").html("Month"))
			.append(j$("<td>").html("Percentage"))
	);
	srTable.append(srTableHead);
	
	// create the table body
	var srTableBody = j$("<tbody>");
	srTableBody.append(""
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("July"),
			j$("<td>").append(
				j$("<input>").val(sr.July__c).bind("keyup",function(){
					CalculateRateTotal(); var num=parseFloat(this.value); sr.July__c = num != null && !isNaN(num) ? num : 0; })
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("August"),
			j$("<td>").append(
				j$("<input>").val(sr.August__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.August__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("September"),
			j$("<td>").append(
				j$("<input>").val(sr.September__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.September__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("October"),
			j$("<td>").append(
				j$("<input>").val(sr.October__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.October__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("November"),
			j$("<td>").append(
				j$("<input>").val(sr.November__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.November__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("December"),
			j$("<td>").append(
				j$("<input>").val(sr.December__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.December__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("January"),
			j$("<td>").append(
				j$("<input>").val(sr.January__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.January__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("February"),
			j$("<td>").append(
				j$("<input>").val(sr.February__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.February__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("March"),
			j$("<td>").append(
				j$("<input>").val(sr.March__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.March__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("April"),
			j$("<td>").append(
				j$("<input>").val(sr.April__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.April__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("odd").append(
			j$("<td>").html("May"),
			j$("<td>").append(
				j$("<input>").val(sr.May__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.May__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("even").append(
			j$("<td>").html("June"),
			j$("<td>").append(
				j$("<input>").val(sr.June__c).bind("keyup",function(){
					CalculateRateTotal();var num=parseFloat(this.value);sr.June__c=num!=null&&!isNaN(num)?num:0;})
			))
		,j$("<tr>").addClass("total").append(
			j$("<td>").html("Total"),
			j$("<td>").append(j$("<span>").attr("id","SeasonalRateTotalPercentage")))
	);
	srTable.append(srTableBody);
	
	// append the generated table
	dialog.append(srTable);
	
	// calculate the total of all percentage inputs
	CalculateRateTotal();
	
	// open the dialog
	dialog.dialog("open");
	
	if(sr.Name.toLowerCase() == "even distribution") 
	{
		j$('input',srTableBody).attr("disabled","disabled").css("cursor","default");
		j$(":button:contains('Save')",dialog.parent()).attr("disabled","disabled").addClass("ui-state-disabled"); 
	}
}

function SaveSeasonalRate(sr)
{
	j$("input",dialog.parent()).attr("disabled","disabled");
	
	j$(":button:contains('Cancel')",dialog.parent()).children(":first-child").html("Close"); 
	j$(":button:contains('Save')",dialog.parent()).attr("disabled","disabled").addClass("ui-state-disabled"); // disable buttons while saving
	j$(":button:contains('Save')",dialog.parent()).children(":first-child").html("Saving..."); // change the save button text to Saving...
	
	DS_SalesPlanManagement.SaveSeasonalRate(sr, function(result,event){
		if (result && result.Success) 
		{
			j$(":button:contains('Saving')",dialog.parent()).children(":first-child").html("Saved"); // change the Save button text to Saved
			setTimeout(function(){dialog.dialog("close");},2000); // close the dialog after 2 seconds
		}
		else
		{
			// add an error message
			dialog.append(
				j$("<div>")
					.html("An error occurred while saving. Error: "+result.Message)
					.css("padding","18px 0 4px 0")
					.css("text-align","center")
					.css("color","red"));
		}
	});
	
	GetAllSeasonalRates();
}

function CalculateRateTotal()
{
	var total = 0; 
	
	j$("#SeasonalRateTable input").each(function(index,input) { 
		var num = parseFloat(input.value);
		total += num!=null&&!isNaN(num) ? num : 0;
	});
	
	// total should be very precise per Lyle (numbers should add up to exactly 100)
	// because of issues when adding floating point decimal in javascript, the numbers are rounded to the nearest 6th decimal place
	total = Math.round(total*1000000)/1000000;
	
	var color = "black";
	if(total != 100) //if(total > 102 || total < 98)
	{
		color = "red";
		j$(":button:contains('Save')",dialog.parent()).attr("disabled","disabled").addClass("ui-state-disabled"); // disable save
	}
	else
	{
		color = "black";
		j$(":button:contains('Save')",dialog.parent()).removeAttr("disabled","disabled").removeClass("ui-state-disabled"); // enable save
	}
	
	j$("#SeasonalRateTotalPercentage").html(total+"%").css("color",color);
}

// -- Utility Functions --

// formatMoney from http://stackoverflow.com/a/149099/549141, Patrick Desjardins
function formatMoney(c, d, t) 
{
	var n = this, c = isNaN(c = Math.abs(c)) ? 2 : c, d = d == undefined ? "," : d, t = t == undefined ? "." : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
	return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
};

function getYearOptions()
{
	var years = [];
	var today = new Date();
	var year = (today.getMonth()+1 > 5) ? today.getFullYear()+1 : today.getFullYear();
	for(var i=0; (year-i)>(year-2); i++) { years.push(j$("<option>").val(year-i).html(year-i)); }
	return years;
};

function TableInputNavigation(current,index)
{
	var code = (current.keyCode ? current.keyCode : current.which); //alert(code); //log(code);
	var parentrow = j$(current.target).parent("td").parent("tr");
	
	// prevent default event action if specific keys
	if ((code >= 37 && code <= 40) || code == 13) { current.preventDefault(); }
	
	if (code == 40 || code == 13) { // down or enter
		var nextrowinputs = parentrow.next("tr").children("td").children("input");
		if (nextrowinputs.length > 0) {
			j$(nextrowinputs[index]).select().focus();
		}
	}
	if (code == 38) { // up
		var prevrowinputs = parentrow.prev("tr").children("td").children("input");
		if (prevrowinputs.length > 0) {
			j$(prevrowinputs[index]).select().focus();
		}
	}
	if (code == 37) { // left
		var parentrowinputs = parentrow.children("td").children("input");
		if (parentrowinputs.length > 0 && parentrowinputs[index-1]) {
			j$(parentrowinputs[index-1]).select().focus();
		}
	}
	if (code == 39) { // right
		var parentrowinputs = parentrow.children("td").children("input");
		if (parentrowinputs.length > 0 && parentrowinputs[index+1]) {
			j$(parentrowinputs[index+1]).select().focus();
		}
	}
}

function log(item) { if(j$.browser.mozilla) { console.log(item); } }
