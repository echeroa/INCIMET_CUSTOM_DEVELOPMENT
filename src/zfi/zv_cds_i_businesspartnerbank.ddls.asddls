@AbapCatalog.sqlViewName: 'ZV_CDS_I_BP_BANK'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Partner Bank'
define view ZV_CDS_I_BUSINESSPARTNERBANK as select from I_BusinessPartnerBank
{
  key BusinessPartner,
  key BankIdentification,
      BankControlKey,
      BankNumber,
//      BankAccountReferenceText, //-vchero 09.06.2026
      BankAccountName, //+vchero 09.06.2026
      BusinessPartnerExternalBankID,
      BankAccount
}
