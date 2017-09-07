trigger BackendIntgrationReq on Backend_Integration__e (after Insert) {

    
    system.debug(trigger.new);

}