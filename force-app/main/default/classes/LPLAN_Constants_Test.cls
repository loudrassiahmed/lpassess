@IsTest
public with sharing class LPLAN_Constants_Test {
    @IsTest
    public static void testConstants() {
        Test.startTest() ;
        LPLAN_Constants constants = new LPLAN_Constants() ;
        Test.stopTest() ;
        System.assertNotEquals(null, constants, 'The constants object must not be null');
    }
}