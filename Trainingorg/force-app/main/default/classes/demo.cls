public class demo {
   // Public static boolean hasRecords {get;set;}
   @auraenabled
    public static accWrapper getAllRecords(Map<Id,Account> accMap){
        if(accMap==null || accMap.iSEmpty())
        {
              accMap = new Map<id,Account>();
        }
       list<account> acclist = fetchAcc(accMap.keySet());
        for(account acc: acclist){
            
            accMap.put(acc.Id,acc);
            
        }
        accWrapper ac = new accWrapper();
        ac.accountmap = accMap;
        ac.hasRecord = !acclist.isEmpty();
        return ac;
    }
    Public static list<Account> fetchAcc(set<Id> accIdSet){
        list<account> accList = new list<account>();
        If(accIdSet == null || accIdSet.isEmpty()){
            return [select id,name from account limit 2000];
        }else{
            Database.QueryLocator q = Database.getQueryLocator([SELECT Name FROM Account]);
            Database.QueryLocatorIterator it =  q.iterator();
            system.debug('data->'+it);
            
           // accList.add(it);
            //list<account> accList = [select id, name from account where not(id in : accIdSet) limit 2000];
           // hasRecords = !accList.isEmpty();
            
        }
        return accList;
    }
    public static List<sObject> fetchAllRecords(){
        List<sObject> lstTargetObject = new List<sObject>();
        Integer allAccountCount = [select count() from account];
        Database.QueryLocator q = Database.getQueryLocator([SELECT Name FROM Account LIMIT : Integer.valueOf(allAccountCount - 1)]);
        Database.QueryLocatorIterator it =  q.iterator();
        // Iterate over the records
        while (it.hasNext())
        {
            System.debug('accountInstance---'+(Account)it.next());
            lstTargetObject.add((Account)it.next());
        }
        system.debug('lstTargetObject---!!!'+lstTargetObject);
        return lstTargetObject;
    }
   
    public class accWrapper{
        @auraenabled public map<id,account> accountmap;
        @auraenabled public boolean hasRecord;
    }
}