CLASS zcl_dmee_tool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  .

  PUBLIC SECTION.

    TYPES ty_banco         TYPE c LENGTH 3.
    TYPES ty_moneda        TYPE c LENGTH 3.
    TYPES ty_tipo_abono    TYPE c LENGTH 2.
    TYPES ty_cuenta_abono  TYPE c LENGTH 20.
    TYPES ty_referencia    TYPE c LENGTH 40.
    TYPES ty_bp_receptor   TYPE c LENGTH 10.
    TYPES ty_clave_control TYPE c LENGTH 05.
    TYPES ty_banco_propio  TYPE c LENGTH 05.


    TYPES:
      BEGIN OF ty_st_tipo_abono,
        banco_propio    TYPE ty_banco_propio,
        banco_pagador   TYPE c LENGTH 10,
        banco_receptor  TYPE c LENGTH 10,
        moneda_pago     TYPE ty_moneda,
        moneda_receptor TYPE ty_moneda,
        clave_control   TYPE ty_clave_control,
        tipo_abono      TYPE ty_tipo_abono,
      END OF ty_st_tipo_abono.
    TYPES ty_tt_tipo_abono TYPE STANDARD TABLE OF ty_st_tipo_abono WITH KEY
        banco_pagador
        banco_receptor
        moneda_pago
        moneda_receptor.

    TYPES ty_tipo_cta      TYPE string.
    TYPES ty_tipo_doc_pago TYPE c LENGTH 1.

    TYPES:
      BEGIN OF ty_st_banco,
