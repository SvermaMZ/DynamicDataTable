/***********************************************************************************************************************************************
@Name         : DynamicDataTableCtrl                                                                                                           *
@Author       : Adarsh Singh                                                                                                                   *
@Created Date : 23/01/2020                                                                                                                     *
@Description  : This class is used as server side controller for DynamicDataTable Lightning Application.                                        *
***********************************************************************************************************************************************/
public class DynamicDataTableCtrl{
    public static map<string,string> fieldFormat = new map<string,string>();
    @AuraEnabled(cacheable=true)
    public static object fetchDynamicTable(String targetRecordID, String parentApiID, Decimal pageNumber, Decimal pageSize,String sObjectName,String expression){
        system.debug('targetRecordID-->>'+targetRecordID);
        system.debug('parentApiID-->>'+parentApiID);
        system.debug('Object name-->>'+sObjectName);
        DynamicTableObjectConfiguration__c objTargetConfigData;
        if(targetRecordID != null && targetRecordID != ''){ 
            objTargetConfigData = DynamicDataTableHelper.getRecordBasedOnId(targetRecordID);
        }else{
            throw new AuraHandledException('Configure Record Id Not Found!!' );
        }
        //Pagination and Table object Attributes
        Integer pSize;
        system.debug('inside pageSize =>'+objTargetConfigData.Records_per_page__c);
        if(pageSize == 0 && (objTargetConfigData.Records_per_page__c != '' && objTargetConfigData.Records_per_page__c != null)){
            
             pSize = Integer.valueof(objTargetConfigData.Records_per_page__c);
            system.debug('inside pageSize =>'+pSize);
        }else if(objTargetConfigData.Pagination__c == false){
            pSize = 1;
        }
        else{
             pSize = (Integer)pageSize;
        system.debug('pageSize'+pSize);
        }
        
        Integer pNumber = (Integer)pageNumber;
        Integer offset = (pNumber - 1) * pSize;
        Integer recordEnd = pSize * pNumber;
        String allSelectedColumn = ''; 
        String targetObject = ''; 
        String parentapi = '';
        Integer headerindex = 0; 
        String Query = '';
        String checkObj = '';
        TargetTable TargetTable_inst = new TargetTable();
        List<EachRecord> allListOfRecords = new List<EachRecord>();
        //Total Records
        
        // Integer totalRecords = [select count() from contact];
        //getting the current configuration record
        
        system.debug('objTargetConfigData>>>>'+objTargetConfigData);
        if(objTargetConfigData != null){
            if(objTargetConfigData.Object_Name__c != null && objTargetConfigData.Object_Name__c != ''){
                targetObject = String.valueOf(objTargetConfigData.Object_Name__c).deleteWhitespace();
            }else{
                throw new AuraHandledException('Target Record ID does not contains Target Table');
            }
        }else{
            throw new AuraHandledException('Configure record is not found!!');
        }
        
        //Total Records
        string dummyQuery = 'select count() from '+ targetObject;
        Integer totalRecords= database.countQuery(dummyQuery);
        system.debug('the count is '+ totalRecords);
        
        //Checking objects for showing data
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
            .get(targetObject)
            .getDescribe()
            .fields
            .getMap()
            .get(objTargetConfigData.Parent_Field_API__c)
            .getDescribe();
        
        for(Schema.SObjectType reference : f.getReferenceTo()) {
            System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
            checkObj = reference.getDescribe().getName();
        }
        
        
        List<header> allColumns = lstColumnsWithAttributes((String) objTargetConfigData.Id);
        
        allSelectedColumn = doStringjoin(allColumns);
        
      
        
        // Created a Query for fetching records
        Query = objTargetConfigData != null?'Select ' + allSelectedColumn + ' FROM ' + targetObject :  'Select ' + allSelectedColumn + ' FROM ' + targetObject+' LIMIT '+pSize +' OFFSET '+OFFSET ;
        
        if (objTargetConfigData.Parent_Field_API__c != null && parentApiID != null && parentApiID != '') 
        {
            if(checkObj == sObjectName){
                parentapi = objTargetConfigData.Parent_Field_API__c + ' = \'' + parentApiID + '\'';
                Query =  Query +' where '+ parentapi;
            }
            
        }
        if(!string.isBlank(expression)){
            string srchCondtn = '(';
            for(string fieldname: allSelectedColumn.split(',')){
                if(fieldFormat.get(fieldname) != null && (fieldFormat.get(fieldname) == 'String' || fieldFormat.get(fieldname) == 'Email')){
					srchCondtn += ' '+ fieldname + ' like \'%'+ expression + '%\'';
                    srchCondtn += ' OR ' ;
                }
            }srchCondtn = srchCondtn.removeEnd(' OR ') + ')';
            if(Query.contains(' where ')){
                Query = Query + ' and ' + srchCondtn;
            }else{
                Query = Query + ' where ' + srchCondtn;
            }
        }
       // Query = objTargetConfigData.Pagination__c ? Query + ' LIMIT ' +pSize +' OFFSET '+OFFSET : Query + ' LIMIT 49999';
        
        Query =  Query + ' LIMIT 10';
        
        
        
