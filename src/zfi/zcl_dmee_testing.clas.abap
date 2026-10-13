"!@testing main_testing
CLASS zcl_dmee_testing DEFINITION
  FOR TESTING
  PUBLIC
  FINAL
*  CREATE PUBLIC
  .

* Nota-1 de la clase: "FOR TESTING" se usa para hacer prueba en la clase.
* Nota-2 de la clase: Al quitar "FOR TESTING" descomentar FINAL, CREATE PUBLIC y quitar "FOR TESTING" de método main_test

  PUBLIC SECTION.

    METHODS main_testing
        FOR TESTING
      .

  PROTECTED SECTION.

  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_DMEE_TESTING IMPLEMENTATION.


  METHOD main_testing.

    DATA ip_output_mode       TYPE dmee_end_output_mode.
    DATA cp_output_file_lines TYPE dmee_output_file_lines.
    DATA cp_string            TYPE string.
    DATA cp_log               TYPE cl_dmee_postprocessing=>tt_dmee_log.
    DATA lo_zcl_dmee_tool     TYPE REF TO zcl_dmee_tool.

    FREE cp_output_file_lines.

**   Escenario para Banco BCP
    cp_output_file_lines = VALUE #(

*      (  line = '100000020240928CPEN 1931461249089       00000000011512.03Pago a Proveedores BCP                  N000001100000000' )
      (  line = '100000120260303CPEN 1931483995046       00000000000300.90Pago a Proveedores BCP                  N000001100000000' )
      (  line = '2                     1120504679960    CLIENTE - PROVEEDOR PRUEBA2                                                01-F001-41548463                        CE101900000436202400PEN 00000000004850.00S' )
      (  line = '3F1-F001-1234569000000000001000.00' )
*      (  line = '9BCP2024092700010B CE10190000000100011502   908911 PEN01-F001-41548463' )
*      (  line = '2                     1120331898008    Proveedor para Scotiabank                                                  01-F001-45170246                        CE101900000416202400PEN 00000000004277.03S' )
*      (  line = '3D00000000000000100000000004277.03' )
*      (  line = '9BCP2024092700010B CE10190000000100011802   908935 PEN01-F001-45170246' )
*      (  line = '2                     1120331898008    Proveedor para Scotiabank                                                  01-F001-45170247                        CE101900000417202400PEN 00000000000930.00S' )
*      (  line = '3D00000000000000100000000000930.00' )
*      (  line = '9BCP2024092700010B CE10190000000100011802   908935 PEN01-F001-45170247' )
*      (  line = '2                     1120483851171    PROVEEDOR EJEMPLO PARA BCP                                                 01-F001-45170000                        CE101900000411202400PEN 00000000001455.00S' )
*      (  line = '3D00000000000000100000000001455.00' )
      (  line = '9BCP2024092700010B CE10190000000100017402   908902 PEN01-F001-45170000' )

    ).


**   Escenario para Banco SCOTIABANK
**    Versión de registro temporal al final del registro
*    cp_output_file_lines = VALUE #(
**        ( line = '20504679960CLIENTE - PROVEEDOR PRUEBA2                                 01-F001-4154842024092300000000000C   0000000N                                                                      PE01' )
**        ( line = '9.SCO2024092900014B CE10190000000100011509   983011 PEN01F00141548463' )
**        ( line = '20331898008Proveedor para Scotiabank                                   01-F001-4517022024091600000000000C   0000000N                                                                      PE01' )
**        ( line = '9.SCO2024092900014B CE10190000000100011809   983035 PEN01F00145170246' )
**        ( line = '20331898008Proveedor para Scotiabank                                   01-F001-4517022024091600000000000C   0000000N                                                                      PE01' )
**        ( line = '9.SCO2024092900014B CE10190000000100011809   983035 PEN01F00145170247' )
**        ( line = '20483851171PROVEEDOR EJEMPLO PARA BCP                                  01-F001-4517002024091400000000000C   0000000N                                                                      PE01' )
**        ( line = '9.SCO2024092900014B CE10190000000100017409   983002 PEN01F00145170000' )
*
*        ( line = '20331898008Proveedor para Scotiabank                                   01F001154541322024080500000000000C   0000000N                                                                      PE01' )
*        ( line = '9.SCO2024121200008B CE10190000000100011809   983035 PEN01-F001-15454132' )
*        ( line = '20331898008Proveedor para Scotiabank                                   01F001154545422024080500000000000C   0000000N                                                                      PE01' )
*        ( line = '9.SCO2024121200008B CE10190000000100011809   983035 PEN01-F001-15454542' )
*        ( line = '20331898008Proveedor para Scotiabank                                   01F001764545402024080500000000000C   0000000N                                                                      PE01' )
*        ( line = '9.SCO2024121200008B CE10190000000100011809   983035 PEN01-F001-76454540' )
*
*    ).