*        moneda_receptor  TYPE zv_cds_i_businesspartnerbank-bankaccountreferencetext, "-@vchero 09.06.2026
        moneda_receptor  TYPE zv_cds_i_businesspartnerbank-BankAccountName, "+@vchero 09.06.2026
        banco_receptor   TYPE zv_cds_i_businesspartnerbank-banknumber,
        cta_banco_cci    TYPE zv_cds_i_businesspartnerbank-businesspartnerexternalbankid,
        clave_control    TYPE zv_cds_i_businesspartnerbank-bankcontrolkey,
        cta_banco_propio TYPE zv_cds_i_businesspartnerbank-bankaccount,
        orden            TYPE i,
      END OF ty_st_banco.
    TYPES ty_tt_banco TYPE STANDARD TABLE OF ty_st_banco WITH DEFAULT KEY.


    TYPES:
      BEGIN OF ty_st_banco_res,
        Cod_Banco        TYPE string,
        Moneda_de_Cuenta TYPE string,
      END OF ty_st_banco_res.


    CONSTANTS c_tipo_cta_bco_propio TYPE ty_tipo_cta VALUE '1'.
    CONSTANTS c_tipo_cta_bco_cci    TYPE ty_tipo_cta VALUE '2'.

    CLASS-DATA gt_tipo_abono TYPE ty_tt_tipo_abono.

    METHODS main
      IMPORTING ip_output_mode       TYPE dmee_end_output_mode
      CHANGING  cp_output_file_lines TYPE dmee_output_file_lines OPTIONAL
                cp_string            TYPE string OPTIONAL
                cp_xml_document      TYPE REF TO if_ixml_document OPTIONAL
                cp_log               TYPE cl_dmee_postprocessing=>tt_dmee_log OPTIONAL.

    CLASS-METHODS hubo_error
      IMPORTING
        i_it_log        TYPE cl_dmee_postprocessing=>tt_dmee_log
      RETURNING
        VALUE(r_result) TYPE abap_bool.


    CLASS-METHODS receptor_banco_get
      IMPORTING
        i_banco_propio   TYPE ty_banco_propio
        i_bp_receptor    TYPE ty_bp_receptor
        i_moneda_de_pago TYPE ty_moneda
        i_banco_pagador  TYPE ty_banco
        i_referencia     TYPE ty_referencia
        i_banco          TYPE string
      EXPORTING
        o_found          TYPE abap_bool
        o_tipo_cta       TYPE ty_tipo_cta
        o_st_res         TYPE ty_st_banco_res
      CHANGING
        c_tipo_abono     TYPE ty_tipo_abono
        c_cuenta_abano   TYPE ty_cuenta_abono
        c_log            TYPE cl_dmee_postprocessing=>tt_dmee_log OPTIONAL
      .

    CLASS-METHODS tipo_abono_set.

    CLASS-METHODS tipo_abono_get
      IMPORTING
        i_banco_propio     TYPE ty_banco_propio
        i_banco_pagador    TYPE ty_banco
        i_banco_receptor   TYPE ty_banco
        i_moneda_pago      TYPE ty_moneda
        i_moneda_receptor  TYPE ty_moneda
        i_cta_banco_propio TYPE zv_cds_i_businesspartnerbank-bankaccount
        i_cta_banco_cci    TYPE zv_cds_i_businesspartnerbank-businesspartnerexternalbankid
        i_clave_control    TYPE zv_cds_i_businesspartnerbank-bankcontrolkey
      EXPORTING
        o_found            TYPE abap_bool
        o_tipo_cta         TYPE ty_tipo_cta
        o_st_res           TYPE ty_st_banco_res
      CHANGING
        c_tipo_abono       TYPE ty_tipo_abono
        c_cuenta_abono     TYPE ty_cuenta_abono
      .

    CLASS-METHODS contacto_get
      IMPORTING
        i_proveedor             TYPE i_suppliercompany-supplier
        i_companycode           TYPE i_suppliercompany-CompanyCode
      EXPORTING
        o_found                 TYPE abap_bool
      CHANGING
        c_correo                TYPE i_suppliercompany-supplierclerkurl
        c_persona_contacto_pago TYPE i_suppliercompany-supplieraccountnote OPTIONAL
        c_log                   TYPE cl_dmee_postprocessing=>tt_dmee_log OPTIONAL
      .


    CLASS-METHODS extraer_derecha_a_izquierda
      IMPORTING
        i_cadena    TYPE string
        i_max       TYPE i
      EXPORTING
        e_subcadena TYPE string.

    CLASS-METHODS net_retencion_get
      IMPORTING
        i_supplier              TYPE zdppp_cds_r-supplier
        i_fecha_de_la_propuesta TYPE zdppp_cds_r-paymentrundate
        i_id_de_la_propuesta    TYPE zdppp_cds_r-paymentrunid
        i_doc_ref_id            TYPE zdppp_cds_r-documentreferenceid
        i_can_numc              TYPE i
        i_pto_dec               TYPE abap_bool DEFAULT abap_false
      EXPORTING
        op_net_amount           TYPE any
      CHANGING
        c_log                   TYPE cl_dmee_postprocessing=>tt_dmee_log.

    CLASS-METHODS tipo_doc_pago_get
      IMPORTING
        i_supplier              TYPE zdppp_cds_r-supplier
        i_fecha_de_la_propuesta TYPE zdppp_cds_r-paymentrundate
        i_id_de_la_propuesta    TYPE zdppp_cds_r-paymentrunid
        i_doc_ref_id            TYPE zdppp_cds_r-documentreferenceid
      EXPORTING
        op_tipo_doc_pago        TYPE ty_tipo_doc_pago
      CHANGING
        c_log                   TYPE cl_dmee_postprocessing=>tt_dmee_log.

    CLASS-METHODS numero_generar
      IMPORTING
        iv_numero TYPE any
      EXPORTING
        ev_numero TYPE c.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES ty_char4 TYPE c LENGTH 4.
    CLASS-METHODS banco_ordenar
      IMPORTING
        i_banco    TYPE string
      CHANGING
        c_it_banco TYPE zcl_dmee_tool=>ty_tt_banco.

    CONSTANTS c_procesado_no TYPE string VALUE '0'.
    CONSTANTS c_procesado_si TYPE string VALUE '1'.

    METHODS procesado_validar
      IMPORTING
        ip_banco     TYPE string
        ip_procesado TYPE string
      CHANGING
        cp_log       TYPE cl_dmee_postprocessing=>tt_dmee_log.

