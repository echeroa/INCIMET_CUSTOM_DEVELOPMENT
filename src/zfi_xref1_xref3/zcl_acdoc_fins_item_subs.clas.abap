CLASS zcl_acdoc_fins_item_subs DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_instance) TYPE REF TO zcl_acdoc_fins_item_subs.

    METHODS set_bp
      IMPORTING
        iv_bp TYPE string.

    METHODS get_bp
      RETURNING VALUE(rv_bp) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA mo_instance TYPE REF TO zcl_acdoc_fins_item_subs.
    DATA mv_bp TYPE string.

ENDCLASS.



CLASS ZCL_ACDOC_FINS_ITEM_SUBS IMPLEMENTATION.


  METHOD get_bp.
    rv_bp = mv_bp.
  ENDMETHOD.


  METHOD get_instance.
    IF mo_instance IS NOT BOUND.
      mo_instance = NEW zcl_acdoc_fins_item_subs( ).
    ENDIF.

    ro_instance = mo_instance.
  ENDMETHOD.


  METHOD set_bp.
    mv_bp = iv_bp.
  ENDMETHOD.
ENDCLASS.
