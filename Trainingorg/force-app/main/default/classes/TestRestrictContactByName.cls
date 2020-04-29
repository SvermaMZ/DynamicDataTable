@isTest
public  class TestRestrictContactByName {
	static testMethod void contactInsertSuccess(){
    Contact con=new Contact(FirstName='Arjun', LastName='INVALIDNAME');
         boolean insertfalse;
        try{
          insert con;  
        }
        catch(Exception e){
            insertfalse = true;
        }
	System.assert(true,insertfalse);
            }
    static testMethod void contactInsertSuccess1(){
    Contact con=new Contact(FirstName='Arjun', LastName='Verma');
       insert con;
        boolean insertfalse;
	System.assert(true,insertfalse);
    }
}