ENDCLASS.



CLASS ZCL_DMEE_TOOL IMPLEMENTATION.


  METHOD banco_ordenar.

    tipo_abono_set( ).

    IF c_it_banco IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_orden) = 0.

*   Buscar Banco Propio y asignarle 1
    LOOP AT c_it_banco ASSIGNING FIELD-SYMBOL(<lfs_c_it_banco>).
      LOOP AT gt_tipo_abono ASSIGNING FIELD-SYMBOL(<lfs_gt_tipo_abono>)
      WHERE banco_propio   EQ i_banco
        AND banco_pagador  EQ <lfs_c_it_banco>-banco_receptor
        AND banco_receptor EQ <lfs_c_it_banco>-banco_receptor
        .
        lv_orden = lv_orden + 1.
        <lfs_c_it_banco>-orden = lv_orden.
        EXIT.
      ENDLOOP.
      IF lv_orden NE 0.
        EXIT.
      ENDIF.
    ENDLOOP.

*   Buscar OTROS Bancos y asignarle el orden siguiente
    IF lv_orden <> 0.
      LOOP AT c_it_banco ASSIGNING <lfs_c_it_banco>
      WHERE orden EQ 0.
        lv_orden = lv_orden + 1.
        <lfs_c_it_banco>-orden = lv_orden.
      ENDLOOP.
    ELSE.
      LOOP AT c_it_banco ASSIGNING <lfs_c_it_banco>.
        lv_orden = lv_orden + 1.
        <lfs_c_it_banco>-orden = lv_orden.
      ENDLOOP.
    ENDIF.

    SORT c_it_banco BY
      orden.

  ENDMETHOD.


  METHOD contacto_get.

    o_found = abap_false.

    CLEAR c_correo.
    CLEAR c_persona_contacto_pago.

    SELECT SINGLE
        supplierclerkurl    AS correo,
        supplieraccountnote AS persona_contacto_pago
      FROM zv_cds_i_suppliercompany
      WHERE supplier    EQ @i_proveedor
        AND companycode EQ @i_companycode
      INTO @DATA(ls_reg)
    .
    IF sy-subrc EQ 0.
      o_found  = abap_true.
      c_correo = ls_reg-correo.
      IF c_persona_contacto_pago IS SUPPLIED.
        c_persona_contacto_pago = ls_reg-persona_contacto_pago.
      ENDIF.
    ENDIF.
    IF o_found EQ abap_true.
      IF c_correo IS INITIAL
      OR (     c_persona_contacto_pago IS SUPPLIED
           AND c_persona_contacto_pago IS INITIAL
         ).
        o_found  = abap_false.
*       Error, faltan datos de contacto para pago del proveedor &1
        MESSAGE e005(zdmee) WITH i_proveedor INTO DATA(lv_msg).
        APPEND CORRESPONDING #( sy ) TO c_log.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD extraer_derecha_a_izquierda.

    DATA lv_cadena TYPE string.

    CLEAR e_subcadena.

    lv_cadena = i_cadena.
    CONDENSE lv_cadena.

    DATA(lv_largo) = strlen( lv_cadena ).


    IF lv_largo <= i_max.
      e_subcadena = lv_cadena.
    ELSE.
      DATA(lv_dif) = lv_largo - i_max.
      e_subcadena  = lv_cadena+lv_dif.
    ENDIF.
    CONDENSE e_subcadena.

  ENDMETHOD.


  METHOD hubo_error.

    r_result = abap_false.

    LOOP AT i_it_log ASSIGNING FIELD-SYMBOL(<lfs_i_it_log>)
    WHERE msgty EQ 'E'
       OR msgty EQ 'A'
       OR msgty EQ 'X'
       .
      r_result = abap_true.
      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD main.

    DATA lv_banco TYPE string.

*   RETURN.

    DATA(lv_procesado) = c_procesado_no.

