CLASS zcl_dmee_output_postprocessing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_badi_interface .
    INTERFACES if_dmee_output_postprocessing .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DMEE_OUTPUT_POSTPROCESSING IMPLEMENTATION.


  METHOD if_dmee_output_postprocessing~modify_output.

    DATA lo_tool TYPE REF TO zcl_dmee_tool.

    lo_tool = NEW zcl_dmee_tool(  ).

    lo_tool->main(
      EXPORTING
        ip_output_mode       = output_mode
      CHANGING
        cp_output_file_lines = output_file_lines
        cp_string            = string
        cp_xml_document      = xml_document
        cp_log               = log
    ).


  ENDMETHOD.
ENDCLASS.
