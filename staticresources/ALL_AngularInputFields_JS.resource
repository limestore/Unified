/*********************************************************
* Author: Sanjay.Ghanathey@cdk.com
* Description: Salesforce Datatypes replication in AngularJS
* Test Class: NA
* 
* History:
* 2015-07-28 	Sanjay Ghanathey		Created
* 2015-07-29 	Sanjay Ghanathey		Added lookup directive
* 2015-07-29 	Sanjay Ghanathey		Added filter
* 2015-08-05 	Sanjay Ghanathey		Added picklist directive
* ********************************************************* */
var application = angular.module('inputFields',['ngAnimate','ui.bootstrap']);
var __salesforceBaseUrl;
window.onload = function(){
    var temp = document.getElementById('doTimeoutLocation');
    __salesforceBaseUrl = temp.value.substring(0,temp.value.indexOf('?'));
    if(typeof(__salesforceBaseUrl) == 'undefined' && __salesforceBaseUrl == null)
    {
        alert('Invalid __salesforceBaseUrl');
    }
}
/* ****************************************
* Author: Sanjay Ghanathey
* Description: To filter the queried records instead 
*              of calling remote action again
* **************************************** */
application.filter('lookupFilter', function($filter) {
    return function(data,value,displayName) {
        var filteredList = [];                
        angular.forEach(JSON.parse(data), function(o) {  
            if(angular.lowercase(o[displayName]).indexOf(angular.lowercase(value)) > -1)
            {
                filteredList.push(o);
            }
            
        });
        return filteredList;
    }
});

/* ****************************************
* Author: Sanjay Ghanathey
* Description: Directive to check what type of 
*              input field is being referred
* **************************************** */
application.directive('type',function($compile) {            
    return {                 
        controller: ['$scope', '$q','$http','$filter', function($scope, $q,$http,$filter) {  
            //test            
            $scope.dateData = function(){
                $scope.today = function() {
                    $scope.selected = new Date();
                    $scope.selectedDate = new Date();
                };
                $scope.today();
                
                $scope.clear = function () {
                    $scope.selected = null;
                };
                
                // Disable weekend selection
                /*$scope.disabled = function(date, mode) {
                    return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
                };*/
                
                $scope.toggleMin = function() {
                    $scope.minDate = $scope.minDate ? null : new Date();
                };
                $scope.toggleMin();
                
                $scope.open = function($event) {
                    $scope.status.opened = true;
                };
                
                $scope.dateOptions = {
                    formatYear: 'yy',
                    startingDay: 1
                };
                
                $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
                $scope.format = $scope.formats[0];
                
                $scope.status = {
                    opened: false
                };
                
                var tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                var afterTomorrow = new Date();
                afterTomorrow.setDate(tomorrow.getDate() + 2);
                $scope.events =
                    [
                    {
                        date: tomorrow,
                        status: 'full'
                    },
                    {
                        date: afterTomorrow,
                        status: 'partially'
                    }
                ];
                
                $scope.getDayClass = function(date, mode) {
                    if (mode === 'day') {
                        var dayToCheck = new Date(date).setHours(0,0,0,0);
                        
                        for (var i=0;i<$scope.events.length;i++){
                            var currentDay = new Date($scope.events[i].date).setHours(0,0,0,0);
                            
                            if (dayToCheck === currentDay) {
                                return $scope.events[i].status;
                            }
                        }
                    }
                    
                    return '';
                };
                
                return $scope;
            };
            //test
            
            //Sanjay.Ghanathey@cdk.com 05-Aug-2015 Added picklist feature
            $scope.picklist = function(objectName,columnName){                     
                var deferred = $q.defer();                    
                setTimeout(function() {
                    deferred.notify('About to make a remote call.');                        
                    Visualforce.remoting.Manager.invokeAction(
                        'ALL_AngularInputFields_Controller.getPicklistValues',
                        objectName,columnName,
                        function(result, event){                                                                   
                            $scope.$apply(function () {
                                $scope.options = result;                                    
                            });
                        }                         
                    ); }, 500);
                return deferred.promise;
            };            
            
            $scope.getLookup = function(val){  
                $scope.sessionId = __sessionId;                 
                if(val.length<5)
                {
                    $scope.httpCallout = true;
                }
                else
                {
                    $scope.httpCallout = false;
                }
                
                if($scope.httpCallout)
                {                            
                    var deferred = $q.defer();                    
                    setTimeout(function() {
                        deferred.notify('About to make a remote call.');                                                   
                        var jsonItem = {};
                        jsonItem["objectName"] = $scope.ngObject;
                        jsonItem["columnNames"] = $scope.ngColumnNames;
                        jsonItem["searchString"] = val;
                        jsonItem["displayName"] = $scope.ngDisplayName;
                        
                        var req = {                                        
                            method: 'POST',                                
                            headers:{                                           
                                'Authorization':'OAuth '+$scope.sessionId,
                                'Content-Type': 'application/json',                                            
                                'SalesforceProxy-Endpoint':__salesforceBaseUrl+'/services/apexrest/datatable/'
                            },                                                                                
                            url: '/services/proxy',
                            data: JSON.stringify(jsonItem)
                        }                            
                        
                        $http(req).success(
                            function(data, status, header, config){                                                                    
                                $scope.sObjects = data;                                                                
                                deferred.resolve(JSON.parse(data));
                            }
                        ).error(
                            function(data, status, header, config ){
                                console.log('Error Fetching Data');
                                console.log(data, status, header, config);
                            }
                        );
                        
                    }, 1000);                               
                    return  deferred.promise;   
                } // end of if
                else
                {
                    var deferred = $q.defer();
                    setTimeout(function() {
                        deferred.notify('About to make a remote call.');
                        var filteredResult = $filter('lookupFilter')($scope.sObjects,val,$scope.ngDisplayName);
                        deferred.resolve(filteredResult);
                    },1000);                    
                    return deferred.promise;
                }
            };
        }],
        scope: {
            selected: '=?ngModel'
        },
        link: function(scope,iElement, iAttrs) {
            scope.ngObject = iAttrs.ngObject;
            scope.ngColumnNames = iAttrs.ngColumnnames;
            scope.ngDisplayName = iAttrs.ngDisplayname;
            if(iAttrs.type == 'lookup'){
                var html ='<span class="typeahead"><input type="text" style="display:inline-block;"  ng-model="selected" placeholder="Start Typing" typeahead="sObj as sObj[ngDisplayName] for sObj in getLookup($viewValue)"  typeahead-loading="loading" typeahead-min-length="3" class="form-control"/><i style="display:inline;margin-left:-22px;" ng-class="{ \'fa fa-spinner fa-pulse\': loading == true }"></i></span>';
                var e=angular.element(html);
                $compile(e.contents())(scope);
                iElement.replaceWith(e);
            }
            else if(iAttrs.type == 'picklist'){
                var html ='<ng-include ng-onload="picklist(ngObject,ngColumnNames)"><select class="form-control" ng-model="selected" ng-options="sObj.value for sObj in options"><option value="">-- Options --</option></select></ng-include>';
                var e=angular.element(html);
                e.on('load', scope.picklist(scope.ngObject,scope.ngColumnNames));
                $compile(e.contents())(scope);
                iElement.replaceWith(e);     
            }
        },
        restrict: 'A'
    }
});