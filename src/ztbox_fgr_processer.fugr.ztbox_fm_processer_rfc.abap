FUNCTION ZTBOX_FM_PROCESSER_RFC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(RUNNABLE) TYPE  ZTBOX_PROCESSER_XML_CS_DE
*"  EXPORTING
*"     VALUE(EV_RESULT) TYPE  STRING
*"----------------------------------------------------------------------

  ev_result = ztbox_cl_processer=>execute( runnable ).

ENDFUNCTION.
