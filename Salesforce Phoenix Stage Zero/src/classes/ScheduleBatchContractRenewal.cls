global class ScheduleBatchContractRenewal implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchContractRenewal batch = new BatchContractRenewal();
        Database.executeBatch(batch,500);
    }
}