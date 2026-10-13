CLASS lhc_zr_tbl_asing_mrko DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrTblAsingMrko
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrTblAsingMrko~validateMandatoryFields,
      DeriveClaseDocumento FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ZrTblAsingMrko~DeriveClaseDocumento.

    METHODS DeriveCondicionesPago FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrTblAsingMrko~DeriveCondicionesPago.
ENDCLASS.

CLASS lhc_zr_tbl_asing_mrko IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD validateMandatoryFields.
    READ ENTITIES OF zr_tbl_asing_mrko IN LOCAL MODE
    ENTITY ZrTblAsingMrko
    FIELDS ( Companycode Supplier plant FechaContabilizacion FolioFactura FechaEmision ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_records).

    LOOP AT lt_records INTO DATA(ls_record).
      IF ls_record-Companycode IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Sociedad es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.

      ENDIF.

      IF ls_record-Supplier IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Proveedor es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.

      ENDIF.
      IF ls_record-Plant IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Planta es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.
      ENDIF.
      IF ls_record-FechaContabilizacion IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Fecha Contabilización es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.
      ENDIF.
      IF ls_record-FechaEmision IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Fecha Emisión es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.
      ENDIF.
      IF ls_record-FolioFactura IS INITIAL.
        APPEND VALUE #( %tky = ls_record-%tky ) TO failed-zrtblasingmrko.

        APPEND VALUE #( %tky = ls_record-%tky
                        %state_area = 'ValidacionInicial'
                        %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = 'El campo Folio de Factura es obligatorio'
                         )
                             ) TO reported-zrtblasingmrko.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD DeriveClaseDocumento.
    READ ENTITIES OF zr_tbl_asing_mrko IN LOCAL MODE
    ENTITY ZrTblAsingMrko
    FIELDS ( ClaseDocumento )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_map).


    LOOP AT lt_map ASSIGNING FIELD-SYMBOL(<ls_map>).

      SELECT SINGLE FROM I_AccountingDocumentTypeText
      FIELDS AccountingDocumentTypeName
      WHERE AccountingDocumentType = @<ls_map>-ClaseDocumento
      AND Language = 'S'
      INTO @DATA(ls_clasedocumento).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_tbl_asing_mrko IN LOCAL MODE
      ENTITY ZrTblAsingMrko
      UPDATE FIELDS ( ClaseDocumentoTexto )
      WITH VALUE #( ( %tky = <ls_map>-%tky
        ClaseDocumentoTexto = ls_clasedocumento
      ) ).


    ENDLOOP.


  ENDMETHOD.

  METHOD DeriveCondicionesPago.

    READ ENTITIES OF zr_tbl_asing_mrko IN LOCAL MODE
        ENTITY ZrTblAsingMrko
        FIELDS ( ClaseDocumento )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_map).


    LOOP AT lt_map ASSIGNING FIELD-SYMBOL(<ls_map>).

      SELECT SINGLE FROM I_PaymentTermsText
      FIELDS PaymentTermsName
      WHERE PaymentTerms = @<ls_map>-CondicionesPago
      AND Language = 'S'
      INTO @DATA(ls_condicionespago).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zr_tbl_asing_mrko IN LOCAL MODE
      ENTITY ZrTblAsingMrko
      UPDATE FIELDS ( CondicionesPagoTexto )
      WITH VALUE #( ( %tky = <ls_map>-%tky
        CondicionesPagoTexto = ls_condicionespago
      ) ).


    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
