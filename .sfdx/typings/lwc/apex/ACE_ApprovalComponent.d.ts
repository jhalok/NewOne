declare module "@salesforce/apex/ACE_ApprovalComponent.approvals1" {
  export default function approvals1(): Promise<any>;
}
declare module "@salesforce/apex/ACE_ApprovalComponent.approveLead" {
  export default function approveLead(param: {recId: any, approvalIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ApprovalComponent.rejectLead" {
  export default function rejectLead(param: {recId: any, rejectIds: any}): Promise<any>;
}
