trigger AccountTrigger on Account (Before Insert ) {
    if( trigger.isBefore && trigger.isInsert  )
    {
        AccountTriggerHandler.CreateAccounts(Trigger.new);
            }
}