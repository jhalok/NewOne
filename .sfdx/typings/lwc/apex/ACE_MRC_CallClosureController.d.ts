declare module "@salesforce/apex/ACE_MRC_CallClosureController.loadMRCDispositions" {
  export default function loadMRCDispositions(param: {serviceId: any, dispositionType: any, leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_MRC_CallClosureController.loadMRCServices" {
  export default function loadMRCServices(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_MRC_CallClosureController.closeCall" {
  export default function closeCall(param: {dispositionCode: any, nextDialTime: any, comments: any, recordId: any, dispositionId: any, subdispositionId: any}): Promise<any>;
}
