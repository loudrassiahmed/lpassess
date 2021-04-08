public with sharing class LPLAN_ConsentsManagementController {


    @AuraEnabled
    public static ConsentWrapper getConsentsBySObjectId(Map<String, Object> payload) {
        try {
            ConsentManagementSetting__c consentManagementFieldsList = [SELECT ConsentFields__c FROM ConsentManagementSetting__c];
            Id recordId = (Id)payload.get('recordId');
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            String query = 'SELECT Email, ' + consentManagementFieldsList.ConsentFields__c
            + ' FROM ' + sObjectName + ' WHERE Id =:recordId';
            sObject currentRecord = Database.query(query).get(0);
            ConsentWrapper consentWrapper = new ConsentWrapper();
            consentWrapper.sObjectName = sObjectName;
            consentWrapper.fieldsList = consentManagementFieldsList.ConsentFields__c;
            consentWrapper.email = (String)currentRecord.get('Email');
            List<String> fieldsList = consentManagementFieldsList.ConsentFields__c.split(',');

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectSchema = schemaMap.get(sObjectName);
            Map<String, Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();

            for(String fieldItem : fieldsList) {
                ConsentItemWrapper consentItemWrapper = new ConsentItemWrapper();
                consentItemWrapper.fieldName = fieldItem;
                consentItemWrapper.fieldLabel = fieldMap.get(fieldItem).getDescribe().getLabel();
                consentItemWrapper.fieldValue = Boolean.valueOf(currentRecord.get(fieldItem));
                consentWrapper.consentItems.add(consentItemWrapper);
            }

            return consentWrapper;
        } catch (Exception e) {
            Log.error(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateCustomerConsentsByEmail(ConsentWrapper consentWrapper) {
        try {
            Map<String, Boolean> consentsValuesMap = new Map<String, Boolean> ();
            for(ConsentItemWrapper consentItemWrapper : consentWrapper.consentItems) {
                consentsValuesMap.put(consentItemWrapper.fieldName, consentItemWrapper.fieldValue);
            }
            String email = consentWrapper.email;
            List<SObject> customerRecordsToUpdate = new List<SObject>();
            customerRecordsToUpdate.addAll(Database.query('SELECT Id, '+ consentWrapper.fieldsList + ' FROM Contact WHERE Email =:email'));
            customerRecordsToUpdate.addAll(Database.query('SELECT Id, '+ consentWrapper.fieldsList + ' FROM Lead WHERE Email =:email'));
            for(SObject sObjectItem : customerRecordsToUpdate) {
                for(String fieldItem : consentWrapper.fieldsList.split(',')) {
                    sObjectItem.put(fieldItem, consentsValuesMap.get(fieldItem));
                }
            }
            if(!customerRecordsToUpdate.isEmpty()) {
                update customerRecordsToUpdate;
            }
            return String.format(Label.LPAN_UpdateConsents_SuccessMessage, new List<String> { String.valueOf(customerRecordsToUpdate.size()) });
        } catch (Exception e) {
            Log.error(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ConsentWrapper {
        @AuraEnabled
        public String sObjectName{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String fieldsList{get;set;}
        @AuraEnabled
        public List<ConsentItemWrapper> consentItems{get;set;}

        public ConsentWrapper() {
            this.consentItems = new List<ConsentItemWrapper>();
        }
    }
    public class ConsentItemWrapper {
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public Boolean fieldValue{get;set;}
    }
}