*   Revisar Banco BCP
    NEW zcl_dmee_banco_bcp( )->main(
      EXPORTING
        ip_output_mode       = ip_output_mode
      CHANGING
        cp_output_file_lines = cp_output_file_lines
        cp_string            = cp_string
        cp_xml_document      = cp_xml_document
        cp_log               = cp_log
        cp_procesado         = lv_procesado
        cp_banco             = lv_banco
    ).

*   Validar que se procesó un Banco
    procesado_validar(
      EXPORTING
        ip_banco     = lv_banco
        ip_procesado = lv_procesado
      CHANGING
        cp_log       = cp_log
    ).

  ENDMETHOD.


  METHOD net_retencion_get.

    DATA lr_ref_n TYPE REF TO data.
    DATA lr_ref_c TYPE REF TO data.

    CLEAR op_net_amount.

    SELECT
        netamountintransaccurrency,
        documentreferenceid
      FROM zdppp_cds_r
     WHERE paymentrundate       EQ @i_fecha_de_la_propuesta
       AND paymentrunid         EQ @i_id_de_la_propuesta
       AND paymentrunisproposal EQ @space
       AND payingcompanycode    EQ 'CE10'
       AND supplier             EQ @i_supplier     " Proveedor
*        AND Customer             EQ @              " Cliente
*        AND PaymentRecipient     EQ @              " Receptor de pago
*        AND PaymentDocument      EQ @              " Documento de pago
       AND documentreferenceid  EQ @i_doc_ref_id
      INTO TABLE @DATA(lt_item)
     .
    IF sy-subrc EQ 0.

      CREATE DATA lr_ref_n TYPE n LENGTH i_can_numc.
      CREATE DATA lr_ref_c TYPE c LENGTH i_can_numc.

      ASSIGN lr_ref_n->* TO FIELD-SYMBOL(<lfs_num_n>).
      ASSIGN lr_ref_c->* TO FIELD-SYMBOL(<lfs_num_c>).

      DATA(lv_netamountintransaccurrency) = lt_item[ 1 ]-netamountintransaccurrency.
      lv_netamountintransaccurrency       = abs( lv_netamountintransaccurrency ).
      lv_netamountintransaccurrency       = lv_netamountintransaccurrency * 100.

      <lfs_num_n> = lv_netamountintransaccurrency.
      <lfs_num_c> = <lfs_num_n>.

      IF i_pto_dec EQ abap_true.
        DATA(lv_dif)    = i_can_numc - 2.
        DATA(lv_numc)   = CONV string( <lfs_num_c> ).
        DATA(lv_entero) = lv_numc+0(lv_dif).
        lv_entero       = lv_entero+1.
        <lfs_num_c>     = lv_entero && '.' && lv_numc+lv_dif.
      ENDIF.

      op_net_amount = <lfs_num_c>.

    ELSE.

*     No existe Neto de retenciones para Proveedor &1 y Doc.Ref. &2
      MESSAGE e007(zdmee) WITH i_supplier i_doc_ref_id INTO DATA(lv_msg).
      APPEND CORRESPONDING #( sy ) TO c_log.

    ENDIF.

  ENDMETHOD.


  METHOD NUMERO_GENERAR.

    DATA ls     TYPE string.
    DATA lc_len TYPE i.
    DATA ls_len TYPE i.
    DATA lv_dif TYPE i.

    CLEAR ev_numero WITH '0'.

    ls     = iv_numero.
    CONDENSE ls.

    ls_len = strlen( ls ).
    lc_len = strlen( ev_numero ).
    lv_dif = lc_len - ls_len.

    IF lv_dif LE 0.
      ev_numero = ls.
    ELSE.
      ev_numero = ev_numero+0(lv_dif) && ls.
    ENDIF.

  ENDMETHOD.


  METHOD procesado_validar.

    IF hubo_error( cp_log ) EQ abap_true.
      RETURN.
    ENDIF.

    IF ip_procesado NE c_procesado_si.
*     No se pudo procesar archivo de Banco &1
      MESSAGE e002(zdmee) WITH ip_banco INTO DATA(lv_msg).
      APPEND CORRESPONDING #( sy ) TO cp_log.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD receptor_banco_get.

    DATA lt_banco TYPE ty_tt_banco.

    CLEAR o_found   .
    CLEAR o_tipo_cta.
    CLEAR o_st_res  .


