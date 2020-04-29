({
	  fetchRecords: function(component, event, helper) {
        var action = component.get("c.getAllRecords");
          var accmap = component.get("v.accMap");
			//console.log(accmap);
          action.setParams({
            "accMap": accmap
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
               
                var resultData = result.getReturnValue();
                 console.log('resultdata.accountmap->'+JSON.stringify(resultData.accountmap));
                console.log('resultdata.hasrecord->'+resultData.hasRecord);
                component.set("v.accMap", resultData.accountmap);
                 component.set("v.hasRecord", resultData.hasRecord);
              		helper.evaluateRecords(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    evaluateRecords: function(component, event, helper) {
         var hasRec = component.get("v.hasRecord");
        
          if(hasRec){
              console.log('calling helper->'+hasRec);
             
             
              
              helper.fetchRecords(component, event, helper);
            
          }
    }

	
})