@IsTest
private class AccountHealthServiceTest {
    @TestSetup
    static void setupData() {
        insert new List<Account>{
            new Account(Name='Acme Demo', Industry='Technology', AnnualRevenue=1000000),
            new Account(Name='Globex Demo', Industry='Retail', AnnualRevenue=500000)
        };
    }

    @IsTest
    static void returnsAccounts() {
        Test.startTest();
        List<AccountHealthService.AccountSummary> result = AccountHealthService.getRecentAccounts(10);
        Test.stopTest();
        System.assertEquals(2, result.size());
        System.assertNotEquals(null, result[0].id);
    }

    @IsTest
    static void handlesNullLimit() {
        Test.startTest();
        List<AccountHealthService.AccountSummary> result = AccountHealthService.getRecentAccounts(null);
        Test.stopTest();
        System.assertEquals(2, result.size());
    }
}
