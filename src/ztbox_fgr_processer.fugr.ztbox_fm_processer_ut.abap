FUNCTION ztbox_fm_processer_ut.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(RUNNABLE) TYPE  ZTBOX_PROCESSER_XML_CS_DE
*"----------------------------------------------------------------------

  ztbox_cl_processer=>execute( runnable ).

ENDFUNCTION.
