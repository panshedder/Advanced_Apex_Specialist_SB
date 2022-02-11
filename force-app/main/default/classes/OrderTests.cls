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

        TestDataFactory.VerifyQuantityOrdered(oldProduct[0], newProduct[0], 0);
    }

    @isTest static void OrderExtension_UnitTest() {
        List<Order> orders = [SELECT Id FROM Order LIMIT 1];

        Pagereference orderEditPage = Page.OrderEdit;
        orderEditPage.getParameters().put('recordId', orders[0].Id);
        Test.setCurrentPage(orderEditPage);

        ApexPages.StandardController standardController = new Apexpages.StandardController(orders[0]);

        OrderExtension controllerExtension = new OrderExtension(standardController);


        controllerExtension.OnFieldChange();
        controllerExtension.selectFamily();
        controllerExtension.Save();
        controllerExtension.First();
        controllerExtension.Next();
        controllerExtension.Previous();
        controllerExtension.Last();
        controllerExtension.GetHasPrevious();
        controllerExtension.GetHasNext();
        controllerExtension.GetTotalPages();
        controllerExtension.GetPageNumber();
        controllerExtension.GetFamilyOptions();
        
        Order testOrderAfterSave = OrderExtension.QueryOrderRecord(orders[0].Id);
     
        System.assert(testOrderAfterSave != null);
    }
}