CLASS zcl_dmee_banco_bcp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  .

  PUBLIC SECTION.

    METHODS main
      IMPORTING ip_output_mode       TYPE dmee_end_output_mode
      CHANGING  cp_output_file_lines TYPE dmee_output_file_lines OPTIONAL
                cp_string            TYPE string OPTIONAL
                cp_xml_document      TYPE REF TO if_ixml_document OPTIONAL
                cp_log               TYPE cl_dmee_postprocessing=>tt_dmee_log OPTIONAL
                cp_procesado         TYPE string
                cp_banco             TYPE string
      .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS c_banco TYPE string VALUE 'BCP'.

    TYPES ty_pos_reg TYPE n LENGTH 04.

*   Registro temporal
    TYPES:
      BEGIN OF ty_st_reg_tmp,
        tipo_registro             TYPE c LENGTH  1,
        banco                     TYPE c LENGTH  3,
        fecha_de_la_propuesta     TYPE c LENGTH  8,
        id_de_la_propuesta        TYPE c LENGTH  6,
        ejecucion_de_propuesta    TYPE c LENGTH  1,
        documento_de_pago         TYPE c LENGTH 10,
        bp                        TYPE c LENGTH 10,
        banco_propio              TYPE c LENGTH 05,
        id_cuenta_de_banco_propio TYPE c LENGTH 04,
        id_banco_del_pagador      TYPE c LENGTH 03,
        moneda_de_pago            TYPE c LENGTH 03,
        referencia_de_factura     TYPE c LENGTH 16,
        pos_reg                   TYPE ty_pos_reg , "Es el número del registro no temporal
      END OF ty_st_reg_tmp.

    TYPES ty_tt_reg_tmp TYPE HASHED TABLE OF ty_st_reg_tmp WITH UNIQUE KEY pos_reg.

    TYPES ty_char4 TYPE c LENGTH 4.

    CONSTANTS c_procesado_no TYPE string VALUE '0'.
    CONSTANTS c_procesado_si TYPE string VALUE '1'.

    DATA gs_reg_tmp TYPE ty_st_reg_tmp.
    DATA gh_reg_tmp TYPE ty_tt_reg_tmp.

    METHODS banco_determinar
      EXPORTING
        ep_banco             TYPE string
      CHANGING
        cp_output_file_lines TYPE dmee_output_file_lines
        cp_log               TYPE cl_dmee_postprocessing=>tt_dmee_log
      .

    METHODS banco_tratar
      IMPORTING ip_banco             TYPE string
      CHANGING  cp_output_file_lines TYPE dmee_output_file_lines OPTIONAL
                cp_log               TYPE cl_dmee_postprocessing=>tt_dmee_log OPTIONAL
                cp_procesado         TYPE string
      .

    METHODS moneda_set
      CHANGING
        cp_moneda TYPE ty_char4.

ENDCLASS.



CLASS ZCL_DMEE_BANCO_BCP IMPLEMENTATION.


  METHOD banco_determinar.

    CONSTANTS c_del TYPE string VALUE 'DEL()'.

    DATA lv_pos_reg TYPE ty_st_reg_tmp-pos_reg.

    FIELD-SYMBOLS <lfs_reg_tmp> TYPE any.
    FIELD-SYMBOLS <lfs_line>    TYPE any.

    DATA lv_banco TYPE string.

    CLEAR ep_banco.
    CLEAR gs_reg_tmp.

