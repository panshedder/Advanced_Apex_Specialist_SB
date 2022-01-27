/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
        }
    }
}