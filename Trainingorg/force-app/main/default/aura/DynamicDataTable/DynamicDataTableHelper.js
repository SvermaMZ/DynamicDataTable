({

    getRecordsForTable : function(component, pageNumber, pageSize) {
        
        var action=component.get("c.fetchDynamicTable"); 
        var targetRecordID = component.get("v.ConfigDataTable");
        var parentApiID = component.get("v.RecordId");
        console.log('targetRecordID>>'+targetRecordID);
        console.log('ParentApi>>'+parentApiID);
        action.setParams({
            "tragetRecordID" : targetRecordID,  // This is DTOC name
            "parentApiID" : parentApiID,       // ID returned by HasrecordID interface.
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this,function(response)
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    console.log('Responce---'+JSON.stringify(response.getReturnValue()));
                    component.set("v.Table_header_Records",response.getReturnValue());
                    var records = component.get("v.Table_header_Records");
                    console.log('records...'+records);
                    console.log(component.get("v.Table_header_Records"));
                    if(records==null)
                    {
                        component.set("v.Error", true);
                        component.set("v.showHeaders",false);
                    }
                    if (records!=null && records.ListOfEachRecord.length == 0) {
                        component.set("v.Message", true);
                        component.set("v.showHeaders",false);

                        component.set("v.PageNumber", records.pageNumber);
                        component.set("v.TotalRecords", records.totalRecords);
                        component.set("v.RecordStart", records.recordStart);
                        component.set("v.RecordEnd", records.recordEnd);
                        component.set("v.TotalPages", Math.ceil(records.totalRecords / pageSize));
                        
                    } else {
                        component.set("v.Message", false);
                        component.set("v.showHeaders",true);
                        component.set("v.helpTextMessage", 'DataTable is configured through : ' + targetRecordID );

                        component.set("v.PageNumber", records.pageNumber);
                        component.set("v.TotalRecords", records.totalRecords);
                        component.set("v.RecordStart", records.recordStart);
                        component.set("v.RecordEnd", records.recordEnd);
                        component.set("v.TotalPages", Math.ceil(records.totalRecords / pageSize));
                    }
                }
            });
        $A.enqueueAction(action);
    },
    getTableRows: function(component, pageNumber, pageSize) {
        var action = component.get("c.getContactData");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
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
    }
})