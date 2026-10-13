@EndUserText.label: 'VH Clase de documento'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@ObjectModel: {
  usageType: {
    dataClass: #ORGANIZATIONAL,
    serviceQuality: #A,
    sizeCategory: #S
  },
  dataCategory: #VALUE_HELP,
  supportedCapabilities: [
    #CDS_MODELING_ASSOCIATION_TARGET,
    #SEARCHABLE_ENTITY,
    #VALUE_HELP_PROVIDER
  ]
}
define view entity ZI_AccountingDocumentTypeStdVH
  as select from I_AccountingDocumentType as Root
  association [0..1] to I_AccountingDocumentTypeText as _Text on  Root.AccountingDocumentType = _Text.AccountingDocumentType
                                                              and _Text.Language              = 'S'
{
      @Search.defaultSearchElement: true
  key AccountingDocumentType           as AccountingDocumentType,
@UI.hidden: true
      _Text.AccountingDocumentTypeName as AccountingDocumentTypeName,
      _Text

}
