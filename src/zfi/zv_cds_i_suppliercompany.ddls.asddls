@AbapCatalog.sqlViewName: 'ZV_CDS_I_SU_COM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Proveedor por Sociedad'
define view zv_cds_i_suppliercompany as select from I_SupplierCompany
{
    key Supplier,
    key CompanyCode,
        SupplierClerkURL,
        SupplierAccountNote
}
