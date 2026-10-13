@AbapCatalog.sqlViewName: 'ZV_CDS_I_SUPP'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Obtener TaxNumberType'
define view ZV_CDS_I_SUPPLIER as select from I_Supplier
{
    key Supplier,
    TaxNumberType
}
