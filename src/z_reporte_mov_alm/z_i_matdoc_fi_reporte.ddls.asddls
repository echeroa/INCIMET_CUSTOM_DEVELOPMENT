@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte de Mov. Almacen con Asiento Contable'
@Metadata.ignorePropagatedAnnotations: false
//@EnterpriseSearch.enabled: true
@Search.searchable: true
//@Analytics.query: true

@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity Z_I_MATDOC_FI_REPORTE
  as select from    Z_I_MATDOC_HELPER  as _Logistica

    left outer join I_JournalEntryItem as _Finanzas     on  _Logistica.MaterialDocument       = _Finanzas.ReferenceDocument
                                                        and _Logistica.MaterialDocumentYear   = _Finanzas.ReferenceDocumentContext
                                                        and _Logistica.MaterialDocumentItem_6 = _Finanzas.ReferenceDocumentItem
                                                        and _Finanzas.Ledger                  = '0L'

    left outer join I_GLAccountText    as _Cuentas      on  _Finanzas.GLAccount       = _Cuentas.GLAccount
                                                        and _Finanzas.ChartOfAccounts = _Cuentas.ChartOfAccounts
                                                        and _Cuentas.Language         = $session.system_language

    left outer join I_GLAccountText    as _CuentasAlt   on  _Finanzas.AlternativeGLAccount = _CuentasAlt.GLAccount
                                                        and _Finanzas.ChartOfAccounts      = _CuentasAlt.ChartOfAccounts
                                                        and _CuentasAlt.Language           = $session.system_language

  /* Unimos con las descripciones de los materiales (Version liberada para Cloud) */
    left outer join I_ProductText      as _MaterialText on  _Logistica.Material    = _MaterialText.Product
                                                        and _MaterialText.Language = $session.system_language
{
      /* --- Configuracion de la Object Page (Pagina de Detalle) --- */
      @UI.facet: [
      {
            id:              'GeneralCollection',
            type:            #COLLECTION,
            label:           'Información del Documento',
            position:        10
        },
        {
            id:              'GrupoLogistica',
            type:            #FIELDGROUP_REFERENCE,

            parentId:        'GeneralCollection',
            targetQualifier: 'LogisticaGroup',
            position:        10
        },
        {
            id:              'GrupoFinanzas',
            type:            #FIELDGROUP_REFERENCE,

            parentId:        'GeneralCollection',
            targetQualifier: 'FinanzasGroup',
            position:        20
        }
      ]
      @Search.defaultSearchElement: true

            /* --- Campos de Logistica --- */
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem:       [{ position: 10 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      @UI.identification: [{ position: 10 }] // Esto hace que se vea en el detalle
      @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: true }
  key _Logistica.MaterialDocument           as DocumentoMaterial,

      @UI.lineItem:       [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 20 }]
  key _Logistica.MaterialDocumentYear       as AnioDocumento,

      @UI.lineItem:       [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 30 }]
  key _Logistica.MaterialDocumentItem       as Posicion,

  key _Finanzas.AccountingDocument          as AsientoContable,


  key _Finanzas.GLAccount                   as CuentaContable,
      @Search.defaultSearchElement: true

           /* --- Descripciones --- */
      @UI.lineItem:       [{ position: 45 }]
      @UI.identification: [{ position: 45 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 60 }]
      _Cuentas.GLAccountName                as DescripcionCuenta,
      @Search.defaultSearchElement: true

      @UI.lineItem:       [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 70 }]
      _Finanzas.AlternativeGLAccount        as CuentaAlternativa,

      /* --- Material con Nombre --- */
      @Search.defaultSearchElement: true

      @UI.selectionField: [{ position: 40 }]
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 80 }]
      _Logistica.Material                   as CodigoMaterial,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8   // <-- Agrega esto para textos
      @UI.selectionField: [{ position: 45 }]
      @UI.lineItem:       [{ position: 65 }]
      @UI.identification: [{ position: 65 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 90 }]
      _MaterialText.ProductName             as NombreMaterial,

      @UI.selectionField: [{ position: 50 }]
      @UI.lineItem:       [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 100 }]
      _Logistica.Plant                      as Centro,

      @UI.selectionField: [{ position: 60 }]
      @UI.identification: [{ position: 80 }]
      @UI.lineItem:       [{ position: 80 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 110 }]

      _Logistica.GoodsMovementType          as ClaseMovimiento,


      /* --- Campos de Finanzas (Importes y Fechas) --- */

      @UI.lineItem: [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Moneda'
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 120 }]
      _Finanzas.AmountInCompanyCodeCurrency as Importe,

      @UI.lineItem: [{ position: 95 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 130 }]
      _Finanzas.CompanyCodeCurrency         as Moneda,
      @UI.selectionField: [{ position: 70 }]
      @UI.lineItem:       [{ position: 100 }]
      @UI.identification: [{ position: 100 }]
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 140 }]
      _Logistica.PostingDate                as FechaContabilizacion,


      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 150 }]
      _Logistica.StorageLocation,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 160 }]
      _Logistica.StorageType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 170 }]
      _Logistica.StorageBin,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 180 }]
      _Logistica.Batch,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 190 }]
      _Logistica.ShelfLifeExpirationDate,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 200 }]
      _Logistica.ManufactureDate,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 210 }]
      _Logistica.Supplier,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 220 }]
      _Logistica.SalesOrder,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 230 }]
      _Logistica.SalesOrderItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 240 }]
      _Logistica.SalesOrderScheduleLine,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 250 }]
      _Logistica.WBSElementInternalID,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 260 }]
      _Logistica.Customer,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 270 }]
      _Logistica.InventorySpecialStockType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 280 }]
      _Logistica.InventoryStockType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 290 }]
      _Logistica.StockOwner,


      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 300 }]
      _Logistica.DebitCreditCode,
      _Logistica.InventoryUsabilityCode,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 310 }]
      _Logistica.QuantityInBaseUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 320 }]
      _Logistica.MaterialBaseUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 330 }]
      _Logistica.QuantityInEntryUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 340 }]
      _Logistica.EntryUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 350 }]
      _Logistica.DocumentDate,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 360 }]
      _Logistica.ReservationItemRecordType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 370 }]
      _Logistica.TotalGoodsMvtAmtInCCCrcy,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 380 }]
      _Logistica.CompanyCodeCurrency,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 390 }]
      _Logistica.InventoryValuationType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 400 }]
      _Logistica.ReservationIsFinallyIssued,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.PurchaseOrder,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.PurchaseOrderItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ProjectNetwork,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.OrderID,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.OrderItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaintOrderRoutingNumber,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaintOrderOperationCounter,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.Reservation,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ReservationItem,
      _Logistica.DeliveryDocument,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.DeliveryDocumentItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ReversedMaterialDocumentYear,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ReversedMaterialDocument,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ReversedMaterialDocumentItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.RvslOfGoodsReceiptIsAllowed,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GoodsRecipientName,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GoodsMovementReasonCode,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.UnloadingPointName,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.CostCenter,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GLAccount,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ServicePerformer,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.PersonWorkAgreement,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.AccountAssignmentCategory,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.WorkItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ServicesRenderedDate,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssgOrRcvgMaterial,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssuingOrReceivingPlant,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssuingOrReceivingStorageLoc,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssgOrRcvgBatch,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssgOrRcvgSpclStockInd,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssuingOrReceivingValType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.CompanyCode,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.BusinessArea,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ControllingArea,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.FiscalYearPeriod,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.FiscalYearVariant,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GoodsMovementRefDocType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IsCompletelyDelivered,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaterialDocumentItemText,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IsAutomaticallyCreated,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.SerialNumbersAreCreatedAutomly,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GoodsReceiptType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ConsumptionPosting,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MultiAcctAssgmtOriglMatlDocItm,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MultipleAccountAssignmentCode,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GoodsMovementIsCancelled,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.IssuingOrReceivingStockType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ManufacturingOrder,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ManufacturingOrderItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaterialDocumentLine,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaterialDocumentParentLine,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.SpecialStockIdfgSalesOrder,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.SpecialStockIdfgSalesOrderItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.SpecialStockIdfgWBSElement,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.QtyInPurchaseOrderPriceUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.OrderPriceUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.QuantityInDeliveryQtyUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.DeliveryQuantityUnit,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ProfitCenter,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ProductStandardID,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.GdsMvtExtAmtInCoCodeCrcy,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.ReferenceDocumentFiscalYear,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.InvtryMgmtReferenceDocument,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.InvtryMgmtRefDocumentItem,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.EWMWarehouse,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.EWMStorageBin,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.MaterialDocumentPostingType,
      @UI.fieldGroup:     [{ qualifier: 'FinanzasGroup', position: 10 }]
      _Logistica.OriginalMaterialDocumentItem


}
/* Filtro tecnico para no ver doble en traslados 301 */
where
     _Logistica.DebitCreditCode   =  'H'
  or _Logistica.GoodsMovementType <> '301' //MATDOC (Salida 'H' y Entrada 'S')