*   Obtener y limpiar datos temporales del Tipo de registro 3
    CLEAR lv_pos_reg.

    LOOP AT cp_output_file_lines ASSIGNING FIELD-SYMBOL(<output_file_lines>)
    WHERE line+0(1) = '9'.

      ASSIGN gs_reg_tmp               TO <lfs_reg_tmp>.
      ASSIGN <output_file_lines>-line TO <lfs_line>   .
      <lfs_reg_tmp>      = <lfs_line>.

      lv_pos_reg         = lv_pos_reg + 1.
      gs_reg_tmp-pos_reg = lv_pos_reg.

      IF gs_reg_tmp-banco IS NOT INITIAL.
        IF ep_banco IS INITIAL.
          ep_banco = gs_reg_tmp-banco.
        ENDIF.
      ENDIF.

      IF  ep_banco IS NOT INITIAL
      AND ep_banco NE c_banco.
        RETURN.
      ENDIF.

      INSERT gs_reg_tmp INTO TABLE gh_reg_tmp.
      CLEAR gs_reg_tmp.

      <output_file_lines>-line = c_del.

    ENDLOOP.

*   Eliminar registros temporales
    DELETE cp_output_file_lines WHERE line = c_del.

  ENDMETHOD.


  METHOD banco_tratar.

    TYPES ty_checksum          TYPE n LENGTH 15.

    DATA lv_moneda             TYPE c LENGTH 4 .
    DATA lv_nro_doc_proveedor  TYPE string.
    DATA lv_nro_doc_a_pagar    TYPE n LENGTH 15.
    DATA lv_checksum_tmp       TYPE string.
    DATA lv_checksum_ret       TYPE string.
    DATA lv_checksum_act       TYPE ty_checksum.
    DATA lv_checksum_tot       TYPE ty_checksum.
    DATA lv_pos_reg            TYPE ty_st_reg_tmp-pos_reg.
    DATA lv_tipo_abono         TYPE zcl_dmee_tool=>ty_tipo_abono.

    DATA lv_monto_total_planilla TYPE zdppp_cds_r-netamountintransaccurrency.

    FIELD-SYMBOLS <output_file_lines_cab> TYPE any.

    cp_procesado = c_procesado_no.

    IF ip_banco NE c_banco.
      RETURN.
    ENDIF.

    CLEAR lv_nro_doc_a_pagar   .
    CLEAR gs_reg_tmp           .

    CLEAR lv_monto_total_planilla.

    lv_pos_reg = 0.

*   Revisar Tipo de registro 2
    LOOP AT cp_output_file_lines ASSIGNING FIELD-SYMBOL(<output_file_lines>).

*     Determinar tipo de registro
      CASE <output_file_lines>-line+0(1).

*       Tipo de registro Cabecera
        WHEN '1'.

          lv_checksum_tmp = <output_file_lines>-line+20(20).
          DATA(lv_max) = 10.
          zcl_dmee_tool=>extraer_derecha_a_izquierda(
            EXPORTING
              i_cadena    = lv_checksum_tmp
              i_max       = lv_max
            IMPORTING
              e_subcadena = lv_checksum_ret
          ).
*         Obtener valor para sumar
          lv_checksum_tot = lv_checksum_ret.

*         Guardar apuntador a registros de cabecera
          ASSIGN <output_file_lines>-line TO <output_file_lines_cab>.

*         Obtener valor en campo "Moneda de la cuenta de cargo"
          moneda_set( CHANGING cp_moneda = <output_file_lines>-line+16(4) ).

*       Tipo de registro Detalle 1
        WHEN '2'.

*         Generar clave consecutiva
          lv_pos_reg = lv_pos_reg + 1.
          ASSIGN gh_reg_tmp[ pos_reg = lv_pos_reg ] TO FIELD-SYMBOL(<lfs_gh_reg_tmp>).
          gs_reg_tmp = <lfs_gh_reg_tmp>.

*         Para poder acceder a la información de CDS I_SUPPLIER se creó el CDS ZV_CDS_I_SUPPLIER y se pudo consultar
*           en ejecución en línea y en fondo
          SELECT SINGLE taxnumbertype
            FROM zv_cds_i_supplier
           WHERE supplier EQ @gs_reg_tmp-bp
            INTO @DATA(lv_taxnumbertype).
          IF sy-subrc NE 0.
            MESSAGE s000(zdmee) WITH 'Faltan datos del NIF para el BP' gs_reg_tmp-bp space  space
              INTO DATA(lv_msg).
            APPEND CORRESPONDING #( sy ) TO cp_log.
            CONTINUE.
          ENDIF.

