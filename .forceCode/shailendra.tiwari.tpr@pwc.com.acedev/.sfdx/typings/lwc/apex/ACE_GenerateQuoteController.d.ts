declare module "@salesforce/apex/ACE_GenerateQuoteController.getProducts" {
  export default function getProducts(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_GenerateQuoteController.getOppDetails" {
  export default function getOppDetails(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_GenerateQuoteController.getOppID" {
  export default function getOppID(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_GenerateQuoteController.updateQuote" {
  export default function updateQuote(param: {quoteId: any, quoteCharges: any, updateQuote: any, qLi: any}): Promise<any>;
}
declare module "@salesforce/apex/ACE_GenerateQuoteController.insertQuote" {
  export default function insertQuote(param: {oppId: any, quoteCharges: any, quoteLineItems: any}): Promise<any>;
}
