@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Z_I_MOV_MAT_ACC_DET'
@Metadata.ignorePropagatedAnnotations: false
define view entity Z_I_MOV_MAT_ACC_DET
  as select from    I_JournalEntryItem as _Finanzas

    left outer join I_GLAccountText    as _Cuentas    on  _Finanzas.GLAccount       = _Cuentas.GLAccount
                                                      and _Finanzas.ChartOfAccounts = _Cuentas.ChartOfAccounts
                                                      and _Cuentas.Language         = $session.system_language

    left outer join I_GLAccountText    as _CuentasAlt on  _Finanzas.AlternativeGLAccount = _CuentasAlt.GLAccount
                                                      and _Finanzas.ChartOfAccounts      = _CuentasAlt.ChartOfAccounts
                                                      and _CuentasAlt.Language           = $session.system_language
{
  key _Finanzas.ReferenceDocument           as ReferenceDocument,
  key _Finanzas.ReferenceDocumentContext    as ReferenceDocumentContext,
  key _Finanzas.CompanyCode                 as CompanyCode,

      _Finanzas.AccountingDocument          as AccountingDocument,
      _Finanzas.FiscalYear                  as FiscalYear,
      _Finanzas.GLAccount                   as GLAccount,
      _Cuentas.GLAccountName                as GLAccountName,
      _Finanzas.AlternativeGLAccount        as AlternativeGLAccount,
      _CuentasAlt.GLAccountName             as AlternativeGLAccountName,
      _Finanzas.ChartOfAccounts             as ChartOfAccounts,
      _Finanzas.CompanyCodeCurrency         as CompanyCodeCurrency,

      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Finanzas.AmountInCompanyCodeCurrency as AmountInCompanyCodeCurrency
}
where
      _Finanzas.Ledger           = '0L'
  and _Finanzas.SourceLedger     = '0L'
  and _Finanzas.LedgerGLLineItem = '000001'
