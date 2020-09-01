declare module "@salesforce/apex/ACE_opplist.oppDataRtrv" {
  export default function oppDataRtrv(param: {pageNumber: any, pageSize: any, modelType: any, launch: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_opplist.leadDataRtrv" {
  export default function leadDataRtrv(param: {pageNumber: any, pageSize: any, modelType: any, launch: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_opplist.searchForIds" {
  export default function searchForIds(param: {searchText: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_opplist.changeOwnerMethod" {
  export default function changeOwnerMethod(param: {oppid: any, userName: any}): Promise<any>;
}
