declare module "@salesforce/apex/ACE_leadlist.unAssignedOppData" {
  export default function unAssignedOppData(): Promise<any>;
}
declare module "@salesforce/apex/ACE_leadlist.unAssignedLeadData" {
  export default function unAssignedLeadData(): Promise<any>;
}
declare module "@salesforce/apex/ACE_leadlist.searchForIds" {
  export default function searchForIds(param: {searchText: any, objectType: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_leadlist.changeOwnerMethod" {
  export default function changeOwnerMethod(param: {oppid: any, userName: any}): Promise<any>;
}
