@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte de Movimiento de almacen'
@AbapCatalog.sqlViewName: 'ZI_MOV_MAT'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@Analytics.dataCategory: #CUBE
@Search.searchable: true
define view Z_I_MOVIMIENTO_MATERIAL
  as select from    Z_I_MOV_MAT_LOG_AUX      as _Logistica

    left outer join Z_I_MOV_MAT_ACC_AUX      as _Finanzas     on  _Logistica.MaterialDocument     = _Finanzas.ReferenceDocument
                                                              and _Logistica.MaterialDocumentYear = _Finanzas.ReferenceDocumentContext
                                                              and _Logistica.CompanyCode          = _Finanzas.CompanyCode

    left outer join I_ProductText            as _MaterialText on  _Logistica.Material    = _MaterialText.Product
                                                              and _MaterialText.Language = $session.system_language

    left outer join I_Product                as _Producto     on _Logistica.Material = _Producto.Product

    left outer join I_PurchaseOrderItemAPI01 as _POItem       on  _Logistica.PurchaseOrder     = _POItem.PurchaseOrder
                                                              and _Logistica.PurchaseOrderItem = _POItem.PurchaseOrderItem
    left outer join I_GLAccountText          as _Cuentas      on  _Finanzas.GLAccountAux       = _Cuentas.GLAccount
                                                              and _Finanzas.ChartOfAccountsAux = _Cuentas.ChartOfAccounts
                                                              and _Cuentas.Language            = $session.system_language


{
      /* Keys */
  key _Logistica.MaterialDocument                                   as DocumentoMaterial,
  key _Logistica.MaterialDocumentYear                               as AnioDocumento,
  key _Logistica.MaterialDocumentItem                               as Posicion,
      //      cast( '' as abap.char(10) )                                   as CuentaContable,
      //      cast( '' as abap.char(40) )                                   as DescripcionCuenta,
      //      cast( '' as abap.char(10) )                                   as CuentaAlternativa,
      _Finanzas.GLAccountAux                                        as CuentaContable,
      _Cuentas.GLAccountName                                        as DescripcionCuenta,
      _Finanzas.AlternativeGLAccountAux                             as CuentaAlternativa,
      _Logistica._MaterialDocumentHeader.CreatedByUser              as Autor,
      _Logistica._MaterialDocumentHeader.BillOfLading               as CartaPorte,
      _Logistica._MaterialDocumentHeader.MaterialDocumentHeaderText as TextoCabeceraDocumento,
      cast(
      dats_tims_to_tstmp(
      _Logistica._MaterialDocumentHeader.CreationDate,
      _Logistica._MaterialDocumentHeader.CreationTime,
      abap_system_timezone( $session.client, 'NULL' ),
          $session.client,
          'NULL'
          ) as timestamp
      )                                                             as FechaCreacionUTC,
      /* Documento contable asociado */
      _Finanzas.AccountingDocument                                  as AsientoContable,
      _Finanzas.FiscalYear                                          as FiscalYear,
      /* --- Descripciones --- */
      //      _Cuentas.GLAccountName                     as DescripcionCuenta,
      //      _Finanzas.AlternativeGLAccount        as CuentaAlternativa,
      //      _Finanzas.FiscalYear,
      /* --- Logística y Materiales --- */
      _Logistica.Material                                           as CodigoMaterial,
      _MaterialText.ProductName                                     as NombreMaterial,
      _Logistica.Plant                                              as Centro,
      _Logistica.GoodsMovementType                                  as ClaseMovimiento,
      //      _Logistica.MasterFixedAsset                      as ActivoFijo,
      /* --- Campos de Finanzas (Importes y Monedas) --- */
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Moneda'
      cast( 0 as abap.curr(23,2) )                                  as Importe,

      cast( '' as abap.cuky(5) )                                    as Moneda,
      @Consumption.filter.selectionType: #INTERVAL
      @Consumption.filter.multipleSelections: false
      _Logistica.PostingDate                                        as FechaContabilizacion,

      /* --- Resto de los campos técnicos y de negocio --- */
      _Logistica.StorageLocation,
      _Logistica.StorageType,
      _Logistica.StorageBin,
      _Logistica.Batch,
      _Logistica.ShelfLifeExpirationDate,
      _Logistica.ManufactureDate,
      _Logistica.Supplier,
      _Logistica.SalesOrder,
      _Logistica.SalesOrderItem,
      _Logistica.SalesOrderScheduleLine,
      _Logistica.WBSElementInternalID,
      _Logistica.Customer,
      _Logistica.InventorySpecialStockType,
      _Logistica.InventoryStockType,
      _Logistica.StockOwner,
      _Logistica.DebitCreditCode,
      _Logistica.InventoryUsabilityCode,

      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      _Logistica.QuantityInBaseUnit,
      _Logistica.MaterialBaseUnit,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _Logistica.QuantityInEntryUnit,
      _Logistica.EntryUnit,

      _Logistica.DocumentDate,
      _Logistica.ReservationItemRecordType,
      _Logistica.TotalGoodsMvtAmtInCCCrcy,
      _Logistica.CompanyCodeCurrency,
      _Logistica.InventoryValuationType,
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
      _Logistica.IssuingOrReceivingPlant,
      _Logistica.IssuingOrReceivingStorageLoc,
      _Logistica.IssgOrRcvgBatch,
      _Logistica.IssgOrRcvgSpclStockInd,
      _Logistica.IssuingOrReceivingValType,
      _Logistica.CompanyCode,
      _Logistica.BusinessArea,
      _Logistica.ControllingArea,
      _Logistica.FiscalYearPeriod,
      _Logistica.FiscalYearVariant,
      _Logistica.GoodsMovementRefDocType,
      _Logistica.IsCompletelyDelivered,
      _Logistica.MaterialDocumentItemText,
      _Logistica.IsAutomaticallyCreated,
      _Logistica.SerialNumbersAreCreatedAutomly,
      _Logistica.GoodsReceiptType,
      _Logistica.ConsumptionPosting,
      _Logistica.MultiAcctAssgmtOriglMatlDocItm,
      _Logistica.MultipleAccountAssignmentCode,
      _Logistica.GoodsMovementIsCancelled,
      _Logistica.IssuingOrReceivingStockType,
      _Logistica.ManufacturingOrder,
      _Logistica.ManufacturingOrderItem,
      _Logistica.MaterialDocumentLine,
      _Logistica.MaterialDocumentParentLine,
      _Logistica.SpecialStockIdfgSalesOrder,
      _Logistica.SpecialStockIdfgSalesOrderItem,
      _Logistica.SpecialStockIdfgWBSElement,
      _Logistica.QtyInPurchaseOrderPriceUnit,
      _Logistica.OrderPriceUnit,
      _Logistica.QuantityInDeliveryQtyUnit,
      _Logistica.DeliveryQuantityUnit,
      _Logistica.ProfitCenter,
      _Logistica.ProductStandardID,
      _Logistica.GdsMvtExtAmtInCoCodeCrcy,
      _Logistica.ReferenceDocumentFiscalYear,
      _Logistica.InvtryMgmtReferenceDocument,
      _Logistica.InvtryMgmtRefDocumentItem,
      _Logistica.EWMWarehouse,
      //      _Logistica.WhseGoodsMovementDocument             as DocumentoAlmacen,
      _Logistica.EWMStorageBin,
      _Logistica.MaterialDocumentPostingType,
      _Logistica.OriginalMaterialDocumentItem
}
where
     _Logistica.DebitCreditCode   =  'H'
  or _Logistica.GoodsMovementType <> '301'