        List<String> fieldList = allSelectedColumn.split(',');
        system.debug('fieldList>>>'+fieldList);
        //Creating a Dynamic Object Type with Custom object name
        String listType = 'List<' + targetObject + '>';
        //Creating a Dynamic Record Type with Custom object name
        String EachRecordType =  ''+targetObject+'';
        System.debug('listType'+listType);
        System.debug('Query>>>'+Query);
        System.debug('EachRecordType'+EachRecordType);
        List<SObject> ListOfRecords;
        SObject IndividualMember;
        boolean isTargetObjectAccessible = false;
        //Creating a generic Sobject to hold data of custom object
        try{
            SObjectType sObjectType = Schema.getGlobalDescribe().get(targetObject);
            isTargetObjectAccessible = sObjectType.getDescribe().isAccessible();
            system.debug('isTargetObjectAccessible'+isTargetObjectAccessible);
            //Creating a generic Sobject to hold data of custom object
            ListOfRecords = (List<SObject>)Type.forName(listType).newInstance();
            IndividualMember = (SObject)Type.forName(EachRecordType).newInstance();
            system.debug('IndividualMember?>>'+IndividualMember);
            //Execute the Query to get and store the data in Generic object
            ListOfRecords = Database.query(Query);
            system.debug('ListOfRecords'+ListOfRecords);  
            //removing not accessible fields from the List of Fields to display
            Set<String> notAccessibleFields = new Set<String>();
            for (SObjectField field : sObjectType.getDescribe().fields.getMap().values()){
                if (!field.getDescribe().isAccessible()){ 
                    notAccessibleFields.add(String.valueOf(field));
                } 
            }
            system.debug('accessibleFields'+notAccessibleFields);
            List<Integer> ListtoRemove = new List<Integer>();
            Integer toRemove=0;
            for(String field :fieldList)
            {
                if(notAccessibleFields.contains(field))
                {
                    ListtoRemove.add(toRemove);
                }
                
                toRemove++;            
            }
            system.debug('fieldList'+fieldList);
            system.debug('ListtoRemove'+ListtoRemove);
            if(ListtoRemove.size()>0){
                for(Integer Removefield :ListtoRemove)
                {
                    fieldList.remove(Removefield);
                }
            }
            system.debug('accessibleFields'+fieldList);
            
        }
        catch(Exception e)
        {
            throw new AuraHandledException('Exception Coming---'+e.getMessage());
        }
        if(isTargetObjectAccessible){
            for(Integer i=0;i<ListOfRecords.size();i++)
            {
                IndividualMember = ListOfRecords[i];
                EachRecord Each_record_nested_List_Of_Fields = new EachRecord();
                List<object> temp = new List<object>();
                List<TableRecordValueClass> tRV_list =new List<TableRecordValueClass>();
                for(String field :fieldList)
                {   //record id
                    if(field=='id')
                    {
                        Each_record_nested_List_Of_Fields.recordId=(Id)IndividualMember.get(field);
                    }
                    //if there is any relation like account.name
                    if(field.containsAny('\\.'))
                    {
                        List<String> relation = field.split('\\.');
                        //get the actual value not id in relation
                        temp.add(IndividualMember.getSobject(relation[0]).get(relation[1]));
                    }
                    else
                    {       //except is store in all field and values  
                        if(field!='id'){
                            string fFormat;
                            string rValue;
                            system.debug('field>>>'+field);
                            system.debug('IndividualMember>>'+IndividualMember);
                            system.debug('IndividualMember.get(field)---'+IndividualMember.get(field));
                            fFormat = (fieldFormat.get(field)!=null)?fieldFormat.get(field) : 'string' ;
                            rValue = (String)(IndividualMember.get(String.valueOf(field))==null ?'':IndividualMember.get(String.valueOf(field)));
                            TableRecordValueClass objRecord = new TableRecordValueClass();
                            objRecord.recFormat = fFormat;
                            objRecord.recValue = rValue;
                            tRV_list.add(objRecord);
                            temp.add((IndividualMember.get(String.valueOf(field))==null)?'':IndividualMember.get(String.valueOf(field)));
                        }
                    }
                }
                System.debug('i='+i+'-'+temp);
                //Each_record_nested_List_Of_Fields.recordValue=temp;
                Each_record_nested_List_Of_Fields.recordValue=tRV_list;
                Each_record_nested_List_Of_Fields.recordId=(Id)IndividualMember.get('id');
                allListOfRecords.add(Each_record_nested_List_Of_Fields);
            }
            
            //prepare header  
            List<header> headerList = new List<header>();

            for(String field :fieldList)
            {
                system.debug('field'+field);
                if(field!='id'){
                    header h = new header();
                    h.index=headerindex++;
                    String s = field;
                    //removing __c
                    Integer i=s.lastIndexOf('_');
                    if(i!=-1)
                    {
                        s=s.substring(0,i);
                    }
                    //replacing _ with space so we get the label from API name
                    s=s.replaceAll('_',' ');
                    system.debug('String'+s);
                    h.name=s;
                    h.sorted=2;
                    
                    headerList.add(h);
                }
            }
            system.debug('headerList>>>'+headerList);
            
            TargetTable_inst.headerList=headerList;
            TargetTable_inst.records=ListOfRecords;
            TargetTable_inst.ListOfEachRecord=allListOfRecords;
            TargetTable_inst.pageSize = pSize;
            TargetTable_inst.pageNumber = pNumber;
            TargetTable_inst.recordStart = offset + 1;
            TargetTable_inst.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            TargetTable_inst.totalRecords = totalRecords;
            TargetTable_inst.showPagination = objTargetConfigData.Pagination__c;
            TargetTable_inst.inlineEdit = objTargetConfigData.Inline_Edit__c;
            TargetTable_inst.serverSideSearching = objTargetConfigData.Serverside_Searching__c;
            TargetTable_inst.objName = targetObject;
            TargetTable_inst.attributeFields = fieldList ;
            TargetTable_inst.recordsPerPage = objTargetConfigData.Records_per_page__c;
            system.debug('page size'+TargetTable_inst.recordEnd);
            
            
            return TargetTable_inst;
        }
        else{
            throw new AuraHandledException('Target Object Dont have Access Permission ');
        }
        
    } 
    
