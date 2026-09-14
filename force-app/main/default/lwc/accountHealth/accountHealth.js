import { LightningElement, wire } from 'lwc';
import getRecentAccounts from '@salesforce/apex/AccountHealthService.getRecentAccounts';

const COLUMNS = [
  { label: 'Account', fieldName: 'name' },
  { label: 'Industry', fieldName: 'industry' },
  { label: 'Annual Revenue', fieldName: 'annualRevenue', type: 'currency' }
];

export default class AccountHealth extends LightningElement {
  columns = COLUMNS;
  accounts;
  error;

  @wire(getRecentAccounts, { requestedLimit: 10 })
  wiredAccounts({ data, error }) {
    this.accounts = data;
    this.error = error;
  }

  get errorMessage() {
    return this.error?.body?.message || 'Unable to load accounts.';
  }
}
