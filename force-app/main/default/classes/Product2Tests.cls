@isTest(SeeAllData = true) 
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest private static void Product2Extension_UnitTest(){
        List<Product2> productPage = TestDataFactory.ConstructProducts(1);
        Integer familiesNumber = Constants.PRODUCT_FAMILY.size();

        Pagereference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController stdContr = new Apexpages.StandardController(productPage[0]);

        Product2Extension ext = new Product2Extension(stdContr);

        List<SelectOption> families = ext.GetFamilyOptions();
        ext.GetInventory();

        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS);
        ext.AddRows();
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS * 2);

        for(Integer i = 0; i < ext.productsToInsert.size(); i++) {
            ext.productsToInsert[i].productRecord = new Product2();
            ext.productsToInsert[i].productRecord.Name = 'Test class Ext' + i;
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
    }

    @isTest private static void Product2Trigger_UnitTest() {
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        
        Inventory_Setting__mdt lowBeverageInventory = [SELECT DeveloperName, Low_Quantity_Alert__c 
                                                        FROM Inventory_Setting__mdt
                                                        WHERE DeveloperName = 'Beverage'];
        

        CollaborationGroup collaborationGroupConstructed = TestDataFactory.ConstructCollaborationGroup();
        insert collaborationGroupConstructed;
        List<Product2> productConstructed = TestDataFactory.ConstructProducts(1);
        productConstructed[0].Family = 'Beverage';
        insert productConstructed;
        List<PricebookEntry> pricebookEntriesConstructed = TestDataFactory.ConstructPricebookEntries(productConstructed);
        insert pricebookEntriesConstructed;
        List<Account> accountsContructed = TestDataFactory.ConstructAccounts(1);
        insert accountsContructed;
        List<Contact> contactsConstructed = TestDataFactory.ConstructContacts(1, accountsContructed);
        insert contactsConstructed;
        List<Order> ordersConstructed = TestDataFactory.ConstructOrders(1, accountsContructed);
        insert ordersConstructed;
        List<OrderItem> orderItemsConstructed = TestDataFactory.ConstructOrderItems(1, pricebookEntriesConstructed, ordersConstructed);
        insert orderItemsConstructed;

        AnnouncementQueueable.doChainJob = false;
        Test.startTest();
        productConstructed[0].Quantity_Ordered__c = lowBeverageInventory.Low_Quantity_Alert__c + 1;
        update productConstructed;

        //Simulate Post
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = 'Test' + Constants.INVENTORY_LEVEL_LOW;

        ConnectApi.MessageBodyInput msgBody = new ConnectApi.MessageBodyInput();
        msgBody.messageSegments = new List<ConnectApi.TextSegmentInput>();
        msgBody.messageSegments.add(textSegmentInput);

        ConnectApi.AnnouncementInput singlePost = new ConnectApi.AnnouncementInput();
        singlePost.expirationDate = System.now().addDays(1);
        singlePost.sendEmails = false;
        singlePost.body = msgBody;
        singlePost.parentId = collaborationGroupConstructed.Id;
        toPost.add(singlePost);

        AnnouncementQueueable anqu = new AnnouncementQueueable(toPost);
        System.enqueueJob(anqu);
        Test.stopTest();

        List<FeedItem> fi = [SELECT Id FROM FeedItem LIMIT 1];

        System.assert(1 == fi.size());
    }
}