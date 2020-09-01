declare module "@salesforce/apex/ACE_PI_PrioritizationController.getLeadRecord" {
  export default function getLeadRecord(param: {leadId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_PI_PrioritizationController.getExistingProducts" {
  export default function getExistingProducts(param: {Id: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_PI_PrioritizationController.updateProductInterest" {
  export default function updateProductInterest(param: {allProductInterests: any, editedPIList: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_PI_PrioritizationController.createProductInterestRecord" {
  export default function createProductInterestRecord(param: {selectedProduct: any, currentLead: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_PI_PrioritizationController.saveInterests" {
  export default function saveInterests(param: {productInterests: any}): Promise<any>;
}
