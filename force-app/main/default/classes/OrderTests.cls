@isTest
private class OrderTests {
    @TestSetup private static void SetupTestData() {
        TestDataFactory.InsertTestData(1);
    }

    @isTest private static void OrderUpdate_UnitTest() {
        //Lookup order and activate them
        //From order to Product
        List<Product2> oldProduct = [SELECT Id, Quantity_Ordered__c, Initial_Inventory__c FROM Product2 limit 1];
        List<Product2> newProduct = new List<Product2>();

        Test.startTest();
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Status != :Constants.ACTIVATED_ORDER_STATUS];
        orders[0].Status = Constants.ACTIVATED_ORDER_STATUS;
        update orders[0];
        Test.stopTest();
        
        newProduct = [SELECT Id, Quantity_Ordered__c, Initial_Inventory__c FROM Product2 WHERE Id =: oldProduct[0].Id];

        TestDataFactory.VerifyQuantityOrdered(oldProduct[0], newProduct[0], Constants.DEFAULT_ROWS);
    }
}