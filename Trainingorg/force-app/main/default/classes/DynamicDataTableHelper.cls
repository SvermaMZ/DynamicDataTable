/***********************************************************************************************************************************************
@Name         : DynamicDataTableHelper                                                                                                         *
@Author       : Adarsh Singh                                                                                                                   *
@Created Date : 11/02/2020                                                                                                                     *
@Description  : This class is used act as a helper class for all server side controllers                                                       *
***********************************************************************************************************************************************/
public with sharing class DynamicDataTableHelper {
    public static DynamicTableObjectConfiguration__c getRecordBasedOnId(String recordId){
        try{
            String[] strAllFields = new List<String>{'Object_API_Name__c', 'Pagination__c', 'Records_per_page__c', 'Search__c',
                                                    'Sequence_Column__c', 'Object_Name__c', 'Parent_Field_API__c','Inline_Edit__c','Serverside_Searching__c'};
            String sobj = 'DynamicTableObjectConfiguration__c';
            Set<String> setRecordId = new Set<String>{recordId};
                system.debug('set of record id'+setRecordId);
            String cols = doStringjoin(strAllFields);
            String condition = 'Name in : setRecordId';
            if(docheckAccessibility('DynamicTableObjectConfiguration__c', cols, 'Query').isEmpty()){
                String queryStr = 'select '+cols+' from '+sobj+' where '+condition+' LIMIT 1';
                DynamicTableObjectConfiguration__c ConfigRecord = Database.query(queryStr);
                return ConfigRecord;
            }else{
                throw new AuraHandledException('Target Object Dont have Access Permission --');
            }
        }catch(QueryException ex){
            system.debug('Exception comes while query :'+ex.getMessage());
            return null;
        }
    }
    //method to check object and field lavel accessibility
    public static Map<Boolean, List<String>> docheckAccessibility(String sObjectType, String commaDelimitedFields, String typeOfDml){
        Map<Boolean, List<String>> mapCheckAccessFlagWithField = new Map<Boolean, List<String>>();
        boolean securityPass = true;
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        
		//check object permission first		
		if(schemaType.getDescribe().isAccessible()){
			if(typeOfDml == 'Create'){
				if(!schemaType.getDescribe().isCreateable()){
                    securityPass = false;
                    mapCheckAccessFlagWithField.put(false, new List<String>());
				}
			}
			else if(typeOfDml == 'Update'){
				if(!schemaType.getDescribe().isUpdateable()){
                    securityPass = false;
                    mapCheckAccessFlagWithField.put(false, new List<String>());
				}
			}
			else if(typeOfDml == 'Upsert'){
				if(!schemaType.getDescribe().isCreateable() && !schemaType.getDescribe().isUpdateable()){
                    securityPass = false;
                    mapCheckAccessFlagWithField.put(false, new List<String>());
				}
			}
			else if(typeOfDml == 'Query'){
                securityPass = true;
                if(!schemaType.getDescribe().isqueryable()){
                    mapCheckAccessFlagWithField.put(false, new List<String>());
                }
			}
			for (String field : commaDelimitedFields.split(',')){
				if(fields.get(field) != null && fields.get(field).getDescribe() != null && fields.get(field).getDescribe().isPermissionable()){
					if(typeOfDml == 'Create'){
						if (!fields.get(field).getDescribe().isCreateable()){
                            securityPass = false;
                            mapCheckAccessFlagWithField.put(false, new List<String>());
                            mapCheckAccessFlagWithField.get(false).add(field);
						}
					}
					else if(typeOfDml == 'Update'){
						if (!fields.get(field).getDescribe().isUpdateable()){
                            securityPass = false;
                            mapCheckAccessFlagWithField.put(false, new List<String>());
                            mapCheckAccessFlagWithField.get(false).add(field);
						}
					}
					else if(typeOfDml == 'Query'){
						if (!fields.get(field).getDescribe().isAccessible()){
                            securityPass = false;
                            mapCheckAccessFlagWithField.put(false, new List<String>());
                            mapCheckAccessFlagWithField.get(false).add(field);
						}
					}
					else if(typeOfDml == 'Upsert'){
						if ((!fields.get(field).getDescribe().isUpdateable()) || (!fields.get(field).getDescribe().isCreateable())){
                            securityPass = false;
                            mapCheckAccessFlagWithField.put(false, new List<String>());
                            mapCheckAccessFlagWithField.get(false).add(field);
						}
					}
				}
			}
		}else{
            securityPass = false;
            mapCheckAccessFlagWithField.put(false, new List<String>());
		}
        return mapCheckAccessFlagWithField;
    }
    //get a string[] with commaseprated
	public static String doStringjoin(List<String> lstAllHeader) {
		List<String> lstTableColumns = new List<String>(lstAllHeader);
		if(lstTableColumns.isEmpty())
			return null;
		String stringWithAllComuns = lstTableColumns[0];
		lstTableColumns.remove(0);
		while(!lstTableColumns.isEmpty()) {
			stringWithAllComuns += ',' + lstTableColumns[0];
			lstTableColumns.remove(0);
        }
        system.debug('stringWithAllComuns>>'+stringWithAllComuns); 
		return stringWithAllComuns;
    }
    //method to get total length of existing records
    public static integer totalNumOfRecords(String sObjectName){
        String strQuery = 'select count() from '+ sObjectName;
        return Database.countQuery(strQuery);
    }
}