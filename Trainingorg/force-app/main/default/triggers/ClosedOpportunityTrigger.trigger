trigger ClosedOpportunityTrigger on Opportunity (before insert, before update) {
    
	List<Task> taskList = new List<Task>();
     for(Opportunity opr : Trigger.New) {
         if(opr.StageName ==  'Closed Won'){
             
             Task newTask = new Task(whatID = opr.ID, Subject='Follow Up Test Task'); 
          	 taskList.add(newTask);
             
         }
     }
     if(taskList.size()>0){
        insert tasklist;
    }
}