*   Obtener Datos Bancarios de Receptor
*    SELECT bankaccountreferencetext      AS moneda_receptor, "-vchero 09.06.2026
    SELECT BankAccountName               AS moneda_receptor, "+vchero 09.06.2026
           banknumber                    AS banco_receptor ,
           businesspartnerexternalbankid AS cta_banco_cci  ,
           bankcontrolkey                AS clave_control  ,
           bankaccount                   AS cta_banco_propio
      FROM zv_cds_i_businesspartnerbank
     WHERE businesspartner EQ @i_bp_receptor
      INTO TABLE @lt_banco.

    IF sy-subrc EQ 0.

*     Excluir otras monedas, si Moneda Pagadora = Moneda Receptora
      IF line_exists( lt_banco[ moneda_receptor = i_moneda_de_pago ] ).
        DELETE lt_banco WHERE moneda_receptor NE i_moneda_de_pago.
      ENDIF.

*     Excluir el Banco 18 y 018
      DELETE lt_banco WHERE moneda_receptor EQ i_moneda_de_pago
                        AND (    banco_receptor  EQ '18'
                              OR banco_receptor  EQ '018'
                            ).

*     Ordenar por Banco Propio
      banco_ordenar(
        EXPORTING i_banco     = i_banco
        CHANGING  c_it_banco  = lt_banco
      ).

      LOOP AT lt_banco ASSIGNING FIELD-SYMBOL(<lfs_lt_banco>).

        tipo_abono_get(
          EXPORTING
            i_banco_propio     = i_banco_propio
            i_banco_pagador    = i_banco_pagador
            i_moneda_pago      = i_moneda_de_pago
            i_banco_receptor   = CONV #( <lfs_lt_banco>-banco_receptor )
            i_moneda_receptor  = CONV #( <lfs_lt_banco>-moneda_receptor )
            i_cta_banco_propio = <lfs_lt_banco>-cta_banco_propio
            i_cta_banco_cci    = <lfs_lt_banco>-cta_banco_cci
            i_clave_control    = <lfs_lt_banco>-clave_control
          IMPORTING
            o_found            = o_found
            o_tipo_cta         = o_tipo_cta
            o_st_res           = o_st_res
          CHANGING
            c_tipo_abono       = c_tipo_abono
            c_cuenta_abono     = c_cuenta_abano
        ).

        IF o_found IS NOT INITIAL.
          EXIT.                                             "#EC WARNOK
        ENDIF.

      ENDLOOP.

    ENDIF.

    IF o_found EQ abap_false.
*     Para la Ref. &1, no se determinó Tipo de Abono. Indique un Banco válido
      MESSAGE e003(zdmee) WITH i_referencia INTO DATA(lv_msg).
      APPEND CORRESPONDING #( sy ) TO c_log.
    ENDIF.

  ENDMETHOD.


  METHOD tipo_abono_get.

    DATA lv_cuenta_abono TYPE string.

    CLEAR o_found   .
    CLEAR o_tipo_cta.
    clear o_st_res  .

**     Error "El uso de Clase ZCLS_Z000_MODEL_TRAVEL no está permitido"
*      TYPES ty_tt_business_data TYPE zcls_z000_model_travels=>tyt_yy_1_confi_tipo_abonotype.
*      DATA  t_business_data     TYPE ty_tt_business_data.
*      NEW zcl_proxy_travels_000( )->get_travels( IMPORTING et_business_data = t_business_data ).

*      Error "El uso de Clase ZCL_GJMP_TEST no está permitido"
*       NEW zcl_gjmp_test( )->main(
**         EXPORTING
**           top              =
**           skip             =
**         IMPORTING
**           et_business_data =
*       ).

    tipo_abono_set( ).

