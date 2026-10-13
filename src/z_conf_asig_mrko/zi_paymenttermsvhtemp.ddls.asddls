@EndUserText.label: 'VH Condiciones de pago'
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
define view entity ZI_PaymentTermsVHTemp
  as select from I_PaymentTerms as Root
  association [0..1] to I_PaymentTermsText as _Text on  Root.PaymentTerms = _Text.PaymentTerms
                                                    and _Text.Language    = 'S'
{

       @Search.defaultSearchElement: true

  key  Root.PaymentTerms      as PaymentTerms,
       _Text.PaymentTermsName as PaymentTermsName,
       _Text
}
