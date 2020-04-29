({
    getRecordsForTable : function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 0;
        if(component.find("pageSize") != null || component.find("pageSize") != undefined)
        {
            pageSize =  component.find("pageSize").get("v.value");
        }
        
        
        console.log('Controller RecordId'+component.get("v.ConfigDataTable"));
        console.log('record id'+component.get("v.recordId"));
        console.log('object name'+component.get("v.sObjectName"));
        helper.getRecordsForTable(component, pageNumber, pageSize,null);
        
    },
    keyup: function(component, event, helper) {
        var isServerside = component.get("v.Serversearching");
        console.log("server side->"+isServerside);
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        if(srcValue.length > 2){
            if(isServerside){
                var pageNumber = component.get("v.PageNumber");  
                var pageSize = 0;
                if(component.find("pageSize") != null || component.find("pageSize") != undefined)
                {
                    pageSize =  component.find("pageSize").get("v.value");
                }
                helper.getRecordsForTable(component,pageNumber, pageSize,srcValue);
            }
            
            else{
                helper.clientsidekeyup(component,event , helper);}
            
        }
    },
    
    sortColumn : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var Fieldindex = ctarget.dataset.value;
        console.log("selected Field"+Fieldindex);
        var Wrapedrecords = component.get("v.Table_header_Records");
        var objectRecord = Wrapedrecords.ListOfEachRecord;
        var headerRecord = Wrapedrecords.headerList;
        console.log(headerRecord);
        console.log(objectRecord);
        for(var i=0;i<headerRecord.length;i++){
            console.log("loop:"+headerRecord[i].name+" - "+Fieldindex);
            if(headerRecord[i].index==Fieldindex)
            {	console.log("match entered");
             var sorted = headerRecord[i].sorted;
             if(sorted==1)
             {
                 //desc
                 console.log("descending");
                 objectRecord.sort(function(a,b) {
                     return (a['recordValue'][headerRecord[i].index].toString().toLowerCase()  < b['recordValue'][headerRecord[i].index].toString().toLowerCase() ) ? 1 : ((b['recordValue'][headerRecord[i].index].toString().toLowerCase()  < a['recordValue'][headerRecord[i].index].toString().toLowerCase() ) ? -1 : 0);} );
                 sorted=0;
             }
             else if(sorted==0 || sorted==2)
             {
                 console.log("ascending");
                 objectRecord.sort(function(a,b) {return (a['recordValue'][headerRecord[i].index].toString().toLowerCase()  > b['recordValue'][headerRecord[i].index].toString().toLowerCase() ) ? 1 : ((b['recordValue'][headerRecord[i].index].toString().toLowerCase()  > a['recordValue'][headerRecord[i].index].toString().toLowerCase() ) ? -1 : 0);} ); 
                 sorted=1;
             }
             headerRecord[i].sorted=sorted; 
             
            }
            else{
                headerRecord[i].sorted=2;
            }
        }
        Wrapedrecords.records=objectRecord;
        Wrapedrecords.headerList=headerRecord;
        console.log(Wrapedrecords);
        component.set("v.Table_header_Records",Wrapedrecords);
        
    },
    DOSomeThingOnCLickOfARow : function(component, event, helper) { 
        var ctarget = event.currentTarget;
        
        var id_str = ctarget.dataset.value;
        console.log(id_str);
        component.set("v.CRUDVariable",id_str);
        
      console.log('Access->'+component.get("v.isCRUD"));
        component.set("v.isOpen", true);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        console.log("pagenumebr->"+pageNumber+"page size->"+pageSize);
        pageNumber++;
        helper.getRecordsForTable(component, pageNumber, pageSize);
    },
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        pageNumber--;
        helper.getRecordsForTable(component, pageNumber, pageSize);
    },
    onSelectChange: function(component, event, helper) {
    console.log("page size");
        var page = 1
        var pageSize = component.find("pageSize").get("v.value");
        console.log("page size"+pageSize);
        helper.getRecordsForTable(component, page, pageSize);
    },
    
    closeModel: function(component, event, helper) {
        
        component.set("v.isOpen", false);
    },
})