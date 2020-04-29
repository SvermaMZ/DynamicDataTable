public class AccControler {
public Account acc {get; set;}
    public Boolean isError {get; set;}
    public Boolean isEditable {get; set;}
    
    public AccControler(){
        String accId = ApexPages.currentPage().getParameters().get('id');
        isEditable=false;
        if(accId != null && accId.trim().length()>0){
            isError=false;
            list<Account> accList = [Select Id, Name, Phone, Website, Type,Fax,Ownership, Industry, ShippingStreet, BillingStreet, NumberOfEmployees, AccountNumber From Account Where Id =: accId];
            acc = accList != null && accList.size() > 0 ? accList[0] : new Account();
            
            /*if(accList != null && accList.size() > 0){
                acc=accList[0];
            }else{
                acc=new Account();
            }*/
        }else{
            isError=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Invalid Id.'));
        }
    }
    
    public PageReference saveAcc(){
        if(acc.Name != null && acc.Name.trim().length()>0){
            upsert acc;
            return new PageReference('/'+acc.Id);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Name is a required field.'));
        }
        return null;
    }
    
    public void deleteAcc(){
        
    }
    
    public void editAcc(){
        isEditable=true;
    }
    
    public void cancelAcc(){
        isEditable=false;
    }
}