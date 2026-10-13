@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Z_I_MOV_MAT_ACC_AUX'
@Metadata.ignorePropagatedAnnotations: false
define view entity Z_I_MOV_MAT_ACC_AUX
  as select from I_JournalEntryItem
{
  key ReferenceDocument,
  key ReferenceDocumentContext,
  key CompanyCode,

      min( AccountingDocument )                            as AccountingDocument,
      min( FiscalYear )                                    as FiscalYear,
      cast( min( GLAccount )            as abap.char(10) ) as GLAccountAux,
      cast( min( AlternativeGLAccount ) as abap.char(10) ) as AlternativeGLAccountAux,
      cast( min( ChartOfAccounts )      as abap.char(4) )  as ChartOfAccountsAux
}
where
      Ledger       = '0L'
  and SourceLedger = '0L'
group by
  ReferenceDocument,
  ReferenceDocumentContext,
  CompanyCode
