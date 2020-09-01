declare module "@salesforce/apex/ACE_Assignagent.getUsers" {
  export default function getUsers(): Promise<any>;
}
declare module "@salesforce/apex/ACE_Assignagent.getAccountList" {
  export default function getAccountList(param: {accountName: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_Assignagent.assignUser" {
  export default function assignUser(param: {accountRecordId: any, useID: any}): Promise<any>;
}