**   Escenario para Banco BBVA
**   Estructura
*    cp_output_file_lines = VALUE #(
*        ( line = '750001103770100058368  PEN         485000A         00004B                   CONTARS' )
*        ( line = '002R20504679960 P                    CLIENTE - PROVEEDOR PRUEBA2             000000000000000FPOR BADI    N01-F001-41548463                        E                                                                                ' )
*        ( line = '9BBV2024092900004B CE10190000000100011511   836811 PEN01-F001-41548463                                                                                ' )
*        ( line = '002R20331898008 P                    Proveedor para Scotiabank               000000000000000FPOR BADI    N01-F001-45170246                        E                                                                                ' )
*        ( line = '9BBV2024092900004B CE10190000000100011811   836835 PEN01-F001-45170246                                                                                ' )
*        ( line = '002R20331898008 P                    Proveedor para Scotiabank               000000000000000FPOR BADI    N01-F001-45170247                        E                                                                                ' )
*        ( line = '9BBV2024092900004B CE10190000000100011811   836835 PEN01-F001-45170247                                                                                ' )
*        ( line = '002R20483851171 P                    PROVEEDOR EJEMPLO PARA BCP              000000000000000FPOR BADI    N01-F001-45170000                        E                                                                                ' )
*        ( line = '9BBV2024092900004B CE10190000000100017411   836802 PEN01-F001-45170000                                                                                ' )
*    ).


*   Escenario para Banco BanBIF
*   Estructura
*    cp_output_file_lines = VALUE #(
*        ( line = '120331898008    LUZ DEL SUR S.A.A.                                          1CE101900000485PEN0009215.000000000001-F001-12345112000   00000000000000000000              0000000000' )
*        ( line = '9BIF2024122800004B CE10190000000100004538   045002 PEN01-F001-12345111' )
*        ( line = '120331898008    LUZ DEL SUR S.A.A.                                          1CE101900000486PEN0009215.000000000001-F001-12345112000   00000000000000000000              0000000000' )
*        ( line = '9BIF2024122800004B CE10190000000100004538   045002 PEN01-F001-12345112' )
*        ( line = '120331898008    LUZ DEL SUR S.A.A.                                          1CE101900000487PEN0009215.000000000001-F001-12345112000   00000000000000000000              0000000000' )
*        ( line = '9BIF2024122800004B CE10190000000100004538   045002 PEN01-F001-12345114' )
*    ).

    lo_zcl_dmee_tool = NEW #(  ).
    lo_zcl_dmee_tool->main(
      EXPORTING ip_output_mode       = ip_output_mode
      CHANGING  cp_output_file_lines = cp_output_file_lines
                cp_string            = cp_string
*               cp_xml_document      = cp_xml_document
                cp_log               = cp_log
    ).


**    TYPES TY_TT_business_data TYPE TABLE OF zcls_z000_model_travels=>tyt_yy_1_confi_tipo_abonotype.
*    TYPES ty_tt_business_data TYPE zcls_z000_model_travels=>tyt_yy_1_confi_tipo_abonotype.
*    DATA  t_business_data     TYPE ty_tt_business_data.
*    NEW zcl_proxy_travels_000( )->get_travels( IMPORTING et_business_data = t_business_data ).
*
*    "FINAL(xml) = cl_demo_output_cloud=>new( cl_demo_output_cloud=>xml   )->begin_section( 'XML Output' ).

*    data(lo_dis) = cl_demo_output_cloud=>new(  ).
*
*    lo_dis->write( 'Hola' ).
*    lo_dis->
*    "cl_demo_output=>display( ).


  ENDMETHOD.
ENDCLASS.
