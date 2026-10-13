@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte de Movimiento de almacen (Cubo)'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true

/* --- ESTA ES LA ANOTACIÓN PRINCIPAL PARA HACERLO ANALÍTICO --- */
@Analytics.dataCategory: #CUBE
@Search.searchable: true
define view entity Z_C_MOVIMIENTO_MATERIAL_Q
  as select from    I_MaterialDocumentItem_2   as _Logistica

    left outer join I_JournalEntryItem         as _Finanzas     on  _Logistica.MaterialDocument     = _Finanzas.ReferenceDocument
                                                                and _Logistica.MaterialDocumentYear = _Finanzas.ReferenceDocumentContext
                                                                and _Logistica.CompanyCode          = _Finanzas.CompanyCode

    left outer join I_GLAccountText            as _Cuentas      on  _Finanzas.GLAccount       = _Cuentas.GLAccount
                                                                and _Finanzas.ChartOfAccounts = _Cuentas.ChartOfAccounts
                                                                and _Cuentas.Language         = $session.system_language

    left outer join I_GLAccountText            as _CuentasAlt   on  _Finanzas.AlternativeGLAccount = _CuentasAlt.GLAccount
                                                                and _Finanzas.ChartOfAccounts      = _CuentasAlt.ChartOfAccounts
                                                                and _CuentasAlt.Language           = $session.system_language

    /* Descripciones de los materiales */
    left outer join I_ProductText              as _MaterialText on  _Logistica.Material    = _MaterialText.Product
                                                                and _MaterialText.Language = $session.system_language
    
    /* Cabecera del documento de material */
    left outer join I_MaterialDocumentHeader_2 as _Header       on  _Logistica.MaterialDocumentYear = _Header.MaterialDocumentYear
                                                                and _Logistica.MaterialDocument     = _Header.MaterialDocument                                                              

    /* Datos maestros del material */
    left outer join I_Product                  as _DatosMaterial on _Logistica.Material = _DatosMaterial.Product

    /* NUEVO JOIN: Para obtener el Texto de posición del pedido de compras (Versión Liberada API) */
    left outer join I_PurchaseOrderItemAPI01   as _PedidoCompras on  _Logistica.PurchaseOrder     = _PedidoCompras.PurchaseOrder
                                                                 and _Logistica.PurchaseOrderItem = _PedidoCompras.PurchaseOrderItem
    
