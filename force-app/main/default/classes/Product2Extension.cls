public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get; set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        AddRows();
    }

    public void AddRows(){
        for(Integer i = 0; i < Constants.DEFAULT_ROWS; i++)
            productsToInsert.add( new ProductWrapper() );
    }

    public List<SelectOption> GetFamilyOptions() {
        List<SelectOption> returnedFamilyOptions = new List<SelectOption>();

        returnedFamilyOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for(Schema.PicklistEntry familyOption: Constants.PRODUCT_FAMILY)
           returnedFamilyOptions.add(new SelectOption(familyOption.getLabel(), familyOption.getLabel()));

        return returnedFamilyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){

        Savepoint sp = Database.setSavePoint();
        try {
            List<Product2> products = new List<Product2>();
            List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();

            for(ProductWrapper pti: productsToInsert) {
                if(pti.productRecord != null && pti.pricebookEntryRecord != null
                    && !String.isEmpty(pti.productRecord.Name) && pti.productRecord.Family != Constants.SELECT_ONE
                    && pti.productRecord.IsActive != null && pti.pricebookEntryRecord.UnitPrice != null ) {

                    products.add(pti.productRecord);

                    PricebookEntry pbEntry = pti.pricebookEntryRecord;
                    pbEntry.IsActive = true;
                    pbEntry.UnitPrice = 10;
                    pbEntry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID; //cannot acces the constant
                    pbEntries.add(pbEntry);
                }
            }
            insert products;
            
            for(Integer i = 0; i < products.size(); i++) {
                pbEntries[i].Product2Id = products[i].Id;
            }
            insert pbEntries;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
            Database.rollback(sp);
        }
        return null;
    }

    public class ProductWrapper {
        public Product2 productRecord {get; set;}
        public PriceBookEntry pricebookEntryRecord {get; set;}

        public productWrapper() {
            productRecord = new Product2();
            pricebookEntryRecord = new PricebookEntry();
        }
    }
}