*         Revisar si hay valor en campo "Número de documento del proveedor"
          lv_nro_doc_proveedor = <output_file_lines>-line+24(12).
          CONDENSE lv_nro_doc_proveedor.
          IF lv_nro_doc_proveedor IS NOT INITIAL.
*           Contar cantidad de "Número de documento del proveedor"
            lv_nro_doc_a_pagar = lv_nro_doc_a_pagar + 1.
          ENDIF.

*         Obtener valor en campo "Moneda de la cuenta de cargo"
          moneda_set( CHANGING cp_moneda = <output_file_lines>-line+174(4) ).

*         Actualizar campo "Tipo de documento del proveedor" (I_SUPPLIER-TAXNUMBERTYPE = LFA1-STCDT)
          <output_file_lines>-line+23(1) = lv_taxnumbertype.

*         2.12 - Importe a abonar
*         Sumar campo "Importe a abonar"
          lv_monto_total_planilla = lv_monto_total_planilla + <output_file_lines>-line+178(17).

*         Obtener BP
          DATA(lv_bp_receptor)    = gs_reg_tmp-bp.
*         Banco Pagador
          DATA(lv_banco_pagador)  = CONV zv_cds_i_businesspartnerbank-banknumber( gs_reg_tmp-banco_propio ).
*         Moneda_de_Pago
          DATA(lv_moneda_de_pago) = gs_reg_tmp-moneda_de_pago.
*         Referencia
          DATA(lv_referencia)     = gs_reg_tmp-referencia_de_factura.

*         Obtener datos de Recpetor
          CLEAR lv_tipo_abono.
          zcl_dmee_tool=>receptor_banco_get(
            EXPORTING
              i_banco_propio   = CONV #( gs_reg_tmp-banco )
              i_bp_receptor    = lv_bp_receptor
              i_moneda_de_pago = lv_moneda_de_pago
              i_banco_pagador  = CONV #( lv_banco_pagador )
              i_referencia     = CONV #( lv_referencia )
              i_banco          = c_banco
            IMPORTING
              o_found          = DATA(lv_found)
            CHANGING
              c_tipo_abono     = lv_tipo_abono
              c_cuenta_abano   = <output_file_lines>-line+02(20)
          ).

          IF lv_found EQ abap_false.
            DATA(lv_cancelar) = abap_true.
            EXIT.
          ENDIF.

          <output_file_lines>-line+01(01) = lv_tipo_abono.

*         Determinar longitud para calculo de CheckSum
          CASE <output_file_lines>-line+01(01).
            WHEN 'A'.    lv_max = 11.
            WHEN 'B'
              OR 'C'.    lv_max = 10.
            WHEN OTHERS. lv_max = 0.
          ENDCASE.

          lv_cancelar = abap_false.

          IF lv_max EQ 0.

            lv_cancelar = abap_true.

          ELSE.

*           Obtener subcadena de la cuenta
            lv_checksum_tmp = <output_file_lines>-line+02(20).
            zcl_dmee_tool=>extraer_derecha_a_izquierda(
              EXPORTING
                i_cadena    = lv_checksum_tmp
                i_max       = lv_max
              IMPORTING
                 e_subcadena = lv_checksum_ret
             ).
*           Obtener valor para sumar
            TRY.
                lv_checksum_act = lv_checksum_ret.
                lv_checksum_tot = lv_checksum_tot + lv_checksum_act.
              CATCH cx_root INTO DATA(lv_cx_root).
                lv_cancelar = abap_true.
            ENDTRY.

          ENDIF.

*         Si hubo error. mencionarlo y salir
          IF lv_cancelar EQ abap_true.
