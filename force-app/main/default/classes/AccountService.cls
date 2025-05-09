public with sharing class AccountService {

    // public class AccountValidationResult{
    //     public Account account;
    //     public List<String> missingFields;
    //     public Boolean success;
    //     public String errorMessage;
    // }

    // public static AccountValidationResult getAccountWithValidation(Id accountId, OrderResponseWrapper.Customer customer){
    //     AccountValidationResult result = new AccountValidationResult();
    //     result.success =false;
    //     result.missingfields = new List<String>();

    //     if(customer == null){
    //         return errorResult(result, 'Customer information is missing');
    //     }


    //     try{
    //         Account foundAccount = findAccountByIdOrEmail(accountId, customer, result);

    //         if(foundAccount == null){
    //             if(!isValidCustomer(customer, result)){
    //                 return errorResult(result , 'Missing required customer fields');
    //         }
    //     }
         
    //         foundAccount = createNewAccount(customer);
    //         if(foundAccount == null){
    //             return errorResult(result, 'Internal server error: could not create account');
    //         }

    //         result.account = foundAccount;
    //         result.success = true;


    //     }catch(Exception ex){
    //         return errorResult(result, 'Exception: ' + ex.getMessage());
    //     }
    //     return result;
        
    // }

    // public AccountValidationResult errorResult(AccountValidationResult result, String errorM){
    //     result.success = false;
    //     result.errorMessage = errorM;
    //     return result;
    // }
    // private static Boolean validateFields(Map<String, String> fields, List<String> missingFields) {
    //     for (String key : fields.keySet()) {
    //         if (String.isBlank(fields.get(key))) {
    //             missingFields.add(key);
    //         }
    //     }
    //     return missingFields.isEmpty();
    // }
    

    // public Boolean isValidCustomer(OrderResponseWrapper.Customer customer, AccountValidationResult result){
    //     Map<String, String> customerFields = new Map<String, String>{
    //         'firstName' => customer.firstName,
    //         'lastName'  => customer.lastName,
    //         'email'     => customer.email
    //     };
    
    //     Boolean isCustomerValid = validateFields(customerFields, result.missingFields);
    
        
    //     if (customer.shippingAddress != null) {
    //         Map<String, String> shippingFields = new Map<String, String>{
    //             'shippingStreet'     => customer.shippingAddress.street,
    //             'shippingCity'       => customer.shippingAddress.city,
    //             'shippingPostalCode' => customer.shippingAddress.postalCode,
    //             'shippingCountry'    => customer.shippingAddress.country
    //         };
    
    //         validateFields(shippingFields, result.missingFields);
    //     }
    
    //     return result.missingFields.isEmpty();
    // }

    // private static Account findAccountByIdOrEmail(Id accountId, OrderResponseWrapper.Customer customer,AccountValidationResult result) {
         
    //     Account acc;

    //     if(!Account.SObjectType.getDescribe().isAccessible()){
    //         return errorResult(result, 'Internal server error: Account object not accessible');
    //     }
        
    //     if (accountId != null) {
    //         List<Account> byId = [
    //             SELECT Id, Name, PersonEmail, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, FirstName, LastName, Phone
    //             FROM Account
    //             WHERE Id = :accountId AND IsPersonAccount = true
    //             LIMIT 1
    //         ];
    //         if (!byId.isEmpty()) {
    //             return byId[0];
    //         }
    //     }

    //     if (String.isNotBlank(customer.email)) {
    //         List<Account> byEmail = [
    //             SELECT Id, Name, PersonEmail, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry,FirstName, LastName, Phone
    //             FROM Account
    //             WHERE PersonEmail = :customer.email AND IsPersonAccount = true
    //             LIMIT 1
    //         ];
    //         if (!byEmail.isEmpty()){ 
    //             return byEmail[0];
    //         }
    //     }

    //     return null;
    // }
   
    // private static Account createNewAccount(OrderResponseWrapper.Customer customer) {
    //     Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
    //     if (!recordTypes.containsKey('PersonAccount')) {return null;}

    //     OrderResponseWrapper.ShippingAddress sa = customer.shippingAddress;

    //     Account acc = new Account();
    //     acc.FirstName = customer.firstName;
    //     acc.LastName = customer.lastName;
    //     acc.PersonEmail = customer.email;
    //     acc.Phone = customer.phone;
    //     acc.RecordTypeId = recordTypes.get('PersonAccount').getRecordTypeId();

    //     if (sa != null) {
    //         acc.ShippingStreet = sa.street;
    //         acc.ShippingCity = sa.city;
    //         acc.ShippingPostalCode = sa.postalCode;
    //         acc.ShippingCountry = sa.country;
    //     }

    //     Database.SaveResult sr = Database.insert(acc, false);
    //     return sr.isSuccess() ? acc : null;
    // }





//another code


    // public class AccountValidationResult {
    //     public Account account;
    //     public List<String> missingFields;
    //     public Boolean success;
    //     public String errorMessage;
    // }

    // public static AccountValidationResult getAccountByIdWithValidation(Id accountId, OrderResponseWrapper.Customer customer) {
    //     AccountValidationResult result = new AccountValidationResult();
    //     result.success = false;
    //     result.missingFields = new List<String>();

    //     if (customer == null) {
    //         return errorResult(result, 'Customer information is missing.');
    //     }

    //     if (!Account.SObjectType.getDescribe().isAccessible()) {
    //         return errorResult(result, 'Internal server error: Account object not accessible.');
    //     }

    //     try {
    //         Account foundAccount = findAccountByIdOrEmail(accountId, customer);

    //         if (foundAccount == null) {
    //             if (!isValidCustomer(customer, result)) {
    //                 return errorResult(result, 'Missing required customer fields.');
    //             }

    //             foundAccount = createNewAccount(customer);
    //             if (foundAccount == null) {
    //                 return errorResult(result, 'Internal server error: Could not create account.');
    //             }
    //         }

    //         result.account = foundAccount;
    //         result.success = true;

    //     } catch (Exception ex) {
    //         return errorResult(result, 'Exception: ' + ex.getMessage());
    //     }

    //     return result;
    // }



    // private static Boolean isValidCustomer(OrderResponseWrapper.Customer customer, AccountValidationResult result) {
    //     if (String.isBlank(customer.firstName)){ 
    //         result.missingFields.add('firstName');
    //     }
    //     if (String.isBlank(customer.lastName)){
    //          result.missingFields.add('lastName');
    //         }
    //     if (String.isBlank(customer.email)){ 
    //         result.missingFields.add('email');
    //     }
    //     return result.missingFields.isEmpty();
    // }

    

    // private static AccountValidationResult errorResult(AccountValidationResult result, String message) {
    //     result.success = false;
    //     result.errorMessage = message;
    //     return result;
    // }
  
}
