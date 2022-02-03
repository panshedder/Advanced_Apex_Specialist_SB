/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup collGroup = new CollaborationGroup();
        collGroup.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        collGroup.CollaborationType = 'Public';

        return collGroup;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> products = new List<Product2>();
        List<String> productFamilies = new List<String>();

        for(Schema.PicklistEntry familyOption: Constants.PRODUCT_FAMILY)
            productFamilies.add(familyOption.getValue());

        for(Integer i = 0; i < cnt; i++) {
            Product2 product = new Product2();
            product.Name = 'Test' + i;
            product.IsActive = true;
            product.Initial_Inventory__c = 10;
            product.Family = productFamilies[Math.mod(i, productFamilies.size())];
            products.add(product);
        }
        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();

        for(Product2 prod: prods) {
            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.IsActive = true;
            pbEntry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            pbEntry.Product2Id = prod.Id;
            pbEntry.UnitPrice = 10;

            pbEntries.add(pbEntry);
        }
        return pbEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < cnt; i++) {
            Account account = new Account();
            account.Name = 'Test ' + i + ' ' + System.today() + 'at ' + System.now();
            accounts.add(account);
        }
        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> newContacts = new List<Contact>();
        for(Integer i = 0; i < cnt; i++) {
            Contact contact = new Contact();
            contact.LastName = 'Test ' + i + ' ' + System.today() + 'on ' + System.now();
            contact.AccountId = accts[Math.mod(i, accts.size())].Id;

            newContacts.add(contact);
        }
        return newContacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> newOrders = new List<Order>();

        for(Integer i = 0; i < cnt; i++) {
            Order order = new Order();
            order.AccountId = accts[Math.mod(i, accts.size())].Id;
            order.Status = 'Draft';
            order.EffectiveDate = System.today();
            order.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            newOrders.add(order);
        }
        return newOrders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> newOrdersItems = new List<OrderItem>();

        for(Integer i = 0; i < cnt; i++) {
            OrderItem orderItem = new orderItem();
            orderItem.OrderId = ords[Math.mod(i, ords.size())].Id;
            orderItem.Quantity = Constants.DEFAULT_ROWS;
            orderItem.PricebookEntryId = pbes[Math.mod(i, pbes.size())].Id;
            orderItem.UnitPrice = 10;
            newOrdersItems.add(orderItem);
        }
        
        return newOrdersItems;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
     **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup collaborationGroupConstructed = ConstructCollaborationGroup();
        insert collaborationGroupConstructed;
        List<Product2> productConstructed = ConstructProducts(cnt);
        insert productConstructed;
        List<PricebookEntry> pricebookEntriesConstructed = ConstructPricebookEntries(productConstructed);
        insert pricebookEntriesConstructed;
        List<Account> accountsContructed = ConstructAccounts(cnt);
        insert accountsContructed;
        List<Contact> contactsConstructed = ConstructContacts(cnt, accountsContructed);
        insert contactsConstructed;
        List<Order> ordersConstructed = ConstructOrders(cnt, accountsContructed);
        insert ordersConstructed;
        List<OrderItem> orderItemsConstructed = ConstructOrderItems(cnt, pricebookEntriesConstructed, ordersConstructed);
        insert orderItemsConstructed;
    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals(qtyOrdered, updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c);
    }
}