{
      /* --- Campos Clave --- */
      @UI.facet: [
      { id: 'GeneralCollection', type: #COLLECTION, label: 'Información del Documento', position: 10 },
      { id: 'GrupoLogistica', type: #FIELDGROUP_REFERENCE, parentId: 'GeneralCollection', targetQualifier: 'LogisticaGroup', position: 10 },
      { id: 'GrupoFinanzas', type: #FIELDGROUP_REFERENCE, parentId: 'GeneralCollection', targetQualifier: 'FinanzasGroup', position: 20 }
      ]
      @Search.defaultSearchElement: true

      /* --- Llaves y Logística Básica --- */
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 10 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 10 }]
      @UI.identification: [{ position: 10 }]
      @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: true }
  key _Logistica.MaterialDocument                as DocumentoMaterial,

      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 20 }]
  key _Logistica.MaterialDocumentYear            as AnioDocumento,

      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 30 }]
  key _Logistica.MaterialDocumentItem            as Posicion,

      /* --- Llaves Finanzas (Evitando NULLs) --- */
      @EndUserText.label: 'Asiento Contable'
  key coalesce(_Finanzas.AccountingDocument, '') as AsientoContable,
      @EndUserText.label: 'Cuenta Contable'
  key coalesce(_Finanzas.GLAccount, '')          as CuentaContable,

      /* --- Descripciones --- */
      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 45 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 60 }]
      _Cuentas.GLAccountName                     as DescripcionCuenta,

      @UI.lineItem: [{ position: 50 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 70 }]
      _Finanzas.AlternativeGLAccount             as CuentaAlternativa,

      /* --- Material --- */
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 40 }]
      @UI.lineItem: [{ position: 60 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 80 }]
      _Logistica.Material                        as CodigoMaterial,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8 
      @UI.selectionField: [{ position: 45 }]
      @UI.lineItem: [{ position: 65 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 90 }]
      _MaterialText.ProductName                  as NombreMaterial,

      @UI.selectionField: [{ position: 50 }]
      @UI.lineItem: [{ position: 70 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 100 }]
      _Logistica.Plant                           as Centro,

          /* --- Importes y Fechas --- */
      @UI.lineItem: [{ position: 90 }]
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Moneda'
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 120 }]
      _Finanzas.AmountInCompanyCodeCurrency      as Importe,

      @UI.lineItem: [{ position: 95 }]
      _Finanzas.CompanyCodeCurrency              as Moneda,

      @Consumption.filter.selectionType: #INTERVAL
      @UI.selectionField: [{ position: 70 }]
      @UI.lineItem: [{ position: 100 }]
      @UI.fieldGroup: [{ qualifier: 'FinanzasGroup', position: 140 }]
      _Logistica.PostingDate                     as FechaContabilizacion,

      /* ==================================================================== */
      /* CAMPOS DEL TICKET 0033 (REVERTIDOS PARA EVITAR ERRORES DE PROYECCIÓN)*/
      /* ==================================================================== */

      @UI.lineItem: [{ position: 110, label: 'Activo fijo' }]
      _Finanzas.MasterFixedAsset,

      @UI.lineItem: [{ position: 120, label: 'Cambio de stock' }]
      _Logistica.InventoryStockType              as CambioDeStock,

      /* ==================================================================== */
      /* CORRECCIÓN: Campo expuesto sin alias exclusivo para la query superior */
      /* ==================================================================== */
      _Logistica.InventoryStockType,

      @UI.lineItem: [{ position: 130, label: 'Cantidad unidad pedido' }]
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      _Logistica.QtyInPurchaseOrderPriceUnit,

      @UI.lineItem: [{ position: 140, label: 'Clase de documento' }]
      _Logistica.GoodsMovementRefDocType,

      @UI.lineItem: [{ position: 150, label: 'Clase de movimiento de mercancía' }]
      _Logistica.GoodsMovementType               as ClaseMovimiento,

      @UI.lineItem: [{ position: 160, label: 'Cliente para stock especial (transferencia)' }]
      _Logistica.Customer,

      @UI.lineItem: [{ position: 170, label: 'Documento de almacen' }]
      _Logistica.InvtryMgmtReferenceDocument,

      @UI.lineItem: [{ position: 180, label: 'Elemento PEP (identificador de contabilidad)' }]
      _Logistica.SpecialStockIdfgWBSElement,

      @UI.lineItem: [{ position: 190, label: 'Elemento PEP (transferencia)' }]
      _Logistica.WBSElementInternalID,

      @UI.lineItem: [{ position: 200, label: 'EM no valorada' }]
      _PedidoCompras.GoodsReceiptIsNonValuated     as EMNoValorada,

      @UI.lineItem: [{ position: 210, label: 'Grupo de artículos' }]
      _DatosMaterial.ProductGroup               as GrupoDeArticulos,

      @UI.lineItem: [{ position: 220, label: 'Imputación múltiple' }]
      _Logistica.MultipleAccountAssignmentCode   as ImputacionMultiple,
      
      /* Campo expuesto sin alias exclusivo para la query superior YY1_ */
      _Logistica.MultipleAccountAssignmentCode,

      @UI.lineItem: [{ position: 230, label: 'Indicador de creación automática' }]
      _Logistica.IsAutomaticallyCreated,

      @UI.lineItem: [{ position: 240, label: 'Modificación de cantidad de stocks' }]
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      _Logistica.QuantityInBaseUnit,

      @UI.lineItem: [{ position: 250, label: 'Modificación de valor de stock en moneda local' }]
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Logistica.TotalGoodsMvtAmtInCCCrcy,

      @UI.lineItem: [{ position: 260, label: 'Modificación de stock (lista)' }]
      _Logistica.InventoryStockType              as ModifStockLista,

      @UI.lineItem: [{ position: 270, label: 'Nivel de modificación de stock' }]
      _Logistica.InventoryValuationType,

      @UI.lineItem: [{ position: 280, label: 'Pedido de cliente (identificador de contabilidad)' }]
      _Logistica.SpecialStockIdfgSalesOrder,

      @UI.lineItem: [{ position: 290, label: 'Pedido de cliente (transferencia)' }]
      _Logistica.SalesOrder,

      @UI.lineItem: [{ position: 300, label: 'Posición de pedido de cliente (identificador de contabilidad)' }]
      _Logistica.SpecialStockIdfgSalesOrderItem,

      @UI.lineItem: [{ position: 310, label: 'Posición de pedido de cliente (transferencia)' }]
      _Logistica.SalesOrderItem,

      @UI.lineItem: [{ position: 320, label: 'Proveedor de stock especial (transferencia)' }]
      _Logistica.Supplier,

      @UI.lineItem: [{ position: 330, label: 'Recurso' }]
      _Logistica.ManufacturingOrder,

      @UI.lineItem: [{ position: 340, label: 'Recurso (traslado)' }]
      _Logistica.IssuingOrReceivingPlant,

      @UI.lineItem: [{ position: 350, label: 'Texto de cabecera del documento' }]
      _Header.MaterialDocumentHeaderText,

      @UI.lineItem: [{ position: 360, label: 'Texto de posición del documento' }]
      _Logistica.MaterialDocumentItemText,

      @UI.lineItem: [{ position: 370, label: 'Texto de posición del documento de compras' }]
      _PedidoCompras.PurchaseOrderItemText,


      /* ==================================================================== */
      /* CAMPOS COMPLEMENTARIOS Y DATOS TÉCNICOS                              */
      /* ==================================================================== */

      /* Cálculo de Cantidad con signo basado en Debe/Haber */
      @UI.lineItem: [{ position: 380, label: 'Cantidad con signo' }]
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      case _Logistica.DebitCreditCode
        when 'H' then -_Logistica.QuantityInBaseUnit
        else _Logistica.QuantityInBaseUnit
      end                                        as CantidadConSigno,

      @UI.lineItem: [{ position: 390, label: 'Autor' }]
      _Header.CreatedByUser                      as Autor,
      
      @UI.lineItem: [{ position: 400, label: 'Carta de porte' }]
      _Header.BillOfLading                       as CartaDePorte,
      
      @UI.lineItem: [{ position: 410, label: 'Fecha de creación (UTC)' }]
      _Header.CreationDate                       as FechaCreacionUTC,
      
      @UI.lineItem: [{ position: 420, label: 'Tipo de material' }]
      _DatosMaterial.ProductType                 as TipoDeMaterial,

      /* Resto de campos estándar sin alterar su nombre original */
      _Logistica.StorageLocation,
      _Logistica.StorageType,
      _Logistica.StorageBin,
      _Logistica.Batch,
      _Logistica.ShelfLifeExpirationDate,
      _Logistica.ManufactureDate,
      _Logistica.SalesOrderScheduleLine,
      _Logistica.InventorySpecialStockType,
      _Logistica.StockOwner,
      _Logistica.DebitCreditCode,
      _Logistica.InventoryUsabilityCode,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _Logistica.QuantityInEntryUnit,
      _Logistica.EntryUnit,
      _Logistica.MaterialBaseUnit,
      _Logistica.DocumentDate,
      _Logistica.ReservationItemRecordType,
      _Logistica.CompanyCodeCurrency,
      _Logistica.ReservationIsFinallyIssued,
      _Logistica.PurchaseOrder,
      _Logistica.PurchaseOrderItem,
      _Logistica.ProjectNetwork,
      _Logistica.OrderID,
      _Logistica.OrderItem,
      _Logistica.MaintOrderRoutingNumber,
      _Logistica.MaintOrderOperationCounter,
      _Logistica.Reservation,
      _Logistica.ReservationItem,
      _Logistica.DeliveryDocument,
      _Logistica.DeliveryDocumentItem,
      _Logistica.ReversedMaterialDocumentYear,
      _Logistica.ReversedMaterialDocument,
      _Logistica.ReversedMaterialDocumentItem,
      _Logistica.RvslOfGoodsReceiptIsAllowed,
      _Logistica.GoodsRecipientName,
      _Logistica.GoodsMovementReasonCode,
      _Logistica.UnloadingPointName,
      _Logistica.CostCenter,
      _Logistica.GLAccount,
      _Logistica.ServicePerformer,
      _Logistica.PersonWorkAgreement,
      _Logistica.AccountAssignmentCategory,
      _Logistica.WorkItem,
      _Logistica.ServicesRenderedDate,
      _Logistica.IssgOrRcvgMaterial,
      _Logistica.IssuingOrReceivingStorageLoc,
      _Logistica.IssgOrRcvgBatch,
      _Logistica.IssgOrRcvgSpclStockInd,
      _Logistica.IssuingOrReceivingValType,
      _Logistica.CompanyCode,
      _Logistica.BusinessArea,
      _Logistica.ControllingArea,
      _Logistica.FiscalYearPeriod,
      _Logistica.FiscalYearVariant,
      _Logistica.IsCompletelyDelivered,
      _Logistica.SerialNumbersAreCreatedAutomly,
      _Logistica.GoodsReceiptType,
      _Logistica.ConsumptionPosting,
      _Logistica.MultiAcctAssgmtOriglMatlDocItm,
      _Logistica.GoodsMovementIsCancelled,
      _Logistica.IssuingOrReceivingStockType,
      _Logistica.ManufacturingOrderItem,
      _Logistica.MaterialDocumentLine,
      _Logistica.MaterialDocumentParentLine,
      _Logistica.OrderPriceUnit,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _Logistica.QuantityInDeliveryQtyUnit,
      _Logistica.DeliveryQuantityUnit,

      _Logistica.ProfitCenter,
      _Logistica.ProductStandardID,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _Logistica.GdsMvtExtAmtInCoCodeCrcy,

      _Logistica.ReferenceDocumentFiscalYear,
      _Logistica.InvtryMgmtRefDocumentItem,
      _Logistica.EWMWarehouse,
      _Logistica.EWMStorageBin,
      _Logistica.MaterialDocumentPostingType,
      _Logistica.OriginalMaterialDocumentItem
}
/* Filtro técnico para no ver doble en traslados 301 */
where
     _Logistica.DebitCreditCode   =  'H'
  or _Logistica.GoodsMovementType <> '301'
