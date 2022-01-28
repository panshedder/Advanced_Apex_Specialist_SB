public class Product2Extension {

    //public List<Product2> productsToInsert {get;set;}
    public List<ProductWrapper> productsToInsert {get; set;}

    public Product2Extension(){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
            productsToInsert.add( new ProductWrapper() );
        }
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
        try {
            List<Product2> products = new List<Product2>();
            List<PriceBookEntry> pbEntries = new List<PriceBookEntry>();

            for(ProductWrapper pti: productsToInsert) {
                if(pti.productRecord != null && pti.pricebookEntryRecord != null) {
                    products.add(pti.productRecord);

                    pti.pricebookEntryRecord.IsActive = true;
                    pti.pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    
                    pbEntries.add(pti.pricebookEntryRecord);
                }
            }
            insert products;

            for(Integer i = 0; i < products.size(); i++) {
                pbEntries[i].Product2Id = products[i].Id;
            }
            insert pbEntries;

            //insert productsToInsert;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){

        }
        return null;
    }

    class ProductWrapper {
        Product2 productRecord;
        PriceBookEntry pricebookEntryRecord;
    }
}