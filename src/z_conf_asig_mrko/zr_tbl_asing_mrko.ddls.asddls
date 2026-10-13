@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBL_ASING_MRKO'
@EndUserText.label: 'Asignacion de valores MKRO'
define root view entity ZR_TBL_ASING_MRKO
  as select from ztbl_asing_mrko
  association [0..1] to I_CompanyCode as _companyCode on $projection.Companycode = _companyCode.CompanyCode
  association [0..1] to I_Supplier    as _supplier    on $projection.Supplier = _supplier.Supplier
  association [0..1] to I_Plant       as _plant       on $projection.Plant = _plant.Plant

{
  key uuid                  as UUID,

      companycode           as Companycode,
      supplier              as Supplier,
      plant                 as Plant,
      folio_factura         as FolioFactura,
      fecha_emision         as FechaEmision,
      fecha_contabilizacion as FechaContabilizacion,
      @Consumption.valueHelpDefinition: [
       {
         entity: {
           name: 'ZI_AccountingDocumentTypeStdVH',
           element: 'AccountingDocumentType'
         }
        }
       ]
      clase_documento       as ClaseDocumento,
      clase_documentotexto  as ClaseDocumentoTexto,

      @Consumption.valueHelpDefinition: [
      {
      entity: {
       name: 'ZI_PaymentTermsVHTemp',
       element: 'PaymentTerms'
      }}
      ]
      condiciones_pago      as CondicionesPago,
      condiciones_pagotexto as CondicionesPagoTexto,
      texto_cabecera        as TextoCabecera,
      texto_posicion        as TextoPosicion,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _companyCode,
      _supplier,
      _plant
}
