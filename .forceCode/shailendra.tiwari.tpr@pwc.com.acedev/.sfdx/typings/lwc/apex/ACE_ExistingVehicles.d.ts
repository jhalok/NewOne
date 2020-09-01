declare module "@salesforce/apex/ACE_ExistingVehicles.saveExistingRecord" {
  export default function saveExistingRecord(param: {allrecords: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.getLeadRecord" {
  export default function getLeadRecord(param: {Id: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.getExistingVehicle" {
  export default function getExistingVehicle(param: {Id: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.deleteExistingVehicle" {
  export default function deleteExistingVehicle(param: {vehicleId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.getAllCompetitorsList" {
  export default function getAllCompetitorsList(param: {LeadId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.dataUpdate" {
  export default function dataUpdate(param: {dataUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.makeModelMap" {
  export default function makeModelMap(): Promise<any>;
}
declare module "@salesforce/apex/ACE_ExistingVehicles.getAllModel" {
  export default function getAllModel(param: {make: any}): Promise<any>;
}