    //get configuration object's columns details
    private static header[] lstColumnsWithAttributes(String currentConfigurationRecId){
        String[] allColumnsInTable = new List<String>();
        List<header> lstWrappHeader = new List<header>();
        header objHeaderWrapper ;
        for(DynamicTableAttributeConfiguration__c ObjColumn :  [select Fields_API_Name__c, Formatting__c, Sorting__c,
                                                                Field_Name__c from DynamicTableAttributeConfiguration__c 
                                                                where DynamicTableObjectConfiguration__c = : currentConfigurationRecId]){
                                                                    system.debug('object column' + ObjColumn);
                                                                    objHeaderWrapper = new  header();
                                                                    objHeaderWrapper.name = ObjColumn.Field_Name__c;
                                                                    objHeaderWrapper.api = ObjColumn.Fields_API_Name__c;
                                                                    objHeaderWrapper.sorted = 2;
                                                                    objHeaderWrapper.formate = ObjColumn.Formatting__c;
                                                                    
                                                                    fieldFormat.put(ObjColumn.Fields_API_Name__c,ObjColumn.Formatting__c);     
                                                                    
                                                                    lstWrappHeader.add(objHeaderWrapper);
                                                                }
        system.debug('lstWrappHeader>>>'+lstWrappHeader);
        return lstWrappHeader;
    }
    //perform pagination 
    private static object getRecordsWithPagination(Boolean isPagination, Integer ofst, Integer lmt){
        return null;
    }
    //Create a string with all columns
    private static String doStringjoin(List<header> lstAllHeader) {
        List<header> lstTableColumns = new List<header>(lstAllHeader);
        if(lstTableColumns.isEmpty())
            return null;
        String stringWithAllComuns = lstTableColumns[0].api;
        lstTableColumns.remove(0);
        while(!lstTableColumns.isEmpty()) {
            stringWithAllComuns += ',' + lstTableColumns[0].api;
            lstTableColumns.remove(0);
        }
        system.debug('stringWithAllComuns>>'+stringWithAllComuns); 
        return stringWithAllComuns;
    }
    //Wrapper for Table Header(Columns)
    public class header{
        @AuraEnabled public String name; //Name of the Field
        @AuraEnabled public String api;  //Api of the Field
        @AuraEnabled public Integer sorted; //Is the FieldSorted
        @AuraEnabled public String formate; //family of the column
        @AuraEnabled public Integer index; //Index of the Field on record
       
        
    }
    //Wrapper for Each Table Record
    public class EachRecord{
        @AuraEnabled public List<object> recordValue;  //Record
        @AuraEnabled public Id recordId; //Record Id used for Firing Events
    }
    //Wrapper for Each Table Properties
    public class TargetTable{
        @AuraEnabled public List<header> headerList; //Header wrapper
        @AuraEnabled public List<String> attributeFields; //Header wrapper
        @AuraEnabled public List <sObject> records; //actual list of records
        @AuraEnabled public List <EachRecord> ListOfEachRecord;//all data will be saved as array of array values
        @AuraEnabled public List <EachRecord> SwapVariable;//curated wrapped list of record facilitated for table 
        //pagination variables
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecords {get;set;}
        @AuraEnabled public Integer recordStart {get;set;}
        @AuraEnabled public Integer recordEnd {get;set;}
        @AuraEnabled public Boolean showSearching {get;set;}
        @AuraEnabled public Boolean showPagination {get;set;}
        @AuraEnabled public string recordsPerPage {get;set;}
        //Object data
        @AuraEnabled public String objName {get;set;}
        // Inline editing check
        @AuraEnabled public boolean inlineEdit {get;set;}
        @AuraEnabled public boolean serverSideSearching {get;set;}
    }
    
    // for showing formated data
    public class TableRecordValueClass{
        @AuraEnabled public String recValue {get;set;}
        @AuraEnabled public String recFormat {get;set;}
    }
    //Wrapper for Each Table column attributes
    public class TableColumnAttribute{
        
    }
}