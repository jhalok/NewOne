declare module "@salesforce/apex/ACE_AccountSearch.fetchRecords" {
  export default function fetchRecords(param: {searchText: any, searchObject: any, searchOptVal: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_AccountSearch.updateLeadContact" {
  export default function updateLeadContact(param: {leadId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_AccountSearch.getLeadData" {
  export default function getLeadData(param: {Id: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_AccountSearch.fetchLeadAndContactRecords" {
  export default function fetchLeadAndContactRecords(param: {searchText: any, searchObject: any, searchOptVal: any, altSrch: any}): Promise<any>;
}
