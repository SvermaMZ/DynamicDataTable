public class AccountController {
@AuraEnabled
     public static DynamicWrapper fetchData(String myString) {
             Map<String,String> getDynamicValue = new Map<String,String>();

         String recordid = myString;
         List<DynamicTableConfiguration__c> Data = [SELECT Id, Column_Name__c, Object_Name__c 
                                     				from DynamicTableConfiguration__c 
                                                    where name =: recordid];
                                                    
         
        //return list of accounts
        List<String> colHead = New List<String>();
//if(sizeOf(Data[0].Column_Name__c)){
                      colHead=Data[0].Column_Name__c.split(',');
       //  }else{
        //              colHead=Data[0].Column_Name__c;
       //  }
        List<Sobject> objectList = new List<sObject> () ;
         //for(DynamicTableConfiguration__c objectName : Data) {
             objectList.addAll(fetchObjectList(Data[0].Object_Name__c, Data[0].Column_Name__c)) ;
         //}
             DynamicWrapper dynamicWrap = new DynamicWrapper();
         	 dynamicWrap.colName = colHead;
        	 dynamicWrap.objLst = objectList;
        return dynamicWrap;
     }
    
    private static List <Sobject> fetchObjectList(String sobjectName, String columnName) {
       
        String queryStr = 'Select ' + columnName + ' FROM ' + sobjectName  ;
        
        List<Sobject> accList = DataBase.query(queryStr) ;
        
        
        return accList;

    }
    
    public class DynamicWrapper{
        @AuraEnabled
       Public  List<String> colName;
        @AuraEnabled
       Public  List<Sobject> objLst ;
    }
}