*           Para la Ref. &1 no se pudo calcular CheckSum
            MESSAGE e004(zdmee) WITH lv_referencia INTO lv_msg.
            APPEND CORRESPONDING #( sy ) TO cp_log.
            EXIT.
          ENDIF.
       "+@vchero 02.07.2026{
        whEN '3'.
           "Referencia Pago
           <output_file_lines>-line+02(15) = |0{ <output_file_lines>-line+02(1) }{ <output_file_lines>-line+04(13) }|.
       "+@vchero 02.07.2026}
      ENDCASE.
    ENDLOOP.

    IF lv_cancelar EQ abap_false.
      IF <output_file_lines_cab> IS ASSIGNED.
        TRY.
*           Actualizar CheckSum en registro de cabecera
            <output_file_lines_cab>+98(15) = lv_checksum_tot.
*           1.07 - Monto total de la planilla
*             Rellenar con ceos delante del valor
            zcl_dmee_tool=>numero_generar(
              EXPORTING
                iv_numero = lv_monto_total_planilla
              IMPORTING
                ev_numero = <output_file_lines_cab>+40(17)
            ).
          CATCH cx_root INTO lv_cx_root.
            lv_cancelar = abap_true.
        ENDTRY.
      ENDIF.
    ENDIF.


    IF lv_cancelar EQ abap_true.
      cp_procesado = c_procesado_si.
      RETURN.
    ENDIF.

"-@vchero 03.03.2026{
**   Revisar Tipo de registro 1
*    LOOP AT cp_output_file_lines ASSIGNING <output_file_lines>
*    WHERE line+0(1) = '1'.
**     Obtener valor en campo "Moneda de la cuenta de cargo"
*      moneda_set( CHANGING cp_moneda = <output_file_lines>-line+16(4) ).
*      EXIT.
*    ENDLOOP.
"-@vchero 03.03.2026}
"-@vchero 03.07.2026{"Cliente solicitó enviar en este campo la referencia y no el nro de documento a pagar
**   Revisar Tipo de registro 3
*    LOOP AT cp_output_file_lines ASSIGNING <output_file_lines>
*    WHERE line+0(1) = '3'.
**     Establecer valor a campo "Número de documento a pagar"
*      <output_file_lines>-line+02(15) = lv_nro_doc_a_pagar.
*    ENDLOOP.
"-@vchero 03.07.2026}
*   Indicar que el archivo de banco fue procesado
    cp_procesado = c_procesado_si.

  ENDMETHOD.


  METHOD main.

    IF cp_procesado EQ c_procesado_si.
      RETURN.
    ENDIF.

    IF zcl_dmee_tool=>hubo_error( cp_log ) EQ abap_true.
      RETURN.
    ENDIF.

*   Determinar Banco
    banco_determinar(
      IMPORTING
        ep_banco             = DATA(lv_banco)
      CHANGING
        cp_output_file_lines = cp_output_file_lines
        cp_log               = cp_log
    ).
*   Salir, si no se pudo determinar el Banco
    IF zcl_dmee_tool=>hubo_error( cp_log ) EQ abap_true.
      RETURN.
    ENDIF.

    cp_banco = lv_banco.

    IF cp_banco IS INITIAL.
      RETURN.
    ENDIF.

*   Tratar Banco BCP
    banco_tratar(
      EXPORTING ip_banco             = lv_banco
      CHANGING  cp_output_file_lines = cp_output_file_lines
                cp_log               = cp_log
                cp_procesado         = cp_procesado
    ).

  ENDMETHOD.


  METHOD moneda_set.
    CONDENSE cp_moneda NO-GAPS.

    cp_moneda = COND #(
      WHEN cp_moneda EQ 'PEN' THEN '0001'
      WHEN cp_moneda EQ 'USD' THEN '1001'
      ELSE cp_moneda
    ).
  ENDMETHOD.
ENDCLASS.
