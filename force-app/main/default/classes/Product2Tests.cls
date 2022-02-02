@isTest
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest static void Product2Extension_UnitTest(){
        List<Product2> productPage = TestDataFactory.ConstructProducts(1);
        Integer familiesNumber = Constants.PRODUCT_FAMILY.size();

        Pagereference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController stdContr = new Apexpages.StandardController(productPage[0]);

        Product2Extension ext = new Product2Extension(stdContr);
        Integer initialRowsSize = ext.productsToInsert.size();

        List<SelectOption> families = ext.GetFamilyOptions();
        ext.GetInventory();

        ext.AddRows();
        Integer finalRowSize = ext.productsToInsert.size();

        for(Integer i = 0; i < finalRowSize; i++) {
            ext.productsToInsert[i].productRecord = new Product2();
            ext.productsToInsert[i].productRecord.Name = 'Test class ' + i;
            ext.productsToInsert[i].productRecord.Family = Constants.PRODUCT_FAMILY[Math.mod(i, Constants.PRODUCT_FAMILY.size())].getValue();
            ext.productsToInsert[i].productRecord.IsActive = true;
            ext.productsToInsert[i].productRecord.Initial_Inventory__c = 1;

            ext.productsToInsert[i].pricebookEntryRecord = new PricebookEntry();
            ext.productsToInsert[i].pricebookEntryRecord.IsActive = true;
            ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 10;
        }

        Test.startTest();
            ext.Save();
        Test.stopTest();
        List<Product2> queriedProduct = [SELECT Id FROM Product2 WHERE Name Like 'Test class%'];

        System.assertEquals(finalRowSize, queriedProduct.size());
        System.assertEquals(familiesNumber + 1, families.size());
    }
}