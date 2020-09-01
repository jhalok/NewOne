@isTest
public class bulkCreationUserController_Test{
    @isTest Static void Test1(){
        Test.startTest();
        List<String> requiredFields = bulkCreationUserController.userRequiredFields();
        List<List<String>> userCsvList = new List<List<String>>();
        userCsvList.add(new List<String>{'Name','Lastname','Role'});
        userCsvList.add(new List<String>{'Sam','Goyal1','Agent - M2All'});
        List<bulkCreationUserController.wrapperInfo> userInfo = bulkCreationUserController.insertBulkUsers(userCsvList);  
        System.assertNotEquals(Null,userInfo);
        Test.stopTest();
    }
    @isTest Static void Test2(){
        Test.startTest();
        List<List<String>> userCsvList = new List<List<String>>();
        userCsvList.add(new List<String>{'Name','Lastname','Role'});
        userCsvList.add(new List<String>{'','',''});
        List<bulkCreationUserController.wrapperInfo> userInfo = bulkCreationUserController.insertBulkUsers(userCsvList);
        System.assertEquals(Null,userInfo);
        Test.stopTest();
    }
}