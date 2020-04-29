({
    
    getRecordsForTable : function(component, pageNumber, pageSize,searchableStr) {
        
        var action=component.get("c.fetchDynamicTable"); 
        var targetRecordID = component.get("v.ConfigDataTable");
        var sObjectName = component.get("v.sObjectName");
        var parentApiID = component.get("v.recordId");
        var pagesize = pageSize;
        console.log('targetRecordID>>'+targetRecordID);
        console.log('ParentApi>>'+parentApiID);
        console.log('objectname>>'+sObjectName);
        action.setParams({
            "targetRecordID" : targetRecordID,  // This is DTOC name
            "parentApiID" : parentApiID,       // ID returned by HasrecordID interface.
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "sObjectName":sObjectName, //Object name of hasRecordid.
            "expression":searchableStr
        });
        component.set("v.show", true);
        
        action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               component.set("v.show", false);
                               if (component.isValid() && state === "SUCCESS"){
                                   console.log('Responce---'+JSON.stringify(response.getReturnValue()));		
                                   component.set("v.Table_header_Records",response.getReturnValue());
                                   var records = component.get("v.Table_header_Records");
                                   console.log('records...'+records);
                                   console.log(component.get("v.Table_header_Records"));
                                   if(records==null)
                                   {
                                       console.log('records...inside null');
                                       component.set("v.Error", true);
                                       component.set("v.showHeaders",false);
                                   }
                                   if (records!=null && records.ListOfEachRecord.length == 0) {
                                       console.log('records not null');
                                       component.set("v.Message", true);
                                       component.set("v.showHeaders",false);
                                       console.log('object name'+records.objName);
                                       component.set("v.ObjName",records.objName);
                                       component.set("v.isCRUD", records.inlineEdit);
                                       component.set("v.PageNumber", records.pageNumber);
                                        component.set("v.fields", records.attributeFields);
                                       component.set("v.Serversearching", records.serverSideSearching);
                                       component.set("v.TotalRecords", records.totalRecords);
                                       component.set("v.RecordStart", records.recordStart);
                                       component.set("v.RecordEnd", records.recordEnd);
                                       component.set("v.Recordsperpage", records.recordsPerPage);
                                       component.set("v.TotalPages", Math.ceil(records.totalRecords /records.pageSize));
                                       
                                   } else {
                                       console.log('records not null');
                                       component.set("v.Message", false);
                                       component.set("v.showHeaders",true);
                                       component.set("v.ObjName",records.objName);
                                       component.set("v.Serversearching", records.serverSideSearching);
                                       component.set("v.helpTextMessage", 'DataTable is configured through : ' + targetRecordID );
                                       component.set("v.isPagination", records.showPagination);
                                       component.set("v.isCRUD", records.inlineEdit);
                                       component.set("v.PageNumber", records.pageNumber);
                                       component.set("v.fields", records.attributeFields);
                                       component.set("v.Recordsperpage", records.recordsPerPage);
                                       component.set("v.TotalRecords", records.totalRecords);
                                       component.set("v.RecordStart", records.recordStart);
                                       component.set("v.RecordEnd", records.recordEnd);
                                       
                                       component.set("v.TotalPages", Math.ceil(records.totalRecords / records.pageSize));
                                   }
                               }
                           });
        $A.enqueueAction(action);
       
    },
    clientsidekeyup:function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
       
        console.log("keyupfunction"+event.keyCode); 
        console.log(component.get("v.Table_header_Records"));
        var tableRecords=component.get("v.Table_header_Records");       
         console.log("srcvalue length"+srcValue+"->"+srcValue.length);
        if ((srcValue == '' || srcValue == null) && (event.keyCode === 13)  ) {
            alert("Enter some value to Search");
        }
        else{
            
            if(tableRecords!=null )
            {
                if(tableRecords.SwapVariable==null)
                {
                    tableRecords.SwapVariable=tableRecords.ListOfEachRecord;
                }
                else
                {
                    tableRecords.ListOfEachRecord=tableRecords.SwapVariable;
                }
                var headerRecords = tableRecords.headerList;
                var Index=0;
                var Sorted=1;
                for(var i=0;i<headerRecords.length;i++){
                    if(headerRecords[i].sorted!=2)
                    {
                        Index=headerRecords[i].index;
                        Sorted=headerRecords[i].sorted;
                    }
                }
                var originalRecords=tableRecords.ListOfEachRecord;
                var lstofrec=tableRecords.ListOfEachRecord;
                var searchRelatedRecords=[];
                
                for(var i=0;i<tableRecords.ListOfEachRecord.length;i++){
                    
                    var matchFound=false;
                    for(var j=0;j<tableRecords.ListOfEachRecord[i].recordValue.length;j++)
                    {
                        
                        var value = tableRecords.ListOfEachRecord[i].recordValue[j].recValue;
                        
                        if(value.toString().toLowerCase().indexOf(srcValue)!= -1)
                        {
                            matchFound=true;
                        }
                        
                    }
                    if(matchFound)
                    {
                        
                        searchRelatedRecords.push(tableRecords.ListOfEachRecord[i]);
                        if(Sorted==1){
                            searchRelatedRecords.sort(function(a,b) {return (a['recordValue'][Index].toString().toLowerCase()  > b['recordValue'][Index].toString().toLowerCase() ) ? 1 : ((b['recordValue'][Index].toString().toLowerCase()  > a['recordValue'][Index].toString().toLowerCase() ) ? -1 : 0);} );
                            
                        }
                        else
                        {
                            searchRelatedRecords.sort(function(a,b) {
                                return (a['recordValue'][Index].toString().toLowerCase()  < b['recordValue'][Index].toString().toLowerCase() ) ? 1 : ((b['recordValue'][Index].toString().toLowerCase()  < a['recordValue'][Index].toString().toLowerCase() ) ? -1 : 0);} );
                            
                            
                        }
                    }
                    
                }
                tableRecords.SwapVariable=originalRecords;
                tableRecords.ListOfEachRecord=[];
                tableRecords.ListOfEachRecord=searchRelatedRecords;
                
                if(tableRecords.ListOfEachRecord.length > 0){
                    console.log("src-<"+JSON.stringify(searchRelatedRecords));
                    component.set("v.Table_header_Records",tableRecords);
                    component.set("v.Norecords",true);
                }else{
                    console.log("inside else"+JSON.stringify(tableRecords.ListOfEachRecord));
                    component.set("v.Norecords",false);
                }
                
            }
        }
        
    },
   /* getTableRows: function(component, pageNumber, pageSize) {
        var action = component.get("c.getContactData");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        component.set("v.show", true);
        action.setCallback(this, function(result) {
            var state = result.getState();
            component.set("v.show", false);
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set("v.ContactList", resultData.contactList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
            }
        });
        $A.enqueueAction(action);
    },*/
})