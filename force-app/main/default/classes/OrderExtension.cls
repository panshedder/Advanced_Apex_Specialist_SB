/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
 **/
public class OrderExtension {
    
    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    
    public Map<Id,OrderItem> orderItemMap;

    ApexPages.StandardSetController standardSetController;
    
    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        populateStdSetController();
        total = 0;
        for(OrderItem oi: orderRecord.OrderItems) {
            orderItemMap.put(oi.Product2Id, oi);
            if(oi.Quantity > 0) {
                if(pieData == null) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total += oi.UnitPrice * oi.Quantity;
            }
        }
        PopulateOrderItemList();
    }
    
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void populateStdSetController() {
        List<PricebookEntry> pbe;
        if(selectedFamily == Constants.SELECT_ONE || String.isBlank(selectedFamily)) {
            pbe = [SELECT Id, Name, Product2Id, UnitPrice, Product2.Name, Product2.Family 
            FROM PriceBookEntry 
            WHERE IsActive = true
            ORDER BY Name];
        } else {
            pbe = [SELECT Id, Name, Product2Id, UnitPrice, Product2.Name, Product2.Family 
            FROM PriceBookEntry
            WHERE IsActive = true AND Product2.Family = :selectedFamily
            ORDER BY Name];
        }
                
        standardSetController = new ApexPages.StandardSetController(pbe);
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    public void PopulateOrderItemList() {
        orderItemList = new List<OrderItem>();
        for(SObject sOb: standardSetController.getRecords()) {
            PricebookEntry pbe = (PricebookEntry) sOb;
            
            if(orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            } else {
                OrderItem orderItem = new OrderItem(
                    PriceBookEntryId = pbe.Id,
                    Product2Id = pbe.Product2Id,
                    UnitPrice = pbe.UnitPrice,
                    Quantity = 0,
                    Product2 = pbe.Product2
                    );
                orderItemList.add(orderItem);
                orderItemMap.put(pbe.Product2Id, orderItem);
                }
            }
        }
        
        public void LoadChartData() { //Desglosar
            this.total = 0;
            pieData = new List<ChartHelper.ChartData>();
            for(OrderItem oi: orderRecord.OrderItems) {
                if(oi.Quantity > 0) {
                    pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));

                total += oi.UnitPrice * oi.Quantity;
            }
        }
    }
    
    /**
     * @name OnFieldChange
     * @description
     **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        for(OrderItem oi: orderItemList) {
            orderItemMap.put(oi.Product2Id, oi);
        }
        //      and populate pieData
        //      and populate total
        LoadChartData();
    }
    
    /**
     * @name SelectFamily
     * @description
     **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        populateStdSetController();
        PopulateOrderItemList();
    }
    
    /**
     * @name Save
     * @description
     **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        List<OrderItem> orderItemsToSave = new List<OrderItem>();
        List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        
        System.Savepoint sp = Database.setSavepoint();
        try {
            if(orderRecord.Pricebook2Id == null)
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;

            upsert orderRecord;
            
            for(OrderItem oi: orderItemMap.values()) {
                if(oi.Quantity > 0) {
                    if(oi.OrderId == null) {
                        oi.OrderId = orderRecord.Id;
                    }
                    orderItemsToSave.add(oi);
                } else if(oi.Id != null){
                    orderItemsToDelete.add(new OrderItem(Id = oi.Id));
                    oi.Id = null;
                }
            }
            
            upsert orderItemsToSave;
            delete orderItemsToDelete;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        
    }
    
    /**
     * @name First
     * @description
     **/
    public void First(){
        standardSetController.first();
        PopulateOrderItemList();
    }
    
    /**
     * @name Next
     * @description
     **/
    public void Next(){
        standardSetController.next();
        PopulateOrderItemList();
    }
    
    /**
     * @name Previous
     * @description
     **/
    public void Previous(){
        standardSetController.previous();
        PopulateOrderItemList();
    }
    
    /**
     * @name Last
     * @description
     **/
    public void Last(){
        standardSetController.last();
        PopulateOrderItemList();
    }
    
    /**
     * @name GetHasPrevious
     * @description
     **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }
    
    /**
     * @name GetHasNext
     * @description
     **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }
    
    /**
     * @name GetTotalPages
     * @description
     **/
    public Integer GetTotalPages(){
        return (Integer) Math.ceil(standardSetController.getResultSize()/(Decimal) Constants.DEFAULT_ROWS);
    }
    
    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> returnedFamilyOptions = new List<SelectOption>();

        returnedFamilyOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for(Schema.PicklistEntry familyOption: Constants.PRODUCT_FAMILY)
           returnedFamilyOptions.add(new SelectOption(familyOption.getLabel(), familyOption.getLabel()));

        return returnedFamilyOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }
}