*   Buscar el Tipo de Abono

    DO 4 TIMES.
      CASE sy-index.
        WHEN 1. DATA(lv_banco_receptor) = i_banco_receptor. DATA(lv_clave_control) = i_clave_control.
        WHEN 2.      lv_banco_receptor  = i_banco_receptor.      lv_clave_control  = ''.
        WHEN 3.      lv_banco_receptor  = ''              .      lv_clave_control  = i_clave_control.
        WHEN 4.      lv_banco_receptor  = ''              .      lv_clave_control  = ''.
        WHEN OTHERS.
          EXIT.
      ENDCASE.

      LOOP AT gt_tipo_abono ASSIGNING FIELD-SYMBOL(<lfs_gt_tipo_abono>)
      WHERE banco_propio    EQ i_banco_propio
        AND banco_pagador   EQ i_banco_pagador
        AND banco_receptor  EQ lv_banco_receptor
        AND moneda_pago     EQ i_moneda_pago
        AND moneda_receptor EQ i_moneda_receptor
        AND clave_control   EQ lv_clave_control.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.

        DATA(lv_tipo_abono) = <lfs_gt_tipo_abono>-tipo_abono.

        CASE lv_tipo_abono.
          WHEN 'P'.
            IF i_banco_receptor EQ '11'
            OR i_banco_receptor EQ '011'.
              lv_cuenta_abono = '0011' && i_cta_banco_propio.
            ELSE.
              lv_cuenta_abono = i_cta_banco_propio.
            ENDIF.
            o_tipo_cta = c_tipo_cta_bco_propio.
            o_found    = abap_true.
          WHEN 'I'.
            lv_cuenta_abono = i_cta_banco_cci.
            o_tipo_cta      = c_tipo_cta_bco_cci.
            o_found         = abap_true.
          WHEN 'A'
            OR 'C'
            OR 'M'
            .
            lv_cuenta_abono = i_cta_banco_propio.
            o_tipo_cta      = c_tipo_cta_bco_propio.
            o_found         = abap_true.
          WHEN 'B'.
            lv_cuenta_abono = i_cta_banco_cci.
            o_tipo_cta      = c_tipo_cta_bco_cci.
            o_found         = abap_true.
          WHEN '1'
            OR '2'
            OR '3'
            .
            lv_cuenta_abono = i_cta_banco_propio.
            o_tipo_cta      = c_tipo_cta_bco_propio.
            o_found         = abap_true.
            o_st_res-cod_banco        = <lfs_gt_tipo_abono>-banco_receptor .
            o_st_res-moneda_de_cuenta = COND #( WHEN <lfs_gt_tipo_abono>-moneda_receptor EQ 'PEN' THEN 'SOL' ELSE <lfs_gt_tipo_abono>-moneda_receptor ).

          WHEN OTHERS.

            IF  <lfs_gt_tipo_abono>-banco_propio EQ 'IBK'.

              IF lv_tipo_abono EQ '09'.
                lv_cuenta_abono = i_cta_banco_propio.
              ELSE.
                lv_cuenta_abono = i_cta_banco_cci.
              ENDIF.

              IF <lfs_gt_tipo_abono>-clave_control EQ 'CC'
              OR <lfs_gt_tipo_abono>-clave_control EQ 'CM'.
                o_tipo_cta = '001'.
              ELSE.
                o_tipo_cta = '002'.
              ENDIF.

            ELSE.

              lv_cuenta_abono = i_cta_banco_cci.
              o_tipo_cta      = c_tipo_cta_bco_cci.

            ENDIF.

            o_found = abap_true.

        ENDCASE.

*       Si se halló registro, hacer asignaciones y salir
        IF o_found EQ abap_true.
          c_cuenta_abono = lv_cuenta_abono.
          c_tipo_abono   = <lfs_gt_tipo_abono>-tipo_abono.
          EXIT.
        ENDIF.

      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD tipo_abono_set.

    IF gt_tipo_abono IS INITIAL.

*     Ahora - 05/09/2024 - GJMP
      gt_tipo_abono = VALUE #(
