@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Projection Reporte Mov Alm'
@Metadata.ignorePropagatedAnnotations: false
//@Analytics.query: true
define transient view entity Z_P_MATDOC_FI_REPORTE
  provider contract analytical_query
  as projection on Z_I_MATDOC_FI_REPORTE
{
  /* --- Campos de Logistica --- */
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem:       [{ position: 10 }]
  @UI.identification: [{ position: 10 }] // Esto hace que se vea en el detalle
  @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: true }

  DocumentoMaterial,
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: true }

  AnioDocumento,
  Posicion,
  AsientoContable,
  CuentaContable,
  DescripcionCuenta,
  CuentaAlternativa,
  CodigoMaterial,
  NombreMaterial,
  Centro,
  ClaseMovimiento,
  @Semantics.amount.currencyCode: 'Moneda'
  Importe,
  Moneda,
  FechaContabilizacion
}
