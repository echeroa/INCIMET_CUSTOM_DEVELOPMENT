CLASS zcl_edoc_modifier_pe DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_edoc_adaptor_cloud .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_EDOC_MODIFIER_PE IMPLEMENTATION.


  METHOD if_edoc_adaptor_cloud~change_edocument_type.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~change_form.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~get_variable_key.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~is_relevant.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~restrict_cancel.
  ENDMETHOD.


  METHOD if_edoc_adaptor_cloud~set_output_data.

    FIELD-SYMBOLS <t_billing_reference> TYPE ANY TABLE.

    IF is_source_data-billing_header-yy1_referenciafacturae_bdh IS INITIAL.
      RETURN.

    ENDIF.

    ASSIGN COMPONENT 'BILLING_REFERENCE' OF STRUCTURE cs_output_data
      TO <t_billing_reference>.

    IF sy-subrc EQ 0.
      IF <t_billing_reference> IS INITIAL.
        INSERT INITIAL LINE INTO TABLE <t_billing_reference>
          ASSIGNING FIELD-SYMBOL(<billing_reference>).

      ELSE.
        LOOP AT <t_billing_reference>
            ASSIGNING <billing_reference>.
          EXIT.

        ENDLOOP.

      ENDIF.

      IF <billing_reference> IS ASSIGNED.
        ASSIGN ('<BILLING_REFERENCE>-INVOICE_DOCUMENT_REFERENCE-ID-BASE-BASE-CONTENT') TO FIELD-SYMBOL(<reference>).

        IF sy-subrc EQ 0.
          ASSIGN ('<BILLING_REFERENCE>-INVOICE_DOCUMENT_REFERENCE-DOCUMENT_TYPE_CODE-BASE-BASE-CONTENT') TO FIELD-SYMBOL(<document_type_code>).

          IF sy-subrc EQ 0.
            ASSIGN ('<BILLING_REFERENCE>-INVOICE_DOCUMENT_REFERENCE-DOCUMENT_TYPE_CODE-BASE-BASE-LIST_AGENCY_NAME') TO FIELD-SYMBOL(<document_type_code_agency>).

            IF sy-subrc EQ 0.
              ASSIGN ('<BILLING_REFERENCE>-INVOICE_DOCUMENT_REFERENCE-DOCUMENT_TYPE_CODE-BASE-BASE-LIST_NAME') TO FIELD-SYMBOL(<document_type_code_list>).

              IF sy-subrc EQ 0.
                ASSIGN ('<BILLING_REFERENCE>-INVOICE_DOCUMENT_REFERENCE-DOCUMENT_TYPE_CODE-BASE-BASE-LIST_URI') TO FIELD-SYMBOL(<document_type_code_uri>).

                IF sy-subrc EQ 0.
                  <reference>                 = is_source_data-billing_header-yy1_referenciafacturae_bdh+3.
                  <document_type_code>        = COND string( WHEN <reference> CP 'B*' THEN `03` ELSE `01` ).
                  <document_type_code_agency> = 'PE:SUNAT'.
                  <document_type_code_list>   = 'Tipo de Documento'.
                  <document_type_code_uri>    = 'urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo01'.

                ENDIF.

              ENDIF.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.


  ENDMETHOD.
ENDCLASS.