*===    BBV = BBVA
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = '011'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'P' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = '011'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = '011'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'P' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = '011'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )

        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = '11'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'P' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = '11'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = '11'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'P' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = '11'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )

        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '011'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )

        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = 'I' )
        ( banco_propio = 'BBV'  banco_pagador = '11'  banco_receptor  = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = 'I' )

*===    BCP
"+vchero 09.06.2026 se reemplazó CA por 02 y CC por 01
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'M' )
"-vchero 17.04.2026{
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )
"-vchero 17.04.2026}
"+vchero 17.04.2026{
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'M' )
"+vchero 17.04.2026}
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'M' )
"-vchero 17.04.2026{
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'B' )
"-vchero 17.04.2026}
"+vchero 17.04.2026{
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = '002'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'M' )
"+vchero 17.04.2026}
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '002'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'M' )
"-vchero 17.04.2026{
*        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = 'B' )
*        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )
"-vchero 17.04.2026}
"-vchero 17.04.2026{
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'M' )
"-vchero 17.04.2026}
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'M' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'A' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'C' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = '02'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'M' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = 'B' )

        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '02'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = '01'  tipo_abono = 'B' )
        ( banco_propio = 'BCP'  banco_pagador = '02'  banco_receptor = ''  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = 'B' )

*===    SCO = Scotiabank
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '3' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '3' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = '009'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '009'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '3' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '3' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = '09'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'SCO'  banco_pagador = '09'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )

*===    BIF = BanBIF
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = '038'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '038'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '2' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = '38'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '4' )
        ( banco_propio = 'BIF'  banco_pagador = '38'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '' )

*===    IBK = Interbank
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '09' )
"-vchero 19.10.2025{
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
"-vchero 19.10.2025}
"+vchero 19.10.2025{
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '09' )
"+vchero 19.10.2025}
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = '003'  moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '003'  banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '09' )
"-vchero 19.10.2025{
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
*        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
"-vchero 19.10.2025}
"+vchero 19.10.2025{
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '09' )
"+vchero 19.10.2025}
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = '03'   moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '09' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = 'CM'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CA'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CC'  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'USD'  clave_control = 'CM'  tipo_abono = '99' )
"+vchero 19.10.2025{
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'PEN'  moneda_receptor = 'USD'  clave_control = ''  tipo_abono = '99' )
        ( banco_propio = 'IBK'  banco_pagador = '03'   banco_receptor = ''     moneda_pago = 'USD'  moneda_receptor = 'PEN'  clave_control = ''  tipo_abono = '99' )
"+vchero 19.10.2025}
      ).

    ENDIF.

  ENDMETHOD.


  METHOD tipo_doc_pago_get.

    CLEAR op_tipo_doc_pago.

    SELECT SINGLE
        documentreferenceid
      FROM zdppp_cds_r
     WHERE paymentrundate       EQ @i_fecha_de_la_propuesta
       AND paymentrunid         EQ @i_id_de_la_propuesta
       AND paymentrunisproposal EQ @space
       AND payingcompanycode    EQ 'CE10'
       AND supplier             EQ @i_supplier     " Proveedor
*        AND Customer             EQ @              " Cliente
*        AND PaymentRecipient     EQ @              " Receptor de pago
*        AND PaymentDocument      EQ @              " Documento de pago
       AND documentreferenceid  EQ @i_doc_ref_id
      INTO @DATA(lv_documentreferenceid)
     .
    IF sy-subrc EQ 0.

      DATA(lv_val) =  lv_documentreferenceid+1(1).
      CASE lv_val.
        WHEN '1'. op_tipo_doc_pago = lv_val.
        WHEN '2'. op_tipo_doc_pago = '3'.
        WHEN '3'. op_tipo_doc_pago = '1'.
        WHEN '7'. op_tipo_doc_pago = '2'.
        WHEN '8'. op_tipo_doc_pago = '5 '.
      ENDCASE.

    ELSE.

**     No existe Neto de retenciones para Proveedor &1 y Doc.Ref. &2
*      MESSAGE e007(zdmee) WITH i_supplier i_doc_ref_id INTO DATA(lv_msg).
*      APPEND CORRESPONDING #( sy ) TO c_log.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
