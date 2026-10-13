@Metadata.allowExtensions: true
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBL_ASING_MRKO'
}
@Metadata.ignorePropagatedAnnotations: false
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBL_ASING_MRKO
  provider contract transactional_query
  as projection on ZR_TBL_ASING_MRKO
  association [1..1] to ZR_TBL_ASING_MRKO as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,

      @Consumption.valueHelpDefinition: [{
        entity: { name : 'I_CompanyCode' , element: 'CompanyCode'},
        distinctValues: true
      }]
      Companycode,

      _companyCode.CompanyCodeName as CompanyCodeName,
      @Consumption.valueHelpDefinition: [{
        entity: { name : 'I_Supplier' , element: 'Supplier'},
        distinctValues: true
      }]
      Supplier,

      _supplier.SupplierName       as SupplierName,
      @Consumption.valueHelpDefinition: [{
        entity: { name : 'I_Plant' , element: 'Plant'},
        distinctValues: true
      }]
      Plant,
      _plant.PlantName             as PlantName,
      FolioFactura,
      FechaEmision,
      FechaContabilizacion,
      ClaseDocumento,
      ClaseDocumentoTexto,
      CondicionesPago,
      CondicionesPagoTexto,
      TextoCabecera,
      TextoPosicion,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.lastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      _BaseEntity,
      _companyCode,
      _supplier,
      _plant
}
