public with sharing class AccountHealthService {
    @AuraEnabled(cacheable=true)
    public static List<AccountSummary> getRecentAccounts(Integer requestedLimit) {
        Integer safeLimit = requestedLimit == null ? 10 : Math.max(1, Math.min(requestedLimit, 50));
        List<AccountSummary> summaries = new List<AccountSummary>();
        for (Account accountRecord : [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            ORDER BY LastModifiedDate DESC
            LIMIT :safeLimit
        ]) {
            summaries.add(new AccountSummary(accountRecord));
        }
        return summaries;
    }

    public class AccountSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String industry;
        @AuraEnabled public Decimal annualRevenue;
        public AccountSummary(Account source) {
            id = source.Id;
            name = source.Name;
            industry = source.Industry;
            annualRevenue = source.AnnualRevenue;
        }
    }
}
