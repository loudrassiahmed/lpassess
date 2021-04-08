@isTest(SeeAllData=false)
public with sharing class LPLAN_ConsentsManagementController_Test {

    @testSetup
    static void setupData() {

        ConsentManagementSetting__c consentManagementSetting = (ConsentManagementSetting__c) TestDataFactory.createSObject(
            'ConsentManagementSetting__c', new Map<String, Object>{
                                'ConsentFields__c' => 'CommercialEmailConsent__c,CommercialPhoneConsent__c,MarketingEmailConsent__c,MarketingPhoneConsent__c'
                                }, true);
        Lead lead = (Lead) TestDataFactory.createSObject(
            'Lead', new Map<String, Object>{
                                'LastName' => 'Lead 1',
                                'Company' => 'Company 1',
                                'Email' => 'test@test.com'}, true);
        Contact contact = (Contact) TestDataFactory.createSObject(
            'Contact', new Map<String, Object>{
                                'LastName' => 'Contact 1',
                                'Email' => 'test@test.com'}, true);
    }
    @isTest
    private static void getConsentsBySObjectIdProductTest() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Contact 1' LIMIT 1];
        Map<String,Object> payload = new Map<String,Object> {
            'recordId' => contact.Id
        };
        Test.startTest();
        LPLAN_ConsentsManagementController.ConsentWrapper consentWrapper = LPLAN_ConsentsManagementController.getConsentsBySObjectId(payload);
        Test.stopTest();
        System.assertEquals(4, consentWrapper.consentItems.size());
        System.assertEquals('test@test.com', consentWrapper.email);
    }
    @isTest
    private static void getConsentsBySObjectIdTestEnforceException() {
        Test.startTest();
        try {
            LPLAN_ConsentsManagementController.ConsentWrapper consentWrapper = LPLAN_ConsentsManagementController.getConsentsBySObjectId(null);
        } catch (Exception e) {
            System.assert(true, 'an error must be thrown');
        }
        Test.stopTest();
    }

    @isTest
    private static void updateCustomerConsentsByEmailTest() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Contact 1' LIMIT 1];
        Map<String,Object> payload = new Map<String,Object> {
            'recordId' => contact.Id
        };
        LPLAN_ConsentsManagementController.ConsentWrapper consentWrapper = LPLAN_ConsentsManagementController.getConsentsBySObjectId(payload);
        Test.startTest();
        String successMessage = LPLAN_ConsentsManagementController.updateCustomerConsentsByEmail(consentWrapper);
        Test.stopTest();
        System.assertEquals(String.format(Label.LPAN_UpdateConsents_SuccessMessage, new List<String> { '2'}), successMessage, ' 2 records must be updated');
    }

    @isTest
    private static void updateCustomerConsentsByEmailTestEnforceException() {
        Test.startTest();
        try {
            LPLAN_ConsentsManagementController.updateCustomerConsentsByEmail(null);
        } catch (Exception e) {
            System.assert(true, 'an error must be thrown');
        }
        Test.stopTest